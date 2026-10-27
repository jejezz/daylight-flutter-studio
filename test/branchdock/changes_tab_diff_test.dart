// 변경 파일을 누르면 Studio의 변경점 보기로 열리고, 열 수 없을 때만 Branch Dock의 diff 시트가 뜬다.

import 'dart:io';

import 'package:daylight_flutter_studio/branchdock/core/command_log.dart';
import 'package:daylight_flutter_studio/branchdock/core/command_runner.dart';
import 'package:daylight_flutter_studio/branchdock/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/branchdock/repo/environment.dart';
import 'package:daylight_flutter_studio/branchdock/repo/repo_controller.dart';
import 'package:daylight_flutter_studio/branchdock/repo/repo_prefs.dart';
import 'package:daylight_flutter_studio/branchdock/theme/app_theme.dart';
import 'package:daylight_flutter_studio/branchdock/ui/repo_scope.dart';
import 'package:daylight_flutter_studio/branchdock/ui/services.dart';
import 'package:daylight_flutter_studio/branchdock/ui/tabs/changes_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

Future<void> git(String cwd, List<String> args) async {
  final r = await Process.run('git', args, workingDirectory: cwd);
  if (r.exitCode != 0) fail('git ${args.join(' ')}: ${r.stderr}');
}

/// 행에 두 번 누르기 동작도 있어서, 한 번 누른 것은 이 시간이 지나야 확정된다.
const _doubleTapWait = Duration(milliseconds: 400);

/// diff 시트에만 있는 단추.
const _sheetAction = '편집기로 열기';

void main() {
  late Directory tmp;
  late String dir;
  late AppServices services;
  late RepoController repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('bd_changes_diff');
    dir = '${tmp.path}/repo';
    Directory(dir).createSync();
    await git(dir, ['init', '-q', '-b', 'main']);
    for (final c in [['user.email', 't@e.com'], ['user.name', 'T'], ['commit.gpgsign', 'false']]) {
      await git(dir, ['config', ...c]);
    }
    File('$dir/m.txt').writeAsStringSync('one\n');
    File('$dir/d.txt').writeAsStringSync('gone\n');
    await git(dir, ['add', '-A']);
    await git(dir, ['commit', '-q', '-m', 'init']);
    File('$dir/m.txt').writeAsStringSync('one\ntwo\n'); // 고친 파일
    File('$dir/d.txt').deleteSync(); // 지운 파일
    services = AppServices(
      runner: CommandRunner(log: CommandLog(), path: Platform.environment['PATH'] ?? ''),
      prefs: await RepoPrefs.load(),
    );
    final (r, _) = await RepoController.open(services.runner, dir);
    repo = r!;
  });

  tearDown(() {
    repo.dispose();
    safeDeleteSync(tmp);
  });

  Future<void> pumpTab(WidgetTester tester, {Future<bool> Function(String path)? onShowDiff}) async {
    tester.view.physicalSize = const Size(440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const env = EnvironmentStatus(gitVersion: '2', ghVersion: '2', ghLogins: {}, checked: true);
    await tester.pumpWidget(ServicesScope(
      services: services,
      child: MaterialApp(
        theme: AppTheme.build(StudioPalette.saturn, Brightness.dark),
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RepoScope(repo: repo, environment: env, child: ChangesTab(commitFocus: FocusNode(), onShowDiff: onShowDiff)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// 행을 누르고 diff 시트가 뜰 때까지 기다린다 (시트의 글은 실제 git 실행이 끝나야 나온다).
  Future<void> tapAndWaitForSheet(WidgetTester tester, String name) async {
    await tester.tap(find.text(name, findRichText: true));
    await tester.pump(_doubleTapWait);
    for (var i = 0; i < 100 && find.text(_sheetAction).evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('고친 파일을 누르면 Studio가 그 파일의 절대 경로로 변경점 보기를 연다', (tester) async {
    final opened = <String>[];
    await pumpTab(tester, onShowDiff: (path) async {
      opened.add(path);
      return true;
    });

    await tester.tap(find.text('m.txt', findRichText: true));
    await tester.pump(_doubleTapWait);
    await tester.pumpAndSettle();

    expect(opened, ['$dir${Platform.pathSeparator}m.txt'.replaceAll('/', Platform.pathSeparator)]);
    expect(find.text(_sheetAction), findsNothing, reason: 'Studio가 열었으면 diff 시트는 뜨지 않는다');
  });

  testWidgets('Studio가 열지 못하면(false) Branch Dock의 diff 시트로 보여 준다', (tester) async {
    var calls = 0;
    await pumpTab(tester, onShowDiff: (path) async {
      calls++;
      return false;
    });

    await tapAndWaitForSheet(tester, 'm.txt');

    expect(calls, 1);
    expect(find.text(_sheetAction), findsOneWidget);
  });

  testWidgets('지워진 파일은 열 파일이 없으니 Studio를 부르지 않고 시트로 보여 준다', (tester) async {
    var calls = 0;
    await pumpTab(tester, onShowDiff: (path) async {
      calls++;
      return true;
    });

    await tapAndWaitForSheet(tester, 'd.txt');

    expect(calls, 0);
    expect(find.text(_sheetAction), findsOneWidget);
  });

  testWidgets('연결점이 없으면 예전처럼 diff 시트가 뜬다', (tester) async {
    await pumpTab(tester);
    await tapAndWaitForSheet(tester, 'm.txt');
    expect(find.text(_sheetAction), findsOneWidget);
  });
}
