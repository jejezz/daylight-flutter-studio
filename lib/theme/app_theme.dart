/// 앱의 모든 색·글꼴·크기·모양은 여기서만 정한다.
///
/// 화면 코드(`lib/ui`, `lib/run` 등)는 색 값(`Colors.*`, `Color(0x…)`), `fontSize`, `fontFamily`를
/// 직접 쓰지 않고 `Theme.of(context)`와 [StudioTokens]에서 읽는다 — 그래야 모든 컨트롤이 테마를 따른다.
/// `test/theme_rules_test.dart`가 이 규칙을 검사한다.
///
/// 기본 토큰·ColorScheme은 conventions-v1 Saturn 팔레트(common/lib/theme/app_theme.dart)이고,
/// 색 구성([StudioPalette])은 그 위에서 주색(primary)만 바꾼다.
library;

import 'package:flutter/material.dart';

import 'editor_theme.dart';
export 'editor_theme.dart' show LogText, followEditorFont, logTextStyle;
import 'studio_icons.dart';
import 'syntax_theme.dart';

/// 고를 수 있는 색 구성. 기본 [saturn]은 규약 팔레트 그대로이고, [highContrast] 전을 뺀 나머지는 주색만
/// 바꾼다(다크용·라이트용 한 쌍). [highContrast]는 주색만이 아니라 배경·글자·테두리 전부를 최대 대비로
/// 바꾼 완전히 다른 ColorScheme이라 [apply]를 거치지 않고 [_HighContrastTheme]이 따로 만든다.
enum StudioPalette {
  saturn(Color(0xFF4C9DFF), Color(0xFF2C6BE0)),
  teal(Color(0xFF2DD4BF), Color(0xFF0F766E)),
  amber(Color(0xFFFBBF24), Color(0xFFB45309)),
  rose(Color(0xFFFB7185), Color(0xFFBE123C)),
  slate(Color(0xFF94A3B8), Color(0xFF475569)),
  highContrast(Color(0xFFFFD60A), Color(0xFF0000CC));

  const StudioPalette(this.darkPrimary, this.lightPrimary);

  final Color darkPrimary;
  final Color lightPrimary;

  Color primaryFor(Brightness b) => b == Brightness.dark ? darkPrimary : lightPrimary;

  /// 규약 ColorScheme에 이 색 구성의 주색을 입힌다. [saturn]·[highContrast]는 그대로 둔다.
  ColorScheme apply(ColorScheme scheme) {
    if (this == saturn || this == highContrast) return scheme;
    final dark = scheme.brightness == Brightness.dark;
    return scheme.copyWith(
      primary: dark ? darkPrimary : lightPrimary,
      onPrimary: dark ? AppColors.bg : Colors.white,
      inversePrimary: dark ? lightPrimary : darkPrimary,
    );
  }
}

abstract final class AppColors {
  // Dark
  static const bg = Color(0xFF0A0E14);
  static const surface = Color(0xFF151D27);
  static const surfaceHi = Color(0xFF1D2733);
  static const stroke = Color(0x1AFFFFFF);
  static const strokeStrong = Color(0x33FFFFFF);
  static const textHi = Color(0xFFF1F5F9);
  static const textMid = Color(0xFFA9B4C4);
  static const textLow = Color(0xFF6B7787);

  // Light
  static const bgLight = Color(0xFFF4F6FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceHiLight = Color(0xFFE3E8EF);
  static const strokeLight = Color(0x14000000);
  static const strokeStrongLight = Color(0x24000000);
  static const textHiLight = Color(0xFF101828);
  static const textMidLight = Color(0xFF5B6676);
  static const textLowLight = Color(0xFF8A94A6);

  // Brand
  static const primary = Color(0xFF4C9DFF);
  static const primaryDeep = Color(0xFF2C6BE0);
  static const accent = Color(0xFF7C5CFF);

  // Semantics — 아이콘·점·배경용. 흰 배경 위 글자에는 *Text 변형을 쓴다
  // (warning #FFB020은 흰 바탕에서 대비가 부족하다, theming.md §2).
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF5A5F);
  static const successTextLight = Color(0xFF047857);
  static const warningTextLight = Color(0xFFB45309);
  static const dangerTextLight = Color(0xFFC81E24);
}

abstract final class AppRadius {
  static const sheet = 32.0;
  static const card = 24.0;
  static const tile = 20.0;
  static const button = 10.0;
  static const iconChip = 7.0;
  static const chip = 999.0;
}

