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
  static const _teamKey = 'ios_team_id';
  static const _optionsKeyPrefix = 'build_options:';
  static const _choiceKeyPrefix = 'project_choice:';

  final CommandRunner runner;
  final DeviceService deviceService;
  final VerifyStore store;
  final bool hostIsMac;
  final bool hostIsWindows;

  FlutterProject? project;

  /// 열린 폴더에서 찾은 Flutter 프로젝트 전부. 둘 이상이면 사용자가 [chooseProject]로 고른다.
  List<FlutterProject> candidates = const [];
  String? _openDir;
  List<MobileDevice> devices = const [];
  bool loadingDevices = false;
  String? selectedId;
  BuildMode mode = BuildMode.debug;
  BuildOptions options = const BuildOptions();

  /// 사용자가 입력한 iOS 서명 Team ID (10자리 영문 대문자·숫자). 없으면 프로젝트의 것을 쓴다.
  String? teamId;

  /// `flutter clean` + `flutter pub get`을 실행 중인지, 마지막 결과(null이면 아직 안 함).
  bool cleaning = false;
  bool? cleanResult;

  SharedPreferences? _prefs;

  /// `정리 후 패키지 다시 받기`가 끝나면(성공하든 실패하든) 부른다 — 패키지 정보가 바뀌었으니 문제 분석을 다시 하는 데 쓴다.
  VoidCallback? onCleaned;

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

  /// 입력한 Team ID → 프로젝트의 Team ID 순서.
  String? get effectiveTeamId => teamId ?? project?.iosTeamId;

  InstallPlan get plan => buildInstallPlan(
    project: project,
    device: device,
    mode: mode,
    teamId: effectiveTeamId,
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
      final prefs = _prefs = await SharedPreferences.getInstance();
      mode = BuildMode.values.asNameMap()[prefs.getString(_modeKey)] ?? mode;
      teamId = prefs.getString(_teamKey);
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
    await refreshDevices();
  }

  /// 스튜디오가 연 폴더가 바뀔 때 부른다. Flutter 프로젝트가 아니면 project는 null.
  /// 연 폴더가 아니라 그 바로 아래 폴더(예: Rust 프로젝트의 `gui/`)가 Flutter 프로젝트여도 찾는다.
  /// 후보가 여럿이면 [candidates]에 두고, 전에 고른 것이 있으면 그것을, 없으면 사용자가 고를 때까지 project는 null.
  Future<void> setProjectDir(String? dir) async {
    if (running) return;
    _openDir = dir;
    candidates = dir == null ? const [] : await FlutterProject.findAll(dir);
    project = candidates.length == 1 ? candidates.single : _savedChoice(dir, candidates);
    await _applyProject();
  }

  /// 후보가 여럿일 때 사용할 프로젝트를 고른다. 열린 폴더별로 기억한다.
  Future<void> chooseProject(FlutterProject p) async {
    if (running || p.path == project?.path) return;
    project = p;
    try {
      await _prefs?.setString('$_choiceKeyPrefix$_openDir', p.path);
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
    await _applyProject();
  }

  FlutterProject? _savedChoice(String? dir, List<FlutterProject> from) {
    final saved = dir == null ? null : _prefs?.getString('$_choiceKeyPrefix$dir');
    return from.where((p) => p.path == saved).firstOrNull;
  }

  Future<void> _applyProject() async {
    _loadOptions();
    cleanResult = null;
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

  void _loadOptions() {
    final p = project;
    options = p == null ? const BuildOptions() : BuildOptions.decode(_prefs?.getString('$_optionsKeyPrefix${p.path}'));
  }

  /// 빌드 옵션을 바꾸고 이 프로젝트용으로 저장한다 (비우면 저장된 것도 지운다).
  void setOptions(BuildOptions value) {
    final p = project;
    if (running || value == options) return;
    options = value;
    if (p != null) {
      final key = '$_optionsKeyPrefix${p.path}';
      if (value.isEmpty) {
        _prefs?.remove(key);
      } else {
        _prefs?.setString(key, value.encode());
      }
    }
    notifyListeners();
  }

  void setTeamId(String value) {
    final v = value.trim().toUpperCase();
    teamId = v.isEmpty ? null : v;
    if (teamId == null) {
      _prefs?.remove(_teamKey);
    } else if (RegExp(r'^[A-Z0-9]{10}$').hasMatch(teamId!)) {
      _prefs?.setString(_teamKey, teamId!);
    }
    notifyListeners();
  }

  /// 빌드 없이 실행할 수 있는지: 결과물(release 산출물 또는 전에 `flutter run`으로 만든 debug 실행 파일)이 이미 있다.
  bool get artifactReady {
    final a = plan.artifact;
    return a != null && FileSystemEntity.typeSync(a) != FileSystemEntityType.notFound;
  }

  /// 디버그 데스크톱 실행 파일을 새로 빌드하지 않고 그대로 다시 연다 (hot reload 없이, 그냥 실행만).
  Future<void> relaunchArtifact() async {
    final a = plan.artifact;
    if (a == null || running || !artifactReady) return;
    if (hostIsWindows) {
      await runner.run(['explorer.exe', a]);
    } else if (hostIsMac) {
      await runner.run(['open', a]);
    }
  }

  /// 빌드가 알 수 없는 이유로 깨질 때의 처방: `flutter clean` 다음 `flutter pub get`.
  /// 둘 다 성공하면 true. 명령은 출력에도 남는다.
  Future<bool> cleanProject() async {
    final p = project;
    if (p == null || running || cleaning) return false;
    cleaning = true;
    cleanResult = null;
    missingCommand = null;
    hint = null;
    statuses = const [];
    notifyListeners();
    var ok = true;
    for (final args in const [
      ['flutter', 'clean'],
      ['flutter', 'pub', 'get'],
    ]) {
      final r = await runner.run(args, workingDirectory: p.path);
      if (!r.ok) {
        ok = false;
        if (r.exitCode == 127) missingCommand = args.first;
        break;
      }
    }
    cleaning = false;
    cleanResult = ok;
    notifyListeners();
    onCleaned?.call();
    return ok;
  }

  /// 작업 폴더의 git 상태와 HEAD 커밋의 기록을 다시 읽는다.
  Future<void> refreshVerify() async {
    final p = project;
    snapshot = p == null ? null : await store.snapshot(p.path);
    final s = snapshot;
    record = s == null ? null : await store.read(s.commonDir, s.sha);
    notifyListeners();
  }

  /// 계획의 단계를 차례로 실행한다. 하나라도 실패하면 거기서 멈춘다. 빌드까지 끝까지 성공하면 검증 기록을 남긴다.
  ///
  /// [phase]가 build나 run이면 그 단계들만 실행한다 (release에서 빌드와 실행을 따로 할 때).
  /// 다른 단계의 이전 결과(체크 표시)는 그대로 둔다. 실행(run)만 한 경우에는 새로 빌드한 것이 아니라서 기록하지 않는다.
  Future<void> start({RunPhase phase = RunPhase.all}) async {
    final p = plan;
    if (running || !p.runnable || cleaning) return;
    final indices = p.indicesOf(phase);
    if (indices.isEmpty) return;
    running = true;
    hint = null;
    missingCommand = null;
    awaitingConfirm = false;
    recordSkipped = null;
    if (phase == RunPhase.all || statuses.length != p.steps.length) {
      statuses = List.filled(p.steps.length, StepStatus.pending);
    } else {
      statuses = [...statuses];
      for (final i in indices) {
        statuses[i] = StepStatus.pending;
      }
    }
    final handle = _handle = RunHandle();
    notifyListeners();
    var ok = true;
    for (final i in indices) {
      final step = p.steps[i];
      statuses[i] = StepStatus.running;
      notifyListeners();
      final r = await runner.run(
        step.args,
        workingDirectory: step.workingDirectory,
        environment: step.environment,
        handle: handle,
        keepStdinOpen: step.interactive,
        onOutput: step.interactive
            ? (chunk) {
                // 앱이 종료되면 flutter run은 이 줄을 찍고 끝나야 하는데, 안 끝나는 경우가 있다.
                if (chunk.contains('Application finished')) {
                  Future.delayed(const Duration(seconds: 3), handle.finish);
                }
              }
            : null,
      );
      if (handle.cancelled) {
        statuses[i] = StepStatus.cancelled;
        ok = false;
        break;
      }
      // 계속 실행되는 단계(flutter run)는 사용자가 `q`로 끝내도 정상이다.
      if (r.ok || step.interactive && r.exitCode == 0) {
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
    if (ok && phase != RunPhase.run) await _recordBuilt();
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
