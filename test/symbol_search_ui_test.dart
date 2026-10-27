import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/symbol_index.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/symbol_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const symbols = [
    DartSymbol('Square', SymbolKind.classType, '/p/lib/shape.dart', 3, 7),
    DartSymbol('area', SymbolKind.method, '/p/lib/shape.dart', 7, 10, container: 'Square'),
    DartSymbol('area', SymbolKind.method, '/p/lib/circle.dart', 12, 10, container: 'Circle'),
  ];

  Future<DartSymbol?> open(WidgetTester tester, {String initialQuery = '', required void Function(Future<DartSymbol?>) onResult}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => onResult(showSymbolSearch(context, root: '/p', symbols: Future.value(symbols), initialQuery: initialQuery)),
            child: const Text('열기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    return null;
  }

  testWidgets('이름을 치면 걸러지고 고른 선언을 돌려준다', (tester) async {
    late Future<DartSymbol?> result;
    await open(tester, onResult: (f) => result = f);
    expect(find.text('Square'), findsOneWidget);
    expect(find.text('Square.area'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'area');
    await tester.pumpAndSettle();
    expect(find.text('Square'), findsNothing);
    expect(find.text('Circle.area'), findsOneWidget);
    expect(find.textContaining('lib/circle.dart:12'), findsOneWidget);

    await tester.tap(find.text('Circle.area'));
    await tester.pumpAndSettle();
    expect((await result)!.path, '/p/lib/circle.dart');
  });

  testWidgets('처음 검색어가 있으면 바로 걸러 보여 주고 Enter로 첫 항목을 고른다', (tester) async {
    late Future<DartSymbol?> result;
    await open(tester, initialQuery: 'area', onResult: (f) => result = f);
    expect(find.text('Square'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect((await result)!.name, 'area');
  });

  testWidgets('맞는 선언이 없으면 안내한다', (tester) async {
    await open(tester, initialQuery: 'zzzz', onResult: (_) {});
    expect(find.text('맞는 선언이 없습니다'), findsOneWidget);
  });
}
