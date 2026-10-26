import 'dart:io';

import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/studio_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late StudioController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('tabs_drop');
    for (final n in ['a.txt', 'b.txt', 'c.txt', 'd.txt']) {
      File('${dir.path}${Platform.pathSeparator}$n').writeAsStringSync(n);
    }
    Directory('${dir.path}${Platform.pathSeparator}sub').createSync();
    c = StudioController();
  });

  tearDown(() async {
    c.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      await dir.delete(recursive: true);
    } on FileSystemException {
      // 임시 폴더라 남겨 둬도 된다.
    }
  });

  String p(String n) => '${dir.path}${Platform.pathSeparator}$n';

  group('탭 순서 바꾸기', () {
    setUp(() async {
      await c.openProject(dir.path);
      for (final n in ['a.txt', 'b.txt', 'c.txt']) {
        await c.openFile(p(n));
      }
    });

    List<String> names() => c.tabs.map((t) => t.name).toList();

    test('앞으로 옮기고, 보던 탭은 그대로 본다', () {
      c.selectTab(2); // c
      c.moveTab(2, 0);
      expect(names(), ['c.txt', 'a.txt', 'b.txt']);
      expect(c.activeTab?.name, 'c.txt');
    });

    test('다른 탭을 옮겨도 보던 탭이 따라간다', () {
      c.selectTab(0); // a
      c.moveTab(2, 0); // c를 맨 앞으로
      expect(names(), ['c.txt', 'a.txt', 'b.txt']);
      expect(c.activeTab?.name, 'a.txt');
      expect(c.activeIndex, 1);
    });

    test('뒤로 옮길 때는 옮긴 뒤의 자리를 받는다', () {
      c.moveTab(0, 2); // a를 맨 뒤로
      expect(names(), ['b.txt', 'c.txt', 'a.txt']);
    });

    test('같은 자리나 범위 밖은 아무 일도 없다', () {
      var notified = 0;
      c.addListener(() => notified++);
      c.moveTab(1, 1);
      c.moveTab(9, 0);
      expect(names(), ['a.txt', 'b.txt', 'c.txt']);
      expect(notified, 0);
    });

    test('바뀐 순서를 저장하고 다시 시작하면 그대로 돌아온다', () async {
      c.moveTab(2, 0);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final again = StudioController();
      addTearDown(again.dispose);
      await again.restore();
      expect(again.tabs.map((t) => t.name), ['c.txt', 'a.txt', 'b.txt']);
    });
  });

  group('끌어다 놓기', () {
    test('파일을 놓으면 편집기 탭으로 열고 마지막 파일이 활성이다', () async {
      await c.openDropped([p('a.txt'), p('b.txt')]);
      expect(c.tabs.map((t) => t.name), ['a.txt', 'b.txt']);
      expect(c.activeTab?.name, 'b.txt');
    });

    test('이미 열린 파일은 새 탭을 만들지 않고 그 탭으로 간다', () async {
      await c.openDropped([p('a.txt'), p('b.txt')]);
      await c.openDropped([p('a.txt')]);
      expect(c.tabs.length, 2);
      expect(c.activeTab?.name, 'a.txt');
    });

    test('폴더를 놓으면 그 폴더를 프로젝트로 연다', () async {
      await c.openDropped([dir.path]);
      expect(c.root, isNotNull);
      expect(c.root!.toLowerCase(), dir.path.toLowerCase());
      expect(c.tabs, isEmpty);
    });

    test('폴더가 섞여 있으면 폴더만 연다', () async {
      await c.openDropped([p('a.txt'), p('sub')]);
      expect(c.root!.toLowerCase(), p('sub').toLowerCase());
      expect(c.tabs, isEmpty);
    });

    test('없는 경로는 건너뛴다', () async {
      await c.openDropped([p('nope.txt'), p('a.txt')]);
      expect(c.tabs.map((t) => t.name), ['a.txt']);
    });
  });

  test('모두 저장은 고친 탭만 저장한다', () async {
    await c.openProject(dir.path);
    await c.openFile(p('a.txt'));
    await c.openFile(p('b.txt'));
    c.tabs[0].controller.text = 'A edited';
    expect(c.tabs[0].dirty, isTrue);
    expect(await c.saveAll(), isTrue);
    expect(c.tabs[0].dirty, isFalse);
    expect(File(p('a.txt')).readAsStringSync(), 'A edited');
    expect(File(p('b.txt')).readAsStringSync(), 'b.txt');
  });

  group('메뉴', () {
    test('단축키 글자: Windows는 Ctrl+Shift+F, macOS는 기호', () {
      const a = SingleActivator(LogicalKeyboardKey.keyF, control: true, shift: true);
      expect(shortcutLabel(a, mac: false), 'Ctrl+Shift+F');
      const m = SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true);
      expect(shortcutLabel(m, mac: true), '⇧⌘F');
      expect(shortcutLabel(const SingleActivator(LogicalKeyboardKey.comma, control: true), mac: false), 'Ctrl+,');
    });

    test('macOS 변환: 구분선은 그룹 경계가 되고, 편집 단축키는 시스템에 등록하지 않는다', () {
      final menus = toPlatformMenus([
        const MenuSpec('Edit', [
          MenuAction('Undo', shortcut: SingleActivator(LogicalKeyboardKey.keyZ, meta: true), nativeShortcut: false),
          MenuDivider(),
          MenuAction('Find', shortcut: SingleActivator(LogicalKeyboardKey.keyF, meta: true)),
          SubMenu('More', [MenuAction('X')]),
        ]),
      ]);
      expect(menus.single.label, 'Edit');
      final groups = menus.single.menus.cast<PlatformMenuItemGroup>();
      expect(groups.length, 2);
      final undo = groups[0].members.single;
      expect(undo.shortcut, isNull);
      final find = groups[1].members.first;
      expect(find.shortcut, isNotNull);
      expect(groups[1].members.last, isA<PlatformMenu>());
    });

    testWidgets('창 안 메뉴 막대: 파일을 열면 항목과 단축키가 보이고, 항목을 누르면 실행된다', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: StudioMenuBar(
                menus: [
                  MenuSpec('파일', [
                    MenuAction('프로젝트 열기…', onPressed: () => opened++, shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true)),
                    const MenuAction('비활성'),
                  ]),
                  const MenuSpec('편집', []),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('파일'), findsOneWidget);
      expect(find.text('편집'), findsOneWidget);
      expect(find.text('프로젝트 열기…'), findsNothing, reason: '열기 전에는 항목이 안 보인다');

      await tester.tap(find.text('파일'));
      await tester.pumpAndSettle();
      expect(find.text('Ctrl+O'), findsOneWidget);
      await tester.tap(find.text('프로젝트 열기…'));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });
  });
}
