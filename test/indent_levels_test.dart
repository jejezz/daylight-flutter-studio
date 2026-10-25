import 'package:daylight_flutter_studio/studio/indent_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('앞 공백 칸 수 (탭은 2칸), 빈 줄은 null', () {
    expect(leadingColumns('    foo'), 4);
    expect(leadingColumns('\tfoo'), 2);
    expect(leadingColumns('foo'), 0);
    expect(leadingColumns(''), isNull);
    expect(leadingColumns('   '), isNull);
  });

  test('한 단계 폭: 들여쓰기가 늘어나는 가장 작은 폭', () {
    expect(detectIndentUnit(['a', '  b', '    c', '  d']), 2);
    expect(detectIndentUnit(['a', '    b', '        c']), 4);
    expect(detectIndentUnit(['a', 'b']), 2, reason: '알 수 없으면 Dart 관례의 2칸');
  });

  group('indentLevelAt', () {
    int level(List<String> lines, int i, {int unit = 2}) => indentLevelAt(lines.length, (n) => lines[n], i, unit);

    test('글자 있는 줄은 자기 깊이', () {
      final lines = ['void f() {', '  if (x) {', '    y();', '  }', '}'];
      expect([for (var i = 0; i < lines.length; i++) level(lines, i)], [0, 1, 2, 1, 0]);
    });

    test('블록 안의 빈 줄은 선이 이어지고, 블록 사이의 빈 줄은 끊긴다', () {
      final inside = ['void f() {', '  a();', '', '  b();', '}'];
      expect(level(inside, 2), 1);
      final between = ['void f() {', '  a();', '}', '', 'void g() {', '  b();', '}'];
      expect(level(between, 3), 0);
    });

    test('줄 목록의 처음·끝의 빈 줄은 0', () {
      expect(level(['', '  a'], 0), 0);
      expect(level(['  a', ''], 1), 0);
    });
  });
}
