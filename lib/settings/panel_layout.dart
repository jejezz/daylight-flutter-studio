/// 화면 배치 상태: 아래 패널(Run·문제)의 열림 여부·높이·선택된 탭, 오른쪽 Git Dock의 열림 여부·너비. 저장해서 다음 실행에도 유지한다.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 아래 패널의 탭.
enum BottomTab { run, problems, terminal }

class PanelLayout extends ChangeNotifier {
  static const defaultBottomHeight = 280.0;
  static const minBottomHeight = 120.0;
  static const maxBottomHeight = 700.0;

  /// Git Dock의 너비. 이보다 좁으면 Fetch·Pull·Push 단추와 탭이 찌그러져서 아래로 못 줄인다.
  static const minDockWidth = 380.0;
  static const defaultDockWidth = 420.0;
  static const maxDockWidth = 700.0;

  static const _dockOpenKey = 'layout_dock_open';
  static const _dockWidthKey = 'layout_dock_width';
  static const _openKey = 'layout_bottom_open';
  static const _heightKey = 'layout_bottom_height';
  static const _tabKey = 'layout_bottom_tab';

  bool _bottomOpen = true;
  double _bottomHeight = defaultBottomHeight;
  BottomTab _bottomTab = BottomTab.run;
  bool _dockOpen = true;
  double _dockWidth = defaultDockWidth;

  bool get bottomOpen => _bottomOpen;
  double get bottomHeight => _bottomHeight;
  BottomTab get bottomTab => _bottomTab;
  bool get dockOpen => _dockOpen;
  double get dockWidth => _dockWidth;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bottomOpen = prefs.getBool(_openKey) ?? _bottomOpen;
      final h = prefs.getDouble(_heightKey);
      if (h != null) _bottomHeight = _clamp(h);
      _bottomTab = BottomTab.values.asNameMap()[prefs.getString(_tabKey)] ?? _bottomTab;
      _dockOpen = prefs.getBool(_dockOpenKey) ?? _dockOpen;
      final w = prefs.getDouble(_dockWidthKey);
      if (w != null) _dockWidth = _clampDock(w);
      notifyListeners();
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다 — 기본 배치를 쓴다.
    }
  }

  static double _clamp(double h) => h.clamp(minBottomHeight, maxBottomHeight);

  static double _clampDock(double w) => w.clamp(minDockWidth, maxDockWidth);

  void toggleDock() => _setDock(open: !_dockOpen);

  /// 구분선을 끌 때 부른다. 범위 밖이면 가장 가까운 값으로 맞춘다.
  void setDockWidth(double width) => _setDock(width: _clampDock(width));

  void _setDock({bool? open, double? width}) {
    final changed = (open != null && open != _dockOpen) || (width != null && width != _dockWidth);
    if (!changed) return;
    _dockOpen = open ?? _dockOpen;
    _dockWidth = width ?? _dockWidth;
    notifyListeners();
    _persist();
  }

  void toggleBottom() => _set(open: !_bottomOpen);

  /// 아래 패널을 펼치고 [tab]을 보여 준다 (상태 막대의 문제 개수를 눌렀을 때 등).
  void showBottom(BottomTab tab) => _set(open: true, tab: tab);

  void setBottomTab(BottomTab tab) => _set(tab: tab);

  /// 구분선을 끌 때 부른다. 범위 밖이면 가장 가까운 값으로 맞춘다.
  void setBottomHeight(double height) => _set(height: _clamp(height));

  void _set({bool? open, double? height, BottomTab? tab}) {
    final changed = (open != null && open != _bottomOpen) || (height != null && height != _bottomHeight) || (tab != null && tab != _bottomTab);
    if (!changed) return;
    _bottomOpen = open ?? _bottomOpen;
    _bottomHeight = height ?? _bottomHeight;
    _bottomTab = tab ?? _bottomTab;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_openKey, _bottomOpen);
      await prefs.setDouble(_heightKey, _bottomHeight);
      await prefs.setString(_tabKey, _bottomTab.name);
      await prefs.setBool(_dockOpenKey, _dockOpen);
      await prefs.setDouble(_dockWidthKey, _dockWidth);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}
