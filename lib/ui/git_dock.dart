import 'package:flutter/material.dart';

import '../git/branches_controller.dart';
import '../git/git_controller.dart';
import '../l10n/app_localizations.dart';
import '../studio/worktree.dart';
import 'branches_tab.dart';
import 'git_panel.dart';

/// 오른쪽의 Git 패널: 전체 높이를 쓰고 자기 탭 줄을 가진다.
///
/// 탭: 변경(상태·스테이지·커밋·동기화·PR·병합 관문), 브랜치.
/// Branch Dock의 태그·원격·기록·릴리스 탭이 이 옆에 하나씩 붙는다.
class GitDock extends StatefulWidget {
  const GitDock({
    super.key,
    required this.git,
    required this.branches,
    required this.onOpenDiff,
    this.onOpenWorktree,
  });

  final GitController git;
  final BranchesController branches;
  final void Function(String absolutePath) onOpenDiff;
  final void Function(Worktree worktree)? onOpenWorktree;

  @override
  State<GitDock> createState() => _GitDockState();
}

class _GitDockState extends State<GitDock> with SingleTickerProviderStateMixin {
  static const _branchesIndex = 1;

  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTab);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// 브랜치 탭을 열 때마다 목록을 새로 읽는다 (다른 도구나 터미널에서 바뀌었을 수 있다).
  void _onTab() {
    if (!_tabs.indexIsChanging && _tabs.index == _branchesIndex) widget.branches.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [Tab(text: l10n.gitTabChanges), Tab(text: l10n.gitTabBranches)],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            // 탭이 늘어도 목록을 옆으로 쓸다가 탭이 바뀌지 않게 한다.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GitPanel(controller: widget.git, onOpenDiff: widget.onOpenDiff),
              BranchesTab(controller: widget.branches, onOpenWorktree: widget.onOpenWorktree),
            ],
          ),
        ),
      ],
    );
  }
}
