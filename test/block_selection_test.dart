import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/editor_zoom.dart';
import 'package:daylight_workbench/ui/editor_pane.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;
  late StudioController c;
  late EditorZoom zoom;
  String? clip;

  Widget app() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
    home: Scaffold(
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) => EditorPane(controller: c),
      ),
    ),
  );

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('block_sel');
    c = StudioController();
    zoom = EditorZoom();
    clip = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clip = (call.arguments as Map)['text'] as String?;
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
    c.dispose();
    zoom.dispose();
    await dir.delete(recursive: true);
  });

  Future<void> open(WidgetTester tester) async {
    final f = File('${dir.path}${Platform.pathSeparator}a.txt')..writeAsStringSync('abcdef\nghijkl\nmn\nopqrst\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(app());
    await tester.pump();
  }

  /// 끌기로 인식되도록 여러 걸음으로 움직인다.
  Future<void> drag(WidgetTester tester, Offset from, Offset to) async {
    final g = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
    await tester.pump();
    for (var i = 1; i <= 8; i++) {
      await g.moveTo(Offset.lerp(from, to, i / 8)!);
      await tester.pump(const Duration(milliseconds: 20));
    }
    await g.up();
    await tester.pump();
  }

  CodeLineEditingController controllerOf(WidgetTester tester) => tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!;

  testWidgets('Alt+끌기는 같은 열 범위를 줄마다 고르고 복사한다', (tester) async {
    await open(tester);
    final ctl = controllerOf(tester);
    final origin = tester.getTopLeft(find.byType(CodeEditor));
    final line = ctl.codeLines; // 줄 높이는 화면에서 구한다
    expect(line.length, greaterThan(3));
    // 글자 폭·줄 높이를 모르므로 넉넉히: 첫 줄 앞쪽에서 셋째 줄 뒤쪽까지.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await drag(tester, origin + const Offset(130, 10), origin + const Offset(180, 92));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pump();

    final block = ctl.blockSelection.value;
    expect(block, isNotNull);
    expect(block!.endIndex, greaterThan(block.startIndex));
    expect(block.endColumn, greaterThan(block.startColumn));

    await ctl.copy();
    final lines = clip!.split('\n');
    expect(lines.length, block.endIndex - block.startIndex + 1);
    expect(lines, ['cd', 'ij', '']); // 짧은 줄("mn")은 열 범위를 넘으면 잘려 나온다.
    for (final l in lines) {
      expect(l.length, lessThanOrEqualTo(block.endColumn - block.startColumn));
    }

    // 일반 클릭은 블록을 지운다.
    await tester.tapAt(origin + const Offset(400, 10));
    await tester.pump(const Duration(milliseconds: 100));
    expect(ctl.blockSelection.value, isNull);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Alt 없이 끌면 블록이 생기지 않는다', (tester) async {
    await open(tester);
    final ctl = controllerOf(tester);
    final origin = tester.getTopLeft(find.byType(CodeEditor));
    await drag(tester, origin + const Offset(130, 10), origin + const Offset(180, 50));
    await tester.pump();
    expect(ctl.blockSelection.value, isNull);
    expect(ctl.selection.isCollapsed, isFalse);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  group('블록 편집', () {
    CodeLineEditingController make() {
      final ctl = CodeLineEditingController.fromText('abcdef\nghijkl\nmn\nopqrst');
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 1, extentIndex: 3, extentColumn: 3);
      ctl.selection = const CodeLineSelection.collapsed(index: 3, offset: 3);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 1, extentIndex: 3, extentColumn: 3);
      return ctl;
    }

    test('삭제는 사각형만 지우고 열을 유지한다', () {
      final ctl = make();
      ctl.deleteBackward();
      expect(ctl.text, 'adef\ngjkl\nm\norst');
      expect(ctl.blockSelection.value, isNotNull);
      ctl.undo();
      expect(ctl.text, 'abcdef\nghijkl\nmn\nopqrst');
      ctl.dispose();
    });

    test('잘라내기는 복사한 뒤 지운다', () async {
      final ctl = make();
      ctl.cut();
      expect(ctl.text, 'adef\ngjkl\nm\norst');
      ctl.dispose();
    });

    test('폭 0 블록의 백스페이스는 앞 한 글자를, Delete는 뒤 한 글자를 지운다', () {
      final ctl = CodeLineEditingController.fromText('abc\nabc\nabc');
      ctl.selection = const CodeLineSelection.collapsed(index: 2, offset: 2);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 2, extentIndex: 2, extentColumn: 2);
      ctl.deleteBackward();
      expect(ctl.text, 'ac\nac\nac');
      ctl.deleteForward();
      expect(ctl.text, 'a\na\na');
      ctl.dispose();
    });

    test('붙여넣기는 줄 수가 맞으면 줄마다, 한 줄이면 모든 줄에 넣는다', () async {
      String? clip;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') return {'text': clip};
        return null;
      });
      final ctl = make();
      clip = '1\n2\n3\n4\n';
      ctl.paste();
      await Future<void>.delayed(Duration.zero);
      expect(ctl.text, 'a1def\ng2jkl\nm3\no4rst');
      clip = 'Z';
      final ctl2 = make();
      ctl2.paste();
      await Future<void>.delayed(Duration.zero);
      expect(ctl2.text, 'aZdef\ngZjkl\nmZ\noZrst');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
      ctl.dispose();
      ctl2.dispose();
    });

    test('타이핑은 모든 줄 같은 열에 들어가고 계속 이어진다', () {
      final ctl = make();
      // 커서 줄(opqrst, 열 3)에 X를 친 모양.
      ctl.edit(const TextEditingValue(text: 'opqXrst', selection: TextSelection.collapsed(offset: 4)));
      expect(ctl.text, 'aXdef\ngXjkl\nmX\noXrst');
      expect(ctl.blockSelection.value!.startColumn, 2);
      ctl.edit(const TextEditingValue(text: 'oXYrst', selection: TextSelection.collapsed(offset: 3)));
      expect(ctl.text, 'aXYdef\ngXYjkl\nmXY\noXYrst');
      ctl.dispose();
    });

    test('한글 조합 중에는 모든 줄의 조합 글자가 같이 바뀐다', () {
      TextEditingValue v(String text, int caret, [TextRange composing = TextRange.empty]) =>
        TextEditingValue(text: text, selection: TextSelection.collapsed(offset: caret), composing: composing);
      final ctl = CodeLineEditingController.fromText('abc\nabc\nabc');
      ctl.selection = const CodeLineSelection.collapsed(index: 2, offset: 2);
      ctl.blockSelection.value = const CodeBlockSelection(baseIndex: 0, baseColumn: 2, extentIndex: 2, extentColumn: 2);
      ctl.edit(v('abㅎc', 3, const TextRange(start: 2, end: 3)));
      expect(ctl.text, 'abㅎc\nabㅎc\nabㅎc');
      ctl.edit(v('ab하c', 3, const TextRange(start: 2, end: 3)));
      ctl.edit(v('ab한c', 3, const TextRange(start: 2, end: 3)));
      expect(ctl.text, 'ab한c\nab한c\nab한c');
      expect(ctl.composing, const TextRange(start: 2, end: 3));
      ctl.edit(v('ab한c', 3)); // 확정
      expect(ctl.composing, TextRange.empty);
      ctl.edit(v('ab한ㄱc', 4, const TextRange(start: 3, end: 4)));
      ctl.edit(v('ab한글c', 4, const TextRange(start: 3, end: 4)));
      expect(ctl.text, 'ab한글c\nab한글c\nab한글c');
      expect(ctl.blockSelection.value, isNotNull);
      ctl.dispose();
    });
  });
}
