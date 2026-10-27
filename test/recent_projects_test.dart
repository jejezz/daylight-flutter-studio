import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/recent_projects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late StudioController c;

  Directory project(String name) => Directory('${root.path}${Platform.pathSeparator}$name')..createSync();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('recent_projects');
    c = StudioController();
  });

  tearDown(() async {
    c.dispose();
    await root.delete(recursive: true);
  });

  test('연 프로젝트는 최근 목록 맨 앞에 쌓이고, 같은 폴더는 한 번만 나온다', () async {
    final a = project('a').path, b = project('b').path;
    await c.openProject(a);
    await c.openProject(b);
    await c.openProject(a);
    expect(c.recentProjects, [a, b]);
  });

  test('최대 개수를 넘으면 오래된 것부터 빠지고, 다시 시작해도 목록이 남는다', () async {
    final paths = [for (var i = 0; i < StudioController.maxRecent + 2; i++) project('p$i').path];
    for (final p in paths) {
      await c.openProject(p);
    }
    expect(c.recentProjects, hasLength(StudioController.maxRecent));
    expect(c.recentProjects.first, paths.last);
    expect(c.recentProjects, isNot(contains(paths.first)));

    final again = StudioController();
    await again.restore();
    expect(again.recentProjects, c.recentProjects);
    again.dispose();
  });

  test('worktree로 옮기는 것은 목록에 더하지 않는다', () async {
    final a = project('a').path, other = project('other').path;
    await c.openProject(a);
    await c.openProject(other, remember: false);
    expect(c.recentProjects, [a]);
  });

  test('사라진 폴더를 고르면 알리고 목록에서 뺀다', () async {
    final a = project('a').path, gone = project('gone').path;
    await c.openProject(gone);
    await c.openProject(a);
    Directory(gone).deleteSync();
    expect(await c.openRecent(gone), isFalse);
    expect(c.message, isNotNull);
    expect(c.recentProjects, [a]);
  });

  test('목록 지우기', () async {
    await c.openProject(project('a').path);
    await c.clearRecent();
    expect(c.recentProjects, isEmpty);
  });

  testWidgets('프로젝트 열기 옆 메뉴에 최근 프로젝트가 보이고, 누르면 그 프로젝트를 연다', (tester) async {
    final a = project('alpha').path, b = project('beta').path;
    await tester.runAsync(() async {
      await c.openProject(a);
      await c.openProject(b);
      await c.openProject(a);
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        home: Scaffold(appBar: AppBar(actions: [RecentProjectsMenu(controller: c)])),
      ),
    );
    await tester.tap(find.byTooltip('최근 프로젝트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('최근 프로젝트'), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);

    await tester.tap(find.text('beta'));
    await tester.pumpAndSettle(); // 메뉴가 닫힌 뒤에 고른 값이 전달된다
    await tester.runAsync(() async {
      // 프로젝트를 열 때 git으로 worktree를 읽는다 — 실제 프로세스가 끝나기를 기다린다.
      for (var i = 0; i < 60 && !(c.root == b && c.recentProjects.first == b); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pumpAndSettle();
    expect(c.root, b);
    expect(c.recentProjects.first, b);
  });
}
