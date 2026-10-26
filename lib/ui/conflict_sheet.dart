import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../git/conflicts.dart';
import '../git/git_controller.dart';
import '../git/status.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// 충돌 파일을 구간별로 해결한다. 구간마다 "내 것 / 들어오는 것 / 둘 다"를 고르면
/// 파일을 그대로 다시 쓰고 `git add` 한다. 직접 고쳐 쓰는 일은 편집기에 맡긴다.
/// branch-dock-flutter의 conflict_sheet.dart를 Studio의 대화상자 모양으로 옮겼다.
Future<void> showConflictSheet(BuildContext context, GitController controller, FileChange file) async {
  final path = controller.absolutePath(file.path);
  final text = path == null ? null : await _readConflictFile(path);
  final rebasing = await controller.isRebasing();
  if (!context.mounted || path == null) return;
  await showDialog<void>(
    context: context,
    builder: (context) => _ConflictDialog(controller: controller, file: file, path: path, text: text, swapped: rebasing),
  );
}

/// 파일 내용. 없는 파일, 이진 파일, UTF-8이 아닌 파일은 null.
Future<String?> _readConflictFile(String path) async {
  try {
    return utf8.decode(await File(path).readAsBytes());
  } on Object {
    return null;
  }
}

class _ConflictDialog extends StatefulWidget {
  const _ConflictDialog({required this.controller, required this.file, required this.path, required this.text, required this.swapped});

  final GitController controller;
  final FileChange file;
  final String path;
  final String? text;

  /// rebase 중에는 git의 위/아래가 뒤바뀐다: 위(HEAD)는 옮겨 붙일 바탕, 아래는 내 커밋.
  final bool swapped;

  @override
  State<_ConflictDialog> createState() => _ConflictDialogState();
}

class _ConflictDialogState extends State<_ConflictDialog> {
  late final ConflictFile? _parsed = widget.text == null ? null : ConflictFile.parse(widget.text!);
  late final List<ConflictChoice?> _choices = List.filled(_parsed?.blocks.length ?? 0, null);
  bool _applying = false;

  Future<void> _apply() async {
    final parsed = _parsed!;
    final resolved = parsed.resolve([for (final c in _choices) c!]);
    setState(() => _applying = true);
    try {
      await File(widget.path).writeAsString(resolved);
    } on FileSystemException catch (e) {
      if (!mounted) return;
      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await widget.controller.stage(widget.file);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final parsed = _parsed;
    final title = l10n.conflictSheetTitle(widget.file.fileName);

    String? problem;
    if (widget.text == null) {
      problem = l10n.conflictUnreadable;
    } else if (parsed == null) {
      problem = l10n.conflictBroken;
    } else if (!parsed.hasConflicts) {
      problem = l10n.conflictNone;
    }
    if (problem != null) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(width: 480, child: Text(problem)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonClose))],
      );
    }

    final blocks = parsed!.blocks;
    final left = _choices.where((c) => c == null).length;

    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < blocks.length; i++) ...[
                _BlockCard(
                  index: i + 1,
                  total: blocks.length,
                  block: blocks[i],
                  swapped: widget.swapped,
                  choice: _choices[i],
                  onChoice: (c) => setState(() => _choices[i] = c),
                ),
                SizedBox(height: t.spaceMd),
              ],
              Text(left == 0 ? l10n.conflictApplyNote : l10n.conflictPickHint(left), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _applying ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: left == 0 && !_applying ? _apply : null, child: Text(l10n.conflictApply)),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.index, required this.total, required this.block, required this.swapped, required this.choice, required this.onChoice});

  final int index;
  final int total;
  final ConflictBlock block;
  final bool swapped;
  final ConflictChoice? choice;
  final ValueChanged<ConflictChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    // 위쪽(first)이 "내 것"인지는 병합이냐 rebase냐에 따라 다르다.
    final firstName = swapped ? l10n.conflictSideIncoming : l10n.conflictSideMine;
    final secondName = swapped ? l10n.conflictSideMine : l10n.conflictSideIncoming;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.conflictBlockTitle(index, total), style: theme.textTheme.labelMedium),
        SizedBox(height: t.spaceXs),
        _Side(
          name: firstName,
          label: block.firstLabel,
          text: block.first,
          color: swapped ? theme.colorScheme.primary : t.success,
          selected: choice == ConflictChoice.first,
          onTap: () => onChoice(ConflictChoice.first),
        ),
        SizedBox(height: t.spaceXs),
        _Side(
          name: secondName,
          label: block.secondLabel,
          text: block.second,
          color: swapped ? t.success : theme.colorScheme.primary,
          selected: choice == ConflictChoice.second,
          onTap: () => onChoice(ConflictChoice.second),
        ),
        SizedBox(height: t.spaceXs),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: t.spaceXs),
          leading: Icon(
            choice == ConflictChoice.both ? context.icons.radioButtonChecked : context.icons.radioButtonUnchecked,
            color: choice == ConflictChoice.both ? theme.colorScheme.primary : null,
          ),
          title: Text(l10n.conflictKeepBoth),
          onTap: () => onChoice(ConflictChoice.both),
        ),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.name, required this.label, required this.text, required this.color, required this.selected, required this.onTap});

  final String name;
  final String label;
  final String text;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final lines = text.isEmpty ? const <String>[] : text.replaceAll(RegExp(r'\r?\n$'), '').split(RegExp(r'\r?\n'));
    return InkWell(
      borderRadius: BorderRadius.circular(t.radius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(t.radius),
          border: Border.all(color: selected ? color : theme.colorScheme.outlineVariant, width: selected ? 1.5 : 1),
        ),
        padding: EdgeInsets.all(t.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected ? context.icons.radioButtonChecked : context.icons.radioButtonUnchecked,
                  size: 18,
                  color: selected ? color : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: t.spaceSm),
                Text(name, style: theme.textTheme.labelLarge),
                if (label.isNotEmpty) ...[
                  SizedBox(width: t.spaceSm),
                  Flexible(
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.logText.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4),
            if (lines.isEmpty)
              Text(l10n.conflictEmptySide, style: theme.textTheme.bodySmall)
            else
              for (final line in lines.take(12))
                Text(line.isEmpty ? ' ' : line, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.logText),
            if (lines.length > 12) Text('… +${lines.length - 12}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
