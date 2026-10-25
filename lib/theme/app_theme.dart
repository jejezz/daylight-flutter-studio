/// 앱의 모든 색·글꼴·크기·모양은 여기서만 정한다.
///
/// 화면 코드(`lib/ui`, `lib/run` 등)는 색 값(`Colors.*`, `Color(0x…)`), `fontSize`, `fontFamily`를
/// 직접 쓰지 않고 `Theme.of(context)`와 [StudioTokens]에서 읽는다 — 그래야 모든 컨트롤이 테마를 따른다.
/// `test/theme_rules_test.dart`가 이 규칙을 검사한다.
library;

import 'package:flutter/material.dart';

/// 고를 수 있는 색 구성 (Material 3 시드 색).
enum StudioPalette {
  indigo(Color(0xFF3F51B5)),
  teal(Color(0xFF00897B)),
  amber(Color(0xFFF59E0B)),
  rose(Color(0xFFE11D48)),
  slate(Color(0xFF475569));

  const StudioPalette(this.seed);

  final Color seed;
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

  static const _monoFallback = ['Consolas', 'Menlo', 'Cascadia Mono', 'monospace'];

  factory StudioTokens.forBrightness(Brightness b) {
    final dark = b == Brightness.dark;
    return StudioTokens(
      success: dark ? const Color(0xFF6FD08C) : const Color(0xFF1B7F3B),
      onSuccess: dark ? const Color(0xFF00210D) : const Color(0xFFFFFFFF),
      warning: dark ? const Color(0xFFF2C14E) : const Color(0xFF8A5A00),
      onWarning: dark ? const Color(0xFF2B1D00) : const Color(0xFFFFFFFF),
      danger: dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
      onDanger: dark ? const Color(0xFF410002) : const Color(0xFFFFFFFF),
      editorText: const TextStyle(fontFamilyFallback: _monoFallback, fontSize: 13, height: 1.45),
      logText: const TextStyle(fontFamilyFallback: _monoFallback, fontSize: 12, height: 1.4),
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
  StudioTokens get tokens => Theme.of(this).extension<StudioTokens>()!;
}

abstract final class AppTheme {
  /// [palette]·[brightness]에 맞는 전체 테마. 컨트롤 모양은 여기서 한곳에 모아 정한다.
  static ThemeData build(StudioPalette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: palette.seed, brightness: brightness);
    final tokens = StudioTokens.forBrightness(brightness);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius));
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, visualDensity: VisualDensity.compact);
    return base.copyWith(
      extensions: [tokens],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
        titleTextStyle: base.textTheme.titleSmall?.copyWith(color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: base.textTheme.labelLarge,
        unselectedLabelStyle: base.textTheme.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radius)),
      ),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainerHigh, shape: shape),
      cardTheme: CardThemeData(color: scheme.surfaceContainerLow, elevation: 0, shape: shape),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: shape),
      tooltipTheme: TooltipThemeData(
        textStyle: base.textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(tokens.radius / 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: shape)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: shape)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: shape)),
      listTileTheme: ListTileThemeData(shape: shape, dense: true),
      scrollbarTheme: const ScrollbarThemeData(thumbVisibility: WidgetStatePropertyAll(false)),
    );
  }
}
