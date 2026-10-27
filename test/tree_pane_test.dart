import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/studio/worktree.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/tree_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late StudioController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('tree_pane');
    c = StudioController()..root = dir.path;
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  Widget app() => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ko'), 
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    // 실제 화면의 트리 영역과 같은 너비 (스크린샷의 260px대).
    home: Scaffold(body: SizedBox(width: 260, height: 600, child: TreePane(controller: c))),
  );

  testWidgets('worktree가 여럿이면 선택 칸과 새로 고침 단추가 한 줄에 나란히 있다', (tester) async {
    c.worktrees = [
      Worktree(path: dir.path, branch: 'main', main: true),
      Worktree(path: '${dir.path}-other${Platform.pathSeparator}.claude${Platform.pathSeparator}worktrees${Platform.pathSeparator}fix', branch: 'claude/fix'),
    ];
    await tester.pumpWidget(app());
    await tester.pump();

    final dropdown = tester.getRect(find.byType(DropdownButtonFormField<Worktree>));
    final refresh = tester.getRect(find.byIcon(Icons.refresh_rounded));

    expect(refresh.left, greaterThanOrEqualTo(dropdown.right), reason: '단추는 선택 칸의 오른쪽에 붙는다');
    expect(refresh.center.dy, closeTo(dropdown.center.dy, 8), reason: '같은 줄이라 세로 가운데가 거의 같다');
    expect(refresh.right, lessThanOrEqualTo(260));
    expect(tester.takeException(), isNull, reason: '좁은 폭에서도 넘치지 않는다');
  });

  testWidgets('worktree가 하나뿐이면 제목과 새로 고침 단추가 한 줄이다', (tester) async {
    c.worktrees = [Worktree(path: dir.path, branch: 'main', main: true)];
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.byType(DropdownButtonFormField<Worktree>), findsNothing);
    final title = tester.getRect(find.text('탐색기'));
    final refresh = tester.getRect(find.byIcon(Icons.refresh_rounded));
    expect(refresh.left, greaterThan(title.right));
    expect(refresh.center.dy, closeTo(title.center.dy, 8));
  });

  testWidgets('새로 고침 단추를 누르면 트리를 다시 읽게 한다', (tester) async {
    c.worktrees = [Worktree(path: dir.path, branch: 'main', main: true)];
    await tester.pumpWidget(app());
    await tester.pump();

    final before = c.treeRevision;
    await tester.tap(find.byTooltip('트리 새로 고침'));
    await tester.pump();
    expect(c.treeRevision, before + 1);
  });
}
