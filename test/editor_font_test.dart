import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/settings/editor_settings.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/editor_theme.dart';
import 'package:daylight_workbench/theme/editor_zoom.dart';
import 'package:daylight_workbench/theme/font_probe.dart';
import 'package:daylight_workbench/theme/font_scan.dart';
import 'package:daylight_workbench/theme/theme_controller.dart';
import 'package:daylight_workbench/ui/settings_dialog.dart';
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
    monospaceFontLoader = () async => ['Fira Code', 'Monaco'];
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

  testWidgets('설정 화면: 글꼴 콤보 상자로 고르고, 줄 간격을 되돌린다', (tester) async {
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

    await tester.tap(find.byType(DropdownMenu<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fira Code').last);
    await tester.pumpAndSettle();
    expect(editor.fontName, 'Fira Code');

    await tester.tap(find.byType(DropdownMenu<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기본').last);
    await tester.pumpAndSettle();
    expect(editor.fontName, isNull);

    await editor.setLineHeight(1.9);
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('기본 줄 간격으로'));
    await tester.tap(find.byTooltip('기본 줄 간격으로'));
    await tester.pump();
    expect(editor.lineHeight, isNull);
  });

  group('합자와 로그 글꼴', () {
    test('기본은 합자 켬·로그 글꼴 따로, 저장하고 다시 읽는다', () async {
      expect(editor.ligatures, isTrue);
      expect(editor.logFollowsEditor, isFalse);
      await editor.setLigatures(false);
      await editor.setLogFollowsEditor(true);
      final again = EditorSettings();
      addTearDown(again.dispose);
      await again.restore();
      expect(again.ligatures, isFalse);
      expect(again.logFollowsEditor, isTrue);
    });

    testWidgets('합자를 끄면 편집기 글자 모양과 편집기 스타일에 글꼴 기능 끄기가 들어간다', (tester) async {
      TextStyle? text;
      CodeEditorStyle? style;
      await tester.pumpWidget(
        app((context) {
          text = editorTextStyle(context);
          style = buildEditorStyle(context, languageId: 'dart');
          return const SizedBox();
        }),
      );
      expect(text!.fontFeatures, isNull, reason: '켜 두면 글꼴 기본대로');
      expect(style!.fontFeatures, isNull);

      await editor.setLigatures(false);
      await tester.pump();
      final tags = [for (final f in text!.fontFeatures!) '${f.feature}=${f.value}'];
      expect(tags, containsAll(['liga=0', 'clig=0', 'calt=0']));
      expect(style!.fontFeatures, text!.fontFeatures);
    });

    testWidgets('로그 글꼴: 기본은 테마의 로그 글꼴, 켜면 편집기 글꼴과 합자 설정을 따른다 (크기는 그대로)', (tester) async {
      late TextStyle log;
      late TextStyle themeLog;
      late TextStyle md;
      late TextStyle themeCode;
      await tester.pumpWidget(
        app((context) {
          log = context.logText;
          themeLog = context.tokens.logText;
          md = followEditorFont(context, context.tokens.editorText);
          themeCode = context.tokens.editorText;
          return const SizedBox();
        }),
      );
      expect(log, themeLog);
      expect(md, themeCode);

      await editor.setFontName('Fira Code');
      await editor.setLigatures(false);
      await tester.pump();
      expect(log, themeLog, reason: '켜기 전에는 편집기 설정이 로그에 번지지 않는다');

      await editor.setLogFollowsEditor(true);
      await tester.pump();
      expect(log.fontFamily, contains('Fira Code'));
      expect(log.fontFeatures, isNotEmpty);
      expect(log.fontSize, themeLog.fontSize, reason: '크기·줄 간격은 로그 것을 그대로 쓴다');
      expect(log.height, themeLog.height);
      expect(md.fontFamily, contains('Fira Code'), reason: 'Markdown 코드도 같다');
      expect(md.fontSize, themeCode.fontSize);
    });

    testWidgets('설정 화면의 스위치가 두 설정을 바꾼다', (tester) async {
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

      await tester.ensureVisible(find.text('합자(ligature) 쓰기'));
      await tester.tap(find.text('합자(ligature) 쓰기'));
      await tester.pump();
      expect(editor.ligatures, isFalse);

      await tester.ensureVisible(find.text('로그·출력 글꼴을 편집기와 같이 쓰기'));
      await tester.tap(find.text('로그·출력 글꼴을 편집기와 같이 쓰기'));
      await tester.pump();
      expect(editor.logFollowsEditor, isTrue);
    });
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

  testWidgets('설치되지 않은 글꼴은 콤보 상자 목록에서 빠지고, 저장된 값이 없으면 안내가 뜬다', (tester) async {
    FontProbe.isInstalled = (family) => family != 'Fira Code';
    monospaceFontLoader = () async => ['Fira Code', 'Monaco'];
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

    final entries = tester.widget<DropdownMenu<String?>>(find.byType(DropdownMenu<String?>)).dropdownMenuEntries;
    expect(entries.map((e) => e.label), isNot(contains('Fira Code')));
    // 폴더에서 읽은 글꼴도 목록에 나온다.
    expect(entries.map((e) => e.label), containsAll(['Menlo', 'Monaco']));

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
