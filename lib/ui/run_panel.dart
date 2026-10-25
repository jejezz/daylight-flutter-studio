import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/command_log.dart';
import '../devices/mobile_device.dart';
import '../install/install_plan.dart';
import '../run/run_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'build_options_section.dart';
import 'command_text.dart';
import 'copy_output_button.dart';
import 'output_viewer.dart';
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
            _BuildSection(controller: controller),
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

class _BuildSection extends StatefulWidget {
  const _BuildSection({required this.controller});

  final RunController controller;

  @override
  State<_BuildSection> createState() => _BuildSectionState();
}

class _BuildSectionState extends State<_BuildSection> {
  late final _team = TextEditingController(text: widget.controller.teamId ?? '');

  @override
  void dispose() {
    _team.dispose();
    super.dispose();
  }

  String _stepLabel(AppLocalizations l10n, StepKind k) => switch (k) {
    StepKind.prepare => l10n.homeStepPrepare,
    StepKind.build => l10n.homeStepBuild,
    StepKind.install => l10n.homeStepInstall,
    StepKind.launch => l10n.homeStepLaunch,
    StepKind.run => l10n.homeStepRun,
  };

  /// `flutter clean` → `flutter pub get`을 지금 실행하는 단추와 마지막 결과.
  Widget _cleanButton(RunController c, AppLocalizations l10n) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tooltip(
          message: l10n.homeCleanHelp,
          child: OutlinedButton.icon(
            onPressed: c.running || c.cleaning ? null : c.cleanProject,
            icon: c.cleaning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(context.icons.cleaningServices, size: 18),
            label: Text(l10n.homeActionClean),
          ),
        ),
        if (c.cleanResult != null && !c.cleaning)
          Padding(
            padding: EdgeInsets.only(top: t.spaceXs),
            child: Text(
              c.cleanResult! ? l10n.homeCleanDone : l10n.homeCleanFailed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.cleanResult! ? t.success : t.danger),
            ),
          ),
      ],
    );
  }

  Widget _runOnlyButton(RunController c, AppLocalizations l10n, InstallPlan plan) {
    final ready = plan.runnable && c.artifactReady;
    final button = OutlinedButton(
      onPressed: ready ? () => c.start(phase: RunPhase.run) : null,
      child: Text((c.device?.isDesktop ?? false) ? l10n.homeActionRunOnly : l10n.homeActionInstallOnly),
    );
    // 결과물이 없어서 누를 수 없을 때만 이유를 알려 준다.
    return plan.runnable && !c.artifactReady ? Tooltip(message: l10n.homeRunOnlyNeedsBuild, child: button) : button;
  }

  Widget _statusIcon(StepStatus? s) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      StepStatus.running => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      StepStatus.done => Icon(context.icons.checkCircle, size: 16, color: t.success),
      StepStatus.failed => Icon(context.icons.error, size: 16, color: t.danger),
      StepStatus.cancelled => Icon(context.icons.cancel, size: 16, color: t.warning),
      _ => Icon(context.icons.radioButtonUnchecked, size: 16, color: scheme.outline),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final plan = c.plan;
    final isIos = c.device?.platform == DevicePlatform.ios;
    final interactive = plan.steps.isNotEmpty && plan.steps.first.interactive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.homeBuildTitle),
        SegmentedButton<BuildMode>(
          segments: [
            ButtonSegment(value: BuildMode.debug, label: Text(l10n.homeModeDebug)),
            ButtonSegment(value: BuildMode.release, label: Text(l10n.homeModeRelease)),
          ],
          selected: {c.mode},
          onSelectionChanged: c.running ? null : (s) => c.setMode(s.first),
        ),
        if (c.project != null) ...[
          SizedBox(height: t.spaceXs),
          // 프로젝트마다 입력 칸을 새로 만든다 (저장된 옵션이 그 프로젝트 것으로 채워지게).
          BuildOptionsSection(key: ValueKey(c.project!.path), controller: c),
        ],
        if (isIos) ...[
          SizedBox(height: t.spaceMd),
          TextField(
            controller: _team,
            enabled: !c.running,
            decoration: InputDecoration(
              labelText: l10n.homeTeamLabel,
              hintText: c.project?.iosTeamId,
              helperText: l10n.homeTeamHelp,
              helperMaxLines: 3,
            ),
            onChanged: c.setTeamId,
          ),
        ],
        SizedBox(height: t.spaceMd),
        for (final b in plan.blockers)
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceXs),
            child: Text(_blockerText(l10n, b), style: TextStyle(color: t.warning)),
          ),
        if (plan.steps.isNotEmpty) ...[
          _SectionTitle(l10n.homeStepsTitle),
          Card(
            child: Padding(
              padding: EdgeInsets.all(t.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 빌드 전에 하는 일이라 목록 맨 위에 둔다. 누르면 바로 실행하고, 안 눌러도 빌드는 된다.
                  _cleanButton(c, l10n),
                  Divider(height: t.spaceLg * 2),
                  for (var i = 0; i < plan.steps.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == plan.steps.length - 1 ? 0 : t.spaceMd),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: _statusIcon(i < c.statuses.length ? c.statuses[i] : null),
                          ),
                          SizedBox(width: t.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${i + 1}. ${_stepLabel(l10n, plan.steps[i].kind)}', style: theme.textTheme.labelLarge),
                                CommandText(plan.steps[i].commandLine),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: t.spaceMd),
        Row(
          children: [
            Expanded(
              child: c.running
                  ? OutlinedButton(
                      onPressed: c.cancel,
                      child: Text(interactive ? l10n.homeActionStop : l10n.homeActionCancel),
                    )
                  : FilledButton(
                      onPressed: plan.runnable ? c.start : null,
                      // 데스크톱(이 컴퓨터)은 바로 실행하고, 폰은 설치한다.
                      child: Text(
                        interactive
                            ? l10n.homeActionRun
                            : (c.device?.isDesktop ?? false)
                            ? l10n.homeActionBuildRun
                            : l10n.homeActionInstall,
                      ),
                    ),
            ),
            if (c.running && interactive) ...[
              SizedBox(width: t.spaceSm),
              IconButton.outlined(
                tooltip: l10n.homeHotReload,
                icon: Icon(context.icons.bolt),
                onPressed: () => c.sendKey('r'),
              ),
              IconButton.outlined(
                tooltip: l10n.homeHotRestart,
                icon: Icon(context.icons.restartAlt),
                onPressed: () => c.sendKey('R'),
              ),
            ],
          ],
        ),
        // release: 빌드와 실행을 따로 할 수 있다. 실행만은 이미 만든 결과물이 있을 때 쓴다.
        if (plan.splittable && !c.running) ...[
          SizedBox(height: t.spaceSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: plan.runnable ? () => c.start(phase: RunPhase.build) : null,
                  child: Text(l10n.homeActionBuildOnly),
                ),
              ),
              SizedBox(width: t.spaceSm),
              Expanded(child: _runOnlyButton(c, l10n, plan)),
            ],
          ),
        ],
        // 실행할 명령이 없을 때(기기를 아직 못 골랐을 때 등)는 카드가 없으므로 정리 단추만 따로 둔다.
        if (c.project != null && plan.steps.isEmpty) ...[
          SizedBox(height: t.spaceSm),
          _cleanButton(c, l10n),
        ],
        if (c.missingCommand != null)
          Padding(
            padding: EdgeInsets.only(top: t.spaceSm),
            child: Text(l10n.runCommandNotFound(c.missingCommand!), style: TextStyle(color: t.danger)),
          )
        else if (c.hint != null)
          Padding(
            padding: EdgeInsets.only(top: t.spaceSm),
            child: Text(_hintText(l10n, c.hint!), style: TextStyle(color: t.danger)),
          ),
      ],
    );
  }
}

