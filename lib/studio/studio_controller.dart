import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart_formatter.dart';
import 'file_language.dart';
import 'worktree.dart';

/// 편집기 탭 하나. 저장된 글과 지금 글을 비교해 수정 여부를 안다.
class EditorTab {
  EditorTab(this.path, String text)
    : language = FileLanguage.of(path),
      controller = CodeLineEditingController.fromText(
        text,
        CodeLineOptions(lineBreak: text.contains('\r\n') ? TextLineBreak.crlf : TextLineBreak.lf),
      ) {
    // 줄 끝이 섞인 파일을 열자마자 "수정됨"으로 보이지 않게, 편집기가 정리한 글을 기준으로 삼는다.
    savedText = controller.text;
  }

  final String path;
  final FileLanguage language;
  late String savedText;
  final CodeLineEditingController controller;

  /// Markdown만: 렌더링된 모양으로 보는 중인가 (아니면 글을 편집하는 중).
  bool preview = false;

  /// 편집기가 만든 접기 제어. 편집기가 화면에 올라온 뒤에 채워진다.
  CodeChunkController? chunks;

  bool get dirty => controller.text != savedText;

  String get name => path.split(RegExp(r'[/\\]')).last;

  void dispose() => controller.dispose();
}

/// 열린 프로젝트(폴더), worktree 목록, 편집기 탭을 들고 있다.
class StudioController extends ChangeNotifier {
  StudioController({this.formatDart});

  /// Dart 글을 정렬한다 (`dart format`). 없으면 정렬 기능을 쓸 수 없다.
  final Future<FormatResult> Function(String path, String text)? formatDart;

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
      _watch(tab);
      tabs.add(tab);
      activeIndex = tabs.length - 1;
    } on FormatException {
      message = '글자 파일(UTF-8)이 아니라서 열 수 없습니다: ${file.uri.pathSegments.last}';
    } on FileSystemException catch (e) {
      message = '파일을 읽지 못했습니다: ${e.message}';
    }
    notifyListeners();
  }

  /// 수정 여부가 바뀔 때만 화면을 다시 그린다 (커서 이동·글자 입력마다 전체를 그리지 않는다).
  void _watch(EditorTab tab) {
    var wasDirty = false;
    tab.controller.addListener(() {
      final now = tab.dirty;
      if (now == wasDirty) return;
      wasDirty = now;
      _notifySafely();
    });
  }

  bool _disposed = false;

  /// 편집기가 그려지는 도중(초기화·선택 영역 정리)에 값이 바뀌면 그 프레임이 끝난 뒤에 알린다.
  void _notifySafely() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
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

  /// 지금 탭의 Dart 글을 `dart format`으로 정렬한다. 성공하면 편집기 글을 바꾸되 실행 취소할 수 있다.
  Future<void> formatActive() async {
    final tab = activeTab;
    final format = formatDart;
    if (tab == null || format == null || !tab.language.isDart) return;
    final r = await format(tab.path, tab.controller.text);
    if (!r.ok) {
      message = r.error;
    } else if (r.text == tab.controller.text) {
      message = '이미 정렬되어 있습니다';
    } else {
      final line = tab.controller.selection.extentIndex;
      tab.controller.runRevocableOp(() => tab.controller.text = r.text!);
      final last = tab.controller.codeLines.length - 1;
      tab.controller.selection = CodeLineSelection.collapsed(index: line > last ? last : line, offset: 0);
      message = '정렬했습니다';
    }
    notifyListeners();
  }

  void togglePreview(EditorTab tab) {
    tab.preview = !tab.preview;
    notifyListeners();
  }

  void clearMessage() {
    message = null;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final t in tabs) {
      t.dispose();
    }
    super.dispose();
  }
}
