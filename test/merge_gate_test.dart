import 'dart:io';

import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/github/pull_request.dart';
import 'package:daylight_flutter_studio/settings/gate_settings.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/branchdock/core/command_log.dart' as bd;
import 'package:daylight_flutter_studio/branchdock/core/command_runner.dart' as bd;
import 'package:daylight_flutter_studio/branchdock/github/models.dart' as bd;
import 'package:daylight_flutter_studio/branchdock/repo/environment.dart';
import 'package:daylight_flutter_studio/branchdock/repo/repo_controller.dart' as bd;
import 'package:daylight_flutter_studio/branchdock/ui/merge_gate.dart';
import 'package:daylight_flutter_studio/branchdock/ui/repo_scope.dart';
import 'package:daylight_flutter_studio/branchdock/ui/tabs/pr_tab.dart';
import 'package:daylight_flutter_studio/ui/git_merge_gate.dart';
import 'package:daylight_flutter_studio/ui/settings_dialog.dart';
import 'package:daylight_flutter_studio/verify/verify_state.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'branchdock/support.dart';

const _sha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

/// 실제 프로세스를 띄우지 않고 명령을 기록하며 정해 둔 답을 돌려준다.
class FakeRunner extends CommandRunner {
  FakeRunner() : super(CommandLog());

  final calls = <List<String>>[];

  List<String>? get merge => calls.where((c) => c.length > 2 && c[0] == 'gh' && c[1] == 'pr' && c[2] == 'merge').firstOrNull;

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
    final key = args.take(3).join(' ');
    return switch (key) {
      'git status --porcelain=v2' => const CommandResult(0, '# branch.oid $_sha\x00# branch.head feat\x00# branch.upstream origin/feat\x00# branch.ab +0 -0\x00', ''),
      'git rev-parse --show-toplevel' => const CommandResult(0, '/repo\n', ''),
      'gh pr view' => const CommandResult(1, '', 'no pull requests found'),
      'git rev-list --count' => const CommandResult(0, '2\n', ''),
      'git symbolic-ref --short' => const CommandResult(1, '', ''),
      _ => const CommandResult(0, '', ''),
    };
  }
}

/// PR 카드가 쓰는 Branch Dock 실행기: git은 실제로 돌리고, gh는 병합 명령만 기록하며 성공으로 답한다.
class _BdRunner extends bd.CommandRunner {
  _BdRunner() : super(log: bd.CommandLog(), path: Platform.environment['PATH'] ?? '');

  final ghCalls = <List<String>>[];

  List<String>? get merge => ghCalls.where((c) => c.length > 2 && c[1] == 'pr' && c[2] == 'merge').firstOrNull;

  @override
  Future<bd.CommandResult> run(
    List<String> args, {
    required String workingDirectory,
    bool quiet = false,
    bd.CancelToken? cancel,
    String? stdin,
  }) {
    if (args.first == 'gh') {
      ghCalls.add(args);
      return Future.value(const bd.CommandResult(0, '', ''));
    }
    // 병합 뒤의 pull은 실제 원격이 없으니 성공으로 답한다.
    if (args.length > 1 && args[1] == 'pull') return Future.value(const bd.CommandResult(0, '', ''));
    return super.run(args, workingDirectory: workingDirectory, quiet: quiet, cancel: cancel, stdin: stdin);
  }
}

class FakeStore extends VerifyStore {
  FakeStore(super.runner);

  List<VerifyRecord> records = [];

  @override
  Future<RepoSnapshot?> snapshot(String dir) async => const RepoSnapshot(sha: _sha, branch: 'feat', dirty: false, commonDir: 'common');

  @override
  Future<List<VerifyRecord>> readAll(String commonDir) async => records;
}

VerifyRecord _rec(VerifyStatus status, {String sha = _sha, String note = ''}) =>
    VerifyRecord(sha: sha, branch: 'feat', mode: 'debug', target: 'windows', status: status, at: DateTime(2026, 10, 25), note: note);

