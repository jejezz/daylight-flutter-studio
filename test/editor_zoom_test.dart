import 'dart:io';

import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_zoom.dart';
import 'package:daylight_flutter_studio/ui/editor_pane.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EditorZoom', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('0.1씩 키우고 줄이며 범위를 넘지 않는다', () {
      final z = EditorZoom();
      addTearDown(z.dispose);
      expect(z.value, 1);
      expect(z.isDefault, isTrue);

      z.zoomIn();
      expect(z.value, 1.1);
      expect(z.percent, 110);
      z.zoomOut();
      z.zoomOut();
      expect(z.value, 0.9);

      for (var i = 0; i < 60; i++) {
        z.zoomIn();
      }
      expect(z.value, EditorZoom.max);
      for (var i = 0; i < 60; i++) {
        z.zoomOut();
      }
      expect(z.value, EditorZoom.min);

      z.reset();
      expect(z.value, 1);
    });

    test('소수 오차가 쌓이지 않는다', () {
      final z = EditorZoom();
      addTearDown(z.dispose);
      for (var i = 0; i < 7; i++) {
        z.zoomIn();
      }
      expect(z.value, 1.7);
      expect(z.percent, 170);
    });

    test('저장하고 다시 읽는다', () async {
      final a = EditorZoom();
      addTearDown(a.dispose);
      a.zoomIn();
      a.zoomIn();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final b = EditorZoom();
      addTearDown(b.dispose);
      await b.restore();
      expect(b.value, 1.2);
    });

    test('바뀌지 않으면 알리지 않는다', () {
      final z = EditorZoom();
      addTearDown(z.dispose);
      var calls = 0;
      z.addListener(() => calls++);
      z.reset();
      expect(calls, 0);
      z.zoomIn();
      expect(calls, 1);
    });
  });

  group('편집기 확대·축소', () {
    late Directory dir;
    late StudioController c;
    late EditorZoom zoom;

    Widget app() => MaterialApp(
      theme: AppTheme.build(StudioPalette.indigo, Brightness.light),
      builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
      home: Scaffold(
        body: ListenableBuilder(
          listenable: c,
          builder: (context, _) => EditorPane(controller: c),
        ),
      ),
    );

    double fontSize(WidgetTester tester) => tester.widget<CodeEditor>(find.byType(CodeEditor)).style!.fontSize!;

    Future<void> unmount(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    }

    Future<void> wheel(WidgetTester tester, double dy) async {
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(tester.getCenter(find.byType(CodeEditor))));
      await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
      await tester.pump();
    }

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      SharedPreferences.setMockInitialValues({});
      dir = await Directory.systemTemp.createTemp('editor_zoom');
      c = StudioController();
      zoom = EditorZoom();
    });

    tearDown(() async {
      c.dispose();
      zoom.dispose();
      await dir.delete(recursive: true);
    });

    Future<void> open(WidgetTester tester, String name, String text) async {
      final f = File('${dir.path}${Platform.pathSeparator}$name')..writeAsStringSync(text);
      await tester.runAsync(() => c.openFile(f.path));
      await tester.pumpWidget(app());
      await tester.pump();
    }

    testWidgets('Ctrl+휠을 올리면 글자가 커지고 내리면 작아진다', (tester) async {
      await open(tester, 'a.dart', 'void main() {}\n');
      final base = fontSize(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await wheel(tester, -40);
      await wheel(tester, -40);
      expect(zoom.value, 1.2);
      expect(fontSize(tester), closeTo(base * 1.2, 0.001));

      await wheel(tester, 40);
      expect(zoom.value, 1.1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await unmount(tester);
    });

    testWidgets('배율을 바꾸는 휠은 화면을 스크롤하지 않는다', (tester) async {
      await open(tester, 'long.dart', List.generate(300, (i) => '// line $i').join('\n'));

      double vertical() {
        final scrollables = tester.stateList<ScrollableState>(find.byType(Scrollable));
        return scrollables.firstWhere((s) => s.axisDirection == AxisDirection.down).position.pixels;
      }

      expect(vertical(), 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await wheel(tester, 120);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(zoom.value, 0.9);
      expect(vertical(), 0, reason: 'Ctrl+휠은 크기만 바꾸고 스크롤은 하지 않는다');

      // 같은 휠이 Ctrl 없이는 실제로 스크롤한다 (위 확인이 의미 있다는 증거).
      await wheel(tester, 120);
      expect(vertical(), greaterThan(0));
      await unmount(tester);
    });

    testWidgets('Ctrl 없이 굴리면 크기가 바뀌지 않는다', (tester) async {
      await open(tester, 'a.dart', 'void main() {}\n');
      await wheel(tester, -40);
      expect(zoom.value, 1);
      await unmount(tester);
    });

    testWidgets('Ctrl+= / Ctrl+- / Ctrl+0 단축키', (tester) async {
      await open(tester, 'a.dart', 'void main() {}\n');
      await tester.tap(find.byType(CodeEditor));
      // 탭 제스처가 만든 짧은 타이머(더블 탭 판정)가 끝나도록 시간을 흘린다.
      await tester.pump(const Duration(milliseconds: 500));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      expect(zoom.value, 1.2);
      await tester.sendKeyEvent(LogicalKeyboardKey.minus);
      expect(zoom.value, 1.1);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      expect(zoom.value, 1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await unmount(tester);
    });

    testWidgets('도구 막대의 비율 단추를 누르면 100%로 돌아간다', (tester) async {
      await open(tester, 'a.dart', 'void main() {}\n');
      zoom.zoomIn();
      zoom.zoomIn();
      await tester.pump();

      expect(find.text('120%'), findsOneWidget);
      await tester.tap(find.text('120%'));
      await tester.pump();
      expect(zoom.value, 1);
      await unmount(tester);
    });

    testWidgets('Markdown 보기에서도 Ctrl+휠로 조절된다', (tester) async {
      await open(tester, 'README.md', '# 제목\n\n본문\n');
      await tester.tap(find.text('보기'));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(tester.getCenter(find.text('본문'))));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -40)));
      await tester.pump();
      expect(zoom.value, 1.1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await unmount(tester);
    });
  });
}
