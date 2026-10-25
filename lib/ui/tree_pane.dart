import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../studio/studio_controller.dart';
import '../studio/worktree.dart';
import '../theme/app_theme.dart';
import 'file_tree.dart';

/// 왼쪽 파일 트리 영역. 위쪽 한 줄에 worktree 선택(둘 이상일 때)과 새로 고침 단추를 나란히 둔다.
class TreePane extends StatelessWidget {
  const TreePane({super.key, required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final root = controller.root!;
    final worktrees = controller.worktrees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(t.spaceSm, t.spaceSm, t.spaceXs, t.spaceXs),
          child: Row(
            children: [
              Expanded(
                child: worktrees.length > 1
                    ? _WorktreePicker(controller: controller)
                    : Text(AppLocalizations.of(context).treeExplorer, style: Theme.of(context).textTheme.labelLarge),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).treeRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: controller.refreshTree,
              ),
            ],
          ),
        ),
        Expanded(
          child: FileTree(
            key: ValueKey(root),
            root: root,
            activePath: controller.activeTab?.path,
            revision: controller.treeRevision,
            onOpenFile: controller.openFile,
          ),
        ),
      ],
    );
  }
}

class _WorktreePicker extends StatelessWidget {
  const _WorktreePicker({required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DropdownButtonFormField<Worktree>(
      isExpanded: true,
      initialValue: controller.currentWorktree,
      decoration: const InputDecoration(labelText: 'worktree'),
      items: [
        for (final w in controller.worktrees)
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
    );
  }
}
