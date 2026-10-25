import 'package:daylight_flutter_studio/studio/dart_highlight.dart';
import 'package:daylight_flutter_studio/theme/syntax_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/re_highlight.dart';

const _code = r'''
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (title.isEmpty) return const SizedBox();
    return Scaffold(
      appBar: AppBar(title: Text('Hello $title')),
      body: Center(child: ElevatedButton(onPressed: () async { await foo(); }, child: const Text("go"))),
    );
  }
}
Future<void> foo() async => print(true ? null : 3.14);
''';

void main() {
  final tokens = SyntaxTokens.forBrightness(Brightness.dark);
  final theme = tokens.highlightTheme(base: const Color(0xFFFFFFFF));
  final h = Highlight()..registerLanguage('dart', langDartRich);

  /// 글자 → 색 (같은 글자가 여러 번 나오면 마지막 것).
  Map<String, Color?> colors() {
    final r = h.highlight(code: _code, language: 'dart');
    final renderer = TextSpanRenderer(null, theme);
    r.render(renderer);
    final out = <String, Color?>{};
    void walk(InlineSpan? span, TextStyle? inherited) {
      if (span is! TextSpan) return;
      final style = inherited?.merge(span.style) ?? span.style;
      if (span.text != null) out[span.text!.trim()] = style?.color;
      span.children?.forEach((c) => walk(c, style));
    }

    walk(renderer.span, null);
    return out;
  }

  final c = colors();

  test('함수·메서드 이름은 함수 색 (선언·호출·정적 호출, 키워드 if는 제외)', () {
    expect(c['build'], tokens.title);
    expect(c['foo'], tokens.title);
    expect(c['of'], tokens.title);
    expect(c['isEmpty'], isNot(tokens.title), reason: '`(`가 없는 속성은 함수가 아니다');
    expect(c['if'], tokens.keyword);
  });

  test('위젯·타입·생성자 호출은 타입 색, Flutter 핵심 이름과 Dart 내장 이름은 내장 색', () {
    for (final name in ['Scaffold', 'AppBar', 'Text', 'Center', 'ElevatedButton', 'SizedBox']) {
      expect(c[name], tokens.classType, reason: name);
    }
    expect(c['Widget'], tokens.builtIn);
    expect(c['BuildContext'], tokens.builtIn);
    expect(c['Theme'], tokens.builtIn);
    expect(c['String'], tokens.builtIn);
    expect(c['int'] ?? tokens.builtIn, tokens.builtIn);
  });

  test('이름 붙인 인자와 true/null 리터럴', () {
    for (final name in ['appBar', 'title', 'body', 'child', 'onPressed']) {
      expect(c[name], tokens.attr, reason: name);
    }
    expect(c['true'], tokens.literal);
    expect(c['null'], tokens.literal);
  });

  test('기존 구분(키워드·문자열·숫자·어노테이션)은 그대로', () {
    expect(c['class'], tokens.keyword);
    expect(c['return'], tokens.keyword);
    expect(c['@override'], tokens.meta);
    expect(c['3.14'], tokens.number);
    expect(c["'package:flutter/material.dart'"], tokens.string);
  });
}
