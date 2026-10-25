/// 코드 편집기(re_editor)의 모양. 색은 현재 테마, 글꼴은 [StudioTokens.editorText]에서 가져온다.
library;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';

import 'app_theme.dart';

/// [languageId]/[mode]는 구문 강조 규칙이다. 모르는 파일이면 mode가 null이고 색 없이 보여 준다.
CodeEditorStyle buildEditorStyle(BuildContext context, {required String languageId, Mode? mode}) {
  final scheme = Theme.of(context).colorScheme;
  final font = context.tokens.editorText;
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
