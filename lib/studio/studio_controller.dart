import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/current_l10n.dart';
import '../diff/line_diff.dart';
import '../problems/diagnostic.dart' show pathKey;
import 'dart_formatter.dart';
import 'file_language.dart';
import 'git_base.dart';
import 'json_formatter.dart';
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

  // --- git HEAD와의 차이 ---------------------------------------------------

  /// HEAD 커밋의 글(줄 목록). git 저장소가 아니거나 무시되는 파일이면 null (비교하지 않는다).
  List<String>? baseLines;

  /// 아직 커밋되지 않은 새 파일이다.
  bool baseIsNew = false;

  /// 줄 번호 옆에 그리는 변경 표시. 편집할 때마다(잠깐 멈춘 뒤) 다시 계산한다.
  final ValueNotifier<ChangeMarks> marks = ValueNotifier(ChangeMarks.empty);

  /// 편집 대신 HEAD와의 차이(변경점)를 보여 주는 중인가.
  bool diffMode = false;

  Timer? _marksTimer;
  CodeLines? _marksSource;

  bool get hasBase => baseLines != null;

  List<String> get currentLines => splitLines(controller.text);

  /// 글이 바뀌었으면 잠시 뒤 변경 표시를 다시 계산한다. 커서만 움직였을 때는 아무것도 하지 않는다.
  void onEdited() {
    // 비교할 기준이 없으면 계산할 것이 없다 (기준은 파일을 연 뒤 뒤에서 읽어 온다).
    if (baseLines == null || identical(_marksSource, controller.codeLines)) return;
    _marksSource = controller.codeLines;
    _marksTimer?.cancel();
    _marksTimer = Timer(const Duration(milliseconds: 250), recomputeMarks);
  }

  void recomputeMarks() {
    _marksTimer?.cancel();
    _marksSource = controller.codeLines;
    final base = baseLines;
    marks.value = base == null ? ChangeMarks.empty : marksFromBlocks(diffLines(base, currentLines));
  }

  void dispose() {
    _marksTimer?.cancel();
    marks.dispose();
    controller.dispose();
  }
}

/// 열린 프로젝트(폴더), worktree 목록, 편집기 탭을 들고 있다.
class StudioController extends ChangeNotifier {
  StudioController({this.formatDart, this.readBase, this.onSaved, this.formatOnSave});

  /// Dart 글을 정렬한다 (`dart format`). 없으면 정렬 기능을 쓸 수 없다.
  final Future<FormatResult> Function(String path, String text)? formatDart;

  /// 파일의 git HEAD 내용을 읽는다. 없으면 변경 표시와 변경점 보기를 쓸 수 없다.
  final Future<GitBase> Function(String path)? readBase;

  /// 파일을 저장한 뒤 부른다 (Dart 문제를 다시 분석하는 데 쓴다).
  final void Function(String path)? onSaved;

  /// 저장하기 직전에 정렬할지. 없으면 정렬하지 않는다.
  final bool Function()? formatOnSave;

  static const _lastProjectKey = 'last_project';
  static const _recentKey = 'recent_projects';

  /// 최근 프로젝트를 몇 개까지 기억할지.
  static const maxRecent = 8;
  static const maxFileBytes = 2 * 1024 * 1024;

  String? root;

