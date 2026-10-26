import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/devices/device_service.dart';
import 'package:daylight_flutter_studio/devices/mobile_device.dart';
import 'package:daylight_flutter_studio/install/build_options.dart';
import 'package:daylight_flutter_studio/install/install_plan.dart';
import 'package:daylight_flutter_studio/run/run_controller.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Runner extends CommandRunner {
  _Runner() : super(CommandLog());

  final calls = <List<String>>[];

  @override
  Future<CommandResult> run(
    List<String> args, {
    String? workingDirectory,
    Map<String, String> environment = const {},
    bool quiet = false,
    String? stdin,
    RunHandle? handle,
    bool keepStdinOpen = false,
    void Function(String chunk)? onOutput,
  }) async {
    calls.add(args);
    return const CommandResult(0, '', '');
  }
}

class _NoDevices implements DeviceService {
  @override
  Future<List<MobileDevice>> list() async => const [];
}

class _Store extends VerifyStore {
  _Store(super.runner);

  int writes = 0;

  @override
  Future<RepoSnapshot?> snapshot(String dir) async => const RepoSnapshot(sha: 'abc', branch: 'main', dirty: false, commonDir: '/nowhere');

  @override
  Future<void> write(String commonDir, VerifyRecord record) async => writes++;

  @override
  Future<VerifyRecord?> read(String commonDir, String sha) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late _Runner runner;
  late _Store store;
  late RunController c;

  Future<RunController> controller() async {
    final c = RunController(runner: runner, deviceService: _NoDevices(), store: store, hostIsMac: true, hostIsWindows: false);
    await c.init();
    await c.setProjectDir(dir.path);
    return c;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('run_controller');
    File('${dir.path}/pubspec.yaml').writeAsStringSync('name: sample\nversion: 1.0.0+1\ndependencies:\n  flutter:\n    sdk: flutter\n');
    Directory('${dir.path}/macos/Runner.xcodeproj').createSync(recursive: true);
    File('${dir.path}/macos/Runner.xcodeproj/project.pbxproj').writeAsStringSync('');
    Directory('${dir.path}/macos/Runner/Configs').createSync(recursive: true);
    File('${dir.path}/macos/Runner/Configs/AppInfo.xcconfig').writeAsStringSync('PRODUCT_NAME = Sample\n');
    runner = _Runner();
    store = _Store(runner);
    c = await controller();
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  test('빌드 옵션은 프로젝트별로 저장되고 명령에 들어간다', () async {
    expect(c.options.isEmpty, isTrue);
    c.setOptions(const BuildOptions(flavor: 'dev', extraArgs: '--verbose'));
    expect(c.plan.steps.map((s) => s.commandLine).join('\n'), contains('--flavor dev'));

    final again = await controller();
    expect(again.options.flavor, 'dev');
    again.setOptions(const BuildOptions());
    final cleared = await controller();
    expect(cleared.options.isEmpty, isTrue);
    again.dispose();
    cleared.dispose();
  });

  test('정리 후 패키지 받기는 flutter clean → flutter pub get 순서로 실행한다', () async {
    expect(await c.cleanProject(), isTrue);
    expect(runner.calls, [
      ['flutter', 'clean'],
      ['flutter', 'pub', 'get'],
    ]);
    expect(c.cleanResult, isTrue);
    expect(c.cleaning, isFalse);
  });

  test('정리가 끝나면 문제 분석을 다시 하도록 알린다', () async {
    var notified = 0;
    c.onCleaned = () => notified++;
    await c.cleanProject();
    expect(notified, 1);
  });

  test('release는 빌드만 · 실행만으로 나눠 돌릴 수 있고, 실행만은 새 검증 기록을 남기지 않는다', () async {
    await c.setMode(BuildMode.release);
    expect(c.plan.splittable, isTrue);

    await c.start(phase: RunPhase.build);
    expect(store.writes, 1, reason: '빌드가 끝나면 검증 기록을 남긴다');
    expect(c.statuses.where((s) => s == StepStatus.done), isNotEmpty);

    await c.start(phase: RunPhase.run);
    expect(store.writes, 1, reason: '실행만 한 것은 새로 빌드한 것이 아니다');
  });

  test('iOS Team ID는 입력값을 우선하고 10자리 영문 대문자·숫자만 저장한다', () async {
    c.setTeamId('abcde12345');
    expect(c.effectiveTeamId, 'ABCDE12345');
    c.setTeamId('');
    expect(c.effectiveTeamId, isNull);
  });

  test('Windows debug: 전에 flutter run으로 만든 실행 파일이 있으면 새로 빌드하지 않고 그걸 연다', () async {
    final winDir = await Directory.systemTemp.createTemp('run_controller_win');
    File('${winDir.path}/pubspec.yaml').writeAsStringSync('name: sample\nversion: 1.0.0+1\ndependencies:\n  flutter:\n    sdk: flutter\n');
    Directory('${winDir.path}/windows').createSync(recursive: true);
    File('${winDir.path}/windows/CMakeLists.txt').writeAsStringSync('set(BINARY_NAME "sample")\n');
    final winRunner = _Runner();
    final winController = RunController(
      runner: winRunner,
      deviceService: _NoDevices(),
      store: _Store(winRunner),
      hostIsMac: false,
      hostIsWindows: true,
    );
    await winController.init();
    await winController.setProjectDir(winDir.path);
    await winController.setMode(BuildMode.debug);
    expect(winController.artifactReady, isFalse, reason: '아직 한 번도 안 만들어졌다');

    final exe = winController.plan.artifact!;
    expect(exe, contains('runner\\Debug\\sample.exe'));
    File(exe).createSync(recursive: true);
    await winController.refreshDevices(); // artifact 경로는 바뀌지 않지만 다시 읽어도 됨을 확인
    expect(winController.artifactReady, isTrue);

    await winController.relaunchArtifact();
    expect(winRunner.calls, [
      ['explorer.exe', exe],
    ]);

    winController.dispose();
    await winDir.delete(recursive: true);
  });
}
