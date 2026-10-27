import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../studio/git_base.dart';
import '../theme/app_theme.dart';

/// 변경점 보기가 무엇과 비교할지 고른다: HEAD, 브랜치, 최근 커밋, 또는 직접 친 이름(태그·해시 등).
/// 고른 기준을 돌려준다(`HEAD`면 HEAD로 돌아가는 것). 취소하면 null.
Future<String?> showCompareDialog(BuildContext context, {required Future<CompareChoices> choices, String? current}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CompareDialog(choices: choices, current: current),
  );
}

class _CompareDialog extends StatefulWidget {
  const _CompareDialog({required this.choices, this.current});

  final Future<CompareChoices> choices;
  final String? current;

  @override
  State<_CompareDialog> createState() => _CompareDialogState();
}

class _CompareDialogState extends State<_CompareDialog> {
  late final _field = TextEditingController(text: widget.current ?? '');
  CompareChoices? _choices;

  @override
  void initState() {
    super.initState();
    widget.choices.then((c) {
      if (mounted) setState(() => _choices = c);
    });
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _pick(String ref) => Navigator.pop(context, ref);

  void _submit() {
    final text = _field.text.trim();
    if (text.isNotEmpty) _pick(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final choices = _choices;
    return AlertDialog(
      title: Text(l10n.compareDialogTitle),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _field,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.compareFieldHint, isDense: true),
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: t.spaceSm),
            Expanded(
              child: choices == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(context.icons.history, size: 18),
                          title: Text(l10n.compareUseHead),
                          selected: widget.current == null,
                          onTap: () => _pick('HEAD'),
                        ),
                        if (choices.branches.isNotEmpty) _Header(l10n.compareBranches),
                        for (final b in choices.branches)
                          ListTile(
                            dense: true,
                            leading: Icon(context.icons.callSplit, size: 18),
                            title: Text(b, style: context.mono(13)),
                            selected: widget.current == b,
                            onTap: () => _pick(b),
                          ),
                        if (choices.commits.isNotEmpty) _Header(l10n.compareCommits),
                        for (final c in choices.commits)
                          ListTile(
                            dense: true,
                            leading: Text(c.hash, style: context.mono(12)),
                            title: Text(c.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.userText(13)),
                            selected: widget.current == c.hash,
                            onTap: () => _pick(c.hash),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.compareApply)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.spaceMd, t.spaceMd, t.spaceMd, t.spaceXs),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
    );
  }
}
