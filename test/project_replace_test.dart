import 'dart:io';

import 'package:daylight_workbench/studio/project_index.dart';
import 'package:daylight_workbench/studio/project_replace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('replaceLines', () {
    final re = RegExp('foo');

    test('고른 줄만 바꾸고, 그 줄 안의 맞는 곳은 모두 바꾼다', () {
      final (text, n) = replaceLines('foo foo\nfoo\nbar foo\n', {1, 3}, re, 'X', regex: false);
      expect(text, 'X X\nfoo\nbar X\n');
      expect(n, 2);
    });

    test('줄 끝(CRLF·LF·CR)과 끝의 빈 줄을 그대로 둔다', () {
      final (text, _) = replaceLines('foo\r\nfoo\nfoo\rfoo', {1, 2, 3, 4}, re, 'x', regex: false);
      expect(text, 'x\r\nx\nx\rx');
      final (same, n) = replaceLines('a\n', {1, 2}, re, 'x', regex: false);
      expect(same, 'a\n');
      expect(n, 0);
    });

    test('정규식 모드는 \$1 묶음을 쓰고 \$\$는 \$가 된다, 일반 모드는 그대로 쓴다', () {
      final r = RegExp(r'(\w+)@(\w+)');
      expect(replaceLines('a@b', {1}, r, r'$2:$1 $$', regex: true).$1, r'b:a $');
      expect(replaceLines('a@b', {1}, r, r'$2', regex: false).$1, r'$2');
    });

    test('빈 글에 맞는 곳은 검색처럼 건너뛴다', () {
      expect(replaceLines('abc', {1}, RegExp('x*'), '-', regex: true).$1, 'abc');
    });
  });

  group('ReplaceSession', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('replace_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    String write(String name, String text) {
      final f = File('${dir.path}/$name')..writeAsStringSync(text);
      return f.path;
    }

    test('쓰고 → 같은 글이면 되돌린다', () async {
      final a = write('a.txt', 'foo\nfoo\n');
      final out = await ReplaceSession.apply({
        a: {1},
      }, RegExp('foo'), 'bar', regex: false);
      expect(File(a).readAsStringSync(), 'bar\nfoo\n');
      expect(out.files, 1);
      expect(out.lines, 1);

      final undo = await ReplaceSession(out.changes).undo();
      expect(File(a).readAsStringSync(), 'foo\nfoo\n');
      expect(undo.restored, 1);
    });

    test('바꾼 뒤에 또 수정된 파일은 되돌리지 않고 둔다', () async {
      final a = write('a.txt', 'foo\n');
      final out = await ReplaceSession.apply({
        a: {1},
      }, RegExp('foo'), 'bar', regex: false);
      File(a).writeAsStringSync('bar\nmy edit\n');
      final undo = await ReplaceSession(out.changes).undo();
      expect(File(a).readAsStringSync(), 'bar\nmy edit\n');
      expect(undo.skipped, 1);
      expect(undo.restored, 0);
    });

    test('수정 중인 탭 파일은 건너뛰고, 검색한 뒤 줄이 바뀐 곳은 바꾸지 않는다', () async {
      final busy = write('busy.txt', 'foo\n');
      final stale = write('stale.txt', 'changed meanwhile\n');
      final ok = write('ok.txt', 'foo\n');
      final out = await ReplaceSession.apply(
        {
          busy: {1},
          stale: {1},
          ok: {1},
        },
        RegExp('foo'),
        'bar',
        regex: false,
        isBusy: (p) => p == busy,
      );
      expect(File(busy).readAsStringSync(), 'foo\n');
      expect(File(stale).readAsStringSync(), 'changed meanwhile\n');
      expect(File(ok).readAsStringSync(), 'bar\n');
      expect(out.skippedFiles, 1);
      expect(out.files, 1);
    });

    test('글자 파일이 아니거나 없는 파일은 실패로 세고 나머지는 계속한다', () async {
      final bin = File('${dir.path}/bin.dat')..writeAsBytesSync([0xff, 0xfe, 0x00, 0xc3]);
      final ok = write('ok.txt', 'foo');
      final out = await ReplaceSession.apply(
        {
          bin.path: {1},
          '${dir.path}/missing.txt': {1},
          ok: {1},
        },
        RegExp('foo'),
        'bar',
        regex: false,
      );
      expect(out.failedFiles, 2);
      expect(File(ok).readAsStringSync(), 'bar');
    });

    test('검색과 같은 패턴으로 찾은 결과를 그대로 바꾼다', () async {
      final a = write('a.txt', 'Foo\nfoo\n');
      final re = buildSearchPattern('foo')!; // 대소문자 무시
      final hits = searchProjectSync(dir.path, ['a.txt'], 'foo').hits;
      final out = await ReplaceSession.apply({
        a: {for (final h in hits) h.line},
      }, re, 'x', regex: false);
      expect(File(a).readAsStringSync(), 'x\nx\n');
      expect(out.lines, 2);
    });
  });
}
