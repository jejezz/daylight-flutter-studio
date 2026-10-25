import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart_formatter.dart';
import 'file_language.dart';
import 'worktree.dart';

/// 파일의 마지막 수정 시각과 크기 — 디스크에서 바뀌었는지 가볍게 확인하는 데 쓴다.
class FileStamp {
  const FileStamp(this.modified, this.size);

  final DateTime modified;
  final int size;

  @override
  bool operator ==(Object other) => other is FileStamp && other.modified == modified && other.size == size;

  @override
  int get hashCode => Object.hash(modified, size);
}

/// 열려 있는 파일이 디스크에서 어떻게 달라졌는가.
enum ExternalChange {
  none,

  /// 내가 수정 중인데 디스크의 파일도 바뀌었다 — 저장하면 그쪽 수정을 덮어쓴다.
  modified,

  /// 디스크에서 파일이 사라졌다 (삭제·이름 변경·worktree 정리).
  deleted,
}

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

  /// 디스크에서 마지막으로 확인한 상태. 파일이 없으면 null.
  FileStamp? stamp;

  /// 사용자가 골라야 하는 외부 변경. [ExternalChange.none]이면 아무 일도 없다.
  ExternalChange external = ExternalChange.none;

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
      final tab = EditorTab(path, text)..stamp = await _stampOf(path);
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
    if (tab.external == ExternalChange.modified) {
      message = '디스크의 파일이 바뀌었습니다. 저장하기 전에 "다시 읽기"나 "내 수정 유지"를 먼저 고르세요.';
      notifyListeners();
      return false;
    }
    try {
      await File(tab.path).writeAsString(tab.controller.text);
      tab.savedText = tab.controller.text;
      tab.stamp = await _stampOf(tab.path);
      tab.external = ExternalChange.none;
      notifyListeners();
      return true;
    } on FileSystemException catch (e) {
      message = '저장하지 못했습니다: ${e.message}';
      notifyListeners();
      return false;
    }
  }

  // --- 디스크 변경 감지 -------------------------------------------------------
  // Claude Code가 worktree에서 파일을 고치는 동안 같은 파일이 열려 있으면 낡은 글이 보이고,
  // 거기서 저장하면 Claude의 수정을 덮어쓴다. 열린 탭의 수정 시각·크기를 주기적으로 확인한다.

  Timer? _timer;
  bool _checking = false;

  /// 열린 탭을 [interval]마다 확인하기 시작한다. 창이 다시 활성화될 때는 바로 [checkExternalChanges]를 부른다.
  void startWatching({Duration interval = const Duration(seconds: 1)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => checkExternalChanges());
  }

  /// 파일 트리가 다시 읽어야 할 때 올라가는 번호.
  int treeRevision = 0;

  void refreshTree() {
    treeRevision++;
    notifyListeners();
  }

  Future<FileStamp?> _stampOf(String path) async {
    final stat = await FileStat.stat(path);
    return stat.type == FileSystemEntityType.notFound ? null : FileStamp(stat.modified, stat.size);
  }

  /// 열린 탭마다 디스크의 파일이 바뀌었는지 보고 처리한다.
  /// 수정하지 않은 탭은 조용히 다시 읽고, 수정 중인 탭은 사용자가 고르도록 표시만 한다.
  Future<void> checkExternalChanges() async {
    if (_checking || _disposed) return;
    _checking = true;
    try {
      var changed = false;
      for (final tab in List.of(tabs)) {
        final now = await _stampOf(tab.path);
        if (_disposed || !tabs.contains(tab)) continue;
        if (now == null) {
          if (tab.external != ExternalChange.deleted) {
            tab.external = ExternalChange.deleted;
            tab.stamp = null;
            changed = true;
          }
          continue;
        }
        if (now == tab.stamp && tab.external != ExternalChange.deleted) continue;
        changed |= await _applyDiskChange(tab, now);
      }
      if (changed) notifyListeners();
    } finally {
      _checking = false;
    }
  }

  /// 디스크의 글이 달라졌을 때의 처리. 화면을 다시 그려야 하면 true.
  Future<bool> _applyDiskChange(EditorTab tab, FileStamp now) async {
    String disk;
    try {
      disk = utf8.decode(await File(tab.path).readAsBytes());
    } on FormatException {
      tab.stamp = now;
      tab.external = ExternalChange.modified;
      message = '${tab.name}이(가) 디스크에서 바뀌었지만 글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.';
      return true;
    } on FileSystemException {
      return false; // 쓰는 도중이었을 수 있다 — 다음 확인 때 다시 본다.
    }
    tab.stamp = now;
    final wasExternal = tab.external != ExternalChange.none;
    // 시각만 바뀌고 글이 같으면 없던 일로 한다 (줄 끝 차이도 같은 글로 본다).
    if (_sameText(tab, disk)) {
      tab.external = ExternalChange.none;
      return wasExternal;
    }
    if (tab.dirty) {
      tab.external = ExternalChange.modified;
      return true;
    }
    _replaceText(tab, disk);
    tab.external = ExternalChange.none;
    message = '${tab.name}이(가) 디스크에서 바뀌어 다시 읽었습니다.';
    return true;
  }

  bool _sameText(EditorTab tab, String disk) {
    final a = disk.replaceAll('\r\n', '\n');
    final b = tab.savedText.replaceAll('\r\n', '\n');
    return a == b;
  }

  /// 편집기 글을 [text]로 바꾸고 그것을 저장된 상태로 삼는다. 커서가 있던 줄은 가능한 한 유지한다.
  void _replaceText(EditorTab tab, String text) {
    final line = tab.controller.selection.extentIndex;
    tab.controller.text = text;
    tab.savedText = tab.controller.text;
    final last = tab.controller.codeLines.length - 1;
    tab.controller.selection = CodeLineSelection.collapsed(index: line > last ? last : line, offset: 0);
  }

  /// 내 수정을 버리고 디스크의 글을 다시 읽는다.
  Future<void> reloadFromDisk(EditorTab tab) async {
    try {
      final disk = utf8.decode(await File(tab.path).readAsBytes());
      _replaceText(tab, disk);
      tab.stamp = await _stampOf(tab.path);
      tab.external = ExternalChange.none;
      message = '${tab.name}을(를) 디스크 내용으로 다시 읽었습니다.';
    } on FormatException {
      message = '글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.';
    } on FileSystemException catch (e) {
      message = '파일을 읽지 못했습니다: ${e.message}';
    }
    notifyListeners();
  }

  /// 내 글을 유지한다. 다음에 저장하면 디스크의 파일을 내 글로 덮어쓰거나(바뀐 경우) 다시 만든다(삭제된 경우).
  void keepMine(EditorTab tab) {
    tab.external = ExternalChange.none;
    notifyListeners();
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
    _timer?.cancel();
    for (final t in tabs) {
      t.dispose();
    }
    super.dispose();
  }
}
