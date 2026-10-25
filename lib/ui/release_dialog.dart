import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../git/git_controller.dart';
import '../l10n/app_localizations.dart';
import '../release/release_check.dart';
import '../release/release_controller.dart';
import '../theme/app_theme.dart';

/// 릴리스 태그 대화상자: 점검 목록을 보여 주고, 통과하면 태그를 만들어 올린다.
Future<void> showReleaseDialog(BuildContext context, GitController git) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ReleaseDialog(controller: ReleaseController(git)),
  );
}

class _ReleaseDialog extends StatefulWidget {
  const _ReleaseDialog({required this.controller});

  final ReleaseController controller;

  @override
  State<_ReleaseDialog> createState() => _ReleaseDialogState();
}

class _ReleaseDialogState extends State<_ReleaseDialog> {
  ReleaseController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, ReleaseCheck check) => switch (check) {
    ReleaseCheck.cleanTree => l10n.releaseCheckCleanTree,
    ReleaseCheck.onDefaultBranch => l10n.releaseCheckOnDefaultBranch,
    ReleaseCheck.synced => l10n.releaseCheckSynced,
    ReleaseCheck.versionBumped => l10n.releaseCheckVersionBumped,
    ReleaseCheck.tagFree => l10n.releaseCheckTagFree,
    ReleaseCheck.verified => l10n.releaseCheckVerified,
  };

  Future<void> _tagWithoutVerification() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.releaseUnverifiedTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(c.decision.message), const SizedBox(height: 12), Text(l10n.releaseUnverifiedBody)],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.releaseTagAnyway)),
        ],
      ),
    );
    if (ok ?? false) await c.createTag(overrideGate: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final f = c.facts;
        final version = f?.version;
        return AlertDialog(
          title: Text(l10n.releaseTitle),
          content: SizedBox(
            width: 560,
            child: c.loading && f == null
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        version == null ? l10n.releaseNoVersion : l10n.releaseVersionLine(version.toString(), version.tag),
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        f?.lastTag == null ? l10n.releaseNoLastTag : l10n.releaseLastTag(f!.lastTag!.tag),
                        style: theme.textTheme.bodySmall,
                      ),
                      SizedBox(height: t.spaceMd),
                      for (final check in ReleaseCheck.values)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: t.spaceXs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                c.checks[check] ?? false ? Icons.check_circle : Icons.cancel,
                                size: 18,
                                color: c.checks[check] ?? false ? t.success : t.danger,
                              ),
                              SizedBox(width: t.spaceSm),
                              Expanded(child: Text(_label(l10n, check))),
                            ],
                          ),
                        ),
                      if (f != null && !(c.checks[ReleaseCheck.versionBumped] ?? true)) ...[
                        SizedBox(height: t.spaceSm),
                        Text(c.hasBumpScript ? l10n.releaseBumpHint : l10n.releaseBumpHintNoScript, style: theme.textTheme.bodySmall),
                        if (c.hasBumpScript)
                          Row(
                            children: [
                              Expanded(child: SelectableText('scripts/bump-version.sh patch', style: t.logText)),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () => Clipboard.setData(const ClipboardData(text: 'scripts/bump-version.sh patch')),
                              ),
                            ],
                          ),
                      ],
                      if (f != null && !(c.checks[ReleaseCheck.verified] ?? true)) ...[
                        SizedBox(height: t.spaceSm),
                        Text(c.decision.message, style: TextStyle(color: t.warning)),
                      ],
                      if (c.message != null) ...[
                        SizedBox(height: t.spaceSm),
                        Text(c.message!, style: TextStyle(color: c.messageOk ? t.success : t.danger)),
                      ],
                    ],
                  ),
          ),
          actions: [
            TextButton(onPressed: c.loading || c.busy ? null : c.load, child: Text(l10n.releaseRecheck)),
            if (c.canTagWithoutVerification)
              TextButton(
                onPressed: _tagWithoutVerification,
                child: Text(l10n.releaseTagWithoutVerification, style: TextStyle(color: t.danger)),
              ),
            FilledButton(onPressed: c.canTag ? c.createTag : null, child: Text(l10n.releaseCreateTag)),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonClose)),
          ],
        );
      },
    );
  }
}
