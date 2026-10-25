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

import 'studio_icons.dart';
import 'syntax_theme.dart';

/// 고를 수 있는 색 구성. 기본 [saturn]은 규약 팔레트 그대로이고,
/// 나머지는 주색만 바꾼다 (다크용·라이트용 한 쌍).
enum StudioPalette {
  saturn(Color(0xFF4C9DFF), Color(0xFF2C6BE0)),
  teal(Color(0xFF2DD4BF), Color(0xFF0F766E)),
  amber(Color(0xFFFBBF24), Color(0xFFB45309)),
  rose(Color(0xFFFB7185), Color(0xFFBE123C)),
  slate(Color(0xFF94A3B8), Color(0xFF475569));

  const StudioPalette(this.darkPrimary, this.lightPrimary);

  final Color darkPrimary;
  final Color lightPrimary;

  Color primaryFor(Brightness b) => b == Brightness.dark ? darkPrimary : lightPrimary;

  /// 규약 ColorScheme에 이 색 구성의 주색을 입힌다. [saturn]은 그대로 둔다.
  ColorScheme apply(ColorScheme scheme) {
    if (this == saturn) return scheme;
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

extension StudioTheme on BuildContext {
  StudioIcons get icons => tokens.icons;

  StudioTokens get tokens => Theme.of(this).extension<StudioTokens>()!;
  SyntaxTokens get syntax => Theme.of(this).extension<SyntaxTokens>()!;
}

abstract final class _SaturnTheme {
  static ThemeData dark(StudioPalette palette, {bool dense = true}) => _base(
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
  );

  static ThemeData light(StudioPalette palette, {bool dense = true}) => _base(
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
  );

  /// [dense]: 데스크톱 밀도(본문 13)와 모바일 밀도(본문 15), ui-ux.md §4.
  static ThemeData _base(
    ColorScheme scheme, {
    required Color background,
    required Color textLow,
    required bool dense,
  }) {
    final hi = scheme.onSurface;
    final mid = scheme.onSurfaceVariant;
    final body = dense ? 13.0 : 15.0;
    final small = dense ? 11.5 : 13.0;
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );
    final buttonSize = Size(0, dense ? 36 : 44);
    final buttonText = TextStyle(
      fontFamily: AppFonts.family,
      fontSize: body,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFonts.family,
      fontFamilyFallback: AppFonts.fallback,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: dense ? 20 : 34,
          fontWeight: FontWeight.w800,
          color: hi,
        ),
        titleLarge: TextStyle(
          fontSize: dense ? 16 : 20,
          fontWeight: FontWeight.w700,
          color: hi,
        ),
        titleMedium: TextStyle(
          fontSize: dense ? 14 : 17,
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
          fontFamily: AppFonts.family,
          fontSize: dense ? 16 : 20,
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
      // 액션 글자색이 배경과 구분되도록 명시 (dove-zip의 "복사" 버튼 문제).
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.family,
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

abstract final class AppTheme {
  /// [palette]·[brightness]에 맞는 전체 테마. 컨트롤 모양은 여기서 한곳에 모아 정한다.
  static ThemeData build(StudioPalette palette, Brightness brightness, {StudioIconSet iconSet = StudioIconSet.rounded}) {
    final saturn = brightness == Brightness.dark
        ? _SaturnTheme.dark(palette)
        : _SaturnTheme.light(palette);
    final scheme = saturn.colorScheme;
    final tokens = StudioTokens.forBrightness(brightness, iconSet: iconSet);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
    );
    return saturn.copyWith(
      visualDensity: VisualDensity.compact,
      extensions: [tokens, SyntaxTokens.forBrightness(brightness)],
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
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
      listTileTheme: ListTileThemeData(shape: shape, dense: true),
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
      ),
    );
  }
}
