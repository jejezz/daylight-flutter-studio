import 'package:flutter/material.dart';

import '../git/branches_controller.dart';
import '../git/commits.dart';
import '../git/merge_commands.dart';
import '../git/refs.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'branch_dialogs.dart';

/// 다른 브랜치를 현재 브랜치로 합친다: 들어올 커밋을 미리 보고, 방식(fast-forward · 병합 커밋 · squash · rebase)을
/// 고르고, 실행될 명령을 확인한 뒤에 실행한다. 충돌이 나면 시트는 닫히고 Git 패널의 "변경" 탭이 이어받는다.
Future<void> showMergeSheet(BuildContext context, {required BranchesController controller, required Branch source}) {
  return showDialog<void>(
    context: context,
    builder: (context) => MergeSheet(controller: controller, source: source),
  );
}

class MergeSheet extends StatefulWidget {
  const MergeSheet({super.key, required this.controller, required this.source});

  final BranchesController controller;
  final Branch source;

  @override
  State<MergeSheet> createState() => _MergeSheetState();
}

class _MergeSheetState extends State<MergeSheet> {
  late final Future<MergePreview> _preview = widget.controller.preview(widget.source.name);
  final _message = TextEditingController();
  MergeMode? _mode;

  BranchesController get c => widget.controller;
  String get _target => c.current?.name ?? 'HEAD';

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  /// 메시지 칸을 비워 뒀을 때 쓰는 기본 메시지.
  String _defaultMessage(MergePreview p, MergeMode mode) => switch (mode) {
    MergeMode.squash => p.incoming.length == 1 ? p.incoming.first.subject : 'feat: ${widget.source.shortName}',
    _ => "Merge branch '${widget.source.name}'",
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.mergeTitle(widget.source.name, _target)),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<MergePreview>(
          future: _preview,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasError || snap.data == null) return Text(l10n.mergeLoadFailed);
            return _body(context, snap.data!);
          },
        ),
      ),
      actions: _actions(context),
    );
  }

  /// 미리 보기가 올 때까지는 실행 단추를 두지 않는다 (무엇을 합치는지 보기 전에 누르지 못하게).
  List<Widget> _actions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
      FutureBuilder<MergePreview>(
        future: _preview,
        builder: (context, snap) {
          final p = snap.data;
          if (p == null) return const SizedBox.shrink();
          final mode = _effectiveMode(p);
          final nothing = mode == MergeMode.rebase ? p.replayed.isEmpty : p.incoming.isEmpty;
          return FilledButton(
            onPressed: nothing ? null : () => _submit(p, mode),
            child: Text(mode == MergeMode.rebase ? l10n.mergeConfirmRebase : l10n.mergeConfirm),
          );
        },
      ),
    ];
  }

  /// 고른 방식. 아직 안 골랐으면 fast-forward가 되면 그것을, 아니면 병합 커밋을 기본으로 한다.
  MergeMode _effectiveMode(MergePreview p) => _mode ?? (p.canFastForward ? MergeMode.fastForward : MergeMode.mergeCommit);

  Future<void> _submit(MergePreview p, MergeMode mode) async {
    final message = _message.text.trim().isEmpty ? _defaultMessage(p, mode) : _message.text.trim();
    Navigator.pop(context);
    await c.merge(widget.source.name, mode, message: mode == MergeMode.fastForward || mode == MergeMode.rebase ? '' : message);
  }

  Widget _body(BuildContext context, MergePreview p) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final mode = _effectiveMode(p);
    final rebase = mode == MergeMode.rebase;
    final commits = rebase ? p.replayed : p.incoming;

    // 합칠 것도, 다시 쌓을 것도 없으면 방식을 고를 필요가 없다.
    if (p.incoming.isEmpty && !rebase) {
      return Text(l10n.mergeNothing(widget.source.name, _target));
    }

    final message = _message.text.trim().isEmpty ? _defaultMessage(p, mode) : _message.text.trim();
    final steps = MergeCommands.start(widget.source.name, mode, message: mode == MergeMode.fastForward || rebase ? '' : message);

    Widget option(MergeMode m, String title, String when, {bool enabled = true, String? disabled}) {
      final selected = mode == m;
      return ListTile(
        enabled: enabled,
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(selected ? context.icons.radioButtonChecked : context.icons.radioButtonUnchecked, color: selected ? theme.colorScheme.primary : null),
        title: Text(title),
        subtitle: Text(enabled ? when : (disabled ?? when)),
        onTap: enabled ? () => setState(() => _mode = m) : null,
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(rebase ? l10n.mergeRebaseReplay('${commits.length}') : l10n.mergeIncoming('${commits.length}'), style: theme.textTheme.labelMedium),
          SizedBox(height: t.spaceXs),
          _CommitList(commits: commits),
          SizedBox(height: t.spaceMd),
          option(MergeMode.fastForward, l10n.mergeModeFastForward, l10n.mergeFastForwardWhen, enabled: p.canFastForward, disabled: l10n.mergeFastForwardDisabled),
          option(MergeMode.mergeCommit, l10n.mergeModeMergeCommit, l10n.mergeMergeCommitWhen),
          option(MergeMode.squash, l10n.mergeModeSquash, l10n.mergeSquashWhen),
          option(MergeMode.rebase, l10n.mergeModeRebase, l10n.mergeRebaseWhen(widget.source.name)),
          if (mode == MergeMode.mergeCommit || mode == MergeMode.squash) ...[
            SizedBox(height: t.spaceSm),
            TextField(controller: _message, decoration: InputDecoration(labelText: l10n.mergeMessageLabel, hintText: _defaultMessage(p, mode))),
          ],
          if (mode == MergeMode.squash) ...[SizedBox(height: t.spaceSm), Text(l10n.mergeSquashNote(widget.source.name), style: theme.textTheme.bodySmall)],
          if (rebase && p.replayed.isEmpty) ...[SizedBox(height: t.spaceSm), Text(l10n.mergeRebaseNothing, style: TextStyle(color: t.warning))],
          // 원격에 올라간 브랜치를 rebase하면 커밋이 새로 만들어져 다음 push가 강제여야 한다.
          if (rebase && p.replayed.isNotEmpty && c.current?.upstream != null) ...[
            SizedBox(height: t.spaceSm),
            Text(l10n.mergeRebasePublishedWarning, style: TextStyle(color: t.warning)),
          ],
          SizedBox(height: t.spaceMd),
          for (final s in steps) ...[CommandPreview(s), SizedBox(height: t.spaceXs)],
        ],
      ),
    );
  }
}

class _CommitList extends StatelessWidget {
  const _CommitList({required this.commits});

  final List<Commit> commits;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: BoxDecoration(color: scheme.surfaceContainerLowest, border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(t.radius)),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: t.spaceXs),
        children: [
          for (final c in commits.take(30))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: 2),
              child: Row(
                children: [
                  Text(c.shortHash, style: t.logText.copyWith(color: scheme.outline)),
                  SizedBox(width: t.spaceSm),
                  Expanded(child: Text(c.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ),
          if (commits.length > 30)
            Padding(padding: EdgeInsets.symmetric(horizontal: t.spaceMd), child: Text('… +${commits.length - 30}', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
