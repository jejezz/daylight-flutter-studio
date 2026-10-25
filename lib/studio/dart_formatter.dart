import 'dart:io';

import '../core/command_runner.dart';

/// `dart format` 결과: 정렬된 글자, 또는 실패 이유.
class FormatResult {
  const FormatResult.ok(String this.text) : error = null;
  const FormatResult.failed(String this.error) : text = null;

  final String? text;
  final String? error;

  bool get ok => text != null;
}

/// 편집기에 열린 Dart 글(저장하지 않은 수정 포함)을 `dart format`으로 정렬한다.
///
/// 글을 파일 옆의 임시 파일에 쓰고 정렬한 뒤 읽어 온다. 원본 파일은 건드리지 않고,
/// 같은 폴더라서 `analysis_options.yaml`의 줄 길이와 패키지의 언어 버전도 그대로 따른다.
class DartFormatter {
  DartFormatter(this.runner);

  final CommandRunner runner;

  Future<FormatResult> format(String path, String text) async {
    final file = File(path);
    final tmp = File('${file.parent.path}${Platform.pathSeparator}.studio_format_${DateTime.now().microsecondsSinceEpoch}.dart');
    try {
      await tmp.writeAsString(text);
      final r = await runner.run(['dart', 'format', tmp.path], workingDirectory: file.parent.path, quiet: true);
      if (r.exitCode == 127) {
        return const FormatResult.failed('dart 명령을 찾을 수 없습니다. Flutter SDK의 bin 폴더가 PATH에 있는지 확인하세요.');
      }
      if (!r.ok) return FormatResult.failed(_firstError(r.combined));
      return FormatResult.ok(await tmp.readAsString());
    } on FileSystemException catch (e) {
      return FormatResult.failed('임시 파일을 쓰지 못했습니다: ${e.message}');
    } finally {
      try {
        if (await tmp.exists()) await tmp.delete();
      } on FileSystemException {
        // 임시 파일이 남아도 다음 정리 때 지우면 된다.
      }
    }
  }

  /// 구문 오류 첫 줄만 보여 준다 (임시 파일 이름은 빼고).
  static String _firstError(String output) {
    final line = output.split('\n').map((l) => l.trim()).firstWhere((l) => l.isNotEmpty, orElse: () => '');
    final cleaned = line.replaceAll(RegExp(r'\.studio_format_\d+\.dart'), '(현재 파일)');
    return cleaned.isEmpty ? '정렬하지 못했습니다.' : '정렬하지 못했습니다: $cleaned';
  }
}