/// 4의 배수 간격 (ui-ux.md §3).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppFonts {
  static const family = 'SeoulNamsan';

  /// SeoulNamsan에 없는 글자를 OS 한글 글꼴로 넘긴다 (fonts.md §2).
  static const fallback = [
    'Apple SD Gothic Neo',
    'Malgun Gothic',
    'Noto Sans CJK KR',
    'Noto Sans KR',
  ];

  /// 파일 이름·경로 등 앱이 통제하지 않는 문자열 (fonts.md §3).
  static const userContent = TextStyle(fontFamilyFallback: fallback);

  /// 로그, 16진수, 체크섬 (fonts.md §4). 'monospace'는 데스크톱에서 해석되지 않는다.
  static const mono = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: [
      'SF Mono',
      'Consolas',
      'Cascadia Mono',
      'DejaVu Sans Mono',
      'Noto Sans Mono',
      'Courier New',
    ],
  );
}

/// Material 색 구성에 없는 앱 고유 값. 라이트/다크마다 따로 정한다.
@immutable
class StudioTokens extends ThemeExtension<StudioTokens> {
  const StudioTokens({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.icons,
    required this.editorText,
    required this.logText,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.radius,
    required this.splitterWidth,
    required this.treeIndent,
    required this.rowHeight,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;

  /// 지금 아이콘 세트의 의미 이름 아이콘.
  final StudioIcons icons;

  /// 편집기 글꼴, 명령·로그 출력 글꼴.
  final TextStyle editorText;
  final TextStyle logText;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double radius;
  final double splitterWidth;
  final double treeIndent;
  final double rowHeight;

  factory StudioTokens.forBrightness(Brightness b, {StudioIconSet iconSet = StudioIconSet.rounded}) {
    final dark = b == Brightness.dark;
    return StudioTokens(
      success: dark ? const Color(0xFF6FD08C) : const Color(0xFF1B7F3B),
      onSuccess: dark ? const Color(0xFF00210D) : const Color(0xFFFFFFFF),
      warning: dark ? const Color(0xFFF2C14E) : const Color(0xFF8A5A00),
      onWarning: dark ? const Color(0xFF2B1D00) : const Color(0xFFFFFFFF),
      danger: dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
      onDanger: dark ? const Color(0xFF410002) : const Color(0xFFFFFFFF),
      icons: StudioIcons(iconSet),
      editorText: AppFonts.mono.copyWith(fontSize: 13, height: 1.45),
      logText: AppFonts.mono.copyWith(fontSize: 12, height: 1.4),
      spaceXs: 4,
      spaceSm: 8,
      spaceMd: 12,
      spaceLg: 16,
      radius: 8,
      splitterWidth: 6,
      treeIndent: 14,
      rowHeight: 28,
    );
  }

  @override
  StudioTokens copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    StudioIcons? icons,
    TextStyle? editorText,
    TextStyle? logText,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? radius,
    double? splitterWidth,
    double? treeIndent,
    double? rowHeight,
  }) => StudioTokens(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    danger: danger ?? this.danger,
    onDanger: onDanger ?? this.onDanger,
    icons: icons ?? this.icons,
    editorText: editorText ?? this.editorText,
    logText: logText ?? this.logText,
    spaceXs: spaceXs ?? this.spaceXs,
    spaceSm: spaceSm ?? this.spaceSm,
    spaceMd: spaceMd ?? this.spaceMd,
    spaceLg: spaceLg ?? this.spaceLg,
    radius: radius ?? this.radius,
    splitterWidth: splitterWidth ?? this.splitterWidth,
    treeIndent: treeIndent ?? this.treeIndent,
    rowHeight: rowHeight ?? this.rowHeight,
  );

  @override
  StudioTokens lerp(StudioTokens? other, double t) {
    if (other == null) return this;
    return StudioTokens(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      icons: t < 0.5 ? icons : other.icons,
      editorText: TextStyle.lerp(editorText, other.editorText, t)!,
      logText: TextStyle.lerp(logText, other.logText, t)!,
      spaceXs: _d(spaceXs, other.spaceXs, t),
      spaceSm: _d(spaceSm, other.spaceSm, t),
      spaceMd: _d(spaceMd, other.spaceMd, t),
      spaceLg: _d(spaceLg, other.spaceLg, t),
      radius: _d(radius, other.radius, t),
      splitterWidth: _d(splitterWidth, other.splitterWidth, t),
      treeIndent: _d(treeIndent, other.treeIndent, t),
      rowHeight: _d(rowHeight, other.rowHeight, t),
    );
  }

