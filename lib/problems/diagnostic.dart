/// `dart analyze --format=json` 결과 모델.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum DiagnosticSeverity {
  error,
  warning,
  info;

  /// 숫자가 클수록 심각하다 (한 줄에 여러 문제가 있을 때 가장 심각한 것을 보여 준다).
  int get rank => switch (this) {
    DiagnosticSeverity.error => 2,
    DiagnosticSeverity.warning => 1,
    DiagnosticSeverity.info => 0,
  };

  static DiagnosticSeverity parse(String? value) => switch (value?.toUpperCase()) {
    'ERROR' => DiagnosticSeverity.error,
    'WARNING' => DiagnosticSeverity.warning,
    _ => DiagnosticSeverity.info,
  };
}

@immutable
class Diagnostic {
  const Diagnostic({
    required this.code,
    required this.severity,
    required this.message,
    required this.file,
    required this.line,
    required this.column,
    this.length = 0,
    this.correction = '',
  });

  final String code;
  final DiagnosticSeverity severity;
  final String message;

  /// 문제가 있는 파일의 절대 경로.
  final String file;

  /// 1부터 시작하는 줄과 열.
  final int line;
  final int column;
  final int length;

  /// 고치는 방법 안내 (없으면 빈 글).
  final String correction;

  @override
  bool operator ==(Object other) =>
      other is Diagnostic &&
      other.code == code &&
      other.severity == severity &&
      other.message == message &&
      other.file == file &&
      other.line == line &&
      other.column == column &&
      other.length == length;

  @override
  int get hashCode => Object.hash(code, severity, message, file, line, column, length);

  @override
  String toString() => '${severity.name} $code $file:$line:$column $message';
}

/// 분석 한 번의 결과: 문제 목록, 또는 분석 자체가 실패한 이유.
class AnalyzeResult {
  const AnalyzeResult.ok(this.diagnostics) : error = null;
  const AnalyzeResult.failed(String this.error) : diagnostics = const [];

  final List<Diagnostic> diagnostics;
  final String? error;

  bool get ok => error == null;
}

/// `dart analyze --format=json`의 출력을 읽는다. 읽을 수 없으면 null.
List<Diagnostic>? parseAnalyzeJson(String output) {
  final start = output.indexOf('{');
  if (start < 0) return null;
  try {
    final root = jsonDecode(output.substring(start));
    if (root is! Map<String, dynamic>) return null;
    final list = root['diagnostics'];
    if (list is! List) return null;
    final out = <Diagnostic>[];
    for (final item in list.whereType<Map<String, dynamic>>()) {
      final location = item['location'];
      if (location is! Map<String, dynamic>) continue;
      final range = location['range'];
      final startPos = range is Map<String, dynamic> ? range['start'] : null;
      final endPos = range is Map<String, dynamic> ? range['end'] : null;
      if (startPos is! Map<String, dynamic>) continue;
      final startOffset = (startPos['offset'] as num?)?.toInt() ?? 0;
      final endOffset = endPos is Map<String, dynamic> ? (endPos['offset'] as num?)?.toInt() ?? startOffset : startOffset;
      out.add(
        Diagnostic(
          code: (item['code'] as String?) ?? '',
          severity: DiagnosticSeverity.parse(item['severity'] as String?),
          message: (item['problemMessage'] as String?) ?? '',
          correction: (item['correctionMessage'] as String?) ?? '',
          file: (location['file'] as String?) ?? '',
          line: (startPos['line'] as num?)?.toInt() ?? 1,
          column: (startPos['column'] as num?)?.toInt() ?? 1,
          length: endOffset - startOffset,
        ),
      );
    }
    return out;
  } on FormatException {
    return null;
  }
}

/// [path]가 속한 패키지의 최상위 폴더(가까운 `pubspec.yaml`이 있는 곳). 없으면 null.
String? findPackageRoot(String path) {
  var dir = FileSystemEntity.isDirectorySync(path) ? Directory(path) : File(path).parent;
  while (true) {
    if (File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}

/// 경로 비교용 키: 구분자를 통일하고, 대소문자를 구분하지 않는 OS(Windows·macOS)에서는 소문자로 바꾼다.
String pathKey(String path) {
  final k = path.replaceAll(r'\', '/');
  return Platform.isWindows || Platform.isMacOS ? k.toLowerCase() : k;
}
