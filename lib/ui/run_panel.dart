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

/// Run 패널: 위에 실행 도구 막대(대상 · 모드 · 실행), 아래에 왼쪽 설정(빌드 옵션 · 실행 단계) | 오른쪽 결과(검증 · 출력).
///
/// 대상은 도구 막대의 드롭다운에서 고른다. 기기 목록·새로 고침·"기기가 안 보일 때" 안내가 그 안에 있다.
class RunPanel extends StatelessWidget {
  const RunPanel({super.key, required this.controller, required this.log});

  final RunController controller;
  final CommandLog log;

  /// 이 너비 이상이면 두 칸(설정 | 결과)으로 나눈다.
  static const wideWidth = 760.0;

  /// 두 칸일 때 왼쪽(설정) 칸의 너비.
  static const wideControlsWidth = 380.0;

  /// 이 높이보다 낮으면 너비가 넓어도 두 칸으로 나누지 않고 세로로 스크롤하게 쌓는다.
  /// 도구 막대(둘째 줄로 넘어갈 수 있다)와 구분선이 이 안에 다 들어가야 넘치지 않는다.
  static const wideMinHeight = 240.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, log]),
      builder: (context, _) {
        final project = controller.project;
        if (project == null) {
          if (controller.candidates.length > 1) {
            return Padding(padding: EdgeInsets.all(t.spaceMd), child: _ProjectPicker(controller: controller));
          }
          return Center(child: Text(AppLocalizations.of(context).runNotFlutterProject));
        }
        final verify = controller.awaitingConfirm || controller.recordSkipped != null || controller.record != null;
        return LayoutBuilder(
          builder: (context, box) {
            final toolbar = Padding(
              padding: EdgeInsets.fromLTRB(t.spaceMd, t.spaceSm, t.spaceMd, t.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.candidates.length > 1) ...[
                    _ProjectPicker(controller: controller),
                    SizedBox(height: t.spaceSm),
                  ],
                  _Toolbar(controller: controller),
                ],
              ),
            );
            final settings = <Widget>[_Settings(controller: controller)];
            final results = <Widget>[
              if (verify) ...[_VerifyCard(controller: controller), SizedBox(height: t.spaceMd)],
              _Output(log: log),
            ];
            if (box.maxWidth < wideWidth || box.maxHeight < wideMinHeight) {
              return ListView(
                padding: EdgeInsets.only(bottom: t.spaceMd),
                children: [
                  toolbar,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spaceMd),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...settings, SizedBox(height: t.spaceMd), ...results]),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                toolbar,
                const Divider(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: wideControlsWidth,
                        child: ListView(padding: EdgeInsets.all(t.spaceMd), children: settings),
                      ),
                      const VerticalDivider(),
                      Expanded(child: ListView(padding: EdgeInsets.all(t.spaceMd), children: results)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// 열린 폴더에 Flutter 프로젝트가 여럿일 때 쓸 프로젝트를 고르는 드롭다운.
class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.project == null) ...[Text(l10n.runPickProject), SizedBox(height: t.spaceSm)],
        DropdownButton<String>(
          isExpanded: true,
          hint: Text(l10n.runProject),
          value: c.project?.path,
          items: [
            for (final p in c.candidates)
              DropdownMenuItem(value: p.path, child: Text('${p.name}  (${p.path.split(RegExp(r'[\\/]')).last})')),
          ],
          onChanged: c.running ? null : (path) => c.chooseProject(c.candidates.firstWhere((p) => p.path == path)),
        ),
      ],
    );
  }
}