  static double _d(double a, double b, double t) => a + (b - a) * t;
}

/// 고정폭 글자(명령·해시·로그). 글꼴 계열은 테마의 로그 글꼴을 따르고 크기만 호출하는 쪽이 정한다.
extension MonoText on BuildContext {
  TextStyle mono(double size, {Color? color, FontWeight? fontWeight, double? height}) =>
      logTextStyle(this).copyWith(fontSize: size, color: color, fontWeight: fontWeight, height: height);

  /// 파일 이름·브랜치 이름·커밋 제목처럼 앱이 통제하지 않는 글자 (한글 대체 글꼴 포함).
  TextStyle userText(double size, {Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration}) =>
      AppFonts.userContent.copyWith(fontSize: size, color: color, fontWeight: fontWeight, height: height, decoration: decoration);
}

/// 커밋 그래프에서 줄마다 구분하는 색 중, 테마 색(primary·success·warning·danger)이 아닌 둘.
abstract final class GraphPalette {
  static const purple = Color(0xFFB07CFF);
  static const teal = Color(0xFF3CC8C8);
}

extension StudioTheme on BuildContext {
  StudioIcons get icons => tokens.icons;

  StudioTokens get tokens => Theme.of(this).extension<StudioTokens>()!;
  SyntaxTokens get syntax => Theme.of(this).extension<SyntaxTokens>()!;
}

abstract final class _SaturnTheme {
  static ThemeData dark(
    StudioPalette palette, {
    bool dense = true,
    required String uiFontFamily,
    required List<String> uiFontFallback,
    required double uiFontScale,
  }) => _base(
    palette.apply(
      const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textHi,
        onSurfaceVariant: AppColors.textMid,
        surfaceContainerHighest: AppColors.surfaceHi,
        surfaceContainerHigh: AppColors.surfaceHi,
        surfaceContainer: AppColors.surface,
        surfaceContainerLow: AppColors.surface,
        surfaceContainerLowest: AppColors.bg,
        outline: AppColors.strokeStrong,
        outlineVariant: AppColors.stroke,
        inverseSurface: AppColors.textHi,
        onInverseSurface: AppColors.bg,
        inversePrimary: AppColors.primaryDeep,
        shadow: Colors.black,
        scrim: Colors.black,
      ),
    ),
    background: AppColors.bg,
    textLow: AppColors.textLow,
    dense: dense,
    uiFontFamily: uiFontFamily,
    uiFontFallback: uiFontFallback,
    uiFontScale: uiFontScale,
  );

  static ThemeData light(
    StudioPalette palette, {
    bool dense = true,
    required String uiFontFamily,
    required List<String> uiFontFallback,
    required double uiFontScale,
  }) => _base(
    palette.apply(
      const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryDeep,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: AppColors.dangerTextLight,
        onError: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textHiLight,
        onSurfaceVariant: AppColors.textMidLight,
        surfaceContainerHighest: AppColors.surfaceHiLight,
        surfaceContainerHigh: AppColors.surfaceHiLight,
        surfaceContainer: AppColors.surfaceLight,
        surfaceContainerLow: AppColors.surfaceLight,
        surfaceContainerLowest: AppColors.bgLight,
        outline: AppColors.strokeStrongLight,
        outlineVariant: AppColors.strokeLight,
        inverseSurface: AppColors.textHiLight,
        onInverseSurface: AppColors.bgLight,
        inversePrimary: AppColors.primary,
        shadow: Colors.black,
        scrim: Colors.black,
      ),
    ),
    background: AppColors.bgLight,
    textLow: AppColors.textLowLight,
    dense: dense,
    uiFontFamily: uiFontFamily,
    uiFontFallback: uiFontFallback,
    uiFontScale: uiFontScale,
  );

  /// [dense]: 데스크톱 밀도(본문 13)와 모바일 밀도(본문 15), ui-ux.md §4.
  /// [uiFontScale]은 글자 크기에만 곱한다 — 트리 행 높이·탭 높이·도구 막대 등 칸 크기는 그대로 둔다
  /// (`ThemeController.minUiFontScale`~`maxUiFontScale` 안에서는 칸에 넉넉히 들어간다).
  static ThemeData _base(
    ColorScheme scheme, {
    required Color background,
    required Color textLow,
    required bool dense,
    required String uiFontFamily,
    required List<String> uiFontFallback,
    required double uiFontScale,
  }) {
    final hi = scheme.onSurface;
    final mid = scheme.onSurfaceVariant;
    final body = (dense ? 13.0 : 15.0) * uiFontScale;
    final small = (dense ? 11.5 : 13.0) * uiFontScale;
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );
    final buttonSize = Size(0, dense ? 36 : 44);
    final buttonText = TextStyle(
      fontFamily: uiFontFamily,
      fontFamilyFallback: uiFontFallback,
      fontSize: body,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: uiFontFamily,
      fontFamilyFallback: uiFontFallback,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: (dense ? 20 : 34) * uiFontScale,
          fontWeight: FontWeight.w800,
          color: hi,
        ),
        titleLarge: TextStyle(
          fontSize: (dense ? 16 : 20) * uiFontScale,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
        titleMedium: TextStyle(
          fontSize: (dense ? 14 : 17) * uiFontScale,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
        titleSmall: TextStyle(
          fontSize: body,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
        bodyLarge: TextStyle(fontSize: body + 1, color: hi),
        bodyMedium: TextStyle(fontSize: body, color: hi),
        bodySmall: TextStyle(fontSize: small, color: mid),
        labelLarge: TextStyle(
          fontSize: body,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
        labelMedium: TextStyle(
          fontSize: small,
          fontWeight: FontWeight.w500,
          color: mid,
        ),
        labelSmall: TextStyle(fontSize: small - 0.5, color: textLow),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // 앱 바 높이는 앱마다 따로 정하지 않고 여기서만 정한다 (ui-ux.md §4).
        toolbarHeight: dense ? 44 : kToolbarHeight,
        foregroundColor: hi,
        titleTextStyle: TextStyle(
          fontFamily: uiFontFamily,
          fontFamilyFallback: uiFontFallback,
          fontSize: (dense ? 16 : 20) * uiFontScale,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // 데스크톱은 입력칸·드롭다운을 낮게 (ui-ux.md §4 밀도).
        isDense: dense,
        contentPadding: dense ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide.none,
        ),
      ),
      // M3 기본값은 팝업이 배경에 묻힌다 — surfaceHi + 테두리 (daylight).
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      // 창 안 메뉴 막대(Windows·Linux): 앱 바와 같은 바탕에 얹고, 펼친 메뉴는 팝업과 같은 모양.
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              side: BorderSide(color: scheme.outline),
            ),
          ),
        ),
      ),
      // 액션 글자색이 배경과 구분되도록 명시 (dove-zip의 "복사" 버튼 문제).
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          fontFamily: uiFontFamily,
          fontFamilyFallback: uiFontFallback,
          fontSize: body,
          color: hi,
        ),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.tile),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      focusColor: scheme.primary.withValues(alpha: 0.18),
    );
  }
}

