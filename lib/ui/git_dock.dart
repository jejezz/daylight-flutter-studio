import 'package:flutter/material.dart';

import '../git/git_controller.dart';
import '../l10n/app_localizations.dart';
import 'git_panel.dart';

/// 오른쪽의 Git 패널: 전체 높이를 쓰고 자기 탭 줄을 가진다.
///
/// 지금은 "변경" 탭 하나(상태·스테이지·커밋·동기화·PR·병합 관문)이고,
/// Branch Dock의 브랜치·태그·원격·기록·릴리스 탭이 이 옆에 하나씩 붙는다.
class GitDock extends StatelessWidget {
  const GitDock({super.key, required this.git, required this.onOpenDiff});

  final GitController git;
  final void Function(String absolutePath) onOpenDiff;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [Tab(text: l10n.gitTabChanges)],
          ),
          Expanded(
            child: TabBarView(
              // 탭이 늘어도 목록을 옆으로 쓸다가 탭이 바뀌지 않게 한다.
              physics: const NeverScrollableScrollPhysics(),
              children: [GitPanel(controller: git, onOpenDiff: onOpenDiff)],
            ),
          ),
        ],
      ),
    );
  }
}
