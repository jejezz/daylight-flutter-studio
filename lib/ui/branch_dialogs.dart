import 'package:flutter/material.dart';

import '../git/branch_commands.dart';
import '../git/refs.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// 브랜치 이름 검사 결과를 사용자에게 보일 문구로 바꾼다. 통과하면 null.
String? branchNameMessage(AppLocalizations l10n, String name) => switch (validateBranchName(name)) {
  null => null,
  BranchNameProblem.empty => l10n.branchNameEmpty,
  BranchNameProblem.invalidCharacter => l10n.branchNameInvalidChar,
  BranchNameProblem.startsWithDash => l10n.branchNameDash,
  BranchNameProblem.invalidSequence => l10n.branchNameSequence,
  BranchNameProblem.invalidEdge => l10n.branchNameEdge,
};

/// "실행될 명령"을 그대로 보여 준다 (복사해서 터미널에서 돌려 볼 수 있게 선택 가능).
class CommandPreview extends StatelessWidget {
  const CommandPreview(this.args, {super.key});

  final List<String> args;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).branchCommandPreview, style: Theme.of(context).textTheme.labelSmall),
        SizedBox(height: t.spaceXs),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(t.spaceSm),
          decoration: BoxDecoration(color: scheme.surfaceContainerLowest, border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(t.radius)),
          child: SelectableText(args.join(' '), style: t.logText),
        ),
      ],
    );
  }
}

class NewBranchRequest {
  const NewBranchRequest({required this.name, required this.base, required this.switchAfter});

  final String name;

  /// 기준 브랜치. null이면 현재 위치(HEAD).
  final String? base;
  final bool switchAfter;
}

/// 새 브랜치 만들기. 이름 규칙을 입력하는 동안 바로 검사하고, 실행될 명령을 미리 보여 준다.
Future<NewBranchRequest?> showNewBranchDialog(
  BuildContext context, {
  required List<String> localBranches,
  String? base,
}) => showDialog<NewBranchRequest>(
  context: context,
  builder: (context) => _NewBranchDialog(localBranches: localBranches, initialBase: base),
);

class _NewBranchDialog extends StatefulWidget {
  const _NewBranchDialog({required this.localBranches, this.initialBase});

  final List<String> localBranches;
  final String? initialBase;

  @override
  State<_NewBranchDialog> createState() => _NewBranchDialogState();
}

class _NewBranchDialogState extends State<_NewBranchDialog> {
  final _name = TextEditingController();
  late String? _base = widget.initialBase;
  bool _switchAfter = true;

  static const _prefixes = ['feature/', 'fix/'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _text => _name.text.trim();

  String? _problem(AppLocalizations l10n) {
    if (_text.isEmpty) return null; // 입력하기 전에는 오류를 보이지 않는다 (만들기 단추만 막는다).
    final rule = branchNameMessage(l10n, _text);
    if (rule != null) return rule;
    if (widget.localBranches.contains(_text)) return l10n.branchNameExists;
    return null;
  }

  bool _valid(AppLocalizations l10n) => _text.isNotEmpty && branchNameMessage(l10n, _text) == null && !widget.localBranches.contains(_text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return AlertDialog(
      title: Text(l10n.branchCreateTitle),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.branchNameLabel, errorText: _problem(l10n)),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _valid(l10n) ? _submit() : null,
            ),
            SizedBox(height: t.spaceSm),
            Wrap(
              spacing: t.spaceXs,
              children: [
                for (final p in _prefixes)
                  ActionChip(
                    label: Text(p),
                    onPressed: () => setState(() {
                      if (!_name.text.startsWith(p)) _name.text = '$p${_name.text}';
                      _name.selection = TextSelection.collapsed(offset: _name.text.length);
                    }),
                  ),
              ],
            ),
            SizedBox(height: t.spaceMd),
            DropdownButtonFormField<String?>(
              initialValue: _base,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.branchBaseLabel),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.branchBaseHead)),
                for (final b in widget.localBranches) DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _base = v),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _switchAfter,
              onChanged: (v) => setState(() => _switchAfter = v ?? true),
              title: Text(l10n.branchSwitchAfter),
            ),
            SizedBox(height: t.spaceSm),
            CommandPreview(BranchCommands.create(_text.isEmpty ? '<name>' : _text, base: _base, switchAfter: _switchAfter)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _valid(l10n) ? _submit : null, child: Text(l10n.branchCreate)),
      ],
    );
  }

  void _submit() => Navigator.pop(context, NewBranchRequest(name: _text, base: _base, switchAfter: _switchAfter));
}

/// 이름 바꾸기. 새 이름을 돌려준다 (취소하면 null).
Future<String?> showRenameBranchDialog(BuildContext context, {required String from, required List<String> localBranches}) =>
    showDialog<String>(context: context, builder: (context) => _RenameDialog(from: from, localBranches: localBranches));

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.from, required this.localBranches});

  final String from;
  final List<String> localBranches;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.from);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _text => _name.text.trim();

  String? _problem(AppLocalizations l10n) {
    final rule = branchNameMessage(l10n, _text);
    if (rule != null) return rule;
    if (_text != widget.from && widget.localBranches.contains(_text)) return l10n.branchNameExists;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final problem = _problem(l10n);
    final unchanged = _text == widget.from;
    return AlertDialog(
      title: Text(l10n.branchRenameTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.branchNameLabel, errorText: problem),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => problem == null && !unchanged ? Navigator.pop(context, _text) : null,
            ),
            SizedBox(height: t.spaceMd),
            CommandPreview(BranchCommands.rename(widget.from, _text.isEmpty ? '<name>' : _text)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: problem == null && !unchanged ? () => Navigator.pop(context, _text) : null, child: Text(l10n.branchRenameAction)),
      ],
    );
  }
}

/// 되돌리기 어려운 동작(삭제 등) 앞의 확인창. 실행될 명령을 함께 보여 준다.
Future<bool> confirmBranchAction(
  BuildContext context, {
  required String title,
  required String body,
  required List<String> command,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final t = context.tokens;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text(body), SizedBox(height: t.spaceMd), CommandPreview(command)],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: t.danger, foregroundColor: t.onDanger),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}