/// [StudioPalette.highContrast] 전용 색. 주색은 [StudioPalette.highContrast]의 것을 그대로 쓴다.
abstract final class _HighContrastColors {
  // Dark: 순흑 배경.
  static const dimDark = Color(0xFFBFBFBF);
  static const surfaceHiDark = Color(0xFF262626);
  static const errorDark = Color(0xFFFF6B6B);

  // Light: 순백 배경.
  static const dimLight = Color(0xFF404040);
  static const surfaceHiLight = Color(0xFFE0E0E0);
  static const errorLight = Color(0xFFCC0000);
}

/// 고대비 테마: [_SaturnTheme]처럼 주색만 바꾸는 게 아니라 배경·글자·테두리를 순흑/순백 최대 대비로 바꾼다
/// (Windows 고대비 테마와 같은 생각). 반투명 테두리(`AppColors.stroke` 등)도 꽉 찬 색으로 바꾼다.
abstract final class _HighContrastTheme {
  static ThemeData dark({
    required String uiFontFamily,
    required List<String> uiFontFallback,
    required double uiFontScale,
  }) => _SaturnTheme._base(
    ColorScheme(
      brightness: Brightness.dark,
      primary: StudioPalette.highContrast.darkPrimary,
      onPrimary: Colors.black,
      secondary: StudioPalette.highContrast.darkPrimary,
      onSecondary: Colors.black,
      error: _HighContrastColors.errorDark,
      onError: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      onSurfaceVariant: _HighContrastColors.dimDark,
      surfaceContainerHighest: _HighContrastColors.surfaceHiDark,
      surfaceContainerHigh: _HighContrastColors.surfaceHiDark,
      surfaceContainer: Colors.black,
      surfaceContainerLow: Colors.black,
      surfaceContainerLowest: Colors.black,
      outline: Colors.white,
      outlineVariant: _HighContrastColors.dimDark,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: StudioPalette.highContrast.lightPrimary,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    background: Colors.black,
    textLow: _HighContrastColors.dimDark,
    dense: true,
    uiFontFamily: uiFontFamily,
    uiFontFallback: uiFontFallback,
    uiFontScale: uiFontScale,
  );

  static ThemeData light({
    required String uiFontFamily,
    required List<String> uiFontFallback,
    required double uiFontScale,
  }) => _SaturnTheme._base(
    ColorScheme(
      brightness: Brightness.light,
      primary: StudioPalette.highContrast.lightPrimary,
      onPrimary: Colors.white,
      secondary: StudioPalette.highContrast.lightPrimary,
      onSecondary: Colors.white,
      error: _HighContrastColors.errorLight,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: _HighContrastColors.dimLight,
      surfaceContainerHighest: _HighContrastColors.surfaceHiLight,
      surfaceContainerHigh: _HighContrastColors.surfaceHiLight,
      surfaceContainer: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainerLowest: Colors.white,
      outline: Colors.black,
      outlineVariant: _HighContrastColors.dimLight,
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: StudioPalette.highContrast.darkPrimary,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    background: Colors.white,
    textLow: _HighContrastColors.dimLight,
    dense: true,
    uiFontFamily: uiFontFamily,
    uiFontFallback: uiFontFallback,
    uiFontScale: uiFontScale,
  );
}

abstract final class AppTheme {
  static const defaultUiFontScale = 1.0;
  static const minUiFontScale = 0.85;
  static const maxUiFontScale = 1.25;

  /// [palette]·[brightness]에 맞는 전체 테마. 컨트롤 모양은 여기서 한곳에 모아 정한다.
  /// [uiFontFamily]가 없으면(기본값) 앱 기본 글꼴을 쓴다. [uiFontScale]은 [minUiFontScale]~[maxUiFontScale]로 맞춘다.
  static ThemeData build(
    StudioPalette palette,
    Brightness brightness, {
    StudioIconSet iconSet = StudioIconSet.rounded,
    String? uiFontFamily,
    double uiFontScale = defaultUiFontScale,
  }) {
    final family = uiFontFamily?.trim();
    final resolvedFamily = family == null || family.isEmpty ? AppFonts.family : family;
    // 고른 글꼴에 없는 글리프는 기본 글꼴이, 한글은 OS 한글 글꼴이 채운다.
    final resolvedFallback = resolvedFamily == AppFonts.family ? AppFonts.fallback : [AppFonts.family, ...AppFonts.fallback];
    final scale = uiFontScale.clamp(minUiFontScale, maxUiFontScale);
    final highContrast = palette == StudioPalette.highContrast;
    final saturn = highContrast
        ? (brightness == Brightness.dark
              ? _HighContrastTheme.dark(uiFontFamily: resolvedFamily, uiFontFallback: resolvedFallback, uiFontScale: scale)
              : _HighContrastTheme.light(uiFontFamily: resolvedFamily, uiFontFallback: resolvedFallback, uiFontScale: scale))
        : (brightness == Brightness.dark
              ? _SaturnTheme.dark(palette, uiFontFamily: resolvedFamily, uiFontFallback: resolvedFallback, uiFontScale: scale)
              : _SaturnTheme.light(palette, uiFontFamily: resolvedFamily, uiFontFallback: resolvedFallback, uiFontScale: scale));
    final scheme = saturn.colorScheme;
    final tokens = StudioTokens.forBrightness(brightness, iconSet: iconSet);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
    );
    return saturn.copyWith(
      visualDensity: VisualDensity.compact,
      extensions: [tokens, highContrast ? SyntaxTokens.highContrast(brightness) : SyntaxTokens.forBrightness(brightness)],
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        // 밑줄이 글자 폭이 아니라 탭(칸) 전체 너비로 깔리게 한다.
        indicator: UnderlineTabIndicator(borderSide: BorderSide(width: 2, color: scheme.primary)),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: scheme.outlineVariant,
        labelStyle: saturn.textTheme.labelLarge,
        unselectedLabelStyle: saturn.textTheme.labelLarge,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: saturn.textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(tokens.radius / 2),
        ),
      ),
      // 기본값(colorScheme.primary)은 고대비에서 글자가 선택 배경(secondaryContainer, primary와 같은 색)에
      // 묻혀 버린다 — Chip의 선택된 글자(onSecondaryContainer)와 같은 색 규칙으로 맞춘다.
      listTileTheme: ListTileThemeData(shape: shape, dense: true, selectedColor: scheme.onSecondaryContainer),
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
      ),
    );
  }
}
