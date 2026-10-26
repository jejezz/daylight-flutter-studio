import 'package:daylight_flutter_studio/devices/mobile_device.dart';
import 'package:daylight_flutter_studio/flutter/flutter_project.dart';
import 'package:daylight_flutter_studio/install/install_plan.dart';
import 'package:flutter_test/flutter_test.dart';

const _project = FlutterProject(
  path: '/p',
  name: 'demo',
  hasIos: false,
  hasAndroid: true,
  androidApplicationId: 'art.demo',
  hasWindows: true,
  windowsBinaryName: 'demo',
);

const _windows = MobileDevice(id: 'windows', name: 'Windows', platform: DevicePlatform.windows, link: DeviceLink.local);
const _phone = MobileDevice(id: 'R5', name: 'Galaxy', platform: DevicePlatform.android, link: DeviceLink.usb);

void main() {
  test('Windows debug는 flutter run 한 단계', () {
    final plan = buildInstallPlan(project: _project, device: _windows, mode: BuildMode.debug, teamId: null, hostIsMac: false);
    expect(plan.runnable, isTrue);
    expect(plan.steps.single.args, ['flutter', 'run', '-d', 'windows', '--debug']);
    expect(plan.steps.single.interactive, isTrue);
  });

  test('Windows debug의 artifact는 Debug 폴더를 가리킨다 (빌드 없이 다시 실행용)', () {
    final plan = buildInstallPlan(project: _project, device: _windows, mode: BuildMode.debug, teamId: null, hostIsMac: false);
    expect(plan.artifact, endsWith('runner\\Debug\\demo.exe'));
  });

  test('Windows release의 artifact는 Release 폴더를 가리킨다', () {
    final plan = buildInstallPlan(project: _project, device: _windows, mode: BuildMode.release, teamId: null, hostIsMac: false);
    expect(plan.artifact, endsWith('runner\\Release\\demo.exe'));
  });

  test('Android release는 빌드 → 설치 → 실행 순서', () {
    final plan = buildInstallPlan(project: _project, device: _phone, mode: BuildMode.release, teamId: null, hostIsMac: false);
    expect([for (final s in plan.steps) s.kind], [StepKind.build, StepKind.install, StepKind.launch]);
    expect(plan.steps[1].args, containsAllInOrder(['adb', '-s', 'R5', 'install', '-r']));
  });

  test('지원하지 않는 플랫폼이면 막는다', () {
    final plan = buildInstallPlan(
      project: _project,
      device: const MobileDevice(id: 'u', name: 'iPhone', platform: DevicePlatform.ios, link: DeviceLink.usb),
      mode: BuildMode.release,
      teamId: null,
      hostIsMac: false,
    );
    expect(plan.runnable, isFalse);
    expect(plan.blockers, containsAll([Blocker.platformMissing, Blocker.iosNeedsMac]));
  });

  test('기기가 없으면 막는다', () {
    final plan = buildInstallPlan(project: _project, device: null, mode: BuildMode.debug, teamId: null, hostIsMac: false);
    expect(plan.blockers, [Blocker.noDevice]);
  });
}
