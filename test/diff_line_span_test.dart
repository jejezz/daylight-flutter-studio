import 'package:daylight_workbench/ui/diff_view.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = TextStyle(fontSize: 13);
  const mark = Color(0x55FF0000);

  /// 배경색이 칠해진 조각만 이어 붙인다.
  String marked(TextSpan span) => [
    for (final c in span.children!.cast<TextSpan>())
      if (c.style?.backgroundColor == mark) c.text,
  ].join('|');

  test('달라진 범위만 배경색으로 칠하고 글 전체는 그대로 이어진다', () {
    final span = diffLineSpan('let a = 1;', [(4, 5)], base, mark);
    expect(marked(span), 'a');
    expect(span.toPlainText(), 'let a = 1;');
  });

  test('범위가 없으면 한 조각이다', () {
    final span = diffLineSpan('same', const [], base, mark);
    expect(span.children, isNull);
    expect(span.text, 'same');
  });

  test('범위가 줄 끝을 넘어도 글을 벗어나지 않는다', () {
    final span = diffLineSpan('abc', [(1, 99)], base, mark);
    expect(marked(span), 'bc');
    expect(span.toPlainText(), 'abc');
  });
}
