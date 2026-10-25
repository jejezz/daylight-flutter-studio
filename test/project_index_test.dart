import 'dart:io';

import 'package:daylight_flutter_studio/studio/project_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fuzzyScore / rankFiles', () {
    test('글자가 차례대로 들어 있어야 맞는다', () {
      expect(fuzzyScore('abc', 'a_b_c.dart'), isNotNull);
      expect(fuzzyScore('cba', 'a_b_c.dart'), isNull);
    });

    test('파일 이름에 그대로 들어 있는 것이 먼저 나온다', () {
      final ranked = rankFiles('main', ['lib/src/domain/animal.dart', 'lib/main.dart', 'test/main_test.dart']);
      expect(ranked.first, 'lib/main.dart');
    });

    test('빈 검색어는 모두 맞고 대소문자를 가리지 않는다', () {
      expect(rankFiles('', ['a', 'b']), hasLength(2));
      expect(fuzzyScore('MAIN', 'lib/main.dart'), isNotNull);
    });
  });

  group('파일 목록·검색', () {
    late Directory dir;

    void write(String rel, String text) {
      final f = File('${dir.path}/$rel')..createSync(recursive: true);
      f.writeAsStringSync(text);
    }

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('project_index');
      write('lib/a.dart', 'hello\nWorld hello\n');
      write('lib/b.txt', 'nothing here');
      write('build/out.dart', 'hello');
      write('.git/config', 'hello');
      File('${dir.path}/bin.dat').writeAsBytesSync([0xff, 0xfe, 0x00, 0x80]);
    });

    tearDown(() => dir.delete(recursive: true));

    test('빌드 폴더와 .git은 목록에서 뺀다', () async {
      final files = await listProjectFiles(dir.path);
      expect(files, containsAll(['lib/a.dart', 'lib/b.txt', 'bin.dat']));
      expect(files.any((f) => f.startsWith('build/') || f.startsWith('.git/')), isFalse);
    });

    test('글을 찾아 줄·칸 위치를 준다 (글자 파일이 아닌 것은 건너뛴다)', () async {
      final files = await listProjectFiles(dir.path);
      final r = searchProjectSync(dir.path, files, 'hello');
      expect(r.hits.map((h) => (h.line, h.column)), [(1, 1), (2, 7)]);
      expect(r.hits.first.path, endsWith('a.dart'));
    });

    test('대소문자 구분과 정규식, 잘못된 정규식', () async {
      final files = await listProjectFiles(dir.path);
      expect(searchProjectSync(dir.path, files, 'world').hits, hasLength(1));
      expect(searchProjectSync(dir.path, files, 'world', caseSensitive: true).hits, isEmpty);
      expect(searchProjectSync(dir.path, files, r'hel+o', regex: true).hits, hasLength(2));
      expect(searchProjectSync(dir.path, files, '(', regex: true).invalidPattern, isTrue);
    });
  });
}