/// 구역 제목 (Flutty Dock의 SectionTitle).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spaceSm),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

String _blockerText(AppLocalizations l10n, Blocker b) => switch (b) {
  Blocker.noProject => l10n.runBlockerNoProject,
  Blocker.noDevice => l10n.runBlockerNoDevice,
  Blocker.platformMissing => l10n.runBlockerPlatformMissing,
  Blocker.iosNeedsMac => l10n.runBlockerIosNeedsMac,
  Blocker.wireless => l10n.runBlockerWireless,
  Blocker.developerModeOff => l10n.runBlockerDeveloperModeOff,
  Blocker.androidUnauthorized => l10n.runBlockerAndroidUnauthorized,
  Blocker.needsTeamId => l10n.runBlockerNeedsTeamId,
};

String _hintText(AppLocalizations l10n, FailureHint h) => switch (h) {
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
    final lines = last.output.trimRight().split('\n');
    final tail = lines.length > 60 ? lines.sublist(lines.length - 60) : lines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(l10n.homeOutputTitle)),
            IconButton(
              tooltip: l10n.outputViewer,
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              icon: Icon(context.icons.openInFull),
              onPressed: () => OutputViewerScreen.open(context, log, last),
            ),
            CopyOutputButton(text: () => '\$ ${last.commandLine}\n${last.output.trimRight()}'),
          ],
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 260),
          padding: EdgeInsets.all(t.spaceMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(t.radius),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: SelectableText('\$ ${last.commandLine}\n${tail.join('\n')}', style: t.logText),
          ),
        ),
      ],
    );
  }
}
