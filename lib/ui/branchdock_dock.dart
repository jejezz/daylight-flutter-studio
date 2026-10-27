import 'dart:async';

import 'package:flutter/material.dart';

import '../branchdock/core/command_log.dart';
import '../branchdock/core/command_runner.dart';
import '../branchdock/git/commands.dart';
import '../branchdock/l10n/app_localizations.dart';
import '../branchdock/release/release_flow.dart';
import '../branchdock/release/repo_release_info.dart';
import '../branchdock/repo/environment.dart';
import '../branchdock/repo/next_action.dart';
import '../branchdock/repo/repo_controller.dart';
import '../branchdock/repo/repo_prefs.dart';
import '../branchdock/theme/app_theme.dart';
import '../branchdock/ui/command_bar.dart';
import '../branchdock/ui/merge_gate.dart';
import '../branchdock/ui/repo_scope.dart';
import '../branchdock/ui/services.dart';
import '../branchdock/ui/status_header.dart';
import '../branchdock/ui/tabs/branches_tab.dart';
import '../branchdock/ui/tabs/changes_tab.dart';
import '../branchdock/ui/tabs/history_tab.dart';
import '../branchdock/ui/tabs/pr_tab.dart';
import '../branchdock/ui/tabs/release_tab.dart';
import '../branchdock/ui/tabs/remotes_tab.dart';
import '../branchdock/ui/tabs/tags_tab.dart';
import '../branchdock/ui/widgets.dart';

/// 오른쪽의 Git 패널: Branch Dock의 화면을 그대로 쓴다.
///
/// 위에서부터 상태 헤더 → 다음 할 일 배너 → 아이콘 탭(변경·브랜치·태그·원격·릴리스·PR·기록) → 내용 → 명령 막대.
/// CI 탭은 두지 않는다. 열린 프로젝트 폴더가 바뀌면 그 저장소를 다시 연다.
class BranchDockDock extends StatefulWidget {
  const BranchDockDock({
    super.key,
    required this.root,
    this.gate,
    this.onOpenFolder,
    this.onHeadChanged,
    this.onShowDiff,
    this.onOpenFile,
    this.services,
  });

  /// 열린 프로젝트 폴더. 없으면 안내만 보인다.
  final String? root;

  /// PR 병합 관문 (Studio 전용). 없으면 Branch Dock과 같다.
  final MergeGateSource? gate;

  /// 브랜치가 체크아웃된 다른 worktree 폴더를 연다.
  final void Function(String path)? onOpenFolder;

  /// 브랜치 전환·커밋·병합 등으로 HEAD가 바뀐 뒤 (파일과 비교 기준을 새로 읽을 때).
  final VoidCallback? onHeadChanged;

  /// 변경 파일을 눌렀을 때 Studio 편집기의 변경점 보기로 연다. 절대 경로를 받아 열었으면 true.
  final Future<bool> Function(String path)? onShowDiff;

  /// 변경 파일을 더블클릭했을 때 Studio 내장 편집기로 연다. 절대 경로를 받아 열었으면 true.
  final Future<bool> Function(String path)? onOpenFile;
  // onOpenFolder·onHeadChanged·onShowDiff·onOpenFile와 MergeGateScope(`lib/branchdock/ui/merge_gate.dart`)가 Branch Dock 원본에서 Studio에 맞게
  // 더한 연결점의 전부다. 나머지 `lib/branchdock/`은 원본 그대로(문구·아이콘 규칙만 바꿈)다.

  /// 테스트용. 없으면 PATH를 읽어 직접 만든다.
  final AppServices? services;

  @override
  State<BranchDockDock> createState() => _BranchDockDockState();
}

