import 'dart:io';

import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/settings/app_settings.dart';
import 'package:daylight_flutter_studio/settings/panel_layout.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_zoom.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/bottom_panel.dart';
import 'package:daylight_flutter_studio/ui/branchdock_dock.dart';
import 'package:daylight_flutter_studio/ui/run_panel.dart';
import 'package:daylight_flutter_studio/ui/studio_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PanelLayout', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('기본은 아래 패널이 열려 있고 Run 탭이다', () {
      final l = PanelLayout();
      addTearDown(l.dispose);
      expect(l.bottomOpen, isTrue);
      expect(l.bottomTab, BottomTab.run);
      expect(l.bottomHeight, PanelLayout.defaultBottomHeight);
    });

    test('접고 펴며, 바뀔 때만 알린다', () {
      final l = PanelLayout();
      addTearDown(l.dispose);
      var calls = 0;
      l.addListener(() => calls++);

      l.toggleBottom();
      expect(l.bottomOpen, isFalse);
      l.toggleBottom();
      expect(l.bottomOpen, isTrue);
      expect(calls, 2);

      l.setBottomTab(BottomTab.run);
      l.setBottomHeight(PanelLayout.defaultBottomHeight);
      expect(calls, 2, reason: '같은 값은 알리지 않는다');
    });

    test('showBottom은 접혀 있어도 펼치고 그 탭으로 바꾼다', () {
      final l = PanelLayout()..toggleBottom();
      addTearDown(l.dispose);
      expect(l.bottomOpen, isFalse);
      l.showBottom(BottomTab.problems);
      expect(l.bottomOpen, isTrue);
      expect(l.bottomTab, BottomTab.problems);
    });

    test('높이는 범위 안으로 맞춘다', () {
      final l = PanelLayout();
      addTearDown(l.dispose);
      l.setBottomHeight(5);
      expect(l.bottomHeight, PanelLayout.minBottomHeight);
      l.setBottomHeight(99999);
      expect(l.bottomHeight, PanelLayout.maxBottomHeight);
      l.setBottomHeight(333);
      expect(l.bottomHeight, 333);
    });

    test('열림·높이·탭을 저장하고 다시 읽는다', () async {
      final a = PanelLayout();
      addTearDown(a.dispose);
      a.showBottom(BottomTab.problems);
      a.setBottomHeight(400);
      a.toggleBottom();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final b = PanelLayout();
      addTearDown(b.dispose);
      await b.restore();
      expect(b.bottomOpen, isFalse);
      expect(b.bottomHeight, 400);
      expect(b.bottomTab, BottomTab.problems);
    });

    test('Git Dock: 기본은 열려 있고, 너비는 최소·최대 안으로 맞춘다', () {
      final l = PanelLayout();
      addTearDown(l.dispose);
      expect(l.dockOpen, isTrue);
      expect(l.dockWidth, PanelLayout.defaultDockWidth);
      l.setDockWidth(100);
      expect(l.dockWidth, PanelLayout.minDockWidth, reason: '너무 좁으면 단추가 찌그러진다');
      l.setDockWidth(5000);
      expect(l.dockWidth, PanelLayout.maxDockWidth);
    });

    test('Git Dock: 숨김·너비를 저장하고 다시 읽는다', () async {
      final a = PanelLayout();
      a.toggleDock();
      a.setDockWidth(500);
      a.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final b = PanelLayout();
      addTearDown(b.dispose);
      await b.restore();
      expect(b.dockOpen, isFalse);
      expect(b.dockWidth, 500);
    });

    test('Git Dock: 저장된 너비가 최소보다 좁으면 최소로 올린다', () async {
      SharedPreferences.setMockInitialValues({'layout_dock_width': 200.0});
      final l = PanelLayout();
      addTearDown(l.dispose);
      await l.restore();
      expect(l.dockWidth, PanelLayout.minDockWidth);
    });

    test('깨진 저장 값은 기본 배치로 둔다', () async {
      SharedPreferences.setMockInitialValues({'layout_bottom_tab': 'nonsense', 'layout_bottom_height': 1.0});
      final l = PanelLayout();
      addTearDown(l.dispose);
      await l.restore();
      expect(l.bottomTab, BottomTab.run);
      expect(l.bottomHeight, PanelLayout.minBottomHeight, reason: '너무 작은 높이는 최소로 맞춘다');
    });
  });

  group('StudioScreen 배치', () {
    late Directory project;
    late ThemeController theme;
    late EditorZoom zoom;
    late AppSettings settings;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      project = await Directory.systemTemp.createTemp('layout_project');
      File('${project.path}${Platform.pathSeparator}pubspec.yaml').writeAsStringSync('name: layout_probe\n');
      SharedPreferences.setMockInitialValues({'last_project': project.path});
      settings = await AppSettings.load();
      theme = ThemeController(settings);
      zoom = EditorZoom();
    });

    tearDown(() async {
      theme.dispose();
      zoom.dispose();
      try {
        await project.delete(recursive: true);
      } on FileSystemException {
        // 분석 프로세스가 폴더를 잡고 있으면 임시 폴더라 남겨 둬도 된다.
      }
    });

    Widget app() => AppSettingsScope(
      settings: settings,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
        home: StudioScreen(theme: theme, onAbout: () {}),
      ),
    );

    Future<void> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app());
      // 마지막 프로젝트를 여는 일(설정 읽기, git worktree list)은 실제 입출력이라,
      // 실제 시간을 흘리고 화면을 다시 그리기를 프로젝트가 열릴 때까지 되풀이한다.
      for (var i = 0; i < 40 && find.byType(BranchDockDock).evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        // 가짜 시계 안에 만들어진 타이머도 돌도록 시간을 함께 흘린다.
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    /// 화면이 시작하면서 띄운 실제 프로세스(PATH 확인, git, dart 분석)가 끝나야 타이머가 남지 않는다.
    Future<void> leave(WidgetTester tester) async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    }

    testWidgets('Git은 오른쪽 자기 탭 줄을 갖고, Run·문제는 아래 패널에 있다', (tester) async {
      await pumpScreen(tester);

      final git = find.byType(BranchDockDock);
      // 저장소를 여는 일(PATH 확인, git)은 실제 입출력이라 안내가 나올 때까지 기다린다.
      final init = find.text('이 폴더를 git 저장소로 만들기');
      for (var i = 0; i < 60 && init.evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 200));
      }
      final bottom = find.byType(BottomPanel);
      expect(git, findsOneWidget);
      expect(bottom, findsOneWidget);

      // Git 패널은 자기 내용(여기서는 저장소가 아닌 폴더의 안내)만 갖고 Run·문제 탭은 없다.
      expect(find.descendant(of: git, matching: find.text('이 폴더를 git 저장소로 만들기')), findsOneWidget);
      expect(find.descendant(of: git, matching: find.text('Run')), findsNothing);
      expect(find.descendant(of: git, matching: find.text('문제')), findsNothing);

      // 아래 패널에는 Run·문제 탭이 있고 Git 탭은 없다.
      expect(find.descendant(of: bottom, matching: find.text('Run')), findsOneWidget);
      expect(find.descendant(of: bottom, matching: find.text('문제')), findsOneWidget);
      expect(find.descendant(of: bottom, matching: find.text('Git')), findsNothing);

      // 위치: Git은 화면 오른쪽 끝, 아래 패널은 Git 패널의 왼쪽(편집기 아래).
      final g = tester.getRect(git);
      final b = tester.getRect(bottom);
      expect(g.right, closeTo(1600, 1));
      expect(b.right, lessThanOrEqualTo(g.left + 1));
      expect(b.top, greaterThan(g.top + 100), reason: '아래 패널은 화면 아래쪽');
      expect(g.height, greaterThan(b.height), reason: 'Git 패널은 전체 높이를 쓴다');
      await leave(tester);
    });

    testWidgets('앱 바의 단추와 Ctrl+Alt+B로 Git Dock을 숨기고 다시 보인다', (tester) async {
      await pumpScreen(tester);
      final dock = find.byType(BranchDockDock);
      expect(tester.getSize(dock).width, PanelLayout.defaultDockWidth);

      await tester.tap(find.byTooltip('Git 패널 숨기기 (Ctrl+Alt+B)'));
      await tester.pump();
      expect(find.byType(BranchDockDock, skipOffstage: true), findsNothing, reason: '숨기면 화면에서 빠진다');
      expect(find.byType(BranchDockDock, skipOffstage: false), findsOneWidget, reason: '상태는 그대로 둔다');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(find.byType(BranchDockDock), findsOneWidget);
      expect(find.byTooltip('Git 패널 숨기기 (Ctrl+Alt+B)'), findsOneWidget);
      await leave(tester);
    });

    /// 접히면 Run·문제 탭 줄만 아래에 남는다 (내용은 없고, 펼치기 단추가 보인다).
    void expectCollapsed(WidgetTester tester) {
      expect(find.byType(BottomPanel), findsOneWidget);
      expect(find.byType(RunPanel), findsNothing);
      expect(tester.getSize(find.byType(BottomPanel)).height, BottomPanel.collapsedHeight);
      expect(find.text('Run'), findsOneWidget);
      expect(find.byTooltip('아래 패널 펼치기 (Ctrl+J)'), findsWidgets);
    }

    testWidgets('Ctrl+J로 아래 패널을 접고 다시 편다', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(BottomPanel), findsOneWidget);

      Future<void> ctrlJ() async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
      }

      await ctrlJ();
      expectCollapsed(tester);
      expect(find.byType(BranchDockDock), findsOneWidget, reason: 'Git 패널은 그대로');

      await ctrlJ();
      expect(find.byType(BottomPanel), findsOneWidget);
      await leave(tester);
    });

    testWidgets('접힌 막대에서 탭을 누르면 그 탭으로 펼쳐진다', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byTooltip('아래 패널 접기 (Ctrl+J)').last);
      await tester.pump();
      expectCollapsed(tester);

      await tester.tap(find.text('Run'));
      await tester.pump();
      expect(find.byType(RunPanel), findsOneWidget);
      expect(tester.getSize(find.byType(BottomPanel)).height, PanelLayout.defaultBottomHeight);
      await leave(tester);
    });

    testWidgets('상태 막대의 접기 단추로 접고 펴며 툴팁이 바뀐다', (tester) async {
      await pumpScreen(tester);
      expect(find.byTooltip('아래 패널 접기 (Ctrl+J)'), findsWidgets);

      await tester.tap(find.byTooltip('아래 패널 접기 (Ctrl+J)').last);
      await tester.pump();
      expectCollapsed(tester);
      expect(find.byTooltip('아래 패널 펼치기 (Ctrl+J)'), findsWidgets);

      await tester.tap(find.byTooltip('아래 패널 펼치기 (Ctrl+J)').first);
      await tester.pump();
      expect(find.byType(BottomPanel), findsOneWidget);
      await leave(tester);
    });

    testWidgets('상태 막대의 문제 개수를 누르면 접혀 있어도 문제 탭이 열린다', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byTooltip('아래 패널 접기 (Ctrl+J)').last);
      await tester.pump();
      expectCollapsed(tester);

      await tester.tap(find.byTooltip('문제 탭 열기'));
      // 분석이 도는 중이라 진행 표시줄이 계속 돌아서 pumpAndSettle은 끝나지 않는다.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BottomPanel), findsOneWidget);
      final tabs = tester.widget<TabBar>(find.descendant(of: find.byType(BottomPanel), matching: find.byType(TabBar)));
      expect(tabs.controller!.index, BottomTab.problems.index);
      await leave(tester);
    });

    testWidgets('구분선을 위로 끌면 아래 패널이 높아지고 범위를 넘지 않는다', (tester) async {
      await pumpScreen(tester);
      final before = tester.getSize(find.byType(BottomPanel)).height;
      expect(before, PanelLayout.defaultBottomHeight);

      final splitter = find.byWidgetPredicate((w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeRow);
      expect(splitter, findsOneWidget);
      await tester.drag(splitter, const Offset(0, -100));
      await tester.pump();
      expect(tester.getSize(find.byType(BottomPanel)).height, closeTo(before + 100, 1));

      await tester.drag(splitter, const Offset(0, -5000));
      await tester.pump();
      expect(tester.getSize(find.byType(BottomPanel)).height, PanelLayout.maxBottomHeight);
      await leave(tester);
    });
  });
}
