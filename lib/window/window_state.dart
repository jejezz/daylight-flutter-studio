import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// 마지막으로 연 창의 크기·위치·최대화 여부를 기억해 다음 실행 때 되살린다.
class WindowStateStore with WindowListener {
  static const _key = 'window_state';

  Timer? _debounce;

  /// 저장된 창 상태. 없거나 깨졌거나, 모니터 구성이 바뀌어 화면 밖으로 나가면 null.
  ///
  /// [bounds]는 저장했을 때 그 모니터의 배율(DPI) 기준 논리 좌표다. window_manager의
  /// Windows 쪽 `setBounds`는 이 좌표에 "지금" 뷰의 배율을 곱해 물리 좌표를 만드는데,
  /// 창을 띄우는 시점엔 아직 주모니터 배율을 쓰고 있어 — 저장된 모니터 배율과 다르면
  /// (예: 주모니터 175%, 보조모니터 100%) 엉뚱한 물리 위치로 밀려난다. 그래서 복원할
  /// 모니터의 배율([displayScale])을 같이 돌려주고, 쓰는 쪽에서 보정하게 한다.
  static Future<({Rect bounds, bool maximized, double displayScale})?> load() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_key)?.split(',');
      if (v == null || v.length != 5) return null;
      final n = [for (final s in v.take(4)) double.parse(s)];
      if (n[2] < 200 || n[3] < 200) return null;
      final bounds = Rect.fromLTWH(n[0], n[1], n[2], n[3]);
      final scale = await _displayScaleFor(bounds);
      if (scale == null) return null;
      return (bounds: bounds, maximized: v[4] == '1', displayScale: scale);
    } on Object {
      return null;
    }
  }

  /// 제목줄(위쪽 가장자리)이 지금 연결된 화면 중 하나에 걸쳐 있으면 그 화면의 배율을,
  /// 걸치는 화면이 없으면(예전에 연결됐던 모니터가 빠짐) null을 돌려준다.
  /// 화면 목록을 못 가져오면 보수적으로 1.0(보정 없음)을 돌려준다.
  static Future<double?> _displayScaleFor(Rect bounds) async {
    try {
      final titleBar = Rect.fromLTWH(bounds.left, bounds.top, bounds.width, 40);
      final displays = await ScreenRetriever.instance.getAllDisplays();
      for (final d in displays) {
        final origin = d.visiblePosition ?? Offset.zero;
        final size = d.visibleSize ?? d.size;
        if (titleBar.overlaps(Rect.fromLTWH(origin.dx, origin.dy, size.width, size.height))) {
          return (d.scaleFactor ?? 1.0).toDouble();
        }
      }
      return null;
    } on Object {
      return 1.0;
    }
  }

  /// 저장된 창 상태를 실제로 적용한다. [load]가 돌려준 모니터 배율과 지금 뷰의 배율이
  /// 다르면 그 차이만큼 위치를 미리 보정해서 넘긴다(위 [load] 설명 참고). 크기는 보정하지
  /// 않는다 — window_manager가 실제 물리 좌표로 옮긴 뒤엔 Windows가 그 모니터의 배율에
  /// 맞게 창 크기를 스스로 다시 맞추고, 보정값을 넣으면 오히려 최소 크기 아래로 떨어져
  /// 클램프될 수 있다.
  static Future<void> restore(({Rect bounds, bool maximized, double displayScale}) saved) async {
    final currentDpr = PlatformDispatcher.instance.views.first.devicePixelRatio;
    final factor = saved.displayScale / currentDpr;
    final b = saved.bounds;
    await windowManager.setBounds(Rect.fromLTWH(b.left * factor, b.top * factor, b.width, b.height));
    if (saved.maximized) await windowManager.maximize();
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
