import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_zoom.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeController theme;
  late EditorZoom zoom;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    theme = ThemeController();
    zoom = EditorZoom();
  });

  tearDown(() {
    theme.dispose();
    zoom.dispose();
  });

  Widget app() => MaterialApp(
    theme: AppTheme.build(StudioPalette.indigo, Brightness.light),
    builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
    home: StudioScreen(theme: theme),
  );

  testWidgets('앱 바의 설정 단추로 설정이 열리고, 예전 팔레트 단추는 없다', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.byIcon(Icons.palette_outlined), findsNothing, reason: '테마 메뉴는 설정으로 옮겼다');
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('밝기'), findsOneWidget);
  });

  testWidgets('Ctrl+, 로 설정이 열린다', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.comma);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('밝기'), findsOneWidget);
  });
}
