import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/find_panel.dart';
import 'package:daylight_workbench/ui/project_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';

Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.build(StudioPalette.saturn, Brightness.dark),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('ko'),
  home: home,
);

/// 찾기 칸과 바꾸기 칸의 글이 시작하는 가로 위치(첫 번째·마지막 입력칸).
({double find, double replace}) _textStarts(WidgetTester tester) {
  final fields = find.byType(EditableText);
  return (find: tester.getTopLeft(fields.first).dx, replace: tester.getTopLeft(fields.last).dx);
}

void main() {
  testWidgets('편집기 찾기 줄: 찾기 칸과 바꾸기 칸의 글이 같은 자리에서 시작한다', (tester) async {
    final code = CodeLineEditingController.fromText('hello');
    final findController = CodeFindController(code);
    addTearDown(() {
      findController.dispose();
      code.dispose();
    });
    findController.replaceMode();
    await tester.pumpWidget(_app(Scaffold(body: FindPanel(controller: findController, readOnly: false))));
    await tester.pump();
    expect(find.byType(EditableText), findsNWidgets(2));
    final s = _textStarts(tester);
    expect(s.replace, s.find);
  });

  testWidgets('프로젝트 검색: 찾기 칸과 바꾸기 칸의 글이 같은 자리에서 시작한다', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showProjectSearch(context, root: '/p', files: Future.value([]), onOpen: (a, b, c) {}),
            child: const Text('찾기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('찾기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('바꾸기 보기/숨기기'));
    await tester.pump();
    final s = _textStarts(tester);
    expect(s.replace, s.find);
  });
}
