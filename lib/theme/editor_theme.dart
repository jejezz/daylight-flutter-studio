/// 코드 편집기(re_editor)의 모양. 색은 현재 테마, 글꼴은 [StudioTokens.editorText]에 편집기 배율을 곱한 것이다.
library;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';

import '../settings/editor_settings.dart';
import 'app_theme.dart';
import 'editor_zoom.dart';

/// 편집기 본문 글꼴: 테마의 [StudioTokens.editorText]에 배율을 곱한 것.
TextStyle editorTextStyle(BuildContext context) {
  final settings = EditorSettingsScope.maybeOf(context);
  var base = context.tokens.editorText;
  // 사용자가 고른 글꼴 이름·줄 간격이 테마 기본을 덮는다 (없는 글꼴이면 테마의 대체 글꼴이 이어받는다).
  if (settings?.fontName != null) {
    // 없는 글꼴이면 Menlo가 먼저 이어받는다 (아니면 OS가 Courier 같은 엉뚱한 글꼴을 고른다).
    base = base.copyWith(fontFamily: settings!.fontName, fontFamilyFallback: ['Menlo', ...?base.fontFamilyFallback]);
  }
  if (settings?.lineHeight != null) base = base.copyWith(height: settings!.lineHeight);
  final size = base.fontSize ?? 13;
  // Text 위젯은 주변 글자 모양(M3 본문의 글자 사이 0.25 등)을 물려받지만 편집기는 받지 않는다.
  // 같은 글꼴이 같게 보이도록 물려받을 수 있는 값을 편집기와 같은 값으로 못 박는다.
  return base.copyWith(
    fontSize: size * EditorZoomScope.scaleOf(context),
    letterSpacing: 0,
    wordSpacing: 0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontFeatures: _ligatureFeatures(settings),
  );
}

/// 합자를 끄면 글꼴 기능 `liga`·`clig`·`calt`를 모두 끈다 (코딩용 글꼴은 `calt`로 합자를 만든다). 켜 두면 글꼴 기본대로.
List<FontFeature>? _ligatureFeatures(EditorSettings? settings) => settings != null && !settings.ligatures
    ? const [FontFeature.disable('liga'), FontFeature.disable('clig'), FontFeature.disable('calt')]
    : null;

/// 로그·명령 출력·경로·해시·Markdown 코드의 글꼴. 기본은 테마의 로그 글꼴이고,
/// [EditorSettings.logFollowsEditor]를 켜면 편집기와 같은 글꼴·합자를 쓴다 (크기·줄 간격·색은 호출하는 쪽이 정한다).
TextStyle logTextStyle(BuildContext context) => followEditorFont(context, context.tokens.logText);

/// [EditorSettings.logFollowsEditor]가 켜져 있으면 [base]의 글꼴 계열·합자만 편집기 것으로 바꾼다. 꺼져 있으면 [base] 그대로.
TextStyle followEditorFont(BuildContext context, TextStyle base) {
  final settings = EditorSettingsScope.maybeOf(context);
  if (settings == null || !settings.logFollowsEditor) return base;
  final editor = editorTextStyle(context);
  return base.copyWith(fontFamily: editor.fontFamily, fontFamilyFallback: editor.fontFamilyFallback, fontFeatures: editor.fontFeatures);
}

/// [logTextStyle]를 짧게 쓰는 길 (`context.logText`).
extension LogText on BuildContext {
  TextStyle get logText => logTextStyle(this);
}

/// 줄 번호 글꼴. 현재 줄은 본문 색, 나머지는 흐린 색.
TextStyle editorLineNumberStyle(BuildContext context, {required bool focused}) {
  final scheme = Theme.of(context).colorScheme;
  return editorTextStyle(context).copyWith(color: focused ? scheme.onSurface : scheme.outline);
}

/// [languageId]/[mode]는 구문 강조 규칙이다. 모르는 파일이면 mode가 null이고 색 없이 보여 준다.
CodeEditorStyle buildEditorStyle(BuildContext context, {required String languageId, Mode? mode}) {
  final scheme = Theme.of(context).colorScheme;
  final font = editorTextStyle(context);
  return CodeEditorStyle(
    fontSize: font.fontSize,
    fontFamily: font.fontFamily,
    fontFamilyFallback: font.fontFamilyFallback,
    fontHeight: font.height,
    fontFeatures: font.fontFeatures,
    textColor: scheme.onSurface,
    hintTextColor: scheme.onSurfaceVariant,
    backgroundColor: scheme.surface,
    selectionColor: scheme.primary.withValues(alpha: 0.28),
    cursorColor: scheme.primary,
    cursorLineColor: scheme.primary.withValues(alpha: 0.07),
    chunkIndicatorColor: scheme.onSurfaceVariant,
    codeTheme: mode == null
        ? null
        : CodeHighlightTheme(
            languages: {languageId: CodeHighlightThemeMode(mode: mode)},
            theme: context.syntax.highlightTheme(base: scheme.onSurface),
          ),
  );
}

/// 편집기와 같은 줄 높이 규칙(글자 크기 × 줄 간격, 정확히)을 [Text]에도 적용한다.
/// re_editor는 줄 높이를 이 방식으로 고정하므로, 미리보기·변경점 보기도 같은 strut를 써야 줄 간격이 같다.
StrutStyle editorStrutStyle(BuildContext context) {
  final font = editorTextStyle(context);
  return StrutStyle(fontSize: font.fontSize, fontFamily: font.fontFamily, height: font.height, forceStrutHeight: true);
}
