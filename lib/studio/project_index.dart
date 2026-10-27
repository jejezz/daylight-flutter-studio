import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// 목록·검색에서 건너뛰는 폴더. 빌드 산출물과 도구 캐시는 찾을 이유가 없다.
const skippedDirs = {
  '.git', '.dart_tool', '.idea', '.gradle', '.pub-cache', 'build', 'node_modules', 'Pods', 'ephemeral', '.symlinks',
};

const maxIndexedFiles = 20000;
const maxSearchFileBytes = 1024 * 1024;
const maxSearchHits = 500;

/// [root] 아래 모든 파일의 경로(root 기준, `/` 구분). [skippedDirs]와 심볼릭 링크는 따라가지 않는다.
Future<List<String>> listProjectFiles(String root) => Isolate.run(() => _listSync(root));

List<String> _listSync(String root) {
  final out = <String>[];
  void walk(Directory dir, String prefix) {
    List<FileSystemEntity> entries;
    try {
      entries = dir.listSync(followLinks: false);
    } on FileSystemException {
      return;
    }
    entries.sort((a, b) => a.path.compareTo(b.path));
    for (final e in entries) {
      if (out.length >= maxIndexedFiles) return;
      final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (e is Directory) {
        if (!skippedDirs.contains(name)) walk(e, '$prefix$name/');
      } else if (e is File) {
        out.add('$prefix$name');
      }
    }
  }

  walk(Directory(root), '');
  return out;
}

/// 빠른 열기용 점수. [query]의 글자가 [path]에 차례대로 들어 있어야 하고(대소문자 무시),
/// 파일 이름에서 맞을수록·연속으로 맞을수록·앞에서 맞을수록 높다. 맞지 않으면 null.
int? fuzzyScore(String query, String path) {
  if (query.isEmpty) return 0;
  final q = query.toLowerCase();
  final p = path.toLowerCase();
  final nameStart = p.lastIndexOf('/') + 1;
  var score = 0;
  var from = 0;
  var prev = -2;
  for (final ch in q.split('')) {
    final i = p.indexOf(ch, from);
    if (i < 0) return null;
    score += 1;
    if (i == prev + 1) score += 5; // 연속
    if (i >= nameStart) score += 3; // 파일 이름 안
    if (i == 0 || p[i - 1] == '/' || p[i - 1] == '_' || p[i - 1] == '-' || p[i - 1] == '.') score += 4; // 낱말 앞
    prev = i;
    from = i + 1;
  }
  if (p.substring(nameStart).contains(q)) score += 20; // 이름에 그대로 들어 있다
  return score - path.length ~/ 10;
}

/// 점수 순으로 고른 상위 [limit]개.
List<String> rankFiles(String query, List<String> files, {int limit = 50}) {
  final scored = <(int, String)>[];
  for (final f in files) {
    final s = fuzzyScore(query, f);
    if (s != null) scored.add((s, f));
  }
  scored.sort((a, b) => b.$1 != a.$1 ? b.$1.compareTo(a.$1) : a.$2.length.compareTo(b.$2.length));
  return [for (final e in scored.take(limit)) e.$2];
}

/// 검색 결과 한 곳. [line]·[column]은 1부터.
class SearchHit {
  const SearchHit(this.path, this.line, this.column, this.text);

  final String path;
  final int line;
  final int column;

  /// 그 줄의 글(앞뒤 공백 제거, 너무 길면 자름).
  final String text;
}

class SearchResult {
  const SearchResult(this.hits, {this.truncated = false, this.invalidPattern = false});

  final List<SearchHit> hits;

  /// [maxSearchHits]에서 멈췄다.
  final bool truncated;

  /// 정규식이 올바르지 않다.
  final bool invalidPattern;
}

/// [files]를 [root] 기준 상대 경로로 받아 각 파일에서 [query]를 찾는다. 글자 파일(UTF-8)이 아니거나 1MB를 넘는 파일은 건너뛴다.
Future<SearchResult> searchProject(
  String root,
  List<String> files,
  String query, {
  bool caseSensitive = false,
  bool regex = false,
}) {
  return Isolate.run(() => searchProjectSync(root, files, query, caseSensitive: caseSensitive, regex: regex));
}

/// 검색·바꾸기가 함께 쓰는 패턴. 비었거나 정규식이 올바르지 않으면 null.
RegExp? buildSearchPattern(String query, {bool caseSensitive = false, bool regex = false}) {
  if (query.isEmpty) return null;
  try {
    return RegExp(regex ? query : RegExp.escape(query), caseSensitive: caseSensitive);
  } on FormatException {
    return null;
  }
}

SearchResult searchProjectSync(String root, List<String> files, String query, {bool caseSensitive = false, bool regex = false}) {
  if (query.isEmpty) return const SearchResult([]);
  final re = buildSearchPattern(query, caseSensitive: caseSensitive, regex: regex);
  if (re == null) return const SearchResult([], invalidPattern: true);
  final sep = Platform.pathSeparator;
  final hits = <SearchHit>[];
  for (final rel in files) {
    final path = '$root$sep${rel.replaceAll('/', sep)}';
    String text;
    try {
      final file = File(path);
      if (file.lengthSync() > maxSearchFileBytes) continue;
      text = utf8.decode(file.readAsBytesSync());
    } on FormatException {
      continue;
    } on FileSystemException {
      continue;
    }
    final lines = const LineSplitter().convert(text);
    for (var i = 0; i < lines.length; i++) {
      final m = re.firstMatch(lines[i]);
      if (m == null || m.end == m.start) continue;
      var shown = lines[i].trim();
      if (shown.length > 200) shown = '${shown.substring(0, 200)}…';
      hits.add(SearchHit(path, i + 1, m.start + 1, shown));
      if (hits.length >= maxSearchHits) return SearchResult(hits, truncated: true);
    }
  }
  return SearchResult(hits);
}
