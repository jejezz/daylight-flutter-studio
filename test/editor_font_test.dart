import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/settings/editor_settings.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_zoom.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EditorSettings editor;
  late EditorZoom zoom;
  late ThemeController theme;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    editor = EditorSettings();
    zoom = EditorZoom();
    theme = ThemeController();
  });

  tearDown(() {
    editor.dispose();
    zoom.dispose();
    theme.dispose();
  });

  Widget app(Widget Function(BuildContext) home) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    builder: (context, child) => EditorSettingsScope(
      settings: editor,
      child: EditorZoomScope(zoom: zoom, child: child!),
    ),
    home: Builder(builder: home),
  );

  testWidgets('편집기 글꼴 이름과 줄 간격이 편집기 글자 모양에 반영된다', (tester) async {
    late TextStyle before;
    late TextStyle after;
    await tester.pumpWidget(
      app((context) {
        final s = editorTextStyle(context);
        if (editor.fontName == null) {
          before = s;
        } else {
          after = s;
        }
        return const SizedBox();
      }),
    );
    expect(before.fontFamily, isNot('Fira Code'));

    await editor.setFontName('Fira Code');
    await editor.setLineHeight(1.8);
    await tester.pump();
    expect(after.fontFamily, contains('Fira Code'));
    expect(after.height, 1.8);
  });

  testWidgets('설정 화면: 글꼴 단추와 입력칸, 줄 간격 되돌리기', (tester) async {
    await tester.pumpWidget(
      app(
        (context) => FilledButton(
          onPressed: () => showSettingsDialog(context, theme: theme, initial: SettingsSection.editor),
          child: const Text('열기'),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fira Code'));
    await tester.tap(find.text('Fira Code'));
    await tester.pump();
    expect(editor.fontName, 'Fira Code');

    await tester.ensureVisible(find.text('기본'));
    await tester.tap(find.text('기본'));
    await tester.pump();
    expect(editor.fontName, isNull);

    await editor.setLineHeight(1.9);
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('기본 줄 간격으로'));
    await tester.tap(find.byTooltip('기본 줄 간격으로'));
    await tester.pump();
    expect(editor.lineHeight, isNull);
  });

  test('글꼴·줄 간격은 저장되고 다시 읽힌다', () async {
    await editor.setFontName('Consolas');
    await editor.setLineHeight(1.7);
    final again = EditorSettings();
    await again.restore();
    expect(again.fontName, 'Consolas');
    expect(again.lineHeight, 1.7);
    again.dispose();
  });
}
