/// Dart 선언(클래스·함수·메서드 …)을 정규식으로 뽑는 가벼운 심볼 색인 (ctags 수준).
///
/// 분석 서버(LSP)가 아니라 줄 단위로 훑는다: 정확한 정의 해석은 못 하고 이름이 같은 선언을 모두 돌려준다.
/// 줄 맨 앞(깊이 0)과 두 칸 들여쓴 줄(깊이 1, 클래스 멤버)만 본다 — 함수 본문 안의 호출을 선언으로 착각하지 않기 위해서다.
library;

import 'dart:io';
import 'dart:isolate';

import 'project_index.dart';

enum SymbolKind { classType, mixin, enumType, extension, typedef, function, method, getter, setter }

class DartSymbol {
  const DartSymbol(this.name, this.kind, this.path, this.line, this.column, {this.container});

  final String name;
  final SymbolKind kind;

  /// 파일 경로 (색인한 때 받은 그대로).
  final String path;

  /// 이름이 있는 곳. 1부터.
  final int line;
  final int column;

  /// 멤버를 품은 클래스·믹스인 이름. 최상위 선언이면 null.
  final String? container;

  @override
  String toString() => '${container == null ? '' : '$container.'}$name (${kind.name}) $path:$line:$column';
}

final _typeDecl = RegExp(
  r'^(?:@\w+(?:\([^)]*\))?\s+)*(?:(?:abstract|base|sealed|final|interface|mixin)\s+)*(class|mixin|enum|extension\s+type|extension|typedef)\s+([A-Za-z_]\w*)',
);

// [들여쓰기][@주석][static 등]* [반환 형식] [get|set] 이름 [<제네릭>] (
final _funcDecl = RegExp(
  r'^( {0,2})(?:@\w+(?:\([^)]*\))?\s+)*(?:(?:static|external|abstract|override|covariant)\s+)*'
  r'([A-Za-z_][\w.]*(?:<[^()=;{}]*>)?\??)\s+(?:(get|set)\s+)?([A-Za-z_]\w*)\s*(?:<[^()=;{}]*>)?\s*(\(|=>|\{)',
);

// 반환 형식 자리에 올 수 없는 낱말 — 함수 본문의 문장이다.
const _notTypes = {
  'await', 'return', 'throw', 'new', 'else', 'case', 'in', 'yield', 'final', 'var', 'late', 'const', 'if', 'for', 'while', 'switch', 'catch', 'assert',
};

/// [text]에서 선언을 뽑는다. [path]는 결과에 그대로 담긴다.
List<DartSymbol> extractDartSymbols(String path, String text) {
  final out = <DartSymbol>[];
  String? container;
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (line.endsWith('\r')) line = line.substring(0, line.length - 1);
    final trimmed = line.trimLeft();
    if (trimmed.isEmpty || trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) continue;

    final indent = line.length - trimmed.length;
    if (indent == 0) {
      final t = _typeDecl.firstMatch(line);
      if (t != null) {
        final kind = switch (t.group(1)!.replaceAll(RegExp(r'\s+'), ' ')) {
          'class' => SymbolKind.classType,
          'mixin' => SymbolKind.mixin,
          'enum' => SymbolKind.enumType,
          'typedef' => SymbolKind.typedef,
          _ => SymbolKind.extension,
        };
        final name = t.group(2)!;
        out.add(DartSymbol(name, kind, path, i + 1, line.indexOf(name, t.start) + 1));
        container = kind == SymbolKind.typedef ? null : name;
        continue;
      }
    }
    if (indent > 2) continue;

    final f = _funcDecl.firstMatch(line);
    if (f == null) continue;
    final type = f.group(2)!;
    // 반환 형식을 생략한 접근자: `set label(String v)`.
    final bare = (type == 'get' || type == 'set') && f.group(3) == null;
    if (_notTypes.contains(type)) continue;
    final name = f.group(4)!;
    if (_notTypes.contains(name)) continue;
    final member = indent > 0;
    if (member && container == null) continue;
    final accessor = bare ? type : f.group(3);
    final kind = accessor == 'get'
        ? SymbolKind.getter
        : accessor == 'set'
        ? SymbolKind.setter
        : member
        ? SymbolKind.method
        : SymbolKind.function;
    final column = line.indexOf(name, line.indexOf(type) + type.length) + 1;
    out.add(DartSymbol(name, kind, path, i + 1, column, container: member ? container : null));
  }
  return out;
}

const _maxSymbolFileBytes = 512 * 1024;

/// [root] 아래 Dart 파일(`files`는 root 기준 경로)의 선언을 모두 뽑는다. 결과의 `path`는 절대 경로.
Future<List<DartSymbol>> indexProjectSymbols(String root, List<String> files) => Isolate.run(() => indexProjectSymbolsSync(root, files));

List<DartSymbol> indexProjectSymbolsSync(String root, List<String> files) {
  final sep = Platform.pathSeparator;
  final out = <DartSymbol>[];
  for (final rel in files) {
    if (!rel.endsWith('.dart')) continue;
    final path = '$root$sep${rel.replaceAll('/', sep)}';
    try {
      final file = File(path);
      if (file.lengthSync() > _maxSymbolFileBytes) continue;
      out.addAll(extractDartSymbols(path, file.readAsStringSync()));
    } on FileSystemException {
      continue;
    } on FormatException {
      continue; // 글자 파일이 아니다
    }
  }
  return out;
}

/// 이름으로 고른 상위 [limit]개. 이름이 정확히 같으면 맨 앞, 그다음은 [fuzzyScore] 순.
List<DartSymbol> rankSymbols(String query, List<DartSymbol> symbols, {int limit = 60}) {
  final q = query.trim();
  if (q.isEmpty) return symbols.take(limit).toList();
  final scored = <(int, DartSymbol)>[];
  for (final s in symbols) {
    final base = fuzzyScore(q, s.name);
    if (base == null) continue;
    final exact = s.name == q ? 1000 : (s.name.toLowerCase() == q.toLowerCase() ? 500 : 0);
    scored.add((base + exact, s));
  }
  scored.sort((a, b) => b.$1 != a.$1 ? b.$1.compareTo(a.$1) : a.$2.name.length.compareTo(b.$2.name.length));
  return [for (final e in scored.take(limit)) e.$2];
}

/// [name]과 이름이 정확히 같은 선언 (정의로 이동에 쓴다).
List<DartSymbol> definitionsOf(String name, List<DartSymbol> symbols) => [
  for (final s in symbols)
    if (s.name == name) s,
];

/// [line]의 [offset] 자리에 있는(또는 바로 앞에 붙은) 낱말. 없으면 빈 문자열.
String wordAt(String line, int offset) {
  bool isWord(String ch) => RegExp(r'[A-Za-z0-9_$]').hasMatch(ch);
  var start = offset.clamp(0, line.length);
  var end = start;
  while (start > 0 && isWord(line[start - 1])) {
    start--;
  }
  while (end < line.length && isWord(line[end])) {
    end++;
  }
  return line.substring(start, end);
}
