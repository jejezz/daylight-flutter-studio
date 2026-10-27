import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:window_manager/window_manager.dart';

import '../core/command_log.dart';
import '../core/command_runner.dart';
import '../dev/demo_runner.dart';
import '../devices/device_service.dart';
import '../verify/verify_gate_controller.dart';
import '../run/run_controller.dart';
import '../problems/dart_analyzer.dart';
import '../settings/gate_settings.dart';
import '../settings/panel_layout.dart';
import '../settings/terminal_settings.dart';
import '../problems/problems_controller.dart';
import '../studio/dart_formatter.dart';
import '../studio/git_base.dart';
import '../studio/studio_controller.dart';
import '../terminal/terminal_sessions_controller.dart';
import '../app_identity.dart';
import '../doctor/diagnostics.dart';
import '../doctor/environment_controller.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_menus.dart';
import '../theme/app_theme.dart';
import '../theme/editor_zoom.dart';
import '../window/focus_tint.dart';
import '../theme/theme_controller.dart';
import '../update/update_scope.dart';
import '../verify/verify_store.dart';
import 'bottom_panel.dart';
import 'editor_pane.dart';
import 'branchdock_dock.dart';
import 'dock_bars.dart';
import 'studio_menus.dart';
import 'git_merge_gate.dart';
import '../settings/editor_settings.dart';
import '../studio/project_index.dart';
import 'project_search.dart';
import 'quick_open.dart';
import 'recent_projects.dart';
import 'settings_dialog.dart';
import 'tree_pane.dart';

