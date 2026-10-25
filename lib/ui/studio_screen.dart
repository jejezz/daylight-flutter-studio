import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../studio/studio_controller.dart';
import '../studio/worktree.dart';
import 'editor_pane.dart';
import 'file_tree.dart';

/// 프로젝트 트리 | 편집기 | Dock 패널 (3단) + 하단 상태 막대.
class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final _controller = StudioController();
  double _treeWidth = 260;
  double _dockWidth = 380;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_showMessage);
    _controller.restore();
  }

  @override
  void dispose() {
    _controller.removeListener(_showMessage);
    _controller.dispose();
    super.dispose();
  }

  void _showMessage() {
    final m = _controller.message;
    if (m == null || !mounted) return;
    _controller.clearMessage();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pickProject() async {
    final dir = await getDirectoryPath(confirmButtonText: '프로젝트 열기');
    if (dir != null) await _controller.openProject(dir);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final root = _controller.root;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 44,
            title: Text(root == null ? 'Daylight Flutter Studio' : root.split(RegExp(r'[/\\]')).last, style: const TextStyle(fontSize: 15)),
            actions: [
              TextButton.icon(onPressed: _pickProject, icon: const Icon(Icons.folder_open, size: 18), label: const Text('프로젝트 열기')),
              const SizedBox(width: 8),
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
                          _Splitter(onDrag: (dx) => setState(() => _dockWidth = (_dockWidth - dx).clamp(280, 640))),
                          SizedBox(width: _dockWidth, child: const _DockPane()),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _StatusBar(controller: _controller),
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
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: SizedBox(width: 6, child: VerticalDivider(width: 6, color: Theme.of(context).dividerColor)),
      ),
    );
  }
}

class _TreePane extends StatelessWidget {
  const _TreePane({required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final root = controller.root!;
    final worktrees = controller.worktrees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (worktrees.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: DropdownButtonFormField<Worktree>(
              isExpanded: true,
              initialValue: controller.currentWorktree,
              decoration: const InputDecoration(labelText: 'worktree', isDense: true, border: OutlineInputBorder()),
              items: [
                for (final w in worktrees)
                  DropdownMenuItem(
                    value: w,
                    child: Text('${w.byClaude ? '🤖 ' : ''}${w.label}', overflow: TextOverflow.ellipsis),
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

/// Run(Flutty Dock)·Git(Branch Dock) 패널 자리. 2·3단계에서 채운다.
class _DockPane extends StatelessWidget {
  const _DockPane();

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [Tab(text: 'Run'), Tab(text: 'Git')]),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Run 패널 (2단계)')),
                Center(child: Text('Git 패널 (3단계)')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final w = controller.currentWorktree;
    final tab = controller.activeTab;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(w == null ? '저장소 아님' : w.label, style: const TextStyle(fontSize: 12)),
          if (w?.byClaude ?? false) const Text('  · Claude worktree', style: TextStyle(fontSize: 12)),
          const Spacer(),
          if (tab != null) Text(tab.dirty ? '수정됨 (Ctrl+S 저장)' : '저장됨', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
