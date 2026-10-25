import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/command_log.dart';
import '../devices/mobile_device.dart';
import '../install/install_plan.dart';
import '../run/run_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../verify/verify_store.dart';

/// Run 패널: 대상 기기·모드를 고르고, 실행될 명령을 보며 빌드·설치하고, 결과를 눈으로 확인해 기록한다.
class RunPanel extends StatelessWidget {
  const RunPanel({super.key, required this.controller, required this.log});

  final RunController controller;
  final CommandLog log;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, log]),
      builder: (context, _) {
        final project = controller.project;
        if (project == null) {
          return Center(child: Text(AppLocalizations.of(context).runNotFlutterProject));
        }
        return ListView(
          padding: EdgeInsets.all(t.spaceMd),
          children: [
            _Header(controller: controller),
            SizedBox(height: t.spaceMd),
            _Devices(controller: controller),
            SizedBox(height: t.spaceMd),
            _ModeAndRun(controller: controller),
            SizedBox(height: t.spaceMd),
            _Steps(controller: controller),
            if (controller.awaitingConfirm || controller.recordSkipped != null || controller.record != null) ...[
              SizedBox(height: t.spaceMd),
              _VerifyCard(controller: controller),
            ],
            SizedBox(height: t.spaceMd),
            _Output(log: log),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = controller.project!;
    final platforms = [
      if (p.hasAndroid) 'Android',
      if (p.hasIos) 'iOS',
      if (p.hasMacos) 'macOS',
      if (p.hasWindows) 'Windows',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${p.name}${p.version == null ? '' : '  ${p.version}'}', style: theme.textTheme.titleMedium),
        Text(platforms.isEmpty ? AppLocalizations.of(context).runNoPlatforms : platforms.join(' · '), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Devices extends StatelessWidget {
  const _Devices({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devices = controller.visibleDevices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context).runTarget, style: theme.textTheme.titleSmall),
            const Spacer(),
            if (controller.loadingDevices)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(tooltip: AppLocalizations.of(context).runRefreshDevices, icon: Icon(context.icons.refresh, size: 18), onPressed: controller.running ? null : controller.refreshDevices),
          ],
        ),
        if (devices.isEmpty) Text(AppLocalizations.of(context).runNoDevices),
        RadioGroup<String>(
          groupValue: controller.selectedId,
          onChanged: (id) {
            for (final d in devices) {
              if (d.id == id && !controller.running) controller.select(d);
            }
          },
          child: Column(
            children: [
              for (final d in devices)
                RadioListTile<String>(
                  value: d.id,
                  title: Text(d.name),
                  subtitle: Text(_describe(AppLocalizations.of(context), d)),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _describe(AppLocalizations l10n, MobileDevice d) {
    final platform = switch (d.platform) {
      DevicePlatform.ios => 'iOS',
      DevicePlatform.android => 'Android',
      DevicePlatform.macos => l10n.runPlatformMacos,
      DevicePlatform.windows => l10n.runPlatformWindows,
    };
    final link = switch (d.link) {
      DeviceLink.usb => 'USB',
      DeviceLink.wireless => l10n.runLinkWireless,
      DeviceLink.local => l10n.runLinkLocal,
    };
    return '$platform · $link${d.osVersion == null ? '' : ' · ${d.osVersion}'}';
  }
}

class _ModeAndRun extends StatelessWidget {
  const _ModeAndRun({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final plan = controller.plan;
    final running = controller.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<BuildMode>(
          segments: [
            ButtonSegment(value: BuildMode.debug, label: Text(l10n.runModeDebug)),
            const ButtonSegment(value: BuildMode.release, label: Text('Release')),
          ],
          selected: {controller.mode},
          onSelectionChanged: running ? null : (s) => controller.setMode(s.first),
        ),
        SizedBox(height: t.spaceSm),
        for (final b in plan.blockers)
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceXs),
            child: Text(_blockerText(l10n, b), style: TextStyle(color: t.warning)),
          ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: !running && plan.runnable ? controller.start : null,
                icon: Icon(controller.mode == BuildMode.debug ? context.icons.playArrow : context.icons.build),
                label: Text(controller.mode == BuildMode.debug ? l10n.runStart : l10n.runBuildInstall),
              ),
            ),
            if (running) ...[
              SizedBox(width: t.spaceSm),
              OutlinedButton.icon(onPressed: controller.cancel, icon: Icon(context.icons.stop), label: Text(l10n.commonStop)),
            ],
          ],
        ),
        if (running && controller.mode == BuildMode.debug)
          Padding(
            padding: EdgeInsets.only(top: t.spaceSm),
            child: Row(
              children: [
                TextButton(onPressed: () => controller.sendKey('r'), child: Text(l10n.runHotReload)),
                TextButton(onPressed: () => controller.sendKey('R'), child: Text(l10n.runHotRestart)),
                TextButton(onPressed: () => controller.sendKey('q'), child: Text(l10n.runQuit)),
              ],
            ),
          ),
      ],
    );
  }

  static String _blockerText(AppLocalizations l10n, Blocker b) => switch (b) {
    Blocker.noProject => l10n.runBlockerNoProject,
    Blocker.noDevice => l10n.runBlockerNoDevice,
    Blocker.platformMissing => l10n.runBlockerPlatformMissing,
    Blocker.iosNeedsMac => l10n.runBlockerIosNeedsMac,
    Blocker.wireless => l10n.runBlockerWireless,
    Blocker.developerModeOff => l10n.runBlockerDeveloperModeOff,
    Blocker.androidUnauthorized => l10n.runBlockerAndroidUnauthorized,
    Blocker.needsTeamId => l10n.runBlockerNeedsTeamId,
  };
}

class _Steps extends StatelessWidget {
  const _Steps({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final steps = controller.plan.steps;
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.runCommandsToRun, style: theme.textTheme.titleSmall),
        SizedBox(height: t.spaceXs),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceXs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusIcon(context, i < controller.statuses.length ? controller.statuses[i] : null),
                SizedBox(width: t.spaceSm),
                Expanded(child: SelectableText(steps[i].commandLine, style: t.logText)),
              ],
            ),
          ),
        if (controller.hint != null)
          Text(_hintText(l10n, controller.hint!), style: TextStyle(color: t.danger)),
        if (controller.missingCommand != null)
          Text(l10n.runCommandNotFound(controller.missingCommand!), style: TextStyle(color: t.danger)),
      ],
    );
  }

  Widget _statusIcon(BuildContext context, StepStatus? s) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      StepStatus.done => Icon(context.icons.checkCircle, size: 16, color: t.success),
      StepStatus.failed => Icon(context.icons.error, size: 16, color: t.danger),
      StepStatus.cancelled => Icon(context.icons.cancel, size: 16, color: t.warning),
      StepStatus.running => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      _ => Icon(context.icons.radioButtonUnchecked, size: 16, color: scheme.outline),
    };
  }

  static String _hintText(AppLocalizations l10n, FailureHint h) => switch (h) {
    FailureHint.useUsb => l10n.runHintUseUsb,
    FailureHint.unlockDevice => l10n.runHintUnlockDevice,
    FailureHint.developerMode => l10n.runHintDeveloperMode,
    FailureHint.signing => l10n.runHintSigning,
    FailureHint.trustComputer => l10n.runHintTrustComputer,
    FailureHint.noAdb => l10n.runHintNoAdb,
    FailureHint.cocoapods => l10n.runHintCocoapods,
    FailureHint.visualStudio => l10n.runHintVisualStudio,
    FailureHint.restartApp => l10n.runHintRestartApp,
    FailureHint.staleBuildCache => l10n.runHintStaleBuildCache,
  };
}