  /// 최근에 연 프로젝트 폴더 (가장 최근이 앞). "프로젝트 열기" 메뉴에서 다시 연다.
  List<String> recentProjects = const [];
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
    recentProjects = prefs.getStringList(_recentKey) ?? const [];
    // 기록이 생기기 전에 열어 둔 프로젝트도 목록에 넣는다.
    if (last != null && !recentProjects.any((p) => pathKey(p) == pathKey(last))) recentProjects = [last, ...recentProjects];
    if (last != null && Directory(last).existsSync() && await openProject(last)) await _restoreTabs(last);
  }

  // --- 열어 둔 탭 복원 -----------------------------------------------------

  static String _tabsKey(String root) => 'open_tabs:$root';

  bool _restoringTabs = false;

  /// 프로젝트별로 열어 둔 탭 경로와 활성 탭을 기억한다.
  Future<void> _persistTabs() async {
    final r = root;
    if (r == null || _restoringTabs) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _tabsKey(r),
        jsonEncode({'paths': [for (final t in tabs) t.path], 'active': activeIndex}),
      );
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  Future<void> _restoreTabs(String r) async {
    _restoringTabs = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_tabsKey(r));
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final paths = [for (final p in data['paths'] as List<dynamic>) p as String];
      for (final p in paths) {
        if (File(p).existsSync()) await openFile(p);
      }
      message = null; // 사라졌거나 못 여는 파일은 조용히 건너뛴다.
      final active = data['active'] as int? ?? -1;
      final wanted = active >= 0 && active < paths.length ? tabFor(paths[active]) : null;
      if (wanted != null) activeIndex = tabs.indexOf(wanted);
      notifyListeners();
    } on Object {
      // 형식이 맞지 않으면 복원하지 않는다.
    } finally {
      _restoringTabs = false;
    }
  }

  /// [remember]가 true면 최근 프로젝트 목록 맨 앞에 올린다 (같은 저장소의 다른 worktree로 옮길 때는 false).
  Future<bool> openProject(String path, {bool remember = true}) async {
    if (!Directory(path).existsSync()) {
      message = CurrentL10n.value.messageFolderUnavailable(path);
      notifyListeners();
      return false;
    }
    root = path;
    worktrees = await Worktree.list(path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastProjectKey, path);
    if (remember) {
      recentProjects = [path, ...recentProjects.where((p) => pathKey(p) != pathKey(path))].take(maxRecent).toList();
      await prefs.setStringList(_recentKey, recentProjects);
    }
    notifyListeners();
    return true;
  }

  /// 최근 프로젝트에서 다시 연다. 폴더가 사라졌으면 알리고 목록에서 뺀다.
  Future<bool> openRecent(String path) async {
    if (await openProject(path)) return true;
    await forgetRecent(path);
    return false;
  }

  Future<void> forgetRecent(String path) async {
    recentProjects = [for (final p in recentProjects) if (pathKey(p) != pathKey(path)) p];
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setStringList(_recentKey, recentProjects);
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  Future<void> clearRecent() async {
    recentProjects = const [];
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).remove(_recentKey);
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  /// 다른 worktree의 같은 하위 폴더를 연다. 열린 탭은 그대로 둔다.
  Future<bool> switchWorktree(Worktree target) async {
    final from = currentWorktree;
    final r = root;
    if (from == null || r == null || target == from) return false;
    var rel = r.length > from.path.length ? r.substring(from.path.length) : '';
    if (rel.startsWith('/') || rel.startsWith(r'\')) rel = rel.substring(1);
    final next = rel.isEmpty ? target.path : '${target.path}${Platform.pathSeparator}$rel';
    return openProject(Directory(next).existsSync() ? next : target.path, remember: false);
  }

  Future<void> refreshWorktrees() async {
    final r = root;
    if (r == null) return;
    worktrees = await Worktree.list(r);
    notifyListeners();
  }

  /// [path]를 가진 탭. 경로 표기(구분자·대소문자)가 달라도 같은 파일이면 찾는다.
  EditorTab? tabFor(String path) {
    final key = pathKey(path);
    return tabs.where((t) => pathKey(t.path) == key).firstOrNull;
  }

  Future<void> openFile(String path) async {
    final existing = tabs.indexWhere((t) => pathKey(t.path) == pathKey(path));
    if (existing >= 0) {
      activeIndex = existing;
      notifyListeners();
      unawaited(_persistTabs());
      return;
    }
    final file = File(path);
    try {
      if (await file.length() > maxFileBytes) {
        message = CurrentL10n.value.messageFileTooLarge(file.uri.pathSegments.last);
        notifyListeners();
        return;
      }
      final text = utf8.decode(await file.readAsBytes());
      final tab = EditorTab(path, text)..stamp = await _stampOf(path);
      _watch(tab);
      tabs.add(tab);
      activeIndex = tabs.length - 1;
      // 변경 표시용 기준은 git을 몇 번 부르므로 화면을 막지 않고 뒤에서 읽는다.
      unawaited(refreshBase(tab));
    } on FormatException {
      message = CurrentL10n.value.messageNotUtf8Open(file.uri.pathSegments.last);
    } on FileSystemException catch (e) {
      message = CurrentL10n.value.messageReadFailed(e.message);
    }
    notifyListeners();
    unawaited(_persistTabs());
  }

  /// 탭의 비교 기준(git HEAD의 글)을 다시 읽고 변경 표시를 새로 계산한다.
  Future<void> refreshBase(EditorTab tab) async {
    final read = readBase;
    if (read == null) return;
    final base = await read(tab.path);
    if (_disposed || !tabs.contains(tab)) return;
    tab.baseLines = base.available ? splitLines(base.text) : null;
    tab.baseIsNew = base.isNew;
    tab.recomputeMarks();
    notifyListeners();
  }

  /// 열린 모든 탭의 기준을 다시 읽는다 (커밋·브랜치 전환·창 활성화 뒤).
  Future<void> refreshBases() => Future.wait([for (final t in List.of(tabs)) refreshBase(t)]);

  /// 파일을 열고 곧바로 변경점 보기로 보여 준다.
  Future<void> openDiff(String path) async {
    await openFile(path);
    final tab = tabFor(path);
    if (tab == null) return;
    tab.diffMode = true;
    activeIndex = tabs.indexOf(tab);
    notifyListeners();
  }

  /// 파일을 열고 [line]/[column](1부터)에 커서를 두어 보여 준다. 문제 패널에서 문제를 눌렀을 때 쓴다.
  Future<void> openAt(String path, int line, int column) async {
    await openFile(path);
    final tab = tabFor(path);
    if (tab == null) return;
    tab.diffMode = false;
    activeIndex = tabs.indexOf(tab);
    final lines = tab.controller.codeLines;
    final index = (line - 1).clamp(0, lines.length - 1);
    final offset = (column - 1).clamp(0, lines[index].text.length);
    tab.controller.selection = CodeLineSelection.collapsed(index: index, offset: offset);
    notifyListeners();
    // 편집기가 화면에 올라와 배치를 마친 뒤에 그 줄이 가운데 오게 스크롤한다.
    void center() {
      try {
        tab.controller.makeCursorCenterIfInvisible();
      } on Object {
        // 편집기가 아직 붙지 않았으면 선택만 남는다.
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) => SchedulerBinding.instance.addPostFrameCallback((_) => center()));
  }

  void toggleDiff(EditorTab tab) {
    tab.diffMode = !tab.diffMode;
    notifyListeners();
  }

  /// 수정 여부가 바뀔 때만 화면을 다시 그린다 (커서 이동·글자 입력마다 전체를 그리지 않는다).
  void _watch(EditorTab tab) {
    var wasDirty = false;
    tab.controller.addListener(() {
      tab.onEdited();
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

  /// 탭을 끌어서 순서를 바꾼다. [newIndex]는 옮긴 뒤의 자리다 (`onReorderItem`이 넘겨 주는 값).
  /// 보고 있던 탭은 그대로 보고 있는다.
  void moveTab(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= tabs.length) return;
    newIndex = newIndex.clamp(0, tabs.length - 1);
    if (newIndex == oldIndex) return;
    final active = activeTab;
    tabs.insert(newIndex, tabs.removeAt(oldIndex));
    if (active != null) activeIndex = tabs.indexOf(active);
    notifyListeners();
    unawaited(_persistTabs());
  }

  /// 창에 끌어다 놓은 것을 연다. 폴더가 있으면 그 폴더를 프로젝트로 열고, 아니면 파일을 편집기 탭으로 연다.
  Future<void> openDropped(List<String> paths) async {
    final dir = paths.where((p) => FileSystemEntity.isDirectorySync(p)).firstOrNull;
    if (dir != null) {
      await openProject(dir);
      return;
    }
    for (final p in paths) {
      if (FileSystemEntity.isFileSync(p)) await openFile(p);
    }
  }

  /// 고친 탭을 모두 저장한다. 하나라도 저장하지 못하면 false.
  Future<bool> saveAll() async {
    var ok = true;
    for (final t in List.of(tabs)) {
      if (t.dirty && !await save(t)) ok = false;
    }
    return ok;
  }

  void selectTab(int index) {
    activeIndex = index;
    notifyListeners();
    unawaited(_persistTabs());
  }

  Future<bool> save(EditorTab tab) async {
    if (tab.external == ExternalChange.modified) {
      message = CurrentL10n.value.messageDiskChangedSaveBlocked;
      notifyListeners();
      return false;
    }
    if (formatOnSave?.call() ?? false) {
      // 문법 오류 등으로 정렬하지 못해도 저장은 한다 — 정렬은 덤이다.
      final r = await _formatted(tab);
      if (r != null && r.ok) _applyFormatted(tab, r.text!);
    }
    try {
      await File(tab.path).writeAsString(tab.controller.text);
      tab.savedText = tab.controller.text;
      tab.stamp = await _stampOf(tab.path);
      tab.external = ExternalChange.none;
      notifyListeners();
      onSaved?.call(tab.path);
      return true;
    } on FileSystemException catch (e) {
      message = CurrentL10n.value.messageSaveFailed(e.message);
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
      message = CurrentL10n.value.messageChangedNotUtf8(tab.name);
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
    message = CurrentL10n.value.messageChangedReloaded(tab.name);
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
      message = CurrentL10n.value.messageReloadedFromDisk(tab.name);
    } on FormatException {
      message = CurrentL10n.value.messageNotUtf8Reload;
    } on FileSystemException catch (e) {
      message = CurrentL10n.value.messageReadFailed(e.message);
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
    unawaited(_persistTabs());
  }

  /// 이 탭의 글을 정렬할 수 있는가 (Dart · JSON · ARB).
  bool canFormat(EditorTab tab) => tab.language.isDart || tab.language.isJson;

  Future<FormatResult?> _formatted(EditorTab tab) async {
    if (tab.language.isJson) return formatJson(tab.controller.text);
    final format = formatDart;
    if (tab.language.isDart && format != null) return format(tab.path, tab.controller.text);
    return null;
  }

  /// 정렬한 글로 편집기 글을 바꾼다 (실행 취소할 수 있다). 바꿨으면 true.
  bool _applyFormatted(EditorTab tab, String text) {
    if (text == tab.controller.text) return false;
    final line = tab.controller.selection.extentIndex;
    tab.controller.runRevocableOp(() => tab.controller.text = text);
    final last = tab.controller.codeLines.length - 1;
    tab.controller.selection = CodeLineSelection.collapsed(index: line > last ? last : line, offset: 0);
    return true;
  }

  /// 지금 탭의 글을 정렬한다. 성공하면 편집기 글을 바꾸되 실행 취소할 수 있다.
  Future<void> formatActive() async {
    final tab = activeTab;
    if (tab == null) return;
    final r = await _formatted(tab);
    if (r == null) return;
    if (!r.ok) {
      message = r.error;
    } else if (_applyFormatted(tab, r.text!)) {
      message = CurrentL10n.value.messageFormatted;
    } else {
      message = CurrentL10n.value.messageAlreadyFormatted;
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
