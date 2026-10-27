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
}