class _VerifyCard extends StatelessWidget {
  const _VerifyCard({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final rec = controller.record;
    final (label, color) = switch (rec?.status) {
      VerifyStatus.confirmed => (l10n.runVerifyConfirmed, t.success),
      VerifyStatus.built => (l10n.runVerifyBuilt, t.warning),
      VerifyStatus.problem => (l10n.runVerifyProblem, t.danger),
      null => (l10n.runVerifyNone, theme.colorScheme.onSurfaceVariant),
    };
    return Card(
      child: Padding(
        padding: EdgeInsets.all(t.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.runVerifyTitle, style: theme.textTheme.titleSmall),
            SizedBox(height: t.spaceXs),
            if (controller.snapshot != null)
              Text('${controller.snapshot!.branch ?? l10n.runDetachedHead} @ ${controller.snapshot!.shortSha}', style: t.logText),
            Text(label, style: TextStyle(color: color)),
            if (rec != null && rec.note.isNotEmpty) Text(rec.note),
            if (controller.recordSkipped != null)
              Text(_skippedText(l10n, controller.recordSkipped!), style: TextStyle(color: t.warning)),
            if (controller.awaitingConfirm) ...[
              SizedBox(height: t.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(onPressed: controller.confirm, icon: Icon(context.icons.check), label: Text(l10n.runVerifyConfirmed)),
                  ),
                  SizedBox(width: t.spaceSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reportProblem(context),
                      icon: Icon(context.icons.reportProblem),
                      label: Text(l10n.runVerifyProblem),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reportProblem(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.runProblemTitle),
        content: TextField(controller: text, autofocus: true, minLines: 3, maxLines: 8, decoration: InputDecoration(hintText: l10n.runProblemHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, text.text.trim()), child: Text(l10n.runRecordAndCopy)),
        ],
      ),
    );
    text.dispose();
    if (note == null || note.isEmpty) return;
    await controller.reportProblem(note);
    // Claude 세션에 바로 붙여 넣을 수 있게 복사한다.
    await Clipboard.setData(ClipboardData(text: note));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.runNoteCopied)));
    }
  }
}

String _skippedText(AppLocalizations l10n, RecordSkip skip) => switch (skip) {
  RecordSkip.notGit => l10n.runRecordSkippedNotGit,
  RecordSkip.dirty => l10n.runRecordSkippedDirty,
};

class _Output extends StatelessWidget {
  const _Output({required this.log});

  final CommandLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final last = log.last;
    if (last == null) return const SizedBox.shrink();
    final text = last.output;
    final tail = text.length > 20000 ? text.substring(text.length - 20000) : text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(l10n.runOutput, style: theme.textTheme.titleSmall),
            const Spacer(),
            IconButton(
              tooltip: l10n.runCopyOutput,
              icon: Icon(context.icons.copy, size: 16),
              onPressed: () => Clipboard.setData(ClipboardData(text: text)),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 280),
          padding: EdgeInsets.all(t.spaceSm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(t.radius),
          ),
          child: SingleChildScrollView(reverse: true, child: SelectableText(tail.isEmpty ? l10n.runNoOutput : tail, style: t.logText)),
        ),
      ],
    );
  }
}
