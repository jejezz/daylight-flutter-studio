import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/settings/editor_settings.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_theme.dart';
import 'package:daylight_flutter_studio/theme/editor_zoom.dart';
import 'package:daylight_flutter_studio/theme/font_probe.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

CodeEditorStyle buildEditorStyleForTest(WidgetTester tester) {
  late CodeEditorStyle style;
  final context = tester.element(find.byType(AlertDialog));
  style = buildEditorStyle(context, languageId: 'dart');
  return style;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EditorSettings editor;
  late EditorZoom zoom;
  late ThemeController theme;

  setUp(() {
    // 테스트에서는 모든 글꼴이 같은 글꼴로 그려지므로 설치 여부를 흉내 낸다.
    FontProbe.isInstalled = (family) => family != 'Nonexistent Font';
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

  testWidgets('Text로 그린 편집기 글자는 주변 글자 모양을 물려받지 않아 편집기와 같다', (tester) async {
    await editor.setFontName('Fira Code');
    await tester.pumpWidget(
      app(
        (context) => AlertDialog(
          content: Text('code', style: editorTextStyle(context), strutStyle: editorStrutStyle(context)),
        ),
      ),
    );
    final span = tester.widget<RichText>(find.descendant(of: find.text('code'), matching: find.byType(RichText))).text as TextSpan;
    expect(span.style!.letterSpacing, 0);
    expect(span.style!.fontWeight, FontWeight.w400);
    expect(span.style!.fontFamily, contains('Fira Code'));
    final style = buildEditorStyleForTest(tester);
    expect(style.fontFamily, span.style!.fontFamily);
    expect(style.fontHeight, span.style!.height);
    expect(style.fontSize, span.style!.fontSize);
  });

  testWidgets('설치되지 않은 글꼴은 단추에서 빠지고, 직접 적으면 안내가 뜬다', (tester) async {
    FontProbe.isInstalled = (family) => family != 'Fira Code';
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
    expect(find.widgetWithText(ChoiceChip, 'Fira Code'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Menlo'), findsOneWidget);

    await editor.setFontName('Fira Code');
    await tester.pump();
    expect(find.textContaining('설치되어 있지 않은'), findsOneWidget);
  });

  testWidgets('미리보기는 글꼴 설정 아래에 있고, 글꼴을 바꾸면 따라 바뀐다', (tester) async {
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
    final fontY = tester.getTopLeft(find.text('편집기 글꼴')).dy;
    final lineY = tester.getTopLeft(find.text('줄 간격')).dy;
    final previewY = tester.getTopLeft(find.text('미리보기')).dy;
    expect(previewY, greaterThan(lineY));
    expect(lineY, greaterThan(fontY));

    await editor.setFontName('Consolas');
    await tester.pump();
    final preview = tester.widget<Text>(find.textContaining('Hello, Flutter'));
    expect(preview.style!.fontFamily, 'Consolas');
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