class _BranchDockDockState extends State<BranchDockDock> with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _tabCount = 7;
  static const _tabChanges = 0, _tabBranches = 1, _tabRemotes = 3, _tabRelease = 4;

  AppServices? _services;
  EnvironmentStatus _env = const EnvironmentStatus();
  RepoController? _repo;
  ReleaseFlow? _flow;
  OpenFailure? _failure;
  String? _opening;
  bool _logExpanded = false;
  String? _lastHeadKey;
  Timer? _autoFetch;
  final _dismissed = <String>{};
  final _commitFocus = FocusNode();
  late final TabController _tabs = TabController(length: _tabCount, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabs.addListener(() {
      final repo = _repo;
      if (repo != null && !_tabs.indexIsChanging) _services?.prefs.setLastTab(repo.root, _tabs.index);
    });
    unawaited(_start());
  }

  Future<void> _start() async {
    var services = widget.services;
    if (services == null) {
      final prefs = await RepoPrefs.load();
      services = AppServices(
        runner: CommandRunner(
          log: CommandLog(),
          path: await resolvePath(),
          gitPath: prefs.toolPath('git'),
          ghPath: prefs.toolPath('gh'),
        ),
        prefs: prefs,
      );
    }
    if (!mounted) return;
    setState(() => _services = services);
    _autoFetch = Timer.periodic(const Duration(minutes: 5), (_) {
      if (services!.prefs.autoFetch) _repo?.backgroundFetch();
    });
    final env = await EnvironmentStatus.check(services.runner, widget.root ?? '.');
    if (!mounted) return;
    _repo?.ghReady = env.ghReady;
    _flow?.ghReady = env.ghReady;
    setState(() => _env = env);
    await _open(widget.root);
  }

  @override
  void didUpdateWidget(BranchDockDock old) {
    super.didUpdateWidget(old);
    if (old.root != widget.root && _services != null) unawaited(_open(widget.root));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoFetch?.cancel();
    _repo?.removeListener(_onRepoChanged);
    _flow?.dispose();
    _repo?.dispose();
    _tabs.dispose();
    _commitFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 다른 앱(터미널, Claude Code)에서 돌아오면 상태를 다시 읽는다.
    if (state != AppLifecycleState.resumed) return;
    final repo = _repo;
    if (repo == null) return;
    repo.refresh();
    repo.loadHeadPr();
    if (_services?.prefs.autoFetch ?? false) repo.backgroundFetch();
    _flow?.poll();
  }

  Future<void> _open(String? path) async {
    final services = _services;
    if (services == null) return;
    _opening = path;
    if (path == null) {
      _closeRepo();
      return;
    }
    final (repo, failure) = await RepoController.open(services.runner, path);
    if (!mounted || _opening != path) {
      repo?.dispose();
      return;
    }
    if (repo == null) {
      _closeRepo();
      setState(() => _failure = failure);
      return;
    }
    _closeRepo();
    final flow = ReleaseFlow(repo, ghReady: _env.ghReady)
      ..customVersionFile = services.prefs.customVersionFile(repo.root);
    repo.ghReady = _env.ghReady;
    repo.addListener(_onRepoChanged);
    unawaited(repo.loadHeadPr());
    setState(() {
      _repo = repo;
      _flow = flow;
      _failure = null;
      _lastHeadKey = repo.loaded ? _headKey(repo) : null;
      _dismissed.clear();
    });
    _tabs.index = services.prefs.lastTab(repo.root).clamp(0, _tabCount - 1);
    // 진행 중이던 릴리스가 있으면 이어서 연다.
    if (await flow.resume() && mounted && _flow == flow) _tabs.index = _tabRelease;
  }

  void dismiss(String key) => setState(() => _dismissed.add(key));

  void _closeRepo() {
    _repo?.removeListener(_onRepoChanged);
    _flow?.dispose();
    _repo?.dispose();
    if (mounted) {
      setState(() {
        _repo = null;
        _flow = null;
        _failure = null;
      });
    }
  }

  String _headKey(RepoController repo) => '${repo.status.head} ${repo.status.oid}';

  /// HEAD가 달라졌을 때만 바깥에 알린다 (상태 새로 읽기마다 부르지 않는다).
  void _onRepoChanged() {
    final repo = _repo;
    if (repo == null || !repo.loaded) return;
    final key = '${repo.status.head}\n${repo.status.oid}';
    if (key == _lastHeadKey) return;
    final first = _lastHeadKey == null;
    _lastHeadKey = key;
    if (!first) widget.onHeadChanged?.call();
  }

  /// 릴리스 탭으로 가서 마법사를 시작한다 (태그 탭의 버전 불일치 안내).
  void _openReleaseWizard() {
    final repo = _repo;
    final flow = _flow;
    if (repo == null || flow == null) return;
    _tabs.animateTo(_tabRelease);
    if (flow.checks.isEmpty &&
        flow.step == ReleaseStep.check &&
        repo.githubRemote != null &&
        _env.ghReady &&
        missingReleaseFiles(repo.root).isEmpty) {
      flow.ghReady = _env.ghReady;
      flow.runChecks();
    }
  }

  Future<void> _initRepository() async {
    final root = widget.root;
    final services = _services;
    if (root == null || services == null) return;
    final r = await services.runner.run(GitCommands.init, workingDirectory: root);
    if (!mounted) return;
    if (r.ok) {
      await _open(root);
    } else {
      showCommandError(context, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) return const Center(child: CircularProgressIndicator());
    final repo = _repo;
    Widget body = repo == null
        ? _NoRepo(root: widget.root, failure: _failure, onInit: _initRepository)
        : RepoScope(
            repo: repo,
            environment: _env,
            openRepo: widget.onOpenFolder,
            child: _RepoView(state: this),
          );
    final gate = widget.gate;
    if (gate != null) body = MergeGateScope(gate: gate, child: body);
    return ServicesScope(
      services: services,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: body),
          CommandBar(
            log: services.log,
            expanded: _logExpanded,
            onToggle: () => setState(() => _logExpanded = !_logExpanded),
            onCancel: repo?.cancel,
          ),
        ],
      ),
    );
  }
}

class _NoRepo extends StatelessWidget {
  const _NoRepo({required this.root, required this.failure, required this.onInit});

