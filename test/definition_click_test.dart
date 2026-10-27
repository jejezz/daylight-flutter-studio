import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/editor_zoom.dart';
import 'package:daylight_workbench/ui/editor_pane.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;
  late StudioController c;
  late EditorZoom zoom;
  var calls = 0;

  Widget app() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
    home: Scaffold(
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) => EditorPane(controller: c, onGoToDefinition: () => calls++),
      ),
    ),
  );

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('def_click');
    c = StudioController();
    zoom = EditorZoom();
    calls = 0;
  });

  tearDown(() async {
    c.dispose();
    zoom.dispose();
    await dir.delete(recursive: true);
  });

  /// 화면을 내리고 플랫폼 덮어쓰기를 푼다 — 테스트가 끝나기 전에 풀어야 한다.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  }

  Future<void> open(WidgetTester tester, String name) async {
    final f = File('${dir.path}${Platform.pathSeparator}$name')..writeAsStringSync('void main() { helper(); }\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(app());
    await tester.pump();
  }

  Future<void> clickEditor(WidgetTester tester) async {
    await tester.tapAt(tester.getTopLeft(find.byType(CodeEditor)) + const Offset(120, 20));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Ctrl+클릭(Dart 글)이면 정의로 이동을 부른다', (tester) async {
    await open(tester, 'a.dart');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await clickEditor(tester);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(calls, 1);
    await finish(tester);
  });

  testWidgets('그냥 클릭하면 부르지 않는다', (tester) async {
    await open(tester, 'a.dart');
    await clickEditor(tester);
    expect(calls, 0);
    await finish(tester);
  });

  testWidgets('Dart가 아닌 글에서는 Ctrl+클릭해도 부르지 않는다', (tester) async {
    await open(tester, 'a.txt');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await clickEditor(tester);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(calls, 0);
    await finish(tester);
  });

  testWidgets('macOS에서는 Ctrl이 아니라 Cmd로 부른다', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    await open(tester, 'a.dart');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await clickEditor(tester);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(calls, 0);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await clickEditor(tester);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    expect(calls, 1);
    await finish(tester);
  });
}
