import 'package:flutter/material.dart';

import '../git/git_controller.dart';
import '../git/status.dart';
import '../settings/gate_settings.dart';
import '../l10n/app_localizations.dart';
import 'release_dialog.dart';
import '../theme/app_theme.dart';
import '../verify/verify_state.dart';

/// Git 패널: 브랜치 상태, 현재 브랜치의 PR과 병합, 그리고 PR head 커밋의 검증 상태.
/// 검증 상태는 지금은 보여 주기만 한다 (병합을 막는 관문은 4단계).
class GitPanel extends StatefulWidget {
  const GitPanel({super.key, required this.controller, this.onOpenDiff});

  final GitController controller;

  /// 변경된 파일을 누르면 그 파일의 변경점 보기를 연다 (절대 경로).
  final void Function(String absolutePath)? onOpenDiff;

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> {
  final _title = TextEditingController();
  PrMergeMethod _method = PrMergeMethod.merge;
  bool _deleteBranch = true;
  String? _titleFor;

  GitController get c => widget.controller;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// 브랜치가 바뀌면 PR 제목 기본값을 마지막 커밋 제목으로 다시 채운다.
  Future<void> _prefillTitle() async {
    final branch = c.status?.head;
    if (branch == null || _titleFor == branch) return;
    _titleFor = branch;
    final subject = await c.lastCommitSubject();
    if (mounted && _titleFor == branch) _title.text = subject;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: Listenable.merge([c, if (c.gate != null) c.gate!]),
      builder: (context, _) {
        final s = c.status;
        if (c.dir == null || s == null) {
          return Center(child: Text(AppLocalizations.of(context).gitNotRepo));
        }
        _prefillTitle();
        return ListView(
          padding: EdgeInsets.all(t.spaceMd),
          children: [
            _BranchHeader(controller: c, onOpenDiff: widget.onOpenDiff),
            SizedBox(height: t.spaceMd),
            _Sync(controller: c),
            if (c.message != null) ...[
              SizedBox(height: t.spaceSm),
              Text(c.message!, style: TextStyle(color: c.messageOk ? t.success : t.danger)),
            ],
            SizedBox(height: t.spaceMd),
            _VerifyCard(controller: c),
            SizedBox(height: t.spaceMd),
            if (c.ghMissing)
              Text(AppLocalizations.of(context).gitNoGh, style: TextStyle(color: t.warning))
            else if (c.pr == null)
              _CreatePr(controller: c, title: _title)
            else
              _PrCard(
                controller: c,
                method: _method,
                deleteBranch: _deleteBranch,
                onMethod: (m) => setState(() => _method = m),
                onDeleteBranch: (v) => setState(() => _deleteBranch = v),
              ),
          ],
        );
      },
    );
  }
}

class _BranchHeader extends StatelessWidget {
  const _BranchHeader({required this.controller, this.onOpenDiff});

  final GitController controller;
  final void Function(String absolutePath)? onOpenDiff;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final s = controller.status!;
    final sync = [
      if (s.ahead > 0) '↑${s.ahead}',
      if (s.behind > 0) '↓${s.behind}',
      if (s.upstreamGone) l10n.gitUpstreamGone,
      if (s.upstream == null) l10n.gitNoUpstream,
    ].join('  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_outlined, size: 18),
            SizedBox(width: t.spaceSm),
            Expanded(child: Text(s.head ?? l10n.gitDetachedHead, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
            IconButton(tooltip: l10n.gitRefresh, icon: const Icon(Icons.refresh, size: 18), onPressed: controller.busy ? null : controller.refresh),
          ],
        ),
        if (sync.isNotEmpty) Text(sync, style: theme.textTheme.bodySmall),
        if (s.clean)
          Text(l10n.gitClean, style: theme.textTheme.bodySmall)
        else
          ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.gitChangedFiles(s.changedCount), style: theme.textTheme.bodyMedium),
            children: [
              for (final f in s.files.take(60)) _FileRow(file: f, controller: controller, onOpenDiff: onOpenDiff),
              if (s.files.length > 60) Text(l10n.gitMoreFiles(s.files.length - 60)),
            ],
          ),
      ],
    );
  }

}