  final String? root;
  final OpenFailure? failure;
  final VoidCallback onInit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = root;
    if (path == null) {
      return EmptyState(icon: context.icons.folderOpen, title: l10n.bdDockNoFolder);
    }
    return EmptyState(
      icon: context.icons.folderOpen,
      title: failure == OpenFailure.notFound ? l10n.bdStartNotFound(path) : l10n.bdStartNotARepository(path),
      action: failure == OpenFailure.notARepository ? FilledButton(onPressed: onInit, child: Text(l10n.bdStartInitRepository)) : null,
    );
  }
}

class _RepoView extends StatelessWidget {
  const _RepoView({required this.state});

  final _BranchDockDockState state;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (!repo.loaded) return const Center(child: CircularProgressIndicator());

    final next = suggestNextAction(
      status: repo.status,
      remotes: repo.remotes,
      headMergedAndGone: repo.headMergedAndGone,
      suggestPr: repo.shouldSuggestPr,
    );
    final showNext = next != null && !state._dismissed.contains(next.key);

    // 이 패널은 좁다 (300–700px). 탭을 모두 같은 폭으로 두고 좁으면 가로로 스크롤한다.
    final labels = [
      l10n.bdTabChanges,
      l10n.bdTabBranches,
      l10n.bdTabTags,
      l10n.bdTabRemotes,
      l10n.bdTabRelease,
      l10n.bdTabPr,
      l10n.bdTabHistory,
    ];
    final icons = context.icons;
    Widget icon(int i) => switch (i) {
          0 => Badge(
              isLabelVisible: repo.status.changedCount > 0,
              label: Text('${repo.status.changedCount}'),
              child: Icon(icons.editNote, size: 20),
            ),
          1 => Icon(icons.callSplit, size: 20),
          2 => Icon(icons.sell, size: 20),
          3 => Icon(icons.cloud, size: 20),
          4 => ListenableBuilder(
              listenable: state._flow!,
              builder: (context, _) {
                final flow = state._flow!;
                // 진행 중인 릴리스가 있으면 점으로 알린다.
                final active = flow.step != ReleaseStep.check && flow.step != ReleaseStep.done;
                return Badge(isLabelVisible: active, smallSize: 8, child: Icon(icons.rocketLaunch, size: 20));
              },
            ),
          5 => Icon(icons.merge, size: 20),
          _ => Icon(icons.history, size: 20),
        };

    final labelStyle = theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    final tabWidth = labels
            .map((t) => (TextPainter(
                  text: TextSpan(text: t, style: labelStyle),
                  textDirection: TextDirection.ltr,
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout())
                    .width)
            .reduce((a, b) => a > b ? a : b)
            .ceilToDouble() +
        12;
    // 패널 폭을 알 수 없으니 (화면 폭이 아니라) 실제 제약으로 정한다.
    return LayoutBuilder(
      builder: (context, constraints) {
        final scroll = constraints.maxWidth < tabWidth * labels.length;
        return Column(
          children: [
            StatusHeader(onBranchTap: () => state._tabs.animateTo(_BranchDockDockState._tabBranches)),
            _DelayedProgress(visible: repo.busy),
            if (showNext)
              NextActionBanner(
                action: next,
                onDismiss: () => state.dismiss(next.key),
                onShowChanges: () => state._tabs.animateTo(_BranchDockDockState._tabChanges),
                onShowRemotes: () => state._tabs.animateTo(_BranchDockDockState._tabRemotes),
              ),
            TabBar(
              controller: state._tabs,
              isScrollable: scroll,
              tabAlignment: scroll ? TabAlignment.center : TabAlignment.fill,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: labelStyle,
              unselectedLabelStyle: theme.textTheme.labelMedium,
              tabs: [
                for (var i = 0; i < labels.length; i++)
                  SizedBox(
                    width: scroll ? tabWidth : null,
                    child: Tab(height: 48, icon: icon(i), text: labels[i]),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: state._tabs,
                // 목록을 옆으로 쓸다가 탭이 바뀌지 않게 한다.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ChangesTab(commitFocus: state._commitFocus, onShowDiff: state.widget.onShowDiff, onOpenFile: state.widget.onOpenFile),
                  const BranchesTab(),
                  TagsTab(onOpenReleaseWizard: state._openReleaseWizard),
                  const RemotesTab(),
                  ReleaseTab(flow: state._flow!, onShowChanges: () => state._tabs.animateTo(_BranchDockDockState._tabChanges)),
                  const PrTab(),
                  const HistoryTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 0.5초 이상 걸리는 작업만 진행 표시.
class _DelayedProgress extends StatefulWidget {
  const _DelayedProgress({required this.visible});

  final bool visible;

  @override
  State<_DelayedProgress> createState() => _DelayedProgressState();
}

class _DelayedProgressState extends State<_DelayedProgress> {
  Timer? _timer;
  bool _show = false;

  @override
  void didUpdateWidget(_DelayedProgress old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) {
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _show = true);
      });
    } else if (!widget.visible) {
      _timer?.cancel();
      _show = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(height: 2, child: _show ? const LinearProgressIndicator(minHeight: 2) : null);
}
