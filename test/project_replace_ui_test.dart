import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/project_index.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/project_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('replace_ui'));
  tearDown(() => dir.deleteSync(recursive: true));

  Widget host({bool Function(String path)? isBusy, VoidCallback? onReplaced}) => MaterialApp(
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => showProjectSearch(
          context,
          root: dir.path,
          files: Future.value(['a.txt', 'b.txt']),
          onOpen: (path, line, column) {},
          search: (root, files, query, {caseSensitive = false, regex = false}) async =>
              searchProjectSync(root, files, query, caseSensitive: caseSensitive, regex: regex),
          isBusy: isBusy,
          onReplaced: onReplaced,
        ),
        child: const Text('찾기'),
      ),
    ),
  );

  /// 실제 파일을 쓰는 동안 기다린다 (위젯 테스트의 가짜 시계 밖에서).
  /// 파일 입출력은 진짜 시계로, 그 사이사이 이어지는 코드는 pump로 흘려 보낸다.
  Future<void> waitFor(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 150 && !done(); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    // 마지막 입출력(되돌리기 뒤 다시 찾기 등)이 끝나게 조금 더 흘린다.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> openAndSearch(WidgetTester tester, {bool Function(String)? isBusy, VoidCallback? onReplaced}) async {
    await tester.pumpWidget(host(isBusy: isBusy, onReplaced: onReplaced));
    await tester.tap(find.text('찾기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('바꾸기 보기/숨기기'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'X');
    // Enter는 마지막으로 입력한 칸에 간다 — 찾을 글을 나중에 넣는다.
    await tester.enterText(find.byType(TextField).first, 'foo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('골라서 바꾸고, 바뀐 곳은 미리 보이고, 되돌린다', (tester) async {
    final a = File('${dir.path}/a.txt')..writeAsStringSync('foo\nbar\nfoo\n');
    final b = File('${dir.path}/b.txt')..writeAsStringSync('foo');
    var replacedCalls = 0;
    await openAndSearch(tester, onReplaced: () => replacedCalls++);

    expect(find.text('3곳'), findsOneWidget);
    expect(find.text('선택한 3곳 바꾸기'), findsOneWidget);
    expect(find.descendant(of: find.byType(ListView), matching: find.text('X')), findsNWidgets(3)); // 바꾼 뒤의 모습(미리보기)

    // a.txt의 둘째 결과(3번째 줄)를 뺀다. 체크 상자 순서: [a 머리, a:1, a:3, b 머리, b:1]
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pump();
    expect(find.text('선택한 2곳 바꾸기'), findsOneWidget);

    await tester.tap(find.text('선택한 2곳 바꾸기'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2개 파일의 2곳을 바꿉니다'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '바꾸기'));
    await tester.pumpAndSettle();
    await waitFor(tester, () => b.readAsStringSync() == 'X');

    expect(a.readAsStringSync(), 'X\nbar\nfoo\n');
    expect(b.readAsStringSync(), 'X');
    expect(find.text('2개 파일에서 2곳을 바꿨습니다.'), findsOneWidget);
    expect(replacedCalls, 1);

    await tester.tap(find.text('되돌리기'));
    await tester.pumpAndSettle();
    await waitFor(tester, () => b.readAsStringSync() == 'foo');
    expect(a.readAsStringSync(), 'foo\nbar\nfoo\n');
    expect(b.readAsStringSync(), 'foo');
    expect(find.text('2개 파일을 되돌렸습니다.'), findsOneWidget);
    expect(replacedCalls, 2);
  });

  testWidgets('확인창에서 취소하면 아무것도 바꾸지 않는다', (tester) async {
    final a = File('${dir.path}/a.txt')..writeAsStringSync('foo');
    await openAndSearch(tester);
    await tester.tap(find.textContaining('바꾸기').last); // 선택한 N곳 바꾸기
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(a.readAsStringSync(), 'foo');
  });

  testWidgets('수정 중인 탭이 열린 파일은 건너뛰고 안내한다', (tester) async {
    final a = File('${dir.path}/a.txt')..writeAsStringSync('foo');
    final b = File('${dir.path}/b.txt')..writeAsStringSync('foo');
    await openAndSearch(tester, isBusy: (p) => p.endsWith('a.txt'));

    await tester.tap(find.text('선택한 2곳 바꾸기'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '바꾸기'));
    await tester.pumpAndSettle();
    await waitFor(tester, () => b.readAsStringSync() == 'X');

    expect(a.readAsStringSync(), 'foo');
    expect(b.readAsStringSync(), 'X');
    expect(find.textContaining('1개 파일은 건너뛰었습니다'), findsOneWidget);
  });
}
