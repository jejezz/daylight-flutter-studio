import 'dart:io';

import 'package:daylight_flutter_studio/studio/json_formatter.dart';
import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatJson', () {
    test('들여쓰기 2칸으로 정렬하고 키 순서와 끝 줄바꿈을 지킨다', () {
      final r = formatJson('{"b":1,"a":["x","한글"]}\n');
      expect(r.ok, isTrue);
      expect(r.text, '{\n  "b": 1,\n  "a": [\n    "x",\n    "한글"\n  ]\n}\n');
      expect(formatJson('[1]').text, '[\n  1\n]');
    });

    test('문법 오류는 실패로 알린다', () {
      final r = formatJson('{"a": }');
      expect(r.ok, isFalse);
      expect(r.error, contains('JSON'));
    });
  });

  group('저장할 때 정렬', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('format_on_save'));
    tearDown(() => dir.delete(recursive: true));

    Future<(StudioController, File)> open(String text, {required bool on}) async {
      final file = File('${dir.path}${Platform.pathSeparator}app_ko.arb')..writeAsStringSync(text);
      final c = StudioController(formatOnSave: () => on);
      await c.openFile(file.path);
      return (c, file);
    }

    test('켜져 있으면 저장하기 직전에 정렬한다', () async {
      final (c, file) = await open('{"a":1}', on: true);
      expect(await c.save(c.activeTab!), isTrue);
      expect(file.readAsStringSync(), '{\n  "a": 1\n}');
      expect(c.activeTab!.dirty, isFalse);
      c.dispose();
    });

    test('꺼져 있으면 글을 그대로 저장한다', () async {
      final (c, file) = await open('{"a":1}', on: false);
      c.activeTab!.controller.text = '{"a":2}';
      await c.save(c.activeTab!);
      expect(file.readAsStringSync(), '{"a":2}');
      c.dispose();
    });

    test('문법 오류가 있어도 저장은 한다', () async {
      final (c, file) = await open('{"a":1}', on: true);
      c.activeTab!.controller.text = '{"a": ';
      expect(await c.save(c.activeTab!), isTrue);
      expect(file.readAsStringSync(), '{"a": ');
      c.dispose();
    });

    test('JSON·ARB 탭은 정렬 단추를 쓸 수 있다', () async {
      final (c, _) = await open('{}', on: false);
      expect(c.canFormat(c.activeTab!), isTrue);
      c.dispose();
    });
  });
}
