import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/editor_zoom.dart';
import 'package:daylight_workbench/theme/font_probe.dart';
import 'package:daylight_workbench/theme/font_scan.dart';
import 'package:daylight_workbench/theme/theme_controller.dart';
import 'package:daylight_workbench/ui/settings_dialog.dart';
import 'package:flutter/material.dart';
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
    // 실제 설치된 글꼴을 다 훑으면(특히 UI 글꼴) 목록이 길어져 선택한 항목이 화면 밖으로 밀려날 수 있다
    // — 테스트에서는 작은 목록으로 고정한다.
    FontProbe.isInstalled = (family) => true;
    proportionalFontLoader = () async => ['Segoe UI'];
  });

  tearDown(() {
    theme.dispose();
    zoom.dispose();
  });

  /// 앱과 같은 구조: 배율 범위를 MaterialApp.builder로 감싸고, 단추를 눌러 설정을 연다.
  Widget app({SettingsSection initial = SettingsSection.appearance}) =>
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        builder: (context, child) => EditorZoomScope(zoom: zoom, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    showSettingsDialog(context, theme: theme, initial: initial),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      );

  Future<void> open(
    WidgetTester tester, {
    SettingsSection initial = SettingsSection.appearance,
  }) async {
    await tester.pumpWidget(app(initial: initial));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
  }

  testWidgets('왼쪽 목록에 구역이 있고 외형이 먼저 열린다', (tester) async {
    await open(tester);
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('외형'), findsOneWidget);
    expect(find.text('편집기'), findsOneWidget);
    expect(find.text('밝기'), findsOneWidget);
    expect(find.text('색 구성'), findsOneWidget);
  });

  testWidgets('밝기를 고르면 바로 적용된다', (tester) async {
    await open(tester);
    expect(theme.mode, ThemeMode.system);

    await tester.tap(find.text('다크'));
    await tester.pump();
    expect(theme.mode, ThemeMode.dark);

    await tester.tap(find.text('라이트'));
    await tester.pump();
    expect(theme.mode, ThemeMode.light);
  });

  testWidgets('색 구성을 고르면 바로 적용된다', (tester) async {
    await open(tester);
    expect(theme.palette, StudioPalette.saturn);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '청록'));
    await tester.tap(find.widgetWithText(ChoiceChip, '청록'));
    await tester.pump();
    expect(theme.palette, StudioPalette.teal);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '장미'));
    await tester.tap(find.widgetWithText(ChoiceChip, '장미'));
    await tester.pump();
    expect(theme.palette, StudioPalette.rose);
  });

  testWidgets('색 구성에서 고대비를 고르면 바로 적용된다', (tester) async {
    await open(tester);
    expect(theme.palette, StudioPalette.saturn);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '고대비'));
    await tester.tap(find.widgetWithText(ChoiceChip, '고대비'));
    await tester.pump();
    expect(theme.palette, StudioPalette.highContrast);
  });

  testWidgets('UI 글꼴을 고르면 바로 적용되고, 기본으로 되돌릴 수 있다', (tester) async {
    await open(tester);
    expect(theme.uiFontFamily, isNull);

    final dropdown = find.byType(DropdownMenu<String?>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segoe UI').last);
    await tester.pumpAndSettle();
    expect(theme.uiFontFamily, 'Segoe UI');

    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('기본').last);
    await tester.pumpAndSettle();
    expect(theme.uiFontFamily, isNull);
  });

  testWidgets('UI 글꼴 배율 슬라이더로 바꾸고 100%로 되돌린다', (tester) async {
    await open(tester);
    expect(theme.uiFontScale, 1.0);

    final sliders = find.byType(Slider);
    await tester.ensureVisible(sliders);
    await tester.tapAt(tester.getTopRight(sliders) + const Offset(-4, 24));
    await tester.pump();
    expect(theme.uiFontScale, greaterThan(1.0));

    await tester.ensureVisible(find.byTooltip('100%로'));
    await tester.tap(find.byTooltip('100%로'));
    await tester.pump();
    expect(theme.uiFontScale, 1.0);
  });

  testWidgets('편집기 구역: 슬라이더로 글자 크기를 바꾸고 100%로 되돌린다', (tester) async {
    await open(tester);
    await tester.tap(find.text('편집기'));
    await tester.pump();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('글자 크기'), findsOneWidget);

    // 슬라이더 오른쪽 끝을 눌러 최대로 만든다.
    final slider = find.byType(Slider);
    await tester.tapAt(tester.getTopRight(slider) + const Offset(-4, 24));
    await tester.pump();
    expect(zoom.value, greaterThan(2.5));
    expect(find.text('${zoom.percent}%'), findsOneWidget);

    await tester.tap(find.byTooltip('100%로'));
    await tester.pump();
    expect(zoom.value, 1);
  });

  testWidgets('설정 밖에서 바뀐 글자 크기(Ctrl+스크롤 등)도 슬라이더에 반영된다', (tester) async {
    await open(tester, initial: SettingsSection.editor);
    zoom.zoomIn();
    zoom.zoomIn();
    await tester.pump();
    expect(find.text('120%'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 1.2);
  });

  testWidgets('닫기 단추로 닫힌다', (tester) async {
    await open(tester);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('설정'), findsNothing);
  });
}
