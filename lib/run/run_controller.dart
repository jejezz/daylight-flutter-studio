import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/command_runner.dart';
import '../devices/device_service.dart';
import '../devices/mobile_device.dart';
import '../flutter/flutter_project.dart';
import '../install/build_options.dart';
import '../install/install_plan.dart';
import '../verify/verify_store.dart';

/// 검증 기록을 남기지 않은 이유 — 문구는 화면이 번역해 보여 준다.
enum RecordSkip { notGit, dirty }

enum StepStatus { pending, running, done, failed, cancelled }

/// Run 패널의 상태: 프로젝트·기기·모드를 고르고 계획을 실행하며, 성공하면 검증 기록을 남긴다.
class RunController extends ChangeNotifier {
  RunController({required this.runner, required this.deviceService, required this.store, bool? hostIsMac, bool? hostIsWindows})
    : hostIsMac = hostIsMac ?? Platform.isMacOS,
      hostIsWindows = hostIsWindows ?? Platform.isWindows;

  static const _modeKey = 'build_mode';

  final CommandRunner runner;
  final DeviceService deviceService;
  final VerifyStore store;
  final bool hostIsMac;
  final bool hostIsWindows;

  FlutterProject? project;
  List<MobileDevice> devices = const [];
  bool loadingDevices = false;
  String? selectedId;
  BuildMode mode = BuildMode.debug;
  BuildOptions options = const BuildOptions();

  bool running = false;
  List<StepStatus> statuses = const [];
  FailureHint? hint;
  String? missingCommand;
  RunHandle? _handle;

  /// 작업 폴더의 git 상태와, 지금 HEAD 커밋에 남아 있는 검증 기록.
  RepoSnapshot? snapshot;
  VerifyRecord? record;

  /// 이번 실행을 기록하지 못한 이유 (수정 중인 파일이 있음 등). 없으면 null.
  RecordSkip? recordSkipped;

  /// 방금 끝난 실행이 기록 대상인지 — 성공했을 때만 "확인함/문제 있음"을 묻는다.
  bool awaitingConfirm = false;

  List<MobileDevice> get visibleDevices {
    final host = hostDesktopDevice(project, isMac: hostIsMac, isWindows: hostIsWindows);
    return [...devices, ?host];
  }

  MobileDevice? get device {
    for (final d in visibleDevices) {
      if (d.id == selectedId) return d;
    }
    return null;
  }

  InstallPlan get plan => buildInstallPlan(
    project: project,
    device: device,
    mode: mode,
    teamId: null,
    hostIsMac: hostIsMac,
    windowsArch: Platform.environment['PROCESSOR_ARCHITECTURE']?.toUpperCase() == 'ARM64' ? 'arm64' : 'x64',
    options: options,
  );

  bool _supports(MobileDevice d) {
    final p = project;
    if (p == null) return true;
    return switch (d.platform) {
      DevicePlatform.ios => p.hasIos,
      DevicePlatform.android => p.hasAndroid,
      DevicePlatform.macos => p.hasMacos,
      DevicePlatform.windows => p.hasWindows,
    };
  }

  /// 프로젝트가 지원하는 대상 중 USB 실기기 → 이 컴퓨터 순으로 기본 선택.
  void _pickDefaultDevice() {
    final all = visibleDevices;
    final supported = all.where(_supports).toList();
    selectedId = [...supported.where((d) => d.isUsb), ...supported, ...all].firstOrNull?.id;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      mode = BuildMode.values.asNameMap()[prefs.getString(_modeKey)] ?? mode;
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
    await refreshDevices();
  }

  /// 스튜디오가 연 폴더가 바뀔 때 부른다. Flutter 프로젝트가 아니면 project는 null.
  Future<void> setProjectDir(String? dir) async {
    if (running) return;
    project = dir == null ? null : await FlutterProject.detect(dir);
    statuses = const [];
    hint = null;
    missingCommand = null;
    awaitingConfirm = false;
    recordSkipped = null;
    if (device == null || !_supports(device!)) _pickDefaultDevice();
    await refreshVerify();
    notifyListeners();
  }