/// 변경된 파일 한 줄. 눌러서 변경점 보기를 연다 (삭제된 파일과 폴더는 열 수 없다).
class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.controller, this.onOpenDiff});

  final FileChange file;
  final GitController controller;
  final void Function(String absolutePath)? onOpenDiff;

  static String letter(FileChange f) {
    if (f.conflicted) return 'U';
    if (f.untracked) return '?';
    return f.index != '.' ? f.index : f.worktree;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    final deleted = file.index == 'D' || file.worktree == 'D';
    final absolute = file.path.endsWith('/') || deleted ? null : controller.absolutePath(file.path);
    final open = absolute == null || onOpenDiff == null ? null : () => onOpenDiff!(absolute);
    final color = switch (letter(file)) {
      'A' || '?' => t.success,
      'D' => t.danger,
      'U' => t.warning,
      _ => theme.colorScheme.primary,
    };
    return Tooltip(
      message: deleted ? l10n.gitFileDeleted : (open == null ? '' : l10n.gitFileOpenDiff),
      child: InkWell(
        onTap: open,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: t.spaceXs / 2),
          child: Row(
            children: [
              SizedBox(width: 18, child: Text(letter(file), style: t.logText.copyWith(color: color))),
              Expanded(child: Text(file.path, style: t.logText, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sync extends StatelessWidget {
  const _Sync({required this.controller});

  final GitController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = controller.status!;
    final t = context.tokens;
    final busy = controller.busy;
    final needsPush = s.head != null && (s.ahead > 0 || !s.hasUpstream);
    return Wrap(
      spacing: t.spaceSm,
      runSpacing: t.spaceSm,
      children: [
        OutlinedButton.icon(onPressed: busy ? null : controller.fetch, icon: const Icon(Icons.sync, size: 18), label: Text(l10n.gitFetch)),
        if (s.behind > 0)
          OutlinedButton.icon(
            onPressed: busy || !s.clean ? null : controller.pull,
            icon: const Icon(Icons.download, size: 18),
            label: Text(l10n.gitPull(s.behind)),
          ),
        if (needsPush)
          FilledButton.icon(onPressed: busy ? null : controller.push, icon: const Icon(Icons.upload, size: 18), label: Text(l10n.gitPush)),
        OutlinedButton.icon(
          onPressed: busy ? null : () => showReleaseDialog(context, controller),
          icon: const Icon(Icons.rocket_launch_outlined, size: 18),
          label: Text(l10n.releaseButton),
        ),
        if (busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      ],
    );
  }
}

class _VerifyCard extends StatelessWidget {
  const _VerifyCard({required this.controller});

  final GitController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final v = controller.verdict;
    final (icon, label, color) = switch (v?.state) {
      VerifyState.verified => (Icons.verified, l10n.gitVerified, t.success),
      VerifyState.builtOnly => (Icons.build_circle_outlined, l10n.gitBuiltOnly, t.warning),
      VerifyState.problem => (Icons.report_problem_outlined, l10n.gitVerifyProblem, t.danger),
      VerifyState.stale => (
        Icons.update,
        v!.commitsSince == null ? l10n.gitStaleSome : l10n.gitStaleCount(v.commitsSince!),
        t.warning,
      ),
      VerifyState.unverified || null => (Icons.help_outline, l10n.gitUnverified, theme.colorScheme.onSurfaceVariant),
    };
    final rec = v?.record;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(t.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                SizedBox(width: t.spaceSm),
                Expanded(child: Text(label, style: TextStyle(color: color))),
              ],
            ),
            if (rec != null) Text('${rec.target} · ${rec.mode} · ${rec.sha.substring(0, 7)}', style: t.logText),
            if (rec != null && rec.note.isNotEmpty) Text(rec.note),
            if (controller.localDiffersFromPr)
              Text(l10n.gitHeadDiffers, style: theme.textTheme.bodySmall),
            if (v != null && !v.passes) Text(l10n.gitBuildInRunTab, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CreatePr extends StatelessWidget {
  const _CreatePr({required this.controller, required this.title});

  final GitController controller;
  final TextEditingController title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final s = controller.status!;
    if (s.head == null) return const SizedBox.shrink();
    final pushed = s.hasUpstream && s.ahead == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pull Request', style: theme.textTheme.titleSmall),
        SizedBox(height: t.spaceXs),
        Text(l10n.gitNoPr),
        SizedBox(height: t.spaceSm),
        TextField(controller: title, decoration: InputDecoration(labelText: l10n.gitPrTitle)),
        SizedBox(height: t.spaceSm),
        if (!pushed) Text(l10n.gitPushFirst, style: theme.textTheme.bodySmall),
        FilledButton.icon(
          onPressed: controller.busy || !pushed ? null : () => controller.createPr(title.text),
          icon: const Icon(Icons.call_merge, size: 18),
          label: Text(l10n.gitCreatePr),
        ),
      ],
    );
  }
}

/// 병합 단추. 관문 설정에 따라 그대로 병합하거나, 확인을 받거나, 막고 "검증 없이 병합"만 둔다.
class _MergeButtons extends StatelessWidget {
  const _MergeButtons({required this.controller, required this.method, required this.deleteBranch});

  final GitController controller;
  final PrMergeMethod method;
  final bool deleteBranch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    final pr = controller.pr!;
    final decision = controller.gateDecision;
    final unavailable = controller.busy || pr.draft || pr.conflicting;
    final blocked = decision.action == GateAction.block;

    Future<void> mergeWithConfirm() async {
      final ok = await _confirmUnverified(context, decision.message);
      if (ok) await controller.merge(method, deleteBranch: deleteBranch, overrideGate: true);
    }

    final (color, icon) = switch (decision.action) {
      GateAction.allow => (t.success, Icons.verified_outlined),
      GateAction.confirm => (t.warning, Icons.help_outline),
      GateAction.block => (t.danger, Icons.block),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 관문을 끄면(검증 규칙 없음) 상태 줄도 보이지 않는다.
        if (controller.gate?.mode != GateMode.off)
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color),
                SizedBox(width: t.spaceSm),
                Expanded(child: Text(decision.message, style: theme.textTheme.bodySmall?.copyWith(color: color))),
              ],
            ),
          ),
        FilledButton.icon(
          // 차단 중에는 단추를 아예 비활성화한다. 예외는 아래의 "검증 없이 병합"으로만 가능하다.
          onPressed: unavailable || blocked
              ? null
              : decision.action == GateAction.confirm
              ? mergeWithConfirm
              : () => controller.merge(method, deleteBranch: deleteBranch),
          icon: const Icon(Icons.merge, size: 18),
          label: Text(blocked ? l10n.gitMergeBlocked : decision.action == GateAction.confirm ? l10n.gitMergeConfirm : l10n.gitMerge),
        ),
        if (blocked)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: unavailable ? null : mergeWithConfirm,
              child: Text(l10n.gitMergeUnverified, style: TextStyle(color: t.danger)),
            ),
          ),
      ],
    );
  }

  static Future<bool> _confirmUnverified(BuildContext context, String reason) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).gitUnverifiedDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reason),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context).gitUnverifiedDialogBody),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context).commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context).gitMergeAnyway)),
        ],
      ),
    );
    return ok ?? false;
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({
    required this.controller,
    required this.method,
    required this.deleteBranch,
    required this.onMethod,
    required this.onDeleteBranch,
  });

  final GitController controller;
  final PrMergeMethod method;
  final bool deleteBranch;
  final void Function(PrMergeMethod) onMethod;
  final void Function(bool) onDeleteBranch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final pr = controller.pr!;
    final c = pr.checks;
    final blocker = pr.draft
        ? l10n.gitPrDraft
        : pr.conflicting
        ? l10n.gitPrConflict
        : c.failed > 0
        ? l10n.gitPrChecksFailed(c.failedNames.join(', '))
        : c.pending > 0
        ? l10n.gitPrChecksPending(c.pending)
        : pr.reviewRequired
        ? l10n.gitPrReviewRequired
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('PR #${pr.number}', style: theme.textTheme.titleSmall),
            SizedBox(width: t.spaceSm),
            Chip(label: Text(pr.merged ? l10n.gitPrMerged : l10n.gitPrOpen), visualDensity: VisualDensity.compact),
          ],
        ),
        Text(pr.title),
        Text('${pr.headRef} → ${pr.baseRef}', style: t.logText),
        if (c.total > 0) Text(l10n.gitPrChecks(c.passed, c.failed, c.pending), style: theme.textTheme.bodySmall),
        if (pr.open) ...[
          if (blocker != null) Text(blocker, style: TextStyle(color: t.warning)),
          SizedBox(height: t.spaceSm),
          DropdownButtonFormField<PrMergeMethod>(
            initialValue: method,
            decoration: InputDecoration(labelText: l10n.gitMergeMethod),
            items: [
              DropdownMenuItem(value: PrMergeMethod.merge, child: Text(l10n.gitMergeCommit)),
              const DropdownMenuItem(value: PrMergeMethod.squash, child: Text('Squash')),
              const DropdownMenuItem(value: PrMergeMethod.rebase, child: Text('Rebase')),
            ],
            onChanged: (m) => m == null ? null : onMethod(m),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: deleteBranch,
            onChanged: (v) => onDeleteBranch(v ?? true),
            title: Text(l10n.gitDeleteBranchAfter),
          ),
          SelectableText('gh pr merge ${pr.number} --${method.name}${deleteBranch ? ' --delete-branch' : ''}', style: t.logText),
          SizedBox(height: t.spaceSm),
          _MergeButtons(controller: controller, method: method, deleteBranch: deleteBranch),
        ],
      ],
    );
  }
}
