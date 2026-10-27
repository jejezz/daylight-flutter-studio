import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/settings/editor_settings.dart';
import 'package:daylight_workbench/studio/dart_chunk_analyzer.dart';
import 'package:daylight_workbench/studio/fold_plan.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/editor_pane.dart';
import 'package:daylight_workbench/ui/markdown_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dart = '''
class A {
  void a() {
    print(1);
  }

  void b() {
    if (true) {
      print(2);
    }
  }
}
''';

Widget _app(StudioController c, {Brightness brightness = Brightness.light}) => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ko'), 
  theme: AppTheme.build(StudioPalette.saturn, brightness),
  home: Scaffold(
    body: ListenableBuilder(
      listenable: c,
      builder: (context, _) => EditorPane(controller: c),
    ),
  ),
);

/// 편집기는 커서 깜빡임 타이머를 쓴다 — 트리를 내려야 타이머가 정리된다.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  late Directory dir;
  late StudioController c;

  setUp(() async {
    // 테스트의 기본 플랫폼은 Android다 — 편집기가 모바일용 지연 타이머를 만들지 않게 데스크톱으로 맞춘다.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('editor_pane');
    c = StudioController();
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  File write(String name, String text) => File('${dir.path}${Platform.pathSeparator}$name')..writeAsStringSync(text);

  testWidgets('편집 메뉴의 찾기·바꾸기는 편집기에 포커스가 없어도 찾기 줄을 연다', (tester) async {
    final f = write('a.txt', 'hello\nworld\n');
    await tester.runAsync(() => c.openFile(f.path));
    final outside = FocusNode();
    addTearDown(outside.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              // 메뉴 항목을 누른 직후처럼 포커스가 편집기 밖에 있다.
              TextField(focusNode: outside),
              Expanded(
                child: ListenableBuilder(listenable: c, builder: (context, _) => EditorPane(controller: c)),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    outside.requestFocus();
    await tester.pump();
    expect(c.activeTab!.find.value, isNull); // 찾기 줄이 닫혀 있다

    c.activeTab!.find.findMode(); // 편집 메뉴 > 찾기
    await tester.pump();
    expect(c.activeTab!.find.value, isNotNull);
    expect(find.byType(EditableText), findsNWidgets(2)); // 본문 + 찾을 글
    expect(find.text('바꿀 내용'), findsNothing);

    c.activeTab!.find.replaceMode(); // 편집 메뉴 > 바꾸기
    await tester.pump();
    expect(find.text('바꿀 내용'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('편집기에서 Ctrl+R은 바꾸기를, Ctrl+F는 찾기를 연다', (tester) async {
    final f = write('a.txt', 'hello\nworld\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();
    await tester.tap(find.byType(CodeEditor)); // 편집기에 포커스를 둔다
    await tester.pump(const Duration(seconds: 1)); // 탭 감지 타이머를 흘려 보낸다
    await tester.pump();

    Future<void> ctrl(LogicalKeyboardKey key) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
    }

    final finder = c.activeTab!.find;
    await ctrl(LogicalKeyboardKey.keyF);
    expect(finder.value, isNotNull);
    expect(finder.value!.replaceMode, isFalse);

    finder.close();
    await tester.pump();
    await ctrl(LogicalKeyboardKey.keyR);
    expect(finder.value, isNotNull);
    expect(finder.value!.replaceMode, isTrue);

    finder.close();
    await tester.pump();
    await ctrl(LogicalKeyboardKey.keyH); // 예전 단축키는 더 이상 바꾸기가 아니다
    expect(finder.value, isNull);
    await _unmount(tester);
  });

  testWidgets('편집기에서 Ctrl+S는 수정한 글을 파일에 저장한다', (tester) async {
    final f = write('a.txt', 'hello\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(seconds: 1));
    c.activeTab!.controller.text = 'changed\n';
    await tester.pump();
    expect(c.activeTab!.dirty, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    // 저장은 실제 파일 입출력이라 진짜 시계로 기다리며 pump로 뒷일을 흘려 보낸다.
    for (var i = 0; i < 100 && c.activeTab!.dirty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }

    expect(f.readAsStringSync(), 'changed\n');
    expect(c.activeTab!.dirty, isFalse);
    await _unmount(tester);
  });

  for (final alreadyOpen in [false, true]) {
    testWidgets('문제 위치로 이동하면 그 줄이 보이게 스크롤하고 편집기에 포커스를 준다 (${alreadyOpen ? '열려 있던 파일' : '새로 여는 파일'})', (tester) async {
      final f = write('long.txt', [for (var i = 1; i <= 300; i++) 'line $i'].join('\n'));
      final outside = FocusNode();
      addTearDown(outside.dispose);
      if (alreadyOpen) await tester.runAsync(() => c.openFile(f.path));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: outside), // 문제 목록을 눌렀을 때처럼 포커스가 편집기 밖에 있다
                Expanded(child: ListenableBuilder(listenable: c, builder: (context, _) => EditorPane(controller: c))),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      outside.requestFocus();
      await tester.pump();

      await tester.runAsync(() => c.openAt(f.path, 250, 3));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final vertical = [
        for (final e in find.byType(Scrollable).evaluate()) ((e as StatefulElement).state as ScrollableState).position,
      ].firstWhere((p) => p.axis == Axis.vertical);
      expect(vertical.pixels, greaterThan(0), reason: '250번째 줄이 보이도록 스크롤했다');
      expect(c.activeTab!.focusNode.hasFocus, isTrue, reason: '커서가 보이게 편집기로 포커스를 옮긴다');
      expect(c.activeTab!.controller.selection.extentIndex, 249);
      await _unmount(tester);
    });
  }

  testWidgets('합자를 끄면 편집기 본문 글자 모양까지 글꼴 기능 끄기가 전해진다 (고친 re_editor)', (tester) async {
    final f = write('a.txt', 'a != b -> c${String.fromCharCode(10)}');
    await tester.runAsync(() => c.openFile(f.path));
    final settings = EditorSettings();
    addTearDown(settings.dispose);
    await settings.setLigatures(false);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        home: Scaffold(
          body: EditorSettingsScope(
            settings: settings,
            child: ListenableBuilder(listenable: c, builder: (context, _) => EditorPane(controller: c)),
          ),
        ),
      ),
    );
    await tester.pump();

    // re_editor가 안에서 만드는 본문 글자 모양 (비공개 위젯의 공개 필드).
    final editable = tester.widget(find.byWidgetPredicate((w) => w.runtimeType.toString() == '_CodeEditable'));
    final style = (editable as dynamic).textStyle as TextStyle;
    expect([for (final f in style.fontFeatures!) f.feature], containsAll(['liga', 'clig', 'calt']));
    await _unmount(tester);
  });

  testWidgets('Dart 파일을 열면 편집기와 정렬 단추가 보이고, 줄 끝(CRLF)을 유지한다', (tester) async {
    final f = write('a.dart', _dart.replaceAll('\n', '\r\n'));
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(find.byTooltip('정렬 (Ctrl+Alt+L)'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(c.activeTab!.dirty, isFalse);
    expect(c.activeTab!.controller.text.contains('\r\n'), isTrue);

    await tester.runAsync(() => c.save(c.activeTab!));
    expect(f.readAsStringSync().contains('\r\n'), isTrue, reason: '저장해도 CRLF가 LF로 바뀌면 안 된다');
    await _unmount(tester);
  });

  testWidgets('모두 접기 → 모두 펴기', (tester) async {
    final f = write('a.dart', _dart);
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    // 접기 구간은 별도 isolate에서 계산된다.
    final tab = c.activeTab!;
    expect(tab.chunks, isNotNull);
    // 접기 구간은 편집기가 별도 isolate에서 계산한다 — 테스트에서는 같은 분석기를 직접 돌려 넣는다.
    tab.chunks!.value = const DartChunkAnalyzer().run(tab.controller.codeLines);
    expect(tab.chunks!.value, isNotEmpty);

    foldAll(tab.chunks);
    await tester.pump();
    final folded = [for (var i = 0; i < tab.controller.codeLines.length; i++) tab.controller.codeLines[i]].where((l) => l.chunkParent);
    expect(folded.length, 2, reason: 'a(), b() 몸통 두 개가 접힌다');

    unfoldAll(tab.controller, tab.chunks);
    await tester.pump();
    expect([for (var i = 0; i < tab.controller.codeLines.length; i++) tab.controller.codeLines[i]].any((l) => l.chunkParent), isFalse);
    await _unmount(tester);
  });

  testWidgets('Markdown은 편집과 보기를 전환한다', (tester) async {
    final f = write('README.md', '# 제목\n\n본문 **굵게**\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(find.byType(MarkdownView), findsNothing);
    expect(find.byTooltip('정렬 (Ctrl+Alt+L)'), findsNothing);

    await tester.tap(find.text('보기'));
    await tester.pump();
    expect(find.byType(MarkdownView), findsOneWidget);
    expect(find.byType(CodeEditor), findsNothing);
    expect(find.text('제목'), findsOneWidget);

    await tester.tap(find.text('편집'));
    await tester.pump();
    expect(find.byType(CodeEditor), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('수정 중에 디스크가 바뀌면 배너가 뜨고, 다시 읽기로 디스크 글을 가져온다', (tester) async {
    final f = write('a.dart', _dart);
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();

    final tab = c.activeTab!;
    tab.controller.text = '// my edit\n';
    f.writeAsStringSync('// claude edit\n');
    f.setLastModifiedSync(DateTime.now().add(const Duration(seconds: 5)));
    await tester.runAsync(c.checkExternalChanges);
    await tester.pump();

    expect(find.textContaining('디스크의 파일이 바뀌었습니다'), findsOneWidget);
    expect(tab.controller.text, '// my edit\n');

    expect(find.textContaining('다시 읽기'), findsOneWidget);
    expect(find.text('내 수정 유지'), findsOneWidget);
    // 단추가 부르는 동작을 실제 입출력과 함께 돌린다 (가짜 시계 안에서는 파일 읽기가 끝나지 않는다).
    await tester.runAsync(() => c.reloadFromDisk(tab));
    await tester.pump();

    expect(find.textContaining('디스크의 파일이 바뀌었습니다'), findsNothing);
    expect(tab.controller.text, '// claude edit\n');
    await _unmount(tester);
  });

  testWidgets('다크 테마에서도 편집기가 그려진다', (tester) async {
    final f = write('a.dart', _dart);
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c, brightness: Brightness.dark));
    await tester.pump();
    expect(find.byType(CodeEditor), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  testWidgets('탭을 끌어서 순서를 바꾼다', (tester) async {
    final files = [write('a.txt', 'a'), write('b.txt', 'b'), write('c.txt', 'c')];
    await tester.runAsync(() async {
      for (final f in files) {
        await c.openFile(f.path);
      }
    });
    await tester.pumpWidget(_app(c));
    await tester.pump();
    expect(c.tabs.map((t) => t.name), ['a.txt', 'b.txt', 'c.txt']);
    expect(find.byIcon(Icons.drag_handle), findsNothing, reason: '탭 글자 위에 끌기 손잡이를 그리지 않는다');

    // c 탭을 잡아 a 탭 앞까지 끈다.
    final from = tester.getCenter(find.text('c.txt'));
    final to = tester.getCenter(find.text('a.txt')) - const Offset(160, 0);
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(to, timeStamp: const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(c.tabs.map((t) => t.name), ['c.txt', 'a.txt', 'b.txt']);
    expect(c.activeTab?.name, 'c.txt', reason: '보던 탭은 그대로');
    await _unmount(tester);
  });
}
