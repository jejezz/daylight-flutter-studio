import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/app_settings.dart';
import 'app_theme.dart';
import 'studio_icons.dart';

/// 사용자가 고른 밝기(시스템/라이트/다크)와 색 구성. 저장해 두고 다음 실행에도 쓴다.
///
/// 밝기는 규약 공통 설정([AppSettings], `theme_mode` 키)에 있고, 색 구성은 이 앱 고유라 여기서 저장한다.
/// [settings] 없이 만들면(테스트) 밝기도 이 객체가 직접 들고 있다.
class ThemeController extends ChangeNotifier {
  ThemeController([this.settings]) {
    settings?.addListener(notifyListeners);
  }

  static const _modeKey = AppSettings.themeModeKey;
  static const _paletteKey = 'theme_palette';
  static const _iconSetKey = 'theme_icon_set';
  static const _uiFontFamilyKey = 'theme_ui_font_family';
  static const _uiFontScaleKey = 'theme_ui_font_scale';

  /// 설정 화면에서 한 번에 고를 수 있는 UI 글꼴 이름(고정폭이 아닌, OS에 흔한 것들).
  static const presetUiFonts = ['Segoe UI', 'SF Pro Text', 'Helvetica Neue', 'Roboto', 'Noto Sans KR', 'Pretendard'];

  final AppSettings? settings;
  ThemeMode _mode = ThemeMode.system;
  StudioPalette palette = StudioPalette.saturn;
  StudioIconSet iconSet = StudioIconSet.rounded;

  /// null이면 앱 기본 UI 글꼴(SeoulNamsan)을 쓴다.
  String? uiFontFamily;
  double uiFontScale = AppTheme.defaultUiFontScale;

  ThemeMode get mode => settings?.themeMode ?? _mode;

  ThemeData get light => AppTheme.build(palette, Brightness.light, iconSet: iconSet, uiFontFamily: uiFontFamily, uiFontScale: uiFontScale);
  ThemeData get dark => AppTheme.build(palette, Brightness.dark, iconSet: iconSet, uiFontFamily: uiFontFamily, uiFontScale: uiFontScale);

  @override
  void dispose() {
    settings?.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings == null) {
        _mode =
            ThemeMode.values.asNameMap()[prefs.getString(_modeKey)] ?? _mode;
      }
      palette =
          StudioPalette.values.asNameMap()[prefs.getString(_paletteKey)] ??
          palette;
      iconSet =
          StudioIconSet.values.asNameMap()[prefs.getString(_iconSetKey)] ??
          iconSet;
      uiFontFamily = prefs.getString(_uiFontFamilyKey) ?? uiFontFamily;
      final scale = prefs.getDouble(_uiFontScaleKey);
      if (scale != null) uiFontScale = scale.clamp(AppTheme.minUiFontScale, AppTheme.maxUiFontScale);
      notifyListeners();
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  Future<void> setMode(ThemeMode value) async {
    if (settings != null) return settings!.setThemeMode(value);
    _mode = value;
    notifyListeners();
    try {
      (await SharedPreferences.getInstance()).setString(_modeKey, value.name);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  Future<void> setPalette(StudioPalette value) async {
    palette = value;
    notifyListeners();
    try {
      (await SharedPreferences.getInstance()).setString(
        _paletteKey,
        value.name,
      );
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  Future<void> setIconSet(StudioIconSet value) async {
    iconSet = value;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(_iconSetKey, value.name);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  /// null(또는 빈 문자열)이면 앱 기본 글꼴로 되돌린다.
  Future<void> setUiFontFamily(String? value) async {
    final next = (value == null || value.trim().isEmpty) ? null : value.trim();
    if (next == uiFontFamily) return;
    uiFontFamily = next;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (next == null) {
        await prefs.remove(_uiFontFamilyKey);
      } else {
        await prefs.setString(_uiFontFamilyKey, next);
      }
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  Future<void> setUiFontScale(double value) async {
    final next = value.clamp(AppTheme.minUiFontScale, AppTheme.maxUiFontScale);
    if (next == uiFontScale) return;
    uiFontScale = next;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setDouble(_uiFontScaleKey, next);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}
