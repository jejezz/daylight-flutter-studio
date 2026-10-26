// Git 패널(Branch Dock 셸): 실제 저장소를 열어 탭 줄·상태 헤더·HEAD 변경 알림을 확인한다.

import 'dart:io';

import 'package:daylight_flutter_studio/branchdock/core/command_log.dart';
import 'package:daylight_flutter_studio/branchdock/core/command_runner.dart';
import 'package:daylight_flutter_studio/branchdock/repo/repo_prefs.dart';
import 'package:daylight_flutter_studio/branchdock/ui/services.dart';
import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/branchdock_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'branchdock/support.dart';

Future<String> git(String cwd, List<String> args) async {
  final r = await Process.run('git', args, workingDirectory: cwd);
  if (r.exitCode != 0) fail('git ${args.join(' ')}: ${r.stderr}');
  return (r.stdout as String).trim();
}

void main() {
  late Directory tmp;
  late String dir;
  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('dock_shell');
    dir = '${tmp.path}/repo';
    Directory(dir).createSync();
    await git(dir, ['init', '-q', '-b', 'main']);
    for (final c in [['user.email', 't@e.com'], ['user.name', 'T'], ['commit.gpgsign', 'false']]) {
      await git(dir, ['config', ...c]);
    }
    File('$dir/a.txt').writeAsStringSync('a\n');
    await git(dir, ['add', '-A']);
    await git(dir, ['commit', '-q', '-m', 'init']);
    services = AppServices(
      runner: CommandRunner(log: CommandLog(), path: Platform.environment['PATH'] ?? ''),
      prefs: await RepoPrefs.load(),
    );
  });

  tearDown(() => safeDeleteSync(tmp));

  Widget app({required String? root, VoidCallback? onHeadChanged}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    home: Scaffold(
      body: BranchDockDock(root: root, services: services, onHeadChanged: onHeadChanged),
    ),
  );

  /// 실제 git 실행(실제 시간)과 화면 갱신(가짜 시간)을 번갈아, 조건이 될 때까지 기다린다.
  Future<void> waitFor(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 60 && !done(); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Branch Dock 탭 줄: 변경·브랜치·태그·원격·릴리스·PR·기록 (CI 없음), 상태 헤더에 브랜치', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(root: dir));
    await waitFor(tester, () => find.text('기록').evaluate().isNotEmpty);

    for (final label in ['변경', '브랜치', '태그', '원격', '릴리스', 'PR', '기록']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('CI'), findsNothing);
    expect(find.text('main'), findsWidgets, reason: '상태 헤더의 브랜치 이름');
    await leave(tester);
  });

  testWidgets('저장소가 아닌 폴더는 안내와 git init 단추를 보인다', (tester) async {
    final plain = Directory('${tmp.path}/plain')..createSync();
    await tester.pumpWidget(app(root: plain.path));
    await waitFor(tester, () => find.text('이 폴더를 git 저장소로 만들기').evaluate().isNotEmpty);
    expect(find.text('이 폴더를 git 저장소로 만들기'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('다른 도구에서 브랜치를 바꾸고 창으로 돌아오면 HEAD 변경을 알린다', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var changed = 0;

    await tester.pumpWidget(app(root: dir, onHeadChanged: () => changed++));
    await waitFor(tester, () => find.text('기록').evaluate().isNotEmpty);
    expect(changed, 0, reason: '처음 읽을 때는 알리지 않는다');

    await tester.runAsync(() => git(dir, ['switch', '-q', '-c', 'feature']));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await waitFor(tester, () => changed > 0);
    expect(changed, greaterThan(0));
    expect(find.text('feature'), findsWidgets);
    await leave(tester);
  });
}
