import 'package:flutter/material.dart';

import '../git/git_controller.dart';
import '../git/status.dart';
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
      listenable: c,
      builder: (context, _) {
        final s = c.status;
        if (c.dir == null || s == null) {
          return const Center(child: Text('열린 폴더가 git 저장소가 아닙니다'));
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
              Text('GitHub CLI(gh)를 찾을 수 없어 PR 기능을 쓸 수 없습니다.', style: TextStyle(color: t.warning))
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
    final theme = Theme.of(context);
    final t = context.tokens;
    final s = controller.status!;
    final sync = [
      if (s.ahead > 0) '↑${s.ahead}',
      if (s.behind > 0) '↓${s.behind}',
      if (s.upstreamGone) '원격에 없음',
      if (s.upstream == null) '추적 브랜치 없음',
    ].join('  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_outlined, size: 18),
            SizedBox(width: t.spaceSm),
            Expanded(child: Text(s.head ?? '(분리된 HEAD)', style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
            IconButton(tooltip: '새로 고침', icon: const Icon(Icons.refresh, size: 18), onPressed: controller.busy ? null : controller.refresh),
          ],
        ),
        if (sync.isNotEmpty) Text(sync, style: theme.textTheme.bodySmall),
        if (s.clean)
          Text('변경 없음', style: theme.textTheme.bodySmall)
        else
          ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            title: Text('변경된 파일 ${s.changedCount}개', style: theme.textTheme.bodyMedium),
            children: [
              for (final f in s.files.take(60)) _FileRow(file: f, controller: controller, onOpenDiff: onOpenDiff),
              if (s.files.length > 60) Text('… 외 ${s.files.length - 60}개'),
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
      message: deleted ? '삭제된 파일' : (open == null ? '' : '눌러서 변경점 보기'),
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
    final s = controller.status!;
    final t = context.tokens;
    final busy = controller.busy;
    final needsPush = s.head != null && (s.ahead > 0 || !s.hasUpstream);
    return Wrap(
      spacing: t.spaceSm,
      runSpacing: t.spaceSm,
      children: [
        OutlinedButton.icon(onPressed: busy ? null : controller.fetch, icon: const Icon(Icons.sync, size: 18), label: const Text('가져오기')),
        if (s.behind > 0)
          OutlinedButton.icon(
            onPressed: busy || !s.clean ? null : controller.pull,
            icon: const Icon(Icons.download, size: 18),
            label: Text('받기 (↓${s.behind})'),
          ),
        if (needsPush)
          FilledButton.icon(onPressed: busy ? null : controller.push, icon: const Icon(Icons.upload, size: 18), label: const Text('올리기')),
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
    final theme = Theme.of(context);
    final t = context.tokens;
    final v = controller.verdict;
    final (icon, label, color) = switch (v?.state) {
      VerifyState.verified => (Icons.verified, '검증됨', t.success),
      VerifyState.builtOnly => (Icons.build_circle_outlined, '빌드만 됨 — 눈으로 확인하지 않았습니다', t.warning),
      VerifyState.problem => (Icons.report_problem_outlined, '확인했더니 문제가 있었습니다', t.danger),
      VerifyState.stale => (
        Icons.update,
        v!.commitsSince == null ? '검증한 뒤 커밋이 추가되었습니다' : '검증한 뒤 커밋 ${v.commitsSince}개가 추가되었습니다',
        t.warning,
      ),
      VerifyState.unverified || null => (Icons.help_outline, '검증하지 않은 커밋입니다', theme.colorScheme.onSurfaceVariant),
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
              Text('로컬 HEAD와 PR head가 다릅니다. 판정은 PR head 기준입니다.', style: theme.textTheme.bodySmall),
            if (v != null && !v.passes) Text('병합하기 전에 Run 탭에서 이 커밋을 빌드해 확인하세요.', style: theme.textTheme.bodySmall),
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
        const Text('이 브랜치의 PR이 없습니다.'),
        SizedBox(height: t.spaceSm),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'PR 제목')),
        SizedBox(height: t.spaceSm),
        if (!pushed) Text('먼저 브랜치를 올려야 PR을 만들 수 있습니다.', style: theme.textTheme.bodySmall),
        FilledButton.icon(
          onPressed: controller.busy || !pushed ? null : () => controller.createPr(title.text),
          icon: const Icon(Icons.call_merge, size: 18),
          label: const Text('PR 만들기'),
        ),
      ],
    );
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
    final theme = Theme.of(context);
    final t = context.tokens;
    final pr = controller.pr!;
    final c = pr.checks;
    final blocker = pr.draft
        ? '초안(draft) PR입니다.'
        : pr.conflicting
        ? '충돌이 있습니다.'
        : c.failed > 0
        ? '실패한 검사: ${c.failedNames.join(', ')}'
        : c.pending > 0
        ? '검사 ${c.pending}개가 진행 중입니다.'
        : pr.reviewRequired
        ? '리뷰가 필요합니다.'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('PR #${pr.number}', style: theme.textTheme.titleSmall),
            SizedBox(width: t.spaceSm),
            Chip(label: Text(pr.merged ? '병합됨' : '열림'), visualDensity: VisualDensity.compact),
          ],
        ),
        Text(pr.title),
        Text('${pr.headRef} → ${pr.baseRef}', style: t.logText),
        if (c.total > 0) Text('검사 통과 ${c.passed} · 실패 ${c.failed} · 진행 ${c.pending}', style: theme.textTheme.bodySmall),
        if (pr.open) ...[
          if (blocker != null) Text(blocker, style: TextStyle(color: t.warning)),
          SizedBox(height: t.spaceSm),
          DropdownButtonFormField<PrMergeMethod>(
            initialValue: method,
            decoration: const InputDecoration(labelText: '병합 방식'),
            items: const [
              DropdownMenuItem(value: PrMergeMethod.merge, child: Text('병합 커밋')),
              DropdownMenuItem(value: PrMergeMethod.squash, child: Text('Squash')),
              DropdownMenuItem(value: PrMergeMethod.rebase, child: Text('Rebase')),
            ],
            onChanged: (m) => m == null ? null : onMethod(m),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: deleteBranch,
            onChanged: (v) => onDeleteBranch(v ?? true),
            title: const Text('병합 후 브랜치 삭제'),
          ),
          SelectableText('gh pr merge ${pr.number} --${method.name}${deleteBranch ? ' --delete-branch' : ''}', style: t.logText),
          SizedBox(height: t.spaceSm),
          FilledButton.icon(
            onPressed: controller.busy || pr.draft || pr.conflicting ? null : () => controller.merge(method, deleteBranch: deleteBranch),
            icon: const Icon(Icons.merge, size: 18),
            label: const Text('PR 병합'),
          ),
        ],
      ],
    );
  }
}
