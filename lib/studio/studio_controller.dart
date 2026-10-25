import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'worktree.dart';

/// 편집기 탭 하나. 저장된 글과 지금 글을 비교해 수정 여부를 안다.
class EditorTab {
  EditorTab(this.path, String text)
      : savedText = text,
        controller = TextEditingController(text: text);

  final String path;
  String savedText;
  final TextEditingController controller;

  bool get dirty => controller.text != savedText;

  String get name => path.split(RegExp(r'[/\\]')).last;

  void dispose() => controller.dispose();
}

/// 열린 프로젝트(폴더), worktree 목록, 편집기 탭을 들고 있다.
class StudioController extends ChangeNotifier {
  static const _lastProjectKey = 'last_project';
  static const maxFileBytes = 2 * 1024 * 1024;

  String? root;
  List<Worktree> worktrees = const [];
  final List<EditorTab> tabs = [];
  int activeIndex = -1;

  /// 마지막으로 낸 알림(열 수 없는 파일, 저장 실패 등). 화면이 보여 주고 지운다.
  String? message;

  EditorTab? get activeTab => activeIndex >= 0 && activeIndex < tabs.length ? tabs[activeIndex] : null;

  Worktree? get currentWorktree {
    final r = root;
    return r == null ? null : worktreeContaining(worktrees, r);
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_lastProjectKey);
    if (last != null && Directory(last).existsSync()) await openProject(last);
  }

  Future<bool> openProject(String path) async {
    if (!Directory(path).existsSync()) {
      message = '폴더를 열 수 없습니다: $path';
      notifyListeners();
      return false;
    }
    root = path;
    worktrees = await Worktree.list(path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastProjectKey, path);
    notifyListeners();
    return true;
  }

  /// 다른 worktree의 같은 하위 폴더를 연다. 열린 탭은 그대로 둔다.
  Future<bool> switchWorktree(Worktree target) async {
    final from = currentWorktree;
    final r = root;
    if (from == null || r == null || target == from) return false;
    var rel = r.length > from.path.length ? r.substring(from.path.length) : '';
    if (rel.startsWith('/') || rel.startsWith(r'\')) rel = rel.substring(1);
    final next = rel.isEmpty ? target.path : '${target.path}${Platform.pathSeparator}$rel';
    return openProject(Directory(next).existsSync() ? next : target.path);
  }

  Future<void> refreshWorktrees() async {
    final r = root;
    if (r == null) return;
    worktrees = await Worktree.list(r);
    notifyListeners();
  }

  Future<void> openFile(String path) async {
    final existing = tabs.indexWhere((t) => t.path == path);
    if (existing >= 0) {
      activeIndex = existing;
      notifyListeners();
      return;
    }
    final file = File(path);
    try {
      if (await file.length() > maxFileBytes) {
        message = '2MB보다 큰 파일은 열지 않습니다: ${file.uri.pathSegments.last}';
        notifyListeners();
        return;
      }
      final text = utf8.decode(await file.readAsBytes());
      final tab = EditorTab(path, text);
      tab.controller.addListener(notifyListeners);
      tabs.add(tab);
      activeIndex = tabs.length - 1;
    } on FormatException {
      message = '글자 파일(UTF-8)이 아니라서 열 수 없습니다: ${file.uri.pathSegments.last}';
    } on FileSystemException catch (e) {
      message = '파일을 읽지 못했습니다: ${e.message}';
    }
    notifyListeners();
  }

  void selectTab(int index) {
    activeIndex = index;
    notifyListeners();
  }

  Future<bool> save(EditorTab tab) async {
    try {
      await File(tab.path).writeAsString(tab.controller.text);
      tab.savedText = tab.controller.text;
      notifyListeners();
      return true;
    } on FileSystemException catch (e) {
      message = '저장하지 못했습니다: ${e.message}';
      notifyListeners();
      return false;
    }
  }

  void closeTab(int index) {
    final tab = tabs.removeAt(index);
    tab.dispose();
    if (activeIndex >= tabs.length) activeIndex = tabs.length - 1;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
  }

  @override
  void dispose() {
    for (final t in tabs) {
      t.dispose();
    }
    super.dispose();
  }
}
