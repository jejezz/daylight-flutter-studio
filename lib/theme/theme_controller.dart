import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// 사용자가 고른 밝기(시스템/라이트/다크)와 색 구성. 저장해 두고 다음 실행에도 쓴다.
class ThemeController extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _paletteKey = 'theme_palette';

  ThemeMode mode = ThemeMode.system;
  StudioPalette palette = StudioPalette.indigo;

  ThemeData get light => AppTheme.build(palette, Brightness.light);
  ThemeData get dark => AppTheme.build(palette, Brightness.dark);

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      mode = ThemeMode.values.asNameMap()[prefs.getString(_modeKey)] ?? mode;
      palette = StudioPalette.values.asNameMap()[prefs.getString(_paletteKey)] ?? palette;
      notifyListeners();
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  Future<void> setMode(ThemeMode value) async {
    mode = value;
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
      (await SharedPreferences.getInstance()).setString(_paletteKey, value.name);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}