const _pr = PullRequest(number: 7, title: 'Add thing', url: 'u', state: PrState.open, headRef: 'feat', baseRef: 'main');

VerifyVerdict _verdict(VerifyState state, {VerifyRecord? record, int? since}) => VerifyVerdict(state, record: record, commitsSince: since);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('decideGate', () {
    test('검증됨이면 모드와 상관없이 허용', () {
      for (final mode in GateMode.values) {
        expect(decideGate(mode, _verdict(VerifyState.verified)).allowed, isTrue, reason: mode.name);
      }
    });

    test('차단: 검증되지 않은 모든 상태를 막는다', () {
      for (final v in [
        _verdict(VerifyState.unverified),
        _verdict(VerifyState.builtOnly, record: _rec(VerifyStatus.built)),
        _verdict(VerifyState.problem, record: _rec(VerifyStatus.problem)),
        _verdict(VerifyState.stale, since: 2),
      ]) {
        expect(decideGate(GateMode.block, v).action, GateAction.block, reason: v.state.name);
      }
      expect(decideGate(GateMode.block, null).action, GateAction.block, reason: '판정이 없으면(저장소를 못 읽음) 안전하게 막는다');
    });

    test('경고만: 같은 상태에서 확인을 요구한다', () {
      expect(decideGate(GateMode.warn, _verdict(VerifyState.unverified)).action, GateAction.confirm);
      expect(decideGate(GateMode.warn, _verdict(VerifyState.builtOnly)).action, GateAction.confirm);
    });

    test('끔: 항상 허용', () {
      expect(decideGate(GateMode.off, _verdict(VerifyState.unverified)).allowed, isTrue);
      expect(decideGate(GateMode.off, null).allowed, isTrue);
    });
  });

  group('describeVerdict', () {
    test('상태마다 무엇을 해야 하는지 알려 준다', () {
      expect(describeVerdict(_verdict(VerifyState.unverified)), contains('Run 탭'));
      expect(describeVerdict(_verdict(VerifyState.builtOnly)), contains('확인함'));
      expect(describeVerdict(_verdict(VerifyState.stale, since: 3)), contains('3개'));
      expect(describeVerdict(_verdict(VerifyState.stale)), contains('커밋이 추가'));
      expect(describeVerdict(_verdict(VerifyState.problem, record: _rec(VerifyStatus.problem, note: '버튼이 안 눌려요'))), contains('버튼이 안 눌려요'));
      expect(describeVerdict(_verdict(VerifyState.verified)), contains('병합할 수 있습니다'));
    });
  });

  group('GateSettings', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('기본은 차단이다', () {
      expect(GateSettings().mode, GateMode.block);
    });

    test('저장하고 다시 읽는다', () async {
      final a = GateSettings();
      await a.setMode(GateMode.warn);
      final b = GateSettings();
      await b.restore();
      expect(b.mode, GateMode.warn);
    });

    test('알 수 없는 저장 값은 기본(차단)을 유지한다', () async {
      SharedPreferences.setMockInitialValues({'merge_gate_mode': 'nonsense'});
      final g = GateSettings();
      await g.restore();
      expect(g.mode, GateMode.block);
    });

    test('바뀔 때만 알린다', () async {
      final g = GateSettings();
      var calls = 0;
      g.addListener(() => calls++);
      await g.setMode(GateMode.block);
      expect(calls, 0);
      await g.setMode(GateMode.off);
      expect(calls, 1);
    });
  });

  group('GitController.merge', () {
    late FakeRunner runner;
    late FakeStore store;

    Future<GitController> controller(GateMode? mode) async {
      final c = GitController(runner: runner, store: store, gate: mode == null ? null : GateSettings(mode));
      addTearDown(c.dispose);
      await c.setDir('/repo');
      c
        ..pr = _pr
        ..prHeadSha = _sha;
      await c.refreshVerdict();
      return c;
    }

    setUp(() {
      runner = FakeRunner();
      store = FakeStore(runner);
    });

    test('차단: 확인하지 않은 커밋은 gh를 부르지도 않고 막는다', () async {
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(runner.merge, isNull);
      expect(c.messageOk, isFalse);
      expect(c.message, contains('병합하지 않았습니다'));
      expect(c.message, contains('Run 탭'));
    });

    test('차단: 명시적 예외(overrideGate)로만 병합하고 그렇게 알린다', () async {
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.squash, overrideGate: true), isTrue);
      expect(runner.merge, ['gh', 'pr', 'merge', '7', '--squash', '--delete-branch']);
      expect(c.message, contains('검증 없이 병합'));
    });

    test('확인함 기록이 있으면 예외 없이 병합한다', () async {
      store.records = [_rec(VerifyStatus.confirmed)];
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.merge), isTrue);
      expect(runner.merge, ['gh', 'pr', 'merge', '7', '--merge', '--delete-branch']);
      expect(c.message, isNot(contains('검증 없이')));
    });

    test('빌드만 된 것은 막는다', () async {
      store.records = [_rec(VerifyStatus.built)];
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(c.message, contains('확인함'));
    });

    test('문제가 있다고 기록한 커밋은 메모와 함께 막는다', () async {
      store.records = [_rec(VerifyStatus.problem, note: '로그인 버튼 먹통')];
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(c.message, contains('로그인 버튼 먹통'));
    });

    test('검증한 뒤 커밋이 추가되면 막는다', () async {
      store.records = [_rec(VerifyStatus.confirmed, sha: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')];
      final c = await controller(GateMode.block);
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(c.message, contains('커밋'));
    });

    test('화면의 판정이 낡았어도 병합 직전에 기록을 다시 읽는다', () async {
      final c = await controller(GateMode.block);
      expect(c.gateDecision.action, GateAction.block, reason: '아직 기록이 없다');

      // 그 사이 사용자가 Run 탭에서 "확인함"을 눌렀지만 Git 패널은 아직 모른다.
      store.records = [_rec(VerifyStatus.confirmed)];
      expect(c.gateDecision.action, GateAction.block, reason: '새로 읽기 전의 판정은 그대로');

      expect(await c.merge(PrMergeMethod.merge), isTrue);
    });

    test('경고만: 확인(overrideGate) 없이는 병합하지 않고, 확인하면 병합한다', () async {
      final c = await controller(GateMode.warn);
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(runner.merge, isNull);
      expect(await c.merge(PrMergeMethod.merge, overrideGate: true), isTrue);
    });

    test('끔: 확인 여부와 상관없이 병합한다', () async {
      final c = await controller(GateMode.off);
      expect(await c.merge(PrMergeMethod.rebase), isTrue);
      expect(runner.merge, ['gh', 'pr', 'merge', '7', '--rebase', '--delete-branch']);
    });

    test('관문 설정이 없으면(gate: null) 병합한다', () async {
      final c = await controller(null);
      expect(await c.merge(PrMergeMethod.merge), isTrue);
    });

    test('PR이 없으면 아무것도 하지 않는다', () async {
      final c = await controller(GateMode.off);
      c.pr = null;
      expect(await c.merge(PrMergeMethod.merge), isFalse);
      expect(runner.merge, isNull);
    });

    test('refreshVerdict는 gh나 git 상태를 다시 부르지 않는다', () async {
      final c = await controller(GateMode.block);
      runner.calls.clear();
      await c.refreshVerdict();
      expect(runner.calls.where((c) => c.first == 'gh'), isEmpty);
      expect(runner.calls.where((c) => c.length > 1 && c[1] == 'status'), isEmpty);
    });
  });

  group('PR 카드의 병합 관문', () {
    late FakeRunner runner;
    late FakeStore store;
    late GateSettings gate;
    late GitController c;
    late GitMergeGate mergeGate;
    late _BdRunner bdRunner;
    late Directory tmp;
    late bd.RepoController repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      runner = FakeRunner();
      store = FakeStore(runner);
      gate = GateSettings();
      // PR 카드가 쓰는 저장소는 실제 임시 저장소다 (gh 병합 명령만 가로챈다).
      tmp = Directory.systemTemp.createTempSync('gate_card');
      Future<void> git(List<String> args) async {
        final r = await Process.run('git', args, workingDirectory: tmp.path);
        if (r.exitCode != 0) fail('git ${args.join(' ')}: ${r.stderr}');
      }

      await git(['init', '-q', '-b', 'main']);
      for (final cfg in [['user.email', 't@e.com'], ['user.name', 'T'], ['commit.gpgsign', 'false']]) {
        await git(['config', ...cfg]);
      }
      File('${tmp.path}/a.txt').writeAsStringSync('a\n');
      await git(['add', '-A']);
      await git(['commit', '-q', '-m', 'init']);
      bdRunner = _BdRunner();
      repo = (await bd.RepoController.open(bdRunner, tmp.path)).$1!;
    });

    tearDown(() async {
      repo.dispose();
      await safeDelete(tmp);
    });

    Future<void> show(WidgetTester tester, {GateMode mode = GateMode.block, List<VerifyRecord> records = const []}) async {
      store.records = records;
      await gate.setMode(mode);
      c = GitController(runner: runner, store: store, gate: gate);
      addTearDown(c.dispose);
      await c.setDir('/repo');
      c
        ..pr = _pr
        ..prHeadSha = _sha;
      await c.refreshVerdict();
      mergeGate = GitMergeGate(c);
      addTearDown(mergeGate.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
          home: Scaffold(
            body: RepoScope(
              repo: repo,
              environment: const EnvironmentStatus(),
              child: MergeGateScope(
                gate: mergeGate,
                child: SingleChildScrollView(
                  child: PrCard(
                    pr: const bd.PullRequest(number: 7, title: 'Add thing', url: 'u', state: bd.PrState.open, headRef: 'feat', baseRef: 'main'),
                    repo: repo,
                    activity: const [],
                    onChanged: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    FilledButton mergeButton(WidgetTester tester) =>
        tester.widget<FilledButton>(find.ancestor(of: find.text('병합하기'), matching: find.byType(FilledButton)));

    /// 병합 명령은 실제 입출력(저장소 읽기)을 거치므로 실제 시간을 흘려 기다린다.
    /// 전체 테스트가 함께 돌 때는 느려질 수 있어, 고정 시간이 아니라 [until]이 될 때까지(최대 10초) 기다린다.
    Future<void> settle(WidgetTester tester, {bool Function()? until}) async {
      for (var i = 0; i < 100; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 100));
        if (until != null ? until() : i >= 9) break;
      }
    }

    /// 병합 명령(gh 병합 → 기본 브랜치 전환 → pull)이 모두 끝났는가 — 끝나기 전에 화면을 내리면 타이머가 남는다.
    bool merged() => bdRunner.merge != null && !repo.busy;

    Future<void> leave(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    }

    testWidgets('차단: 단추가 비활성이고 이유와 예외 단추가 보인다', (tester) async {
      await show(tester);

      expect(mergeButton(tester).onPressed, isNull);
      expect(find.textContaining('로컬에서 확인하지 않았습니다'), findsWidgets);
      expect(find.text('검증 없이 병합…'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('차단: 예외 단추 → 확인창에서 취소하면 병합하지 않는다', (tester) async {
      await show(tester);

      await tester.tap(find.text('검증 없이 병합…'));
      await settle(tester);
      expect(find.text('확인하지 않은 커밋입니다'), findsOneWidget);
      expect(find.textContaining('모든 OS 빌드'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await settle(tester);
      expect(bdRunner.merge, isNull);
      await leave(tester);
    });

    testWidgets('차단: 예외 단추 → "그래도 병합"을 눌러야 병합한다', (tester) async {
      await show(tester);

      await tester.tap(find.text('검증 없이 병합…'));
      await settle(tester);
      await tester.tap(find.text('그래도 병합'));
      await settle(tester, until: merged);

      expect(bdRunner.merge, ['gh', 'pr', 'merge', '7', '--merge', '--delete-branch']);
      await leave(tester);
    });

    testWidgets('검증됨: 평소처럼 바로 병합하고 예외 단추는 없다', (tester) async {
      await show(tester, records: [_rec(VerifyStatus.confirmed)]);

      expect(find.text('검증됨 — 병합할 수 있습니다'), findsWidgets);
      expect(find.text('검증 없이 병합…'), findsNothing);
      expect(mergeButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('병합하기'));
      await settle(tester, until: merged);
      expect(bdRunner.merge, isNotNull);
      expect(find.text('확인하지 않은 커밋입니다'), findsNothing, reason: '확인된 커밋은 묻지 않는다');
      await leave(tester);
    });

    testWidgets('경고만: 단추는 눌리고 확인창을 거친다', (tester) async {
      await show(tester, mode: GateMode.warn);

      expect(mergeButton(tester).onPressed, isNotNull);
      expect(find.text('검증 없이 병합…'), findsNothing);

      await tester.tap(find.text('병합하기'));
      await settle(tester);
      expect(find.text('확인하지 않은 커밋입니다'), findsOneWidget);
      expect(bdRunner.merge, isNull, reason: '확인 전에는 병합하지 않는다');

      await tester.tap(find.text('그래도 병합'));
      await settle(tester, until: merged);
      expect(bdRunner.merge, isNotNull);
      await leave(tester);
    });

    testWidgets('끔: 관문 문구 없이 평소 단추', (tester) async {
      await show(tester, mode: GateMode.off);

      expect(find.textContaining('확인하지 않았습니다'), findsNothing);
      expect(find.text('검증 없이 병합…'), findsNothing);
      await tester.tap(find.text('병합하기'));
      await settle(tester, until: merged);
      expect(bdRunner.merge, isNotNull);
      await leave(tester);
    });

    testWidgets('설정에서 모드를 바꾸면 카드가 바로 따라 바뀐다', (tester) async {
      await show(tester);
      expect(mergeButton(tester).onPressed, isNull);

      await gate.setMode(GateMode.off);
      await settle(tester);
      expect(mergeButton(tester).onPressed, isNotNull);
      expect(find.text('검증 없이 병합…'), findsNothing);
      await leave(tester);
    });

    testWidgets('확인함을 누른 기록이 들어오면 막혔던 단추가 풀린다', (tester) async {
      await show(tester);
      expect(mergeButton(tester).onPressed, isNull);

      store.records = [_rec(VerifyStatus.confirmed)];
      await tester.runAsync(c.refreshVerdict);
      await tester.pump();
      expect(mergeButton(tester).onPressed, isNotNull);
      await leave(tester);
    });
  });

  group('설정 대화상자의 병합 관문 구역', () {
    late ThemeController theme;
    late GateSettings gate;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      theme = ThemeController();
      gate = GateSettings();
    });

    tearDown(() {
      theme.dispose();
      gate.dispose();
    });

    Widget app({GateSettings? g}) => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ko'), 
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(onPressed: () => showSettingsDialog(context, theme: theme, gate: g), child: const Text('열기')),
          ),
        ),
      ),
    );

    testWidgets('모드를 고르면 바로 적용되고 설명이 바뀐다', (tester) async {
      await tester.pumpWidget(app(g: gate));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('병합 관문'));
      await tester.pump();

      expect(find.text('PR 병합 전 검증'), findsOneWidget);
      expect(find.textContaining('확인한 커밋만 병합합니다'), findsWidgets);

      await tester.tap(find.text('경고만'));
      await tester.pump();
      expect(gate.mode, GateMode.warn);
      expect(find.textContaining('한 번 더 묻습니다'), findsOneWidget);

      await tester.tap(find.text('끔'));
      await tester.pump();
      expect(gate.mode, GateMode.off);
    });

    testWidgets('관문 설정이 없으면 구역 자체가 나오지 않는다', (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(find.text('병합 관문'), findsNothing);
    });
  });
}
