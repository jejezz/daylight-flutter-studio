import 'dart:io' show Platform;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../doctor/checks.dart';
import '../doctor/environment_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// 점검 항목([CheckItem])을 화면 문구로 바꾼다 — 판단은 `doctor/checks.dart`, 문구는 여기.
String checkTitle(AppLocalizations l, CheckItem c) {
  final p = c.params;
  final s = c.status;
  return switch (c.id) {
    CheckId.flutter =>
      s == CheckStatus.ok
          ? l.checkFlutterOk(p['version']!)
          : p['error'] != null
          ? l.checkFlutterRunFail(p['error']!)
          : l.checkFlutterFail,
    CheckId.xcode => s == CheckStatus.ok ? l.checkXcodeOk(p['version']!) : l.checkXcodeFail,
    CheckId.adb => s == CheckStatus.ok ? l.checkAdbOk(p['version']!) : l.checkAdbWarn,
    CheckId.certificate => s == CheckStatus.ok ? l.checkCertificateOk(p['count']!) : l.checkCertificateFail,
    CheckId.certificateExpiry => switch (s) {
      CheckStatus.ok => l.checkCertExpiryOk(p['name']!, p['days']!),
      CheckStatus.warn => l.checkCertExpiryWarn(p['name']!, p['days']!),
      _ => l.checkCertExpiryFail(p['name']!),
    },
    CheckId.windowsDeveloperMode => s == CheckStatus.ok ? l.checkWindowsDevModeOk : l.checkWindowsDevModeWarn,
    CheckId.visualStudio => s == CheckStatus.ok ? l.checkVisualStudioOk(p['version']!) : l.checkVisualStudioFail,
  };
}

/// 문제 항목을 고치는 단계별 안내(번호 붙은 여러 줄). 해결할 것이 없으면 null.
String? checkSteps(AppLocalizations l, CheckItem c) {
  if (c.status == CheckStatus.ok || c.status == CheckStatus.info) return null;
  return switch (c.id) {
    CheckId.flutter => Platform.isWindows ? l.stepsFlutterMissingWindows : l.stepsFlutterMissing,
    CheckId.xcode => l.stepsXcodeMissing,
    CheckId.adb => l.stepsAdbMissing,
    CheckId.certificate || CheckId.certificateExpiry => l.stepsCertificate,
    CheckId.windowsDeveloperMode => l.stepsWindowsDevMode,
    CheckId.visualStudio => l.stepsVisualStudio,
  };
}

/// 설정 → 환경 점검: 이 컴퓨터의 도구·서명 점검, 도구 위치 지정.
class EnvironmentSection extends StatefulWidget {
  const EnvironmentSection({super.key, required this.controller, required this.hostIsMac, required this.hostIsWindows});

  final EnvironmentController controller;
  final bool hostIsMac;
  final bool hostIsWindows;

  @override
  State<EnvironmentSection> createState() => _EnvironmentSectionState();
}

class _EnvironmentSectionState extends State<EnvironmentSection> {
  EnvironmentController get c => widget.controller;
  final _found = <String, String?>{};

  @override
  void initState() {
    super.initState();
    // 처음 열 때만 점검한다 (점검은 몇 초 걸릴 수 있다). 다시 하려면 단추를 누른다.
    if (c.diagnostics == null) c.run();
    _locate();
  }

  Future<void> _locate() async {
    for (final tool in EnvironmentController.configurableTools) {
      _found[tool] = await c.locateTool(tool);
    }
    if (mounted) setState(() {});
  }

  Future<void> _choose(String tool) async {
    final file = await openFile();
    if (file == null) return;
    await c.setToolPath(tool, file.path);
    await _locate();
  }

  Future<void> _reset(String tool) async {
    await c.setToolPath(tool, null);
    await _locate();
  }

  IconData _icon(CheckStatus s) => switch (s) {
    CheckStatus.ok => context.icons.checkCircle,
    CheckStatus.warn => context.icons.warningAmber,
    CheckStatus.fail => context.icons.error,
    CheckStatus.info => context.icons.info,
  };

  Color _color(CheckStatus s) {
    final t = context.tokens;
    return switch (s) {
      CheckStatus.ok => t.success,
      CheckStatus.warn => t.warning,
      CheckStatus.fail => t.danger,
      CheckStatus.info => Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  Widget _tile(CheckItem item, AppLocalizations l10n) {
    final t = context.tokens;
    final steps = checkSteps(l10n, item);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(_icon(item.status), size: 16, color: _color(item.status))),
        SizedBox(width: t.spaceSm),
        Expanded(child: Text(checkTitle(l10n, item))),
      ],
    );
    if (steps == null) return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: row);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(left: 24, bottom: t.spaceSm),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        dense: true,
        title: row,
        children: [SelectableText(steps, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final checks = buildEnvironmentChecks(
          diagnostics: c.diagnostics,
          hostIsMac: widget.hostIsMac,
          hostIsWindows: widget.hostIsWindows,
          now: DateTime.now(),
        );
        final at = c.diagnostics?.collectedAt;
        final allGood = checks.isNotEmpty && checks.every((i) => i.status == CheckStatus.ok || i.status == CheckStatus.info);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    at == null ? l10n.doctorNever : l10n.doctorCollected(TimeOfDay.fromDateTime(at).format(context)),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: c.diagnosing ? null : c.run,
                  child: Text(c.diagnosing ? l10n.doctorRunning : l10n.doctorRun),
                ),
              ],
            ),
            SizedBox(height: t.spaceSm),
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
                child: Column(children: [for (final i in checks) _tile(i, l10n)]),
              ),
            ),
            if (allGood)
              Padding(
                padding: EdgeInsets.only(top: t.spaceSm),
                child: Text(l10n.doctorAllGood, style: theme.textTheme.bodySmall?.copyWith(color: t.success)),
              ),
            SizedBox(height: t.spaceLg),
            Text(l10n.toolPathsTitle, style: theme.textTheme.titleSmall),
            SizedBox(height: t.spaceXs),
            Text(l10n.toolPathsHelp, style: theme.textTheme.bodySmall),
            SizedBox(height: t.spaceSm),
            for (final tool in EnvironmentController.configurableTools) ...[
              Row(
                children: [
                  Expanded(child: Text(tool == 'adb' ? l10n.toolPathAdb : l10n.toolPathFlutter, style: theme.textTheme.labelLarge)),
                  Text(c.isCustomTool(tool) ? l10n.toolPathCustom : l10n.toolPathAuto, style: theme.textTheme.bodySmall),
                ],
              ),
              SelectableText(
                _found[tool] ?? l10n.toolPathNotFound,
                style: context.logText.copyWith(color: _found[tool] == null ? t.danger : null),
              ),
              Row(
                children: [
                  TextButton(onPressed: () => _choose(tool), child: Text(l10n.toolPathChoose)),
                  if (c.isCustomTool(tool)) TextButton(onPressed: () => _reset(tool), child: Text(l10n.toolPathAuto)),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
