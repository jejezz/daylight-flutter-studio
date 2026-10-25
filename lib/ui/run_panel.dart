import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/command_log.dart';
import '../devices/mobile_device.dart';
import '../install/install_plan.dart';
import '../run/run_controller.dart';
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
          return const Center(child: Text('열린 폴더가 Flutter 프로젝트가 아닙니다'));
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
        Text(platforms.isEmpty ? '지원 플랫폼 없음' : platforms.join(' · '), style: theme.textTheme.bodySmall),
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
            Text('대상', style: theme.textTheme.titleSmall),
            const Spacer(),
            if (controller.loadingDevices)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(tooltip: '기기 다시 찾기', icon: const Icon(Icons.refresh, size: 18), onPressed: controller.running ? null : controller.refreshDevices),
          ],
        ),
        if (devices.isEmpty) const Text('연결된 기기가 없습니다'),
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
                  subtitle: Text(_describe(d)),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _describe(MobileDevice d) {
    final platform = switch (d.platform) {
      DevicePlatform.ios => 'iOS',
      DevicePlatform.android => 'Android',
      DevicePlatform.macos => 'macOS 데스크톱',
      DevicePlatform.windows => 'Windows 데스크톱',
    };
    final link = switch (d.link) {
      DeviceLink.usb => 'USB',
      DeviceLink.wireless => '무선',
      DeviceLink.local => '이 컴퓨터',
    };
    return '$platform · $link${d.osVersion == null ? '' : ' · ${d.osVersion}'}';
  }
}

class _ModeAndRun extends StatelessWidget {
  const _ModeAndRun({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final plan = controller.plan;
    final running = controller.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<BuildMode>(
          segments: const [
            ButtonSegment(value: BuildMode.debug, label: Text('Debug (flutter run)')),
            ButtonSegment(value: BuildMode.release, label: Text('Release')),
          ],
          selected: {controller.mode},
          onSelectionChanged: running ? null : (s) => controller.setMode(s.first),
        ),
        SizedBox(height: t.spaceSm),
        for (final b in plan.blockers)
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceXs),
            child: Text(_blockerText(b), style: TextStyle(color: t.warning)),
          ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: !running && plan.runnable ? controller.start : null,
                icon: Icon(controller.mode == BuildMode.debug ? Icons.play_arrow : Icons.build),
                label: Text(controller.mode == BuildMode.debug ? '실행' : '빌드 & 설치'),
              ),
            ),
            if (running) ...[
              SizedBox(width: t.spaceSm),
              OutlinedButton.icon(onPressed: controller.cancel, icon: const Icon(Icons.stop), label: const Text('중지')),
            ],
          ],
        ),
        if (running && controller.mode == BuildMode.debug)
          Padding(
            padding: EdgeInsets.only(top: t.spaceSm),
            child: Row(
              children: [
                TextButton(onPressed: () => controller.sendKey('r'), child: const Text('r 핫 리로드')),
                TextButton(onPressed: () => controller.sendKey('R'), child: const Text('R 핫 리스타트')),
                TextButton(onPressed: () => controller.sendKey('q'), child: const Text('q 종료')),
              ],
            ),
          ),
      ],
    );
  }

  static String _blockerText(Blocker b) => switch (b) {
    Blocker.noProject => '프로젝트를 열어 주세요.',
    Blocker.noDevice => '대상을 고르세요.',
    Blocker.platformMissing => '이 프로젝트는 선택한 플랫폼을 지원하지 않습니다.',
    Blocker.iosNeedsMac => 'iOS 설치는 macOS에서만 할 수 있습니다.',
    Blocker.wireless => '무선 연결에서는 설치가 실패합니다. USB로 연결하세요.',
    Blocker.developerModeOff => 'iPhone의 개발자 모드가 꺼져 있습니다.',
    Blocker.androidUnauthorized => '휴대폰에서 USB 디버깅 승인을 눌러 주세요.',
    Blocker.needsTeamId => 'iOS 서명 Team ID가 필요합니다. (프로젝트에 DEVELOPMENT_TEAM이 있어야 합니다)',
  };
}

