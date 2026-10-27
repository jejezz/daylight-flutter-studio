import 'package:flutter/material.dart';

import '../branchdock/ui/merge_gate.dart';
import '../verify/verify_gate_controller.dart';
import '../settings/gate_settings.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../verify/verify_state.dart';

/// [VerifyGateController]의 검증 판정을 Branch Dock의 PR 카드에 연결한다.
class GitMergeGate extends MergeGateSource {
  GitMergeGate(this.git) {
    git.addListener(notifyListeners);
    // 설정에서 모드를 바꾸면 판정 줄과 단추가 바로 따라 바뀐다.
    git.gate?.addListener(notifyListeners);
  }

  final VerifyGateController git;

  @override
  bool get active => git.gate?.mode != GateMode.off;

  @override
  GateDecision get decision => git.gateDecision;

  @override
  Widget buildVerifyCard(BuildContext context) => VerifyCard(controller: git);

  @override
  Future<GateDecision> judge() async {
    await git.refreshVerdict();
    return git.gateDecision;
  }

  @override
  Future<bool> confirmOverride(BuildContext context, String reason) => confirmUnverifiedMerge(context, reason);

  @override
  void dispose() {
    git.removeListener(notifyListeners);
    git.gate?.removeListener(notifyListeners);
    super.dispose();
  }
}

/// 지금 커밋의 검증 상태 카드.
class VerifyCard extends StatelessWidget {
  const VerifyCard({super.key, required this.controller});

  final VerifyGateController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final v = controller.verdict;
    final (icon, label, color) = switch (v?.state) {
      VerifyState.verified => (context.icons.verified, l10n.gitVerified, t.success),
      VerifyState.builtOnly => (context.icons.buildCircle, l10n.gitBuiltOnly, t.warning),
      VerifyState.problem => (context.icons.reportProblem, l10n.gitVerifyProblem, t.danger),
      VerifyState.stale => (
        context.icons.update,
        v!.commitsSince == null ? l10n.gitStaleSome : l10n.gitStaleCount(v.commitsSince!),
        t.warning,
      ),
      VerifyState.unverified || null => (context.icons.help, l10n.gitUnverified, theme.colorScheme.onSurfaceVariant),
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
            if (rec != null) Text('${rec.target} · ${rec.mode} · ${rec.sha.substring(0, 7)}', style: context.logText),
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

/// 검증이 없거나 낡은 채로 병합하려 할 때 사유를 보여 주고 확인을 받는다.
Future<bool> confirmUnverifiedMerge(BuildContext context, String reason) async {
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
