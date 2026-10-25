import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/studio/dart_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late DartFormatter formatter;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('dart_format');
    formatter = DartFormatter(CommandRunner(CommandLog()));
  });

  tearDown(() => dir.delete(recursive: true));

  test('들여쓰기를 정렬하고 원본 파일과 임시 파일을 남기지 않는다', () async {
    final file = File('${dir.path}${Platform.pathSeparator}a.dart')..writeAsStringSync('void main(){print( 1 );}\n');
    final r = await formatter.format(file.path, 'void main(){print( 1 );}\n');
    expect(r.ok, isTrue, reason: r.error);
    expect(r.text, contains('void main() {\n'));
    expect(r.text, contains('  print(1);'));
    expect(file.readAsStringSync(), 'void main(){print( 1 );}\n');
    expect(dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last), ['a.dart']);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('구문 오류는 이유를 돌려주고 임시 파일을 지운다', () async {
    final file = File('${dir.path}${Platform.pathSeparator}b.dart')..writeAsStringSync('');
    final r = await formatter.format(file.path, 'void main( {');
    expect(r.ok, isFalse);
    expect(r.error, startsWith('정렬하지 못했습니다'));
    expect(r.error, isNot(contains('.studio_format_')));
    expect(dir.listSync().length, 1);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
