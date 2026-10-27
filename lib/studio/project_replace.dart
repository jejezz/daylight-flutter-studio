/// 프로젝트에서 찾은 곳을 바꾼다. 글만 다루는 순수한 함수와, 파일을 쓰고 되돌리는 함수.
///
/// 바꾸기는 **줄 단위**다: 검색 결과에서 고른 줄마다 그 줄 안의 맞는 곳을 모두 바꾼다. 쓰기 직전에 파일을
/// 다시 읽어 그 줄이 지금도 맞는지 본다 — 검색한 뒤 파일이 바뀌었다면 맞지 않는 줄은 그냥 건너뛴다.
library;

import 'dart:convert';
import 'dart:io';

/// 파일 하나의 바꾸기 결과.
class FileReplace {
  const FileReplace(this.path, this.before, this.after, this.lines);

  final String path;

  /// 바꾸기 전·후의 파일 글 전체. 되돌릴 때 쓴다.
  final String before;
  final String after;

  /// 실제로 바뀐 줄 수.
  final int lines;
}

/// [ReplaceSession.apply]의 결과.
class ReplaceOutcome {
  const ReplaceOutcome({this.changes = const [], this.skippedFiles = 0, this.failedFiles = 0});

  final List<FileReplace> changes;

  /// 수정 중인 탭이라 건너뛴 파일 수.
  final int skippedFiles;

  /// 읽거나 쓰지 못한 파일 수.
  final int failedFiles;

  int get files => changes.length;
  int get lines => changes.fold(0, (sum, c) => sum + c.lines);
}

/// [ReplaceSession.undo]의 결과.
class UndoOutcome {
  const UndoOutcome({this.restored = 0, this.skipped = 0});

  final int restored;

  /// 바꾼 뒤에 또 바뀌어서 덮어쓰지 않고 둔 파일 수.
  final int skipped;
}

/// [replacement]의 `$0`~`$9`를 [m]의 묶음으로, `$$`를 `$`로 바꾼 글. [regex]가 아니면 그대로 쓴다.
String expandReplacement(Match m, String replacement, {required bool regex}) {
  if (!regex) return replacement;
  final out = StringBuffer();
  for (var i = 0; i < replacement.length; i++) {
    final c = replacement[i];
    if (c == r'$' && i + 1 < replacement.length) {
      final next = replacement[i + 1];
      if (next == r'$') {
        out.write(r'$');
        i++;
        continue;
      }
      final group = int.tryParse(next);
      if (group != null && group <= m.groupCount) {
        out.write(m.group(group) ?? '');
        i++;
        continue;
      }
    }
    out.write(c);
  }
  return out.toString();
}

/// 한 줄 안의 맞는 곳을 모두 바꾼다. 빈 글에 맞는 곳(`a*` 같은)은 검색과 같이 건너뛴다.
String replaceInLine(String line, RegExp re, String replacement, {required bool regex}) {
  return line.replaceAllMapped(re, (m) => m.end == m.start ? m.group(0)! : expandReplacement(m, replacement, regex: regex));
}

final _lineBreak = RegExp(r'\r\n|\n|\r');

/// [text]에서 [lineNumbers](1부터)의 줄만 바꾼다. 줄 끝(CRLF·LF)은 그대로 둔다.
/// 돌려주는 것은 (바뀐 글, 실제로 바뀐 줄 수).
(String, int) replaceLines(String text, Set<int> lineNumbers, RegExp re, String replacement, {required bool regex}) {
  final out = StringBuffer();
  var changed = 0;
  var line = 1;
  var start = 0;
  void emit(String content, String terminator) {
    if (lineNumbers.contains(line)) {
      final replaced = replaceInLine(content, re, replacement, regex: regex);
      if (replaced != content) changed++;
      out.write(replaced);
    } else {
      out.write(content);
    }
    out.write(terminator);
  }

  for (final m in _lineBreak.allMatches(text)) {
    emit(text.substring(start, m.start), m.group(0)!);
    start = m.end;
    line++;
  }
  // 마지막 줄(줄 끝 없이 끝나는 줄, 또는 줄 끝 뒤의 빈 글).
  emit(text.substring(start), '');
  return (out.toString(), changed);
}

/// 찾아 바꾸기 한 번의 기록. 바꾼 파일의 이전 글을 들고 있다가 [undo]로 되돌린다.
class ReplaceSession {
  ReplaceSession(this.changes);

  final List<FileReplace> changes;

  /// [selected]: 파일 경로 → 바꿀 줄 번호들(1부터). [isBusy]가 true인 파일(수정 중인 탭 등)은 건너뛴다.
  static Future<ReplaceOutcome> apply(
    Map<String, Set<int>> selected,
    RegExp re,
    String replacement, {
    required bool regex,
    bool Function(String path)? isBusy,
  }) async {
    final changes = <FileReplace>[];
    var skipped = 0;
    var failed = 0;
    for (final entry in selected.entries) {
      final path = entry.key;
      if (isBusy?.call(path) ?? false) {
        skipped++;
        continue;
      }
      try {
        final file = File(path);
        final before = utf8.decode(await file.readAsBytes());
        final (after, lines) = replaceLines(before, entry.value, re, replacement, regex: regex);
        if (lines == 0 || after == before) continue;
        await file.writeAsString(after);
        changes.add(FileReplace(path, before, after, lines));
      } on FormatException {
        failed++;
      } on FileSystemException {
        failed++;
      }
    }
    return ReplaceOutcome(changes: changes, skippedFiles: skipped, failedFiles: failed);
  }

  /// 바꾼 파일을 이전 글로 되돌린다. 바꾼 뒤에 또 바뀐 파일은(그 수정을 덮어쓰지 않으려고) 그대로 둔다.
  Future<UndoOutcome> undo() async {
    var restored = 0;
    var skipped = 0;
    for (final c in changes) {
      try {
        final file = File(c.path);
        final current = utf8.decode(await file.readAsBytes());
        if (current != c.after) {
          skipped++;
          continue;
        }
        await file.writeAsString(c.before);
        restored++;
      } on FormatException {
        skipped++;
      } on FileSystemException {
        skipped++;
      }
    }
    return UndoOutcome(restored: restored, skipped: skipped);
  }
}
