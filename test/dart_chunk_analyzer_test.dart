import 'package:daylight_workbench/studio/dart_chunk_analyzer.dart';
import 'package:daylight_workbench/studio/fold_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';

List<CodeChunk> _chunks(String code) => DartChunkAnalyzer.findChunks(code.split('\n'));

void main() {
  test('여러 줄에 걸친 중괄호를 구간으로 잡는다', () {
    final c = _chunks('void main() {\n  print(1);\n}\n');
    expect(c, [const CodeChunk(0, 2)]);
  });

  test('한 줄에서 열린 ( 와 [ 는 가장 바깥 것을 쓴다', () {
    const code = 'Column(children: [\n'
        '  Text("a"),\n'
        '  Text("b"),\n'
        '],\n'
        ')';
    // ( 는 0~4, [ 는 0~3 → 바깥 ( 만 남는다.
    expect(_chunks(code), [const CodeChunk(0, 4)]);
  });

  test('주석과 문자열 안의 괄호는 무시한다', () {
    const code = 'void f() {\n'
        '  // } 주석 안의 닫는 괄호\n'
        '  var s = "}";\n'
        "  var t = '{';\n"
        '  /* }\n'
        '  } */\n'
        '}\n';
    expect(_chunks(code), [const CodeChunk(0, 6)]);
  });

  test('여러 줄 문자열 안의 괄호는 무시한다', () {
    const code = 'final s = """\n'
        '}}}\n'
        '""";\n'
        'void f() {\n'
        '  x();\n'
        '}\n';
    expect(_chunks(code), [const CodeChunk(3, 5)]);
  });

  test('원시 문자열은 백슬래시를 이스케이프로 보지 않는다', () {
    const code = r"var p = r'C:\';" '\n'
        'void f() {\n'
        '  x();\n'
        '}\n';
    expect(_chunks(code), [const CodeChunk(1, 3)]);
  });

  test('짝이 없는 괄호는 버린다', () {
    expect(_chunks('void f() {\n  x();\n'), isEmpty);
    expect(_chunks('}\n}\nvoid g() {\n  y();\n}\n'), [const CodeChunk(2, 4)]);
  });

  test('한 줄짜리 괄호는 구간이 아니다', () {
    expect(_chunks('var a = [1, 2, 3];\nvar b = f(x);'), isEmpty);
  });

  group('모두 접기 대상', () {
    test('클래스 하나: 메서드 몸통만 접고 클래스는 연다', () {
      // class A {            0..9
      //   void a() {         1..3
      //   }
      //   void b() {         5..8
      //     if (x) {         6..7
      //     }
      //   }
      // }
      const chunks = [CodeChunk(0, 9), CodeChunk(1, 3), CodeChunk(5, 8), CodeChunk(6, 7)];
      expect(chunksToFold(chunks), [const CodeChunk(1, 3), const CodeChunk(5, 8)]);
    });

    test('최상위 함수만 있으면 그것들을 접는다', () {
      const chunks = [CodeChunk(0, 3), CodeChunk(5, 8)];
      expect(chunksToFold(chunks), chunks);
    });

    test('구간이 없으면 빈 목록', () {
      expect(chunksToFold(const []), isEmpty);
    });
  });
}