/// 한 줄 실행 도구 막대: 대상 드롭다운 · Debug/Release · 실행(또는 중지) · 보조 단추 · 프로젝트 이름.
/// 좁으면 다음 줄로 넘어간다.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final c = controller;
    final plan = c.plan;
    final interactive = plan.steps.isNotEmpty && plan.steps.first.interactive;
    final p = c.project!;
    final platforms = [
      if (p.hasAndroid) 'Android',
      if (p.hasIos) 'iOS',
      if (p.hasMacos) 'macOS',
      if (p.hasWindows) 'Windows',
    ];

    final runButton = c.running
        ? OutlinedButton.icon(
            onPressed: c.cancel,
            icon: Icon(context.icons.stop, size: 18),
            label: Text(interactive ? l10n.homeActionStop : l10n.homeActionCancel),
          )
        : FilledButton.icon(
            onPressed: plan.runnable ? c.start : null,
            icon: Icon(context.icons.playArrow, size: 18),
            // 데스크톱(이 컴퓨터)은 바로 실행하고, 폰은 설치한다.
            label: Text(
              interactive
                  ? l10n.homeActionRun
                  : (c.device?.isDesktop ?? false)
                  ? l10n.homeActionBuildRun
                  : l10n.homeActionInstall,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: t.spaceSm,
          runSpacing: t.spaceSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _TargetButton(controller: c),
            SegmentedButton<BuildMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: BuildMode.debug, label: Text(l10n.homeModeDebug)),
                ButtonSegment(value: BuildMode.release, label: Text(l10n.homeModeRelease)),
              ],
              selected: {c.mode},
              onSelectionChanged: c.running ? null : (s) => c.setMode(s.first),
            ),
            runButton,
            if (c.running && interactive) ...[
              IconButton.outlined(tooltip: l10n.homeHotReload, icon: Icon(context.icons.bolt), onPressed: () => c.sendKey('r')),
              IconButton.outlined(tooltip: l10n.homeHotRestart, icon: Icon(context.icons.restartAlt), onPressed: () => c.sendKey('R')),
              // 창을 닫아도 flutter_tools가 스스로 끝나지 않을 때가 있다 — `q`로 정상 종료하면
              // 종료 코드 0이 되어 검증 기록(확인함/문제 있음)으로 이어진다. "중지"는 강제 종료라 기록하지 않는다.
              IconButton.outlined(tooltip: l10n.runQuit, icon: Icon(context.icons.stop), onPressed: () => c.sendKey('q')),
            ],
            // release: 빌드와 실행을 따로 할 수 있다. 실행만은 이미 만든 결과물이 있을 때 쓴다.
            if (plan.splittable && !c.running) ...[
              OutlinedButton(
                onPressed: plan.runnable ? () => c.start(phase: RunPhase.build) : null,
                child: Text(l10n.homeActionBuildOnly),
              ),
              _runOnlyButton(c, l10n, plan),
            ],
            // debug: 전에 `flutter run`으로 만들어 둔 실행 파일이 있으면 새로 빌드·연결하지 않고 그걸 바로 다시 연다.
            if (interactive && !c.running && c.artifactReady)
              OutlinedButton(onPressed: c.relaunchArtifact, child: Text(l10n.homeActionRelaunch)),
            _CleanButton(controller: c),
            Text(
              '${p.name}${p.version == null ? '' : '  ${p.version}'}'
              '${platforms.isEmpty ? '' : '  ·  ${platforms.join(' · ')}'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        for (final b in plan.blockers)
          Padding(
            padding: EdgeInsets.only(top: t.spaceXs),
            child: Text(_blockerText(l10n, b), style: TextStyle(color: t.warning)),
          ),
        if (c.missingCommand != null)
          Padding(
            padding: EdgeInsets.only(top: t.spaceXs),
            child: Text(l10n.runCommandNotFound(c.missingCommand!), style: TextStyle(color: t.danger)),
          )
        else if (c.hint != null)
          Padding(
            padding: EdgeInsets.only(top: t.spaceXs),
            child: Text(_hintText(l10n, c.hint!), style: TextStyle(color: t.danger)),
          ),
      ],
    );
  }

  static Widget _runOnlyButton(RunController c, AppLocalizations l10n, InstallPlan plan) {
    final ready = plan.runnable && c.artifactReady;
    final button = OutlinedButton(
      onPressed: ready ? () => c.start(phase: RunPhase.run) : null,
      child: Text((c.device?.isDesktop ?? false) ? l10n.homeActionRunOnly : l10n.homeActionInstallOnly),
    );
    // 결과물이 없어서 누를 수 없을 때만 이유를 알려 준다.
    return plan.runnable && !c.artifactReady ? Tooltip(message: l10n.homeRunOnlyNeedsBuild, child: button) : button;
  }
}

