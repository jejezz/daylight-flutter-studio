import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// 마지막으로 연 창의 크기·위치·최대화 여부를 기억해 다음 실행 때 되살린다.
class WindowStateStore with WindowListener {
  static const _key = 'window_state';

  Timer? _debounce;

  /// 저장된 창 상태. 없거나 깨졌으면 null.
  static Future<({Rect bounds, bool maximized})?> load() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_key)?.split(',');
      if (v == null || v.length != 5) return null;
      final n = [for (final s in v.take(4)) double.parse(s)];
      if (n[2] < 200 || n[3] < 200) return null;
      return (bounds: Rect.fromLTWH(n[0], n[1], n[2], n[3]), maximized: v[4] == '1');
    } on Object {
      return null;
    }
  }

  void attach() => windowManager.addListener(this);

  void detach() {
    _debounce?.cancel();
    windowManager.removeListener(this);
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _save);
  }

  Future<void> _save() async {
    try {
      final maximized = await windowManager.isMaximized();
      final prefs = await SharedPreferences.getInstance();
      if (maximized) {
        // 최대화일 때의 크기는 저장하지 않는다 — 복원 크기를 남겨 둔다.
        final old = prefs.getString(_key)?.split(',');
        if (old != null && old.length == 5) {
          await prefs.setString(_key, [...old.take(4), '1'].join(','));
          return;
        }
      }
      final b = await windowManager.getBounds();
      await prefs.setString(_key, '${b.left},${b.top},${b.width},${b.height},${maximized ? 1 : 0}');
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  @override
  void onWindowResized() => _schedule();

  @override
  void onWindowMoved() => _schedule();

  @override
  void onWindowMaximize() => _schedule();

  @override
  void onWindowUnmaximize() => _schedule();
}
