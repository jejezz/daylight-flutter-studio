/// 코드 편집기(re_editor)의 모양. 색은 현재 테마, 글꼴은 [StudioTokens.editorText]에 편집기 배율을 곱한 것이다.
library;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';

import 'app_theme.dart';
import 'editor_zoom.dart';

/// 편집기 본문 글꼴: 테마의 [StudioTokens.editorText]에 배율을 곱한 것.
TextStyle editorTextStyle(BuildContext context) {
  final base = context.tokens.editorText;
  final size = base.fontSize ?? 13;
  return base.copyWith(fontSize: size * EditorZoomScope.scaleOf(context));
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
