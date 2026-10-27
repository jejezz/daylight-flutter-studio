import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/project_index.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/project_search.dart';
import 'package:daylight_workbench/ui/quick_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget Function(BuildContext) open) => MaterialApp(
  theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('ko'),
  home: Builder(builder: open),
);

void main() {
  testWidgets('빠른 열기: 치면 걸러지고 Enter로 첫 파일을 연다', (tester) async {
    String? opened;
    await tester.pumpWidget(
      _host(
        (context) => TextButton(
          onPressed: () async => opened = await showQuickOpen(
            context,
            root: '/p',
            files: Future.value(['lib/main.dart', 'lib/src/other.dart', 'README.md']),
          ),
          child: const Text('열기'),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('README.md'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'main');
    await tester.pump();
    expect(find.text('README.md'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(opened, endsWith('main.dart'));
  });

  testWidgets('프로젝트 검색: 검색하면 결과가 나오고 누르면 그 줄을 연다', (tester) async {
    int? openedLine;
    await tester.pumpWidget(
      _host(
        (context) => TextButton(
          onPressed: () => showProjectSearch(
            context,
            root: '/p',
            files: Future.value(['lib/a.dart']),
            onOpen: (path, line, column) => openedLine = line,
            search: (root, files, query, {caseSensitive = false, regex = false}) async =>
                const SearchResult([SearchHit('/p/lib/a.dart', 3, 5, 'final x = 1;')]),
          ),
          child: const Text('찾기'),
        ),
      ),
    );
    await tester.tap(find.text('찾기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('1곳'), findsOneWidget);

    await tester.tap(find.text('final x = 1;'));
    expect(openedLine, 3);
  });
}