/// 대상 드롭다운: 누르면 기기 목록이 팝업으로 열린다. 맨 아래에 "기기 다시 찾기".
class _TargetButton extends StatelessWidget {
  const _TargetButton({required this.controller});

  final RunController controller;

  static const _refresh = Object();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final c = controller;
    final devices = c.visibleDevices;
    final label = c.device == null ? l10n.runTargetNone : c.device!.name;
    return PopupMenuButton<Object>(
      tooltip: l10n.runTarget,
      enabled: !c.running,
      position: PopupMenuPosition.under,
      onSelected: (v) {
        if (identical(v, _refresh)) {
          c.refreshDevices();
        } else if (v is MobileDevice) {
          c.select(v);
        }
      },
      itemBuilder: (context) => [
        if (devices.isEmpty)
          PopupMenuItem<Object>(
            enabled: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.runNoDevices, style: theme.textTheme.titleSmall),
                  SizedBox(height: t.spaceXs),
                  Text(l10n.runStepsNoDevice, style: theme.textTheme.bodySmall?.copyWith(height: 1.5), softWrap: true),
                ],
              ),
            ),
          ),
        for (final d in devices)
          CheckedPopupMenuItem<Object>(
            value: d,
            checked: d.id == c.selectedId,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(d.name), Text(_describe(l10n, d), style: theme.textTheme.bodySmall)],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<Object>(
          value: _refresh,
          child: Row(children: [Icon(context.icons.refresh, size: 18), SizedBox(width: t.spaceSm), Text(l10n.runRefreshDevices)]),
        ),
      ],
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(t.radius)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c.loadingDevices)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(context.icons.smartphone, size: 18),
            SizedBox(width: t.spaceSm),
            Text(label),
            SizedBox(width: t.spaceXs),
            Icon(context.icons.arrowDropDown, size: 20),
          ],
        ),
      ),
    );
  }
}

/// `flutter clean` → `flutter pub get`을 지금 실행하는 단추. 마지막 결과는 단추 옆에 짧게 보인다.
class _CleanButton extends StatelessWidget {
  const _CleanButton({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final c = controller;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: '${l10n.homeActionClean} — ${l10n.homeCleanHelp}',
          child: IconButton.outlined(
            onPressed: c.running || c.cleaning ? null : c.cleanProject,
            icon: c.cleaning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(context.icons.cleaningServices, size: 18),
          ),
        ),
        if (c.cleanResult != null && !c.cleaning)
          Padding(
            padding: EdgeInsets.only(left: t.spaceXs),
            child: Text(
              c.cleanResult! ? l10n.homeCleanDone : l10n.homeCleanFailed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.cleanResult! ? t.success : t.danger),
            ),
          ),
      ],
    );
  }
}

/// 왼쪽 설정 칸: 빌드 옵션(접힘), iOS Team ID, 실행 단계(접힘).
class _Settings extends StatefulWidget {
  const _Settings({required this.controller});

  final RunController controller;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 프로젝트마다 입력 칸을 새로 만든다 (저장된 옵션이 그 프로젝트 것으로 채워지게).
        BuildOptionsSection(key: ValueKey(c.project!.path), controller: c),
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
        if (plan.steps.isNotEmpty) ...[
          SizedBox(height: t.spaceSm),
          // 실행 중이거나 막 끝났을 때는 진행을 볼 수 있게 펼치고, 평소에는 접어 둔다.
          ExpansionTile(
            key: ValueKey('steps-${c.running}'),
            initiallyExpanded: c.running,
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.homeStepsTitle, style: theme.textTheme.titleSmall),
            children: [
              for (var i = 0; i < plan.steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == plan.steps.length - 1 ? 0 : t.spaceMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: const EdgeInsets.only(top: 2), child: _statusIcon(i < c.statuses.length ? c.statuses[i] : null)),
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
        ],
      ],
    );
  }
}

String _describe(AppLocalizations l10n, MobileDevice d) {
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
              Text('${controller.snapshot!.branch ?? l10n.runDetachedHead} @ ${controller.snapshot!.shortSha}', style: context.logText),
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
            child: SelectableText('\$ ${last.commandLine}\n${tail.join('\n')}', style: context.logText),
          ),
        ),
      ],
    );
  }
}