  Future<void> refreshDevices() async {
    loadingDevices = true;
    notifyListeners();
    devices = await deviceService.list();
    if (device == null) _pickDefaultDevice();
    loadingDevices = false;
    notifyListeners();
  }

  void select(MobileDevice d) {
    selectedId = d.id;
    notifyListeners();
  }

  Future<void> setMode(BuildMode m) async {
    mode = m;
    notifyListeners();
    try {
      (await SharedPreferences.getInstance()).setString(_modeKey, m.name);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  /// 작업 폴더의 git 상태와 HEAD 커밋의 기록을 다시 읽는다.
  Future<void> refreshVerify() async {
    final p = project;
    snapshot = p == null ? null : await store.snapshot(p.path);
    final s = snapshot;
    record = s == null ? null : await store.read(s.commonDir, s.sha);
    notifyListeners();
  }

  /// 계획의 단계를 차례로 실행한다. 하나라도 실패하면 거기서 멈춘다. 끝까지 성공하면 검증 기록을 남긴다.
  Future<void> start() async {
    final p = plan;
    if (running || !p.runnable) return;
    running = true;
    hint = null;
    missingCommand = null;
    awaitingConfirm = false;
    recordSkipped = null;
    statuses = List.filled(p.steps.length, StepStatus.pending);
    final handle = _handle = RunHandle();
    notifyListeners();
    var ok = true;
    for (var i = 0; i < p.steps.length; i++) {
      final step = p.steps[i];
      statuses[i] = StepStatus.running;
      notifyListeners();
      final r = await runner.run(
        step.args,
        workingDirectory: step.workingDirectory,
        environment: step.environment,
        handle: handle,
        keepStdinOpen: step.interactive,
      );
      if (handle.cancelled) {
        statuses[i] = StepStatus.cancelled;
        ok = false;
        break;
      }
      if (r.ok) {
        statuses[i] = StepStatus.done;
        continue;
      }
      statuses[i] = StepStatus.failed;
      if (r.exitCode == 127) missingCommand = step.args.first;
      hint = explainFailure(r.combined);
      ok = false;
      break;
    }
    running = false;
    _handle = null;
    if (ok) await _recordBuilt();
    notifyListeners();
  }

  void cancel() => _handle?.cancel();

  /// 실행 중인 `flutter run`에 키를 보낸다 (`r` 핫 리로드, `R` 핫 리스타트, `q` 종료).
  void sendKey(String key) => _handle?.send(key);

  Future<void> _recordBuilt() async {
    final p = project;
    final d = device;
    if (p == null || d == null) return;
    final s = snapshot = await store.snapshot(p.path);
    if (s == null) {
      recordSkipped = RecordSkip.notGit;
      return;
    }
    if (s.dirty) {
      recordSkipped = RecordSkip.dirty;
      record = await store.read(s.commonDir, s.sha);
      return;
    }
    final rec = VerifyRecord(
      sha: s.sha,
      branch: s.branch,
      mode: mode.name,
      target: d.platform.name,
      status: VerifyStatus.built,
      at: DateTime.now(),
    );
    await store.write(s.commonDir, rec);
    record = rec;
    awaitingConfirm = true;
  }

  /// 실행해 보고 괜찮았다.
  Future<void> confirm() => _finish(VerifyStatus.confirmed, '');

  /// 실행해 보니 문제가 있었다. [note]는 Claude에게 전달할 설명.
  Future<void> reportProblem(String note) => _finish(VerifyStatus.problem, note);

  Future<void> _finish(VerifyStatus status, String note) async {
    final s = snapshot;
    final r = record;
    if (s == null || r == null) return;
    final next = r.copyWith(status: status, note: note, at: DateTime.now());
    await store.write(s.commonDir, next);
    record = next;
    awaitingConfirm = false;
    notifyListeners();
  }
}