class _Steps extends StatelessWidget {
  const _Steps({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final steps = controller.plan.steps;
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('실행될 명령', style: theme.textTheme.titleSmall),
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
          Text(_hintText(controller.hint!), style: TextStyle(color: t.danger)),
        if (controller.missingCommand != null)
          Text('${controller.missingCommand} 명령을 찾을 수 없습니다. PATH를 확인하세요.', style: TextStyle(color: t.danger)),
      ],
    );
  }

  Widget _statusIcon(BuildContext context, StepStatus? s) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      StepStatus.done => Icon(Icons.check_circle, size: 16, color: t.success),
      StepStatus.failed => Icon(Icons.error, size: 16, color: t.danger),
      StepStatus.cancelled => Icon(Icons.cancel_outlined, size: 16, color: t.warning),
      StepStatus.running => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      _ => Icon(Icons.radio_button_unchecked, size: 16, color: scheme.outline),
    };
  }

  static String _hintText(FailureHint h) => switch (h) {
    FailureHint.useUsb => '무선 연결에서는 설치가 끊깁니다. USB로 연결하세요.',
    FailureHint.unlockDevice => '기기 화면의 잠금을 풀고 다시 시도하세요.',
    FailureHint.developerMode => '기기에서 개발자 모드를 켜세요.',
    FailureHint.signing => '서명 설정이 맞지 않습니다. Team ID와 프로비저닝 프로파일을 확인하세요.',
    FailureHint.trustComputer => '기기에서 "이 컴퓨터를 신뢰"를 눌러 주세요.',
    FailureHint.noAdb => 'adb를 찾을 수 없습니다. Android SDK platform-tools를 PATH에 추가하세요.',
    FailureHint.cocoapods => 'CocoaPods가 필요합니다.',
    FailureHint.visualStudio => 'Visual Studio의 "C++를 사용한 데스크톱 개발" 구성 요소가 필요합니다.',
    FailureHint.restartApp => '플러그인 링크를 못 찾았습니다. 앱을 다시 연 뒤 한 번 더 시도하세요.',
    FailureHint.staleBuildCache => '이전 Visual Studio 버전의 빌드 캐시가 남아 있습니다. build 폴더를 지우고 다시 시도하세요.',
  };
}

class _VerifyCard extends StatelessWidget {
  const _VerifyCard({required this.controller});

  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final rec = controller.record;
    final (label, color) = switch (rec?.status) {
      VerifyStatus.confirmed => ('확인함', t.success),
      VerifyStatus.built => ('빌드만 됨 — 아직 눈으로 확인하지 않았습니다', t.warning),
      VerifyStatus.problem => ('문제 있음', t.danger),
      null => ('이 커밋은 아직 검증하지 않았습니다', theme.colorScheme.onSurfaceVariant),
    };
    return Card(
      child: Padding(
        padding: EdgeInsets.all(t.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('검증', style: theme.textTheme.titleSmall),
            SizedBox(height: t.spaceXs),
            if (controller.snapshot != null)
              Text('${controller.snapshot!.branch ?? '(분리된 HEAD)'} @ ${controller.snapshot!.shortSha}', style: t.logText),
            Text(label, style: TextStyle(color: color)),
            if (rec != null && rec.note.isNotEmpty) Text(rec.note),
            if (controller.recordSkipped != null)
              Text(controller.recordSkipped!, style: TextStyle(color: t.warning)),
            if (controller.awaitingConfirm) ...[
              SizedBox(height: t.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(onPressed: controller.confirm, icon: const Icon(Icons.check), label: const Text('확인함')),
                  ),
                  SizedBox(width: t.spaceSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reportProblem(context),
                      icon: const Icon(Icons.report_problem_outlined),
                      label: const Text('문제 있음'),
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
    final text = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('어떤 문제가 있나요?'),
        content: TextField(controller: text, autofocus: true, minLines: 3, maxLines: 8, decoration: const InputDecoration(hintText: '예: 로그인 버튼이 눌리지 않습니다')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, text.text.trim()), child: const Text('기록하고 복사')),
        ],
      ),
    );
    text.dispose();
    if (note == null || note.isEmpty) return;
    await controller.reportProblem(note);
    // Claude 세션에 바로 붙여 넣을 수 있게 복사한다.
    await Clipboard.setData(ClipboardData(text: note));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메모를 복사했습니다. Claude 세션에 붙여 넣으세요.')));
    }
  }
}

class _Output extends StatelessWidget {
  const _Output({required this.log});

  final CommandLog log;

  @override
  Widget build(BuildContext context) {
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
            Text('출력', style: theme.textTheme.titleSmall),
            const Spacer(),
            IconButton(
              tooltip: '출력 복사',
              icon: const Icon(Icons.copy, size: 16),
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
          child: SingleChildScrollView(reverse: true, child: SelectableText(tail.isEmpty ? '(출력 없음)' : tail, style: t.logText)),
        ),
      ],
    );
  }
}
