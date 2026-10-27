/// 터미널 패널의 글꼴·스크롤백 설정. 색은 설정 없이 늘 현재 테마를 따른다(lib/theme/terminal_theme.dart).
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerminalSettings extends ChangeNotifier {
  static const defaultScrollback = 10000;
  static const minScrollback = 500;
  static const maxScrollback = 100000;

  static const minSize = 9.0;
  static const maxSize = 24.0;
  static const defaultSize = 13.0;

  static const _shareEditorFontKey = 'terminal_share_editor_font';
  static const _fontNameKey = 'terminal_font_family';
  static const _sizeKey = 'terminal_font_size';
  static const _scrollbackKey = 'terminal_scrollback';

  bool _shareEditorFont = true;
  String? _fontName;
  double _size = defaultSize;
  int _scrollback = defaultScrollback;

  /// 편집기와 같은 글꼴(이름·줄 간격)을 쓴다. 꺼지면 [fontName]·[size]를 따로 쓴다.
  bool get shareEditorFont => _shareEditorFont;
  String? get fontName => _fontName;
  double get size => _size;
  int get scrollback => _scrollback;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _shareEditorFont = prefs.getBool(_shareEditorFontKey) ?? _shareEditorFont;
      _fontName = prefs.getString(_fontNameKey) ?? _fontName;
      _size = (prefs.getDouble(_sizeKey) ?? _size).clamp(minSize, maxSize);
      _scrollback = (prefs.getInt(_scrollbackKey) ?? _scrollback).clamp(minScrollback, maxScrollback);
      notifyListeners();
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다 — 기본값을 쓴다.
    }
  }

  Future<void> setShareEditorFont(bool value) async {
    if (value == _shareEditorFont) return;
    _shareEditorFont = value;
    notifyListeners();
    await _store((p) => p.setBool(_shareEditorFontKey, value));
  }

  Future<void> setFontName(String? value) async {
    final next = (value == null || value.trim().isEmpty) ? null : value.trim();
    if (next == _fontName) return;
    _fontName = next;
    notifyListeners();
    await _store((p) => next == null ? p.remove(_fontNameKey) : p.setString(_fontNameKey, next));
  }

  Future<void> setSize(double value) async {
    final v = value.clamp(minSize, maxSize);
    if (v == _size) return;
    _size = v;
    notifyListeners();
    await _store((p) => p.setDouble(_sizeKey, v));
  }

  Future<void> setScrollback(int value) async {
    final v = value.clamp(minScrollback, maxScrollback);
    if (v == _scrollback) return;
    _scrollback = v;
    notifyListeners();
    await _store((p) => p.setInt(_scrollbackKey, v));
  }

  Future<void> _store(Future<bool> Function(SharedPreferences) write) async {
    try {
      await write(await SharedPreferences.getInstance());
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}