/// 프로젝트 트리 | 편집기 | Dock 패널 (3단) + 하단 상태 막대.
class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key, required this.theme, this.onAbout});

  final ThemeController theme;

  /// 정보 창을 여는 동작 (앱 바 오른쪽 `테마 | 언어 | 정보`). 없으면 정보 단추를 두지 않는다.
  final VoidCallback? onAbout;

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen>
    with WidgetsBindingObserver {
  late final CommandLog _log = CommandLog();
  late final CommandRunner _runner = CommandRunner(_log);
  late final StudioController _controller = StudioController(
    formatDart: DartFormatter(_runner).format,
    readBase: GitBaseReader(_runner).read,
    readRefBase: GitBaseReader(_runner).readAt,
    listCompareChoices: GitBaseReader(_runner).choices,
    onSaved: (path) => _problems.onSaved(path),
    formatOnSave: () => EditorSettingsScope.maybeOf(context)?.formatOnSave ?? false,
  );
  late final DartAnalyzer _analyzer = DartAnalyzer(_runner);
  late final EnvironmentController _env = EnvironmentController(
    runner: _runner,
    service: ProcessDiagnosticsService(_runner),
  );
  late final ProblemsController _problems = ProblemsController(
    analyze: _analyzer.run,
    pubGet: _analyzer.pubGet,
  );
  late final RunController _run = RunController(
    runner: _runner,
    deviceService: ProcessDeviceService(_runner),
    store: VerifyStore(_runner),
  );
  final GateSettings _gate = GateSettings();
  final PanelLayout _layout = PanelLayout();
  final TerminalSettings _terminalSettings = TerminalSettings();
  late final TerminalSessionsController _terminal = TerminalSessionsController(
    scrollback: () => _terminalSettings.scrollback,
  );
  late final VerifyGateController _git = VerifyGateController(
    runner: _runner,
    store: VerifyStore(_runner),
    gate: _gate,
  );
  late final GitMergeGate _mergeGate = GitMergeGate(_git);
  double _treeWidth = 260;
  final _dockKey = GlobalKey();
  bool _dragging = false;
  String? _lastRoot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onStudioChanged);
    _controller.restore();
    _controller.startWatching();
    _git.addListener(_onGitChanged);
    _run.addListener(_onRunChanged);
    _gate.restore();
    _layout.restore();
    _terminalSettings.restore();
    unawaited(_terminal.loadShells());
    unawaited(runDemoIfRequested(studio: _controller, run: _run, runner: _runner));
    _env.onToolPathsChanged = () => _run.refreshDevices();
    // clean + pub get이 끝나면 패키지 정보가 새로 생겼으니 문제 탭도 바로 다시 분석한다.
    _run.onCleaned = _problems.refresh;
    // 저장해 둔 도구 위치를 먼저 실행기에 넣어야 기기 목록이 같은 flutter·adb를 쓴다.
    _env.restore().then((_) => _run.init());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 다른 창(Claude Code, 터미널)에서 돌아오면 바로 디스크 변경을 확인하고 트리를 새로 읽는다.
    if (state == AppLifecycleState.resumed) {
      _controller.checkExternalChanges();
      _controller.refreshTree();
      _controller.refreshBases();
      _problems.refreshIfStale(const Duration(seconds: 30));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _git.removeListener(_onGitChanged);
    _run.removeListener(_onRunChanged);
    // 관문 어댑터는 설정(_gate)과 Git 컨트롤러를 듣고 있으므로 그것들보다 먼저 정리한다.
    _mergeGate.dispose();
    _gate.dispose();
    _layout.dispose();
    _terminal.dispose();
    _terminalSettings.dispose();
    _env.dispose();
    _controller.removeListener(_onStudioChanged);
    _controller.dispose();
    _run.dispose();
    _git.dispose();
    _problems.dispose();
    _log.dispose();
    super.dispose();
  }

  void _onStudioChanged() {
    final m = _controller.message;
    if (m != null && mounted) {
      _controller.clearMessage();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
    // 열린 폴더가 바뀌면(프로젝트 열기, worktree 전환) Run 패널이 그 프로젝트를 다시 읽는다.
    if (_controller.root != _lastRoot) {
      _lastRoot = _controller.root;
      _run.setProjectDir(_lastRoot);
      _problems.setProjectDir(_lastRoot);
      _git.setDir(_lastRoot);
    }
  }

  String? _lastVerifyKey;

  /// Run 탭에서 검증 기록이 바뀌면(확인함·문제 있음) Git 패널의 병합 관문도 바로 새 기록으로 판정한다.
  void _onRunChanged() {
    final r = _run.record;
    final key = r == null ? null : '${r.sha}:${r.status.name}';
    if (key == _lastVerifyKey) return;
    _lastVerifyKey = key;
    _git.refreshVerdict();
  }

  String? _lastHead;

  /// 커밋이나 브랜치 전환으로 HEAD가 바뀌면 열린 파일의 비교 기준(HEAD 내용)을 다시 읽는다.
  void _onGitChanged() {
    final head = _git.status?.oid;
    if (head == _lastHead) return;
    _lastHead = head;
    _controller.refreshBases();
  }

  /// 브랜치를 전환·만들기·이름 바꾸기·삭제한 뒤: 작업 폴더의 파일과 HEAD가 바뀌었을 수 있으니 화면을 새로 읽는다.
  void _onBranchChanged() {
    _git.refresh();
    _controller.checkExternalChanges();
    _controller.refreshTree();
    _controller.refreshBases();
    _run.refreshVerify();
    _problems.refresh();
  }

  Future<void> _openSettings() =>
      showSettingsDialog(context, theme: widget.theme, gate: _gate, environment: _env, terminal: _terminalSettings);

  Future<void> _quickOpen() async {
    final root = _controller.root;
    if (root == null) return;
    final path = await showQuickOpen(context, root: root, files: listProjectFiles(root));
    if (path != null) await _controller.openFile(path);
  }

  /// 편집기에서 한 줄 안의 글을 선택해 두었으면 그것을 검색어로 쓴다 (찾기 줄과 같다). 여러 줄이면 쓰지 않는다.
  String _selectedQuery() {
    final text = _controller.activeTab?.controller.selectedText ?? '';
    return text.isEmpty || text.contains('\n') || text.contains('\r') ? '' : text;
  }

  Future<void> _replaceProject() => _searchProject(replace: true);

  Future<void> _searchProject({bool replace = false}) async {
    final root = _controller.root;
    if (root == null) return;
    await showProjectSearch(
      context,
      root: root,
      initialQuery: _selectedQuery(),
      replaceMode: replace,
      files: listProjectFiles(root),
      onOpen: (path, line, column) => _controller.openAt(path, line, column),
      // 수정 중이거나 디스크와 달라진 탭이 열린 파일은 바꾸지 않는다 — 검색 결과(디스크)와 편집 중인 글이 다르다.
      isBusy: (path) {
        final tab = _controller.tabFor(path);
        return tab != null && (tab.dirty || tab.external != ExternalChange.none);
      },
      // 바꾸거나 되돌린 뒤에는 열린 탭(수정 없는 탭은 조용히 다시 읽는다)·트리·변경 표시·문제를 다시 읽는다.
      onReplaced: _onBranchChanged,
    );
  }

  /// 활성 탭의 편집 동작. 탭이 없으면 아무것도 하지 않는다.
  void _edit(void Function(CodeLineEditingController c) action) {
    final tab = _controller.activeTab;
    if (tab != null) action(tab.controller);
  }

  /// Ctrl/Cmd+S. 탭이 없으면 아무것도 하지 않는다.
  Future<void> _saveActive() async {
    final tab = _controller.activeTab;
    if (tab != null) await _controller.save(tab);
  }

  Future<void> _closeActiveTab() async {
    final i = _controller.activeIndex;
    if (i >= 0 && i < _controller.tabs.length) await closeTabWithPrompt(context, _controller, i);
  }

  List<MenuSpec> _menus(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mac = defaultTargetPlatform == TargetPlatform.macOS;
    SingleActivator key(LogicalKeyboardKey k, {bool shift = false, bool alt = false}) =>
        SingleActivator(k, control: !mac, meta: mac, shift: shift, alt: alt);
    final hasTab = _controller.activeTab != null;
    final hasProject = _controller.root != null;
    final zoom = EditorZoomScope.maybeOf(context);
    return [
      MenuSpec(l10n.menuFile, [
        MenuAction(l10n.menuOpenProject, onPressed: _pickProject, shortcut: key(LogicalKeyboardKey.keyO)),
        SubMenu(l10n.menuRecentProjects, [
          if (_controller.recentProjects.isEmpty) MenuAction(l10n.menuNoRecent),
          for (final p in _controller.recentProjects)
            MenuAction(p.split(RegExp(r'[/\\]')).where((s) => s.isNotEmpty).last, onPressed: () => _controller.openProject(p)),
        ]),
        const MenuDivider(),
        MenuAction(l10n.commonSave, onPressed: hasTab ? _saveActive : null, shortcut: key(LogicalKeyboardKey.keyS)),
        MenuAction(l10n.menuSaveAll, onPressed: hasTab ? _controller.saveAll : null),
        MenuAction(l10n.menuCloseTab, onPressed: hasTab ? _closeActiveTab : null, shortcut: key(LogicalKeyboardKey.keyW)),
        const MenuDivider(),
        MenuAction(l10n.menuQuickOpen, onPressed: hasProject ? _quickOpen : null, shortcut: key(LogicalKeyboardKey.keyP)),
        MenuAction(l10n.menuSettings, onPressed: _openSettings, shortcut: key(LogicalKeyboardKey.comma)),
        // macOS의 종료는 앱 메뉴에 있다.
        if (!mac) ...[const MenuDivider(), MenuAction(l10n.menuExit, onPressed: () => windowManager.close())],
      ]),
      MenuSpec(l10n.menuEdit, [
        MenuAction(l10n.menuUndo, onPressed: hasTab ? () => _edit((c) => c.undo()) : null, shortcut: key(LogicalKeyboardKey.keyZ), nativeShortcut: false),
        MenuAction(
          l10n.menuRedo,
          onPressed: hasTab ? () => _edit((c) => c.redo()) : null,
          shortcut: mac ? key(LogicalKeyboardKey.keyZ, shift: true) : key(LogicalKeyboardKey.keyY),
          nativeShortcut: false,
        ),
        const MenuDivider(),
        MenuAction(l10n.menuCut, onPressed: hasTab ? () => _edit((c) => c.cut()) : null, shortcut: key(LogicalKeyboardKey.keyX), nativeShortcut: false),
        MenuAction(l10n.menuCopy, onPressed: hasTab ? () => _edit((c) => c.copy()) : null, shortcut: key(LogicalKeyboardKey.keyC), nativeShortcut: false),
        MenuAction(l10n.menuPaste, onPressed: hasTab ? () => _edit((c) => c.paste()) : null, shortcut: key(LogicalKeyboardKey.keyV), nativeShortcut: false),
        MenuAction(l10n.menuSelectAll, onPressed: hasTab ? () => _edit((c) => c.selectAll()) : null, shortcut: key(LogicalKeyboardKey.keyA), nativeShortcut: false),
        const MenuDivider(),
        MenuAction(l10n.menuFind, onPressed: hasTab ? () => _controller.activeTab?.find.findMode() : null, shortcut: key(LogicalKeyboardKey.keyF), nativeShortcut: false),
        MenuAction(l10n.menuReplace, onPressed: hasTab ? () => _controller.activeTab?.find.replaceMode() : null, shortcut: key(LogicalKeyboardKey.keyR), nativeShortcut: false),
        MenuAction(l10n.menuFindInProject, onPressed: hasProject ? _searchProject : null, shortcut: key(LogicalKeyboardKey.keyF, shift: true)),
        MenuAction(l10n.menuReplaceInProject, onPressed: hasProject ? _replaceProject : null, shortcut: key(LogicalKeyboardKey.keyH, shift: true)),
        const MenuDivider(),
        MenuAction(
          l10n.menuFormat,
          onPressed: hasTab && _controller.canFormat(_controller.activeTab!) ? _controller.formatActive : null,
          shortcut: SingleActivator(LogicalKeyboardKey.keyL, control: !mac, meta: mac, alt: true),
        ),
      ]),
      MenuSpec(l10n.menuView, [
        MenuAction(l10n.menuBottomPanel, onPressed: _layout.toggleBottom, shortcut: key(LogicalKeyboardKey.keyJ)),
        MenuAction(l10n.menuGitDock, onPressed: _layout.toggleDock, shortcut: SingleActivator(LogicalKeyboardKey.keyB, control: !mac, meta: mac, alt: true)),
        const MenuDivider(),
        MenuAction(l10n.menuZoomIn, onPressed: zoom?.zoomIn, shortcut: key(LogicalKeyboardKey.equal)),
        MenuAction(l10n.menuZoomOut, onPressed: zoom?.zoomOut, shortcut: key(LogicalKeyboardKey.minus)),
        MenuAction(l10n.menuZoomReset, onPressed: zoom?.reset, shortcut: key(LogicalKeyboardKey.digit0)),
      ]),
      if (widget.onAbout != null)
        MenuSpec(l10n.menuHelp, [
          MenuAction(l10n.aboutMenuItem(AppIdentity.displayName), onPressed: widget.onAbout),
          if (UpdateScope.maybeOf(context) != null)
            MenuAction(l10n.updateCheckMenuItem, onPressed: () => UpdateScope.maybeOf(context)!.checkManually(context)),
        ]),
    ];
  }

  /// macOS는 화면 맨 위 시스템 메뉴 막대로 보낸다 (그림은 `AppMenuBar`가 그린다).
  void _publishMenus(List<MenuSpec> menus) {
    final host = StudioMenuHost.maybeOf(context);
    if (host == null) return;
    final platform = toPlatformMenus(menus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      host.value = platform;
    });
  }

  /// 파일·폴더를 창에 끌어다 놓으면 연다 (폴더는 프로젝트로, 파일은 편집기 탭으로).
  Widget _dropTarget({required Widget child}) {
    final theme = Theme.of(context);
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (d) {
        setState(() => _dragging = false);
        _controller.openDropped([for (final f in d.files) f.path]);
      },
      child: Stack(
        children: [
          Positioned.fill(child: child),
          if (_dragging)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                  ),
                  child: Text(AppLocalizations.of(context).studioDropHint, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickProject() async {
    final dir = await getDirectoryPath(confirmButtonText: AppLocalizations.of(context).studioOpenProject);
    if (dir != null) await _controller.openProject(dir);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final root = _controller.root;
        final menus = _menus(context);
        final mac = defaultTargetPlatform == TargetPlatform.macOS;
        if (mac) _publishMenus(menus);
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.comma, control: true):
                _openSettings,
            const SingleActivator(LogicalKeyboardKey.comma, meta: true):
                _openSettings,
            const SingleActivator(LogicalKeyboardKey.keyJ, control: true): _layout.toggleBottom,
            const SingleActivator(LogicalKeyboardKey.keyJ, meta: true): _layout.toggleBottom,
            const SingleActivator(LogicalKeyboardKey.keyB, control: true, alt: true): _layout.toggleDock,
            const SingleActivator(LogicalKeyboardKey.keyB, meta: true, alt: true): _layout.toggleDock,
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): _saveActive,
            const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _saveActive,
            const SingleActivator(LogicalKeyboardKey.keyO, control: true): _pickProject,
            const SingleActivator(LogicalKeyboardKey.keyO, meta: true): _pickProject,
            const SingleActivator(LogicalKeyboardKey.keyW, control: true): _closeActiveTab,
            const SingleActivator(LogicalKeyboardKey.keyW, meta: true): _closeActiveTab,
            const SingleActivator(LogicalKeyboardKey.keyP, control: true): _quickOpen,
            const SingleActivator(LogicalKeyboardKey.keyP, meta: true): _quickOpen,
            const SingleActivator(LogicalKeyboardKey.keyF, control: true, shift: true): _searchProject,
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true): _searchProject,
            const SingleActivator(LogicalKeyboardKey.keyH, control: true, shift: true): _replaceProject,
            const SingleActivator(LogicalKeyboardKey.keyH, meta: true, shift: true): _replaceProject,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                flexibleSpace: const FocusTint(),
                // Windows·Linux는 창 안 메뉴 막대, macOS는 화면 맨 위의 시스템 메뉴 막대.
                bottom: mac
                    ? null
                    : PreferredSize(
                        preferredSize: const Size.fromHeight(32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          // 창 가장자리에 붙지 않게 트리 칸의 안쪽 여백과 맞춘다.
                          child: Padding(padding: EdgeInsets.only(left: t.spaceMd), child: StudioMenuBar(menus: menus)),
                        ),
                      ),
                title: Text(
                  root == null
                      ? AppIdentity.displayName
                      : root.split(RegExp(r'[/\\]')).last,
                ),
                actions: [
                  TextButton.icon(
                    onPressed: _pickProject,
                    icon: Icon(context.icons.folderOpen, size: 18),
                    label: Text(AppLocalizations.of(context).studioOpenProject),
                  ),
                  RecentProjectsMenu(controller: _controller),
                  if (root != null) ...[
                    IconButton(
                      tooltip: AppLocalizations.of(context).studioQuickOpenTooltip,
                      icon: Icon(context.icons.search),
                      onPressed: _quickOpen,
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).studioSearchTooltip,
                      icon: Icon(context.icons.manageSearch),
                      onPressed: _searchProject,
                    ),
                  ],
                  if (root != null)
                    ListenableBuilder(
                      listenable: _layout,
                      builder: (context, _) => IconButton(
                        tooltip: _layout.dockOpen
                            ? AppLocalizations.of(context).studioDockHide
                            : AppLocalizations.of(context).studioDockShow,
                        isSelected: _layout.dockOpen,
                        icon: Icon(context.icons.viewSidebar),
                        onPressed: _layout.toggleDock,
                      ),
                    ),
                  IconButton(
                    tooltip: AppLocalizations.of(context).studioSettingsTooltip,
                    icon: Icon(context.icons.settings),
                    onPressed: _openSettings,
                  ),
                  const ThemeMenuButton(),
                  const LanguageMenuButton(),
                  if (widget.onAbout != null)
                    IconButton(
                      tooltip: AppLocalizations.of(context).aboutTooltip,
                      icon: Icon(context.icons.info),
                      onPressed: widget.onAbout,
                    ),
                  SizedBox(width: t.spaceSm),
                ],
              ),
              body: _dropTarget(
                child: root == null
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton.icon(
                              onPressed: _pickProject,
                              icon: Icon(context.icons.folderOpen),
                              label: Text(AppLocalizations.of(context).studioOpenProjectFolder),
                            ),
                            SizedBox(height: t.spaceLg),
                            RecentProjectsList(controller: _controller),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: _treeWidth,
                                child: TreePane(controller: _controller),
                              ),
                              _Splitter(
                                onDrag: (dx) => setState(
                                  () => _treeWidth = (_treeWidth + dx).clamp(
                                    160,
                                    520,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListenableBuilder(
                                  listenable: _layout,
                                  builder: (context, _) => Column(
                                    children: [
                                      Expanded(
                                        child: EditorPane(
                                          controller: _controller,
                                          problems: _problems,
                                        ),
                                      ),
                                      if (_layout.bottomOpen)
                                        _HorizontalSplitter(
                                          onDrag: (dy) => _layout.setBottomHeight(
                                            _layout.bottomHeight - dy,
                                          ),
                                        ),
                                      // 접어도 탭 줄은 아래에 남겨, 접혀 있다는 것과 다시 펴는 길을 보여 준다.
                                      SizedBox(
                                        height: _layout.bottomOpen ? _layout.bottomHeight : BottomPanel.collapsedHeight,
                                        child: BottomPanel(
                                          layout: _layout,
                                          run: _run,
                                          log: _log,
                                          problems: _problems,
                                          onOpenProblem: (d) => _controller.openAt(
                                            d.file,
                                            d.line,
                                            d.column,
                                          ),
                                          terminal: _terminal,
                                          terminalSettings: _terminalSettings,
                                          projectRoot: root,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 열리면 가로 제목 막대 + 내용, 닫히면 세로 제목 막대만 남긴다.
                              // 닫아도 Dock 위젯은 그대로 둔다 — 다시 열 때 저장소를 처음부터 읽지 않는다.
                              ListenableBuilder(
                                listenable: _layout,
                                builder: (context, _) {
                                  final l10n = AppLocalizations.of(context);
                                  final open = _layout.dockOpen;
                                  final dock = SizedBox(
                                    width: _layout.dockWidth,
                                    child: BranchDockDock(
                                      key: _dockKey,
                                      root: _controller.root,
                                      gate: _mergeGate,
                                      onOpenFolder: (path) => _controller.openProject(path, remember: false),
                                      onHeadChanged: _onBranchChanged,
                                      onShowDiff: _controller.openDiff,
                                    ),
                                  );
                                  if (!open) {
                                    return Row(
                                      children: [
                                        Offstage(child: dock),
                                        CollapsedDockBar(title: 'GIT', openTooltip: l10n.studioDockShow, onOpen: _layout.toggleDock),
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      _Splitter(onDrag: (dx) => _layout.setDockWidth(_layout.dockWidth - dx)),
                                      SizedBox(
                                        width: _layout.dockWidth,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            DockHeader(title: 'GIT', closeTooltip: l10n.studioDockHide, onClose: _layout.toggleDock),
                                            Expanded(child: dock),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        _StatusBar(
                          controller: _controller,
                          run: _run,
                          problems: _problems,
                          layout: _layout,
                        ),
                      ],
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Splitter extends StatelessWidget {
  const _Splitter({required this.onDrag});

  final void Function(double dx) onDrag;

  @override
  Widget build(BuildContext context) {
    final w = context.tokens.splitterWidth;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: SizedBox(
          width: w,
          child: VerticalDivider(width: w),
        ),
      ),
    );
  }
}

/// 편집기와 아래 패널 사이의 가로 구분선. 위아래로 끌어 아래 패널 높이를 바꾼다.
class _HorizontalSplitter extends StatelessWidget {
  const _HorizontalSplitter({required this.onDrag});

  final void Function(double dy) onDrag;

  @override
  Widget build(BuildContext context) {
    final w = context.tokens.splitterWidth;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (d) => onDrag(d.delta.dy),
        child: SizedBox(
          height: w,
          child: Divider(height: w),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.controller,
    required this.run,
    required this.problems,
    required this.layout,
  });

  final StudioController controller;
  final RunController run;
  final ProblemsController problems;
  final PanelLayout layout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final w = controller.currentWorktree;
    final tab = controller.activeTab;
    return ListenableBuilder(
      listenable: Listenable.merge([run, problems, layout]),
      builder: (context, _) {
        final rec = run.record;
        final (label, color) = switch (rec?.status) {
          VerifyStatus.confirmed => (l10n.studioVerifyConfirmed, t.success),
          VerifyStatus.built => (l10n.studioVerifyBuilt, t.warning),
          VerifyStatus.problem => (l10n.studioVerifyProblem, t.danger),
          null => (l10n.studioVerifyNone, theme.colorScheme.onSurfaceVariant),
        };
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.spaceMd,
            vertical: t.spaceXs,
          ),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall,
            child: Row(
              children: [
                Icon(
                  context.icons.accountTree,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: t.spaceXs + 2),
                Text(w == null ? l10n.studioNotRepo : w.label),
                if (w?.byClaude ?? false) const Text('  · Claude worktree'),
                if (run.snapshot != null) Text('  @${run.snapshot!.shortSha}'),
                SizedBox(width: t.spaceMd),
                Icon(context.icons.verified, size: 14, color: color),
                SizedBox(width: t.spaceXs),
                Text(label, style: TextStyle(color: color)),
                SizedBox(width: t.spaceMd),
                // 문제 개수를 누르면 아래 패널이 열리고 문제 탭이 보인다.
                Tooltip(
                  message: l10n.studioShowProblems,
                  child: InkWell(
                    onTap: () => layout.showBottom(BottomTab.problems),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (problems.running)
                          Text(l10n.studioAnalyzing)
                        else if (problems.packageRoot != null &&
                            problems.analyzed) ...[
                          Icon(
                            context.icons.error,
                            size: 14,
                            color: problems.errors > 0
                                ? t.danger
                                : theme.colorScheme.outline,
                          ),
                          SizedBox(width: t.spaceXs),
                          Text('${problems.errors}'),
                          SizedBox(width: t.spaceSm),
                          Icon(
                            context.icons.warningAmber,
                            size: 14,
                            color: problems.warnings > 0
                                ? t.warning
                                : theme.colorScheme.outline,
                          ),
                          SizedBox(width: t.spaceXs),
                          Text('${problems.warnings}'),
                        ] else
                          Icon(
                            context.icons.error,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (tab != null) Text(tab.dirty ? l10n.studioDirty : l10n.studioSaved),
                SizedBox(width: t.spaceSm),
                Tooltip(
                  message: layout.bottomOpen
                      ? l10n.studioBottomPanelHide
                      : l10n.studioBottomPanelShow,
                  child: InkWell(
                    onTap: layout.toggleBottom,
                    child: Icon(
                      layout.bottomOpen
                          ? context.icons.expandMore
                          : context.icons.expandLess,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
