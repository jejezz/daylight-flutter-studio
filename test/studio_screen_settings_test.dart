import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/settings/app_settings.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/editor_zoom.dart';
import 'package:daylight_workbench/theme/theme_controller.dart';
import 'package:daylight_workbench/ui/studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StudioScreen이 시작하면서 띄운 실제 프로세스(PATH 확인)가 끝나야 타이머가 남지 않는다.
Future<void> _drainStartup(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
  await tester.pump(const Duration(seconds: 4));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeController theme;
  late EditorZoom zoom;
  late AppSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    theme = ThemeController(settings);
    zoom = EditorZoom();
  });

  tearDown(() {
    theme.dispose();
    zoom.dispose();
  });

  Widget app() => AppSettingsScope(
    settings: settings,
    child: MaterialApp(
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
      home: StudioScreen(theme: theme, onAbout: () {}),
    ),
  );

  testWidgets('앱 바의 설정 단추로 설정이 열리고, 예전 팔레트 단추는 없다', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(
      find.byIcon(Icons.palette_rounded),
      findsNothing,
      reason: '테마 메뉴는 설정으로 옮겼다',
    );
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('밝기'), findsOneWidget);
    await _drainStartup(tester);
  });

  testWidgets('Ctrl+, 로 설정이 열린다', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.comma);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('밝기'), findsOneWidget);
    await _drainStartup(tester);
  });
}
