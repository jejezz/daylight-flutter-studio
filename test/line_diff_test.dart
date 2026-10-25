import 'dart:math';

import 'package:daylight_flutter_studio/diff/line_diff.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _l(String s) => s.isEmpty ? <String>[] : s.split(',');

/// diff 결과를 옛 글에 적용해 새 글을 만든다 — 결과가 맞다면 항상 b와 같아야 한다.
List<String> _apply(List<String> a, List<String> b, List<DiffBlock> blocks) {
  final out = <String>[];
  for (final block in blocks) {
    if (block.kind == BlockKind.equal) {
      expect(a.sublist(block.aStart, block.aEnd), b.sublist(block.bStart, block.bEnd), reason: 'equal 묶음은 양쪽이 같아야 한다');
      out.addAll(a.sublist(block.aStart, block.aEnd));
    } else {
      out.addAll(b.sublist(block.bStart, block.bEnd));
    }
  }
  return out;
}

void main() {
  group('splitLines', () {
    test('끝 줄바꿈은 빈 줄을 만들지 않는다', () {
      expect(splitLines('a\nb\n'), ['a', 'b']);
      expect(splitLines('a\nb'), ['a', 'b']);
      expect(splitLines(''), isEmpty);
      expect(splitLines('\n'), ['']);
    });

    test('CRLF와 LF는 같은 줄로 본다', () {
      expect(splitLines('a\r\nb\r\n'), splitLines('a\nb\n'));
    });
  });

  group('diffLines', () {
    test('같으면 equal 하나', () {
      expect(diffLines(_l('a,b,c'), _l('a,b,c')), [const DiffBlock(BlockKind.equal, 0, 3, 0, 3)]);
    });

    test('둘 다 비어 있으면 묶음이 없다', () {
      expect(diffLines(const [], const []), isEmpty);
    });

    test('줄 추가', () {
      final blocks = diffLines(_l('a,c'), _l('a,b,c'));
      expect(blocks, [
        const DiffBlock(BlockKind.equal, 0, 1, 0, 1),
        const DiffBlock(BlockKind.change, 1, 0, 1, 1),
        const DiffBlock(BlockKind.equal, 1, 1, 2, 1),
      ]);
    });

    test('줄 삭제', () {
      final blocks = diffLines(_l('a,b,c'), _l('a,c'));
      expect(blocks, [
        const DiffBlock(BlockKind.equal, 0, 1, 0, 1),
        const DiffBlock(BlockKind.change, 1, 1, 1, 0),
        const DiffBlock(BlockKind.equal, 2, 1, 1, 1),
      ]);
    });

    test('줄 수정은 하나의 변경 묶음이다', () {
      final blocks = diffLines(_l('a,b,c'), _l('a,X,c'));
      expect(blocks, [
        const DiffBlock(BlockKind.equal, 0, 1, 0, 1),
        const DiffBlock(BlockKind.change, 1, 1, 1, 1),
        const DiffBlock(BlockKind.equal, 2, 1, 2, 1),
      ]);
    });

    test('빈 파일에서 새로 생기면 전부 추가', () {
      expect(diffLines(const [], _l('a,b')), [const DiffBlock(BlockKind.change, 0, 0, 0, 2)]);
      expect(diffLines(_l('a,b'), const []), [const DiffBlock(BlockKind.change, 0, 2, 0, 0)]);
    });

    test('같은 줄이 반복돼도 올바른 결과를 만든다', () {
      final a = _l('x,x,x,y,x');
      final b = _l('x,y,x,x,x,z');
      expect(_apply(a, b, diffLines(a, b)), b);
    });

    test('무작위 입력 500개: 적용하면 항상 새 글이 된다', () {
      final rnd = Random(42);
      for (var i = 0; i < 500; i++) {
        final a = List.generate(rnd.nextInt(40), (_) => 'l${rnd.nextInt(6)}');
        final b = List.generate(rnd.nextInt(40), (_) => 'l${rnd.nextInt(6)}');
        final blocks = diffLines(a, b);
        expect(_apply(a, b, blocks), b, reason: 'a=$a b=$b blocks=$blocks');
        // 묶음은 빈틈·겹침 없이 양쪽을 끝까지 덮는다.
        var ia = 0, ib = 0;
        for (final block in blocks) {
          expect(block.aStart, ia);
          expect(block.bStart, ib);
          ia = block.aEnd;
          ib = block.bEnd;
        }
        expect(ia, a.length);
        expect(ib, b.length);
      }
    });

    test('최소 편집이다: 줄 하나만 바꾸면 변경은 한 곳', () {
      final a = List.generate(200, (i) => 'line $i');
      final b = [...a]..[100] = 'changed';
      final blocks = diffLines(a, b);
      expect(blocks.where((x) => x.isChange).length, 1);
      expect(countChanges(blocks), (added: 1, removed: 1));
    });

    test('거의 다른 파일은 한 덩어리 변경으로 본다 (편집 상한)', () {
      final a = List.generate(30, (i) => 'a$i');
      final b = List.generate(30, (i) => 'b$i');
      final blocks = diffLines(a, b, maxEdits: 5);
      expect(blocks, [const DiffBlock(BlockKind.change, 0, 30, 0, 30)]);
    });

    test('큰 파일에서 몇 줄만 달라도 빠르다', () {
      final a = List.generate(20000, (i) => 'line $i');
      final b = [...a]
        ..[100] = 'x'
        ..removeAt(15000)
        ..insert(5000, 'new');
      final watch = Stopwatch()..start();
      final blocks = diffLines(a, b);
      watch.stop();
      expect(_apply(a, b, blocks), b);
      expect(watch.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('marksFromBlocks', () {
    test('추가·수정·삭제를 새 글 줄 번호로 나눈다', () {
      final a = _l('a,b,c,d,e');
      final b = _l('a,B,c,new1,new2,e,');
      // b: a, B(수정), c, new1/new2(d를 대체 → 수정), e, ''(추가)
      final marks = marksFromBlocks(diffLines(a, b));
      expect(marks.modified, {1, 3, 4});
      expect(marks.added, {6});
      expect(marks.deletedBefore, isEmpty);
    });

    test('삭제는 지워진 자리의 다음 줄에 표시한다', () {
      final marks = marksFromBlocks(diffLines(_l('a,b,c'), _l('a,c')));
      expect(marks.deletedBefore, {1});
      expect(marks.added, isEmpty);
    });

    test('파일 끝의 삭제는 줄 수 번호', () {
      final marks = marksFromBlocks(diffLines(_l('a,b,c'), _l('a,b')));
      expect(marks.deletedBefore, {2});
    });

    test('변경이 없으면 비어 있다', () {
      expect(marksFromBlocks(diffLines(_l('a,b'), _l('a,b'))).isEmpty, isTrue);
      expect(marksFromBlocks(diffLines(_l('a,b'), _l('a,b'))), ChangeMarks.empty);
    });
  });

  group('buildUnifiedRows', () {
    List<DiffRow> rows(List<String> a, List<String> b, {int context = 1, Set<int> expanded = const {}}) =>
        buildUnifiedRows(a, b, diffLines(a, b), context: context, expandedGaps: expanded);

    test('변경이 없으면 빈 목록', () {
      expect(rows(_l('a,b'), _l('a,b')), isEmpty);
    });

    test('삭제된 줄 뒤에 추가된 줄이 온다', () {
      final r = rows(_l('a,b,c'), _l('a,X,c'));
      expect([for (final x in r) x.kind], [DiffRowKind.context, DiffRowKind.removed, DiffRowKind.added, DiffRowKind.context]);
      expect(r[1].text, 'b');
      expect(r[1].oldNo, 2);
      expect(r[2].text, 'X');
      expect(r[2].newNo, 2);
    });

    test('바뀐 곳에서 먼 같은 줄은 gap으로 접고 펼칠 수 있다', () {
      final a = List.generate(20, (i) => 'l$i');
      final b = [...a]..[10] = 'CHANGED';
      final folded = rows(a, b);
      final gaps = folded.where((x) => x.kind == DiffRowKind.gap).toList();
      expect(gaps.length, 2);
      expect(gaps.first.hidden, 9); // 0..8은 숨기고 9가 문맥으로 남는다
      expect(folded.where((x) => x.kind == DiffRowKind.context).length, 2);

      final expandedAll = rows(a, b, expanded: {for (final g in gaps) g.gapId});
      expect(expandedAll.any((x) => x.kind == DiffRowKind.gap), isFalse);
      expect(expandedAll.length, 21); // 줄 20개 + 삭제 1 - 수정 1 대체
    });

    test('새 파일은 전부 추가로 보인다', () {
      final r = buildUnifiedRows(const [], _l('a,b'), diffLines(const [], _l('a,b')));
      expect(r.map((x) => x.kind), [DiffRowKind.added, DiffRowKind.added]);
      expect(r.map((x) => x.newNo), [1, 2]);
    });
  });
}
