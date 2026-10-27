import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/command_runner.dart';
import '../run/run_controller.dart';
import '../studio/studio_controller.dart';
import '../verify/verify_store.dart';

/// 디버그 빌드 전용: README 데모를 스스로 재생한다 (tool/readme/demo.sh가 켠다).
///
/// 마우스나 키보드 입력 없이 편집 → 저장 → 커밋 → 검증 기록 흐름을 이 앱의 컨트롤러로 그대로 거친다.
/// 컴파일은 몇 분이 걸려 10초짜리 GIF에 담을 수 없으므로, 빌드가 성공했다는 검증 기록(`built`)은
/// 실제 빌드 없이 같은 저장소(`VerifyStore`)에 직접 쓴다. 나머지(편집기, 변경 표시, Git 패널, 검증 카드)는 실제 동작이다.
///
/// 환경 변수: `WORKBENCH_DEMO=1`, `WORKBENCH_DEMO_PROJECT`(열 샘플 프로젝트), `WORKBENCH_DEMO_FILE`(편집할 파일),
/// `WORKBENCH_DEMO_SIGNAL`(신호 파일을 둘 폴더).
Future<void> runDemoIfRequested({
  required StudioController studio,
  required RunController run,
  required CommandRunner runner,
}) async {
  if (!kDebugMode) return;
  final env = Platform.environment;
  if (env['WORKBENCH_DEMO'] != '1') return;

  final project = env['WORKBENCH_DEMO_PROJECT']!;
  final file = env['WORKBENCH_DEMO_FILE']!;
  final signal = Directory(env['WORKBENCH_DEMO_SIGNAL']!);
  Future<void> pause(double seconds) => Future<void>.delayed(Duration(milliseconds: (seconds * 1000).round()));

  await pause(1);
  await studio.openProject(project, remember: false);
  await studio.openFile(file);
  await pause(2.5); // 화면이 자리를 잡을 때까지 (Git 패널·문제 분석)
  File('${signal.path}/ready').writeAsStringSync('');

  // 1. 편집: 맨 위에 주석 한 줄을 타자 치듯 넣는다.
  await pause(1.2);
  final tab = studio.tabFor(file)!;
  const line = '// Show the note count in the app bar.\n';
  final original = tab.controller.text;
  for (var i = 1; i <= line.length; i++) {
    tab.controller.text = line.substring(0, i) + original;
    await pause(0.03);
  }
  await pause(0.6);

  // 2. 저장: 변경 표시와 Git 패널의 "1 changed".
  await studio.save(tab);
  await pause(1.6);

  // 3. 커밋: Git 패널이 깨끗해지고 HEAD가 바뀐다.
  await runner.run(['git', 'commit', '-qam', 'feat: show the note count'], workingDirectory: project, quiet: true);
  await studio.checkExternalChanges();
  await studio.refreshBases();
  await pause(1.4);

  // 4. 검증: 빌드 성공 기록 → "확인함".
  await _recordBuilt(run, runner, project);
  await pause(1.0);
  await run.confirm();
  await pause(1.5);

  File('${signal.path}/done').writeAsStringSync('');
}

Future<void> _recordBuilt(RunController run, CommandRunner runner, String project) async {
  final store = VerifyStore(runner);
  final s = await store.snapshot(project);
  if (s == null) return;
  await store.write(
    s.commonDir,
    VerifyRecord(sha: s.sha, branch: s.branch, mode: 'debug', target: 'macos', status: VerifyStatus.built, at: DateTime.now()),
  );
  run.awaitingConfirm = true;
  await run.refreshVerify();
}
