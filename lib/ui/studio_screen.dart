import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/command_log.dart';
import '../core/command_runner.dart';
import '../devices/device_service.dart';
import '../run/run_controller.dart';
import '../studio/studio_controller.dart';
import '../studio/worktree.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../verify/verify_store.dart';
import 'editor_pane.dart';
import 'file_tree.dart';
import 'run_panel.dart';
import 'theme_menu.dart';

/// 프로젝트 트리 | 편집기 | Dock 패널 (3단) + 하단 상태 막대.
class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key, required this.theme});

  final ThemeController theme;

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final _controller = StudioController();
  late final CommandLog _log = CommandLog();
  late final CommandRunner _runner = CommandRunner(_log);
  late final RunController _run = RunController(
    runner: _runner,
    deviceService: ProcessDeviceService(_runner),
    store: VerifyStore(_runner),
  );
  double _treeWidth = 260;
  double _dockWidth = 400;
  String? _lastRoot;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStudioChanged);
    _controller.restore();
    _run.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStudioChanged);
    _controller.dispose();
    _run.dispose();
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
    }
  }

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
        return Scaffold(
          appBar: AppBar(
            title: Text(root == null ? 'Daylight Flutter Studio' : root.split(RegExp(r'[/\\]')).last),
            actions: [
              TextButton.icon(onPressed: _pickProject, icon: const Icon(Icons.folder_open, size: 18), label: const Text('프로젝트 열기')),
              ThemeMenu(controller: widget.theme),
              SizedBox(width: t.spaceSm),
            ],
          ),
          body: root == null
              ? Center(child: FilledButton.icon(onPressed: _pickProject, icon: const Icon(Icons.folder_open), label: const Text('프로젝트 폴더 열기')))
              : Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(width: _treeWidth, child: _TreePane(controller: _controller)),
                          _Splitter(onDrag: (dx) => setState(() => _treeWidth = (_treeWidth + dx).clamp(160, 520))),
                          Expanded(child: EditorPane(controller: _controller)),
                          _Splitter(onDrag: (dx) => setState(() => _dockWidth = (_dockWidth - dx).clamp(300, 700))),
                          SizedBox(width: _dockWidth, child: _DockPane(run: _run, log: _log)),
                        ],
                      ),
                    ),
                    const Divider(),
                    _StatusBar(controller: _controller, run: _run),
                  ],
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
        child: SizedBox(width: w, child: VerticalDivider(width: w)),
      ),
    );
  }
}

class _TreePane extends StatelessWidget {
  const _TreePane({required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final root = controller.root!;
    final worktrees = controller.worktrees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (worktrees.length > 1)
          Padding(
            padding: EdgeInsets.fromLTRB(t.spaceSm, t.spaceSm, t.spaceSm, t.spaceXs),
            child: DropdownButtonFormField<Worktree>(
              isExpanded: true,
              initialValue: controller.currentWorktree,
              decoration: const InputDecoration(labelText: 'worktree'),
              items: [
                for (final w in worktrees)
                  DropdownMenuItem(
                    value: w,
                    child: Row(
                      children: [
                        if (w.byClaude) ...[const Icon(Icons.smart_toy_outlined, size: 16), SizedBox(width: t.spaceXs)],
                        Expanded(child: Text(w.label, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
              ],
              onChanged: (w) => w == null ? null : controller.switchWorktree(w),
            ),
          ),
        Expanded(
          child: FileTree(
            key: ValueKey(root),
            root: root,
            activePath: controller.activeTab?.path,
            onOpenFile: controller.openFile,
          ),
        ),
      ],
    );
  }
}

/// Run(Flutty Dock)·Git(Branch Dock) 패널. Git 패널은 3단계에서 채운다.
class _DockPane extends StatelessWidget {
  const _DockPane({required this.run, required this.log});

  final RunController run;
  final CommandLog log;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Run'), Tab(text: 'Git')]),
          Expanded(
            child: TabBarView(
              children: [
                RunPanel(controller: run, log: log),
                const Center(child: Text('Git 패널 (3단계)')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller, required this.run});

  final StudioController controller;
  final RunController run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final w = controller.currentWorktree;
    final tab = controller.activeTab;
    return ListenableBuilder(
      listenable: run,
      builder: (context, _) {
        final rec = run.record;
        final (label, color) = switch (rec?.status) {
          VerifyStatus.confirmed => ('검증됨', t.success),
          VerifyStatus.built => ('빌드만 됨', t.warning),
          VerifyStatus.problem => ('문제 있음', t.danger),
          null => ('미검증', theme.colorScheme.onSurfaceVariant),
        };
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall,
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined, size: 14, color: theme.colorScheme.primary),
                SizedBox(width: t.spaceXs + 2),
                Text(w == null ? '저장소 아님' : w.label),
                if (w?.byClaude ?? false) const Text('  · Claude worktree'),
                if (run.snapshot != null) Text('  @${run.snapshot!.shortSha}'),
                SizedBox(width: t.spaceMd),
                Icon(Icons.verified_outlined, size: 14, color: color),
                SizedBox(width: t.spaceXs),
                Text(label, style: TextStyle(color: color)),
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
