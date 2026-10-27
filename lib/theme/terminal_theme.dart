/// 터미널(xterm2)의 글꼴과 색. 둘 다 현재 테마([StudioTokens], [SyntaxTokens], ColorScheme)에서 읽는다 —
/// 터미널만의 "색 구성표"를 따로 고르지 않는다(PLAN.md "터미널 패널").
library;

import 'package:flutter/material.dart';
import 'package:xterm2/ui.dart' show TerminalStyle, TerminalTheme;

import '../settings/terminal_settings.dart';
import 'app_theme.dart';
import 'editor_theme.dart';

/// 터미널 글자 모양. [TerminalSettings.shareEditorFont]면 지금 편집기에 보이는 글꼴·크기·줄 간격을
/// 그대로 쓴다(사용자가 고른 편집기 글꼴·배율까지 포함).
TerminalStyle terminalStyle(BuildContext context, TerminalSettings settings) {
  if (settings.shareEditorFont) return TerminalStyle.fromTextStyle(editorTextStyle(context));
  final family = settings.fontName;
  return TerminalStyle.fromTextStyle(
    TextStyle(
      fontSize: settings.size,
      fontFamily: family ?? AppFonts.mono.fontFamily,
      // 고른 글꼴에 없는 글리프는 테마의 로그 글꼴(Menlo 등)이, 한글은 OS 한글 글꼴이 채운다.
      fontFamilyFallback: [
        if (family != null) AppFonts.mono.fontFamily!,
        ...AppFonts.mono.fontFamilyFallback!,
        ...AppFonts.fallback,
      ],
    ),
  );
}

/// 터미널 배경·글자·커서·선택 영역·ANSI 16색. 구문 강조 색([SyntaxTokens])을 ANSI 색으로도 재활용해서
/// 같은 테마 안에서는 셸 출력의 색도 편집기와 어울리게 한다.
TerminalTheme terminalColorTheme(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final syntax = context.syntax;
  final t = context.tokens;
  return TerminalTheme(
    cursor: scheme.primary,
    selection: scheme.primary.withValues(alpha: 0.28),
    foreground: scheme.onSurface,
    background: scheme.surface,
    black: scheme.outline,
    red: t.danger,
    green: t.success,
    yellow: t.warning,
    blue: syntax.title,
    magenta: syntax.keyword,
    cyan: syntax.literal,
    white: scheme.onSurface,
    brightBlack: scheme.onSurfaceVariant,
    brightRed: t.danger,
    brightGreen: t.success,
    brightYellow: t.warning,
    brightBlue: syntax.meta,
    brightMagenta: syntax.classType,
    brightCyan: syntax.attr,
    brightWhite: scheme.onSurface,
    searchHitBackground: t.warning.withValues(alpha: 0.55),
    searchHitBackgroundCurrent: t.success.withValues(alpha: 0.65),
    searchHitForeground: scheme.onSurface,
  );
}
