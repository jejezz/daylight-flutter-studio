import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../git/branch_commands.dart';
import '../git/branches_controller.dart';
import '../git/error_hints.dart';
import '../git/refs.dart';
import '../l10n/app_localizations.dart';
import '../studio/worktree.dart';
import '../theme/app_theme.dart';
import 'branch_dialogs.dart';

/// 브랜치 탭: 로컬·원격 브랜치를 보고 전환·만들기·이름 바꾸기·삭제를 한다.
/// 다른 worktree가 쥔 브랜치는 표시하고, 전환·삭제가 막히는 이유를 보여 준다.
class BranchesTab extends StatefulWidget {
  const BranchesTab({super.key, required this.controller, this.onOpenWorktree});

  final BranchesController controller;

  /// 다른 worktree를 이 앱에서 연다 (그 브랜치를 쓰는 폴더로 가서 풀 수 있게).
  final void Function(Worktree worktree)? onOpenWorktree;

  @override
  State<BranchesTab> createState() => _BranchesTabState();
}

class _BranchesTabState extends State<BranchesTab> {
  final _search = TextEditingController();
  String _query = '';

  BranchesController get c => widget.controller;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Branch b) =>
      _query.isEmpty || b.name.toLowerCase().contains(_query.toLowerCase());

  // --- 동작: 대화상자를 거친 뒤 컨트롤러를 부른다 ---------------------------------

  Future<void> _create({String? base}) async {
    final req = await showNewBranchDialog(
      context,
      localBranches: [for (final b in c.local) b.name],
      base: base,
    );
    if (req == null) return;
    await c.create(req.name, base: req.base, switchAfter: req.switchAfter);
  }

  Future<void> _rename(Branch b) async {
    final to = await showRenameBranchDialog(
      context,
      from: b.name,
      localBranches: [for (final x in c.local) x.name],
    );
    if (to != null) await c.rename(b.name, to);
  }

  Future<void> _delete(Branch b) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmBranchAction(
      context,
      title: l10n.branchDeleteTitle,
      body: l10n.branchDeleteBody(b.name),
      command: BranchCommands.delete(b.name),
      confirmLabel: l10n.branchDelete,
    );
    if (!ok || !mounted) return;
    final deleted = await c.deleteLocal(b.name);
    if (deleted || c.errorKind != GitErrorKind.branchNotMerged || !mounted) {
      return;
    }
    // 병합되지 않았다 — 지우면 그 커밋을 잃을 수 있으니 한 번 더 분명히 묻는다.
    final force = await confirmBranchAction(
      context,
      title: l10n.branchDeleteNotMergedTitle,
      body: l10n.branchDeleteNotMergedBody(b.name),
      command: BranchCommands.delete(b.name, force: true),
      confirmLabel: l10n.branchForceDelete,
    );
    if (force) await c.deleteLocal(b.name, force: true);
  }

  Future<void> _deleteRemote(Branch b) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmBranchAction(
      context,
      title: l10n.branchDeleteRemoteTitle,
      body: l10n.branchDeleteRemoteBody(b.remoteName ?? '', b.shortName),
      command: BranchCommands.deleteRemote(b.remoteName ?? '', b.shortName),
      confirmLabel: l10n.branchDeleteRemote,
    );
    if (ok) await c.deleteRemote(b);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        if (c.dir == null || (c.branches.isEmpty && !c.loading)) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(t.spaceLg),
              child: Text(
                c.dir == null ? l10n.branchesNotRepo : l10n.branchesEmpty,
              ),
            ),
          );
        }
        final local = c.local.where(_matches).toList();
        final remote = c.remote.where(_matches).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                t.spaceSm,
                t.spaceSm,
                t.spaceXs,
                t.spaceXs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: l10n.branchesSearchHint,
                        prefixIcon: Icon(context.icons.search, size: 18),
                      ),
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.branchesNew,
                    icon: Icon(context.icons.add, size: 20),
                    onPressed: c.busy
                        ? null
                        : () => _create(base: c.current?.name),
                  ),
                  IconButton(
                    tooltip: l10n.branchesRefresh,
                    icon: Icon(context.icons.refresh, size: 18),
                    onPressed: c.loading ? null : c.refresh,
                  ),
                ],
              ),
            ),
            if (c.busy || c.loading)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            if (c.message != null)
              _MessageBar(controller: c, onOpenWorktree: widget.onOpenWorktree),
            Expanded(
              child: ListView(
                children: [
                  _SectionTitle('${l10n.branchesLocal} (${local.length})'),
                  if (local.isEmpty)
                    _Hint(
                      _query.isEmpty
                          ? l10n.branchesEmpty
                          : l10n.branchesNoMatch,
                    ),
                  for (final b in local)
                    _BranchRow(
                      key: ValueKey('branch:${b.name}'),
                      branch: b,
                      holder: c.worktreeHolding(b.name),
                      busy: c.busy,
                      onSwitch: () => c.switchTo(b),
                      onNewFrom: () => _create(base: b.name),
                      onRename: () => _rename(b),
                      onDelete: () => _delete(b),
                      onOpenWorktree: widget.onOpenWorktree,
                    ),
                  // 원격 브랜치는 많을 수 있어 접어 두고, 검색 중이면 펼친다.
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Theme.of(context).colorScheme.surface
                          .withValues(alpha: 0),
                    ),
                    child: ExpansionTile(
                      key: ValueKey('remote-${_query.isNotEmpty}'),
                      initiallyExpanded: _query.isNotEmpty,
                      tilePadding: EdgeInsets.symmetric(horizontal: t.spaceMd),
                      title: Text(
                        '${l10n.branchesRemote} (${remote.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      children: [
                        if (remote.isEmpty)
                          _Hint(
                            _query.isEmpty
                                ? l10n.branchesEmpty
                                : l10n.branchesNoMatch,
                          ),
                        for (final b in remote)
                          _BranchRow(
                            key: ValueKey('branch:${b.name}'),
                            branch: b,
                            holder: null,
                            busy: c.busy,
                            onSwitch: () => c.switchTo(b),
                            onDeleteRemote: () => _deleteRemote(b),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.spaceMd, t.spaceSm, t.spaceMd, t.spaceXs),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: context.tokens.spaceMd,
      vertical: context.tokens.spaceSm,
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

/// 마지막 동작의 결과. 다른 worktree가 쥔 브랜치라서 실패했다면 그 폴더를 여는 단추를 함께 준다.
class _MessageBar extends StatelessWidget {
  const _MessageBar({required this.controller, this.onOpenWorktree});

  final BranchesController controller;
  final void Function(Worktree worktree)? onOpenWorktree;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final color = c.messageOk ? t.success : t.danger;
    final path = c.blockingWorktreePath;
    final target = path == null
        ? null
        : c.worktrees.where((w) => _same(w.path, path)).firstOrNull;
    return Container(
      color: color.withValues(alpha: 0.12),
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          Icon(
            c.messageOk ? context.icons.checkCircle : context.icons.error,
            size: 16,
            color: color,
          ),
          SizedBox(width: t.spaceSm),
          Expanded(
            child: Text(
              c.message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (target != null && onOpenWorktree != null)
            TextButton(
              onPressed: () => onOpenWorktree!(target),
              child: Text(l10n.branchOpenWorktree),
            ),
        ],
      ),
    );
  }

  static bool _same(String a, String b) =>
      a.replaceAll(r'\', '/').toLowerCase() ==
      b.replaceAll(r'\', '/').toLowerCase();
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({
    super.key,
    required this.branch,
    required this.holder,
    required this.busy,
    required this.onSwitch,
    this.onNewFrom,
    this.onRename,
    this.onDelete,
    this.onDeleteRemote,
    this.onOpenWorktree,
  });

  final Branch branch;

  /// 다른 worktree가 이 브랜치를 쥐고 있으면 그 worktree.
  final Worktree? holder;
  final bool busy;
  final VoidCallback onSwitch;
  final VoidCallback? onNewFrom;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteRemote;
  final void Function(Worktree worktree)? onOpenWorktree;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final b = branch;
    final held = holder != null;
    final date = b.lastCommit == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(b.lastCommit!);
    final sub = [
      if (date.isNotEmpty) date,
      if (b.subject.isNotEmpty) b.subject,
    ].join(' · ');

    // 상태 칩: 앞서거나 뒤처진 커밋, 추적 브랜치 문제, worktree.
    final chips = <Widget>[
      if (b.ahead > 0) _Chip('↑${b.ahead}', theme.colorScheme.primary),
      if (b.behind > 0) _Chip('↓${b.behind}', t.warning),
      if (!b.remote && b.upstreamGone) _Chip(l10n.branchGone, t.warning),
      if (!b.remote && b.upstream == null && !b.current)
        _Chip(l10n.branchNoUpstream, theme.colorScheme.outline),
      if (held)
        _Chip(
          'worktree',
          t.warning,
          icon: holder!.byClaude
              ? context.icons.smartToy
              : context.icons.folder,
        ),
    ];

    final switchLabel = b.remote ? l10n.branchTrackSwitch : l10n.branchSwitch;
    return Tooltip(
      message: held ? l10n.branchInWorktree(holder!.path) : '',
      // 행 전체에 탭·더블탭 처리를 걸지 않는다: 안쪽 단추(전환·메뉴)의 탭을 삼킨다.
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.spaceMd,
          vertical: t.spaceXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                b.current
                    ? context.icons.check
                    : (b.remote
                          ? context.icons.cloud
                          : context.icons.accountTree),
                size: 16,
                color: b.current ? t.success : theme.colorScheme.outline,
              ),
            ),
            SizedBox(width: t.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          b.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: b.current ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      if (b.current) ...[
                        SizedBox(width: t.spaceSm),
                        _Chip(l10n.branchCurrent, t.success),
                      ],
                    ],
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  if (chips.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: t.spaceXs),
                      child: Wrap(
                        spacing: t.spaceXs,
                        runSpacing: t.spaceXs,
                        children: chips,
                      ),
                    ),
                ],
              ),
            ),
            if (!b.current)
              TextButton(
                // 다른 worktree가 쥔 브랜치는 전환할 수 없다 — 이유는 툴팁과 오류 문구가 알려 준다.
                onPressed: busy || held ? null : onSwitch,
                child: Text(switchLabel),
              ),
            PopupMenuButton<String>(
              tooltip: '',
              icon: Icon(context.icons.moreVert, size: 18),
              enabled: !busy,
              onSelected: (v) => switch (v) {
                'new' => onNewFrom?.call(),
                'rename' => onRename?.call(),
                'delete' => onDelete?.call(),
                'deleteRemote' => onDeleteRemote?.call(),
                'worktree' =>
                  holder == null ? null : onOpenWorktree?.call(holder!),
                _ => null,
              },
              itemBuilder: (context) => [
                if (onNewFrom != null)
                  PopupMenuItem(value: 'new', child: Text(l10n.branchNewFrom)),
                if (onRename != null)
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l10n.branchRename),
                  ),
                if (held && onOpenWorktree != null)
                  PopupMenuItem(
                    value: 'worktree',
                    child: Text(l10n.branchOpenWorktree),
                  ),
                // 지금 쓰는 브랜치는 지울 수 없다 (git도 거부한다).
                if (onDelete != null && !b.current)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.branchDelete),
                  ),
                if (onDeleteRemote != null)
                  PopupMenuItem(
                    value: 'deleteRemote',
                    child: Text(l10n.branchDeleteRemote),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, this.color, {this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.spaceSm - 1, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(t.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
