import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/command_log.dart';
import '../core/command_runner.dart';
import '../devices/device_service.dart';
import '../git/git_controller.dart';
import '../run/run_controller.dart';
import '../problems/dart_analyzer.dart';
import '../problems/diagnostic.dart';
import '../problems/problems_controller.dart';
import '../studio/dart_formatter.dart';
import '../studio/git_base.dart';
import '../studio/studio_controller.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../verify/verify_store.dart';
import 'editor_pane.dart';
import 'git_panel.dart';
import 'problems_panel.dart';
import 'run_panel.dart';
import 'settings_dialog.dart';
import 'tree_pane.dart';

/// 프로젝트 트리 | 편집기 | Dock 패널 (3단) + 하단 상태 막대.
class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key, required this.theme});

  final ThemeController theme;

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
    onSaved: (path) => _problems.onSaved(path),
  );
  late final DartAnalyzer _analyzer = DartAnalyzer(_runner);
  late final ProblemsController _problems = ProblemsController(
    analyze: _analyzer.run,
    pubGet: _analyzer.pubGet,
  );
  late final RunController _run = RunController(
    runner: _runner,
    deviceService: ProcessDeviceService(_runner),
    store: VerifyStore(_runner),
  );
  late final GitController _git = GitController(
    runner: _runner,
    store: VerifyStore(_runner),
  );
  double _treeWidth = 260;
  double _dockWidth = 400;
  String? _lastRoot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onStudioChanged);
    _controller.restore();
    _controller.startWatching();
    _git.addListener(_onGitChanged);
    _run.init();
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

  String? _lastHead;

  /// 커밋이나 브랜치 전환으로 HEAD가 바뀌면 열린 파일의 비교 기준(HEAD 내용)을 다시 읽는다.
  void _onGitChanged() {
    final head = _git.status?.oid;
    if (head == _lastHead) return;
    _lastHead = head;
    _controller.refreshBases();
  }

  Future<void> _openSettings() =>
      showSettingsDialog(context, theme: widget.theme);

  Future<void> _pickProject() async {
    final dir = await getDirectoryPath(confirmButtonText: '프로젝트 열기');
    if (dir != null) await _controller.openProject(dir);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final root = _controller.root;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.comma, control: true):
                _openSettings,
            const SingleActivator(LogicalKeyboardKey.comma, meta: true):
                _openSettings,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  root == null
                      ? 'Daylight Flutter Studio'
                      : root.split(RegExp(r'[/\\]')).last,
                ),
                actions: [
                  TextButton.icon(
                    onPressed: _pickProject,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('프로젝트 열기'),
                  ),
                  IconButton(
                    tooltip: '설정 (Ctrl+,)',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: _openSettings,
                  ),
                  SizedBox(width: t.spaceSm),
                ],
              ),
              body: root == null
                  ? Center(
                      child: FilledButton.icon(
                        onPressed: _pickProject,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('프로젝트 폴더 열기'),
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
                                child: EditorPane(
                                  controller: _controller,
                                  problems: _problems,
                                ),
                              ),
                              _Splitter(
                                onDrag: (dx) => setState(
                                  () => _dockWidth = (_dockWidth - dx).clamp(
                                    300,
                                    700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: _dockWidth,
                                child: _DockPane(
                                  run: _run,
                                  git: _git,
                                  log: _log,
                                  problems: _problems,
                                  onOpenDiff: _controller.openDiff,
                                  onOpenProblem: (d) => _controller.openAt(
                                    d.file,
                                    d.line,
                                    d.column,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        _StatusBar(
                          controller: _controller,
                          run: _run,
                          problems: _problems,
                        ),
                      ],
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

/// Run(Flutty Dock)·Git(Branch Dock) 패널.
class _DockPane extends StatelessWidget {
  const _DockPane({
    required this.run,
    required this.git,
    required this.log,
    required this.problems,
    required this.onOpenDiff,
    required this.onOpenProblem,
  });

  final ProblemsController problems;
  final void Function(Diagnostic diagnostic) onOpenProblem;
  final RunController run;
  final void Function(String absolutePath) onOpenDiff;
  final GitController git;
  final CommandLog log;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              const Tab(text: 'Run'),
              const Tab(text: 'Git'),
              // 오류가 있으면 탭 이름에 개수를 붙여 다른 탭을 보고 있어도 알아챌 수 있게 한다.
              ListenableBuilder(
                listenable: problems,
                builder: (context, _) {
                  final errors = problems.errors;
                  final warnings = problems.warnings;
                  final badge = errors > 0
                      ? ' $errors'
                      : (warnings > 0 ? ' $warnings' : '');
                  final color = errors > 0
                      ? context.tokens.danger
                      : context.tokens.warning;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('문제'),
                        if (badge.isNotEmpty)
                          Text(
                            badge,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                RunPanel(controller: run, log: log),
                GitPanel(controller: git, onOpenDiff: onOpenDiff),
                ProblemsPanel(controller: problems, onOpen: onOpenProblem),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.controller,
    required this.run,
    required this.problems,
  });

  final StudioController controller;
  final RunController run;
  final ProblemsController problems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final w = controller.currentWorktree;
    final tab = controller.activeTab;
    return ListenableBuilder(
      listenable: Listenable.merge([run, problems]),
      builder: (context, _) {
        final rec = run.record;
        final (label, color) = switch (rec?.status) {
          VerifyStatus.confirmed => ('검증됨', t.success),
          VerifyStatus.built => ('빌드만 됨', t.warning),
          VerifyStatus.problem => ('문제 있음', t.danger),
          null => ('미검증', theme.colorScheme.onSurfaceVariant),
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
                  Icons.account_tree_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: t.spaceXs + 2),
                Text(w == null ? '저장소 아님' : w.label),
                if (w?.byClaude ?? false) const Text('  · Claude worktree'),
                if (run.snapshot != null) Text('  @${run.snapshot!.shortSha}'),
                SizedBox(width: t.spaceMd),
                Icon(Icons.verified_outlined, size: 14, color: color),
                SizedBox(width: t.spaceXs),
                Text(label, style: TextStyle(color: color)),
                SizedBox(width: t.spaceMd),
                if (problems.running)
                  const Text('분석 중…')
                else if (problems.packageRoot != null && problems.analyzed) ...[
                  Icon(
                    Icons.error,
                    size: 14,
                    color: problems.errors > 0
                        ? t.danger
                        : theme.colorScheme.outline,
                  ),
                  SizedBox(width: t.spaceXs),
                  Text('${problems.errors}'),
                  SizedBox(width: t.spaceSm),
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: problems.warnings > 0
                        ? t.warning
                        : theme.colorScheme.outline,
                  ),
                  SizedBox(width: t.spaceXs),
                  Text('${problems.warnings}'),
                ],
                const Spacer(),
                if (tab != null) Text(tab.dirty ? '수정됨 (Ctrl+S 저장)' : '저장됨'),
              ],
            ),
          ),
        );
      },
    );
  }
}
