import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/branches_controller.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/git/operation.dart';
import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/settings/app_settings.dart';
import 'package:daylight_flutter_studio/studio/worktree.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/branches_tab.dart';
import 'package:daylight_flutter_studio/ui/git_panel.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

/// 명령을 기록하고, 정해 둔 조각이 들어 있는 명령에는 정해 둔 답을 돌려준다.
class FakeRunner extends CommandRunner {
  FakeRunner() : super(CommandLog());

  final calls = <List<String>>[];
  final answers = <String, CommandResult>{};
  String refs = '';
  String status = '# branch.oid $_sha\x00# branch.head main\x00';
  String? gitDir;

  List<String>? call(String prefix) => calls.where((c) => c.join(' ').startsWith(prefix)).firstOrNull;

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
    final joined = args.join(' ');
    for (final e in answers.entries) {
      if (joined.contains(e.key)) return e.value;
    }
    if (args.length > 1 && args[1] == 'for-each-ref') return CommandResult(0, refs, '');
    if (joined.startsWith('git status')) return CommandResult(0, status, '');
    if (joined.startsWith('git rev-parse --absolute-git-dir')) return CommandResult(0, '${gitDir ?? Directory.systemTemp.path}\n', '');
    if (joined.startsWith('git rev-parse --show-toplevel')) return const CommandResult(0, '/repo\n', '');
    if (joined.startsWith('gh pr view')) return const CommandResult(1, '', 'no pull requests found');
    return const CommandResult(0, '', '');
  }
}

String _ref(String name, {bool remote = false, String upstream = '', String track = '', bool current = false}) {
  final full = remote ? 'refs/remotes/$name' : 'refs/heads/$name';
  return '$full\x00$name\x00$upstream\x00$track\x001760000000\x00subject\x00${current ? '*' : ' '}\n';
}

/// `git log --format=%H%x00%h%x00%s%x00%b%x00%ct%x1e` 한 줄.
String _commit(String hash, String subject) => '$hash\x00${hash.substring(0, 7)}\x00$subject\x00\x001760000000\x1e';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettings settings;
  late FakeRunner runner;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    runner = FakeRunner()
      ..refs = _ref('main', current: true, upstream: 'origin/main') + _ref('feature/login', upstream: 'origin/feature/login') + _ref('origin/feature/shared', remote: true);
  });

  Widget wrap(Widget body) => AppSettingsScope(
    settings: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      home: Scaffold(body: SizedBox(width: 460, height: 800, child: body)),
    ),
  );

  group('병합 시트', () {
    late BranchesController c;

    /// 들어올 커밋(HEAD..branch), fast-forward 가능 여부, 다시 쌓일 커밋(branch..HEAD)을 정한다.
    void previewFor(String branch, {List<String> incoming = const [], bool ff = true, List<String> replayed = const []}) {
      runner.answers['HEAD..$branch'] = CommandResult(0, [for (var i = 0; i < incoming.length; i++) _commit('${i}1111111111', incoming[i])].join(), '');
      runner.answers['merge-base --is-ancestor HEAD $branch'] = CommandResult(ff ? 0 : 1, '', '');
      runner.answers['$branch..HEAD'] = CommandResult(0, [for (var i = 0; i < replayed.length; i++) _commit('${i}2222222222', replayed[i])].join(), '');
    }

    Future<void> openSheet(WidgetTester tester, String branch) async {
      c = BranchesController(runner: runner, listWorktrees: (_) async => const [Worktree(path: '/repo', branch: 'main', main: true)]);
      addTearDown(c.dispose);
      await c.setDir('/repo');
      await tester.pumpWidget(wrap(BranchesTab(controller: c)));
      await tester.pump();
      await tester.tap(find.descendant(of: find.byKey(ValueKey('branch:$branch')), matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('현재 브랜치로 병합…'));
      await tester.pumpAndSettle();
    }

    testWidgets('들어올 커밋을 미리 보여 주고, 가능하면 fast-forward가 기본이다', (tester) async {
      previewFor('feature/login', incoming: ['Add login form', 'Fix typo']);
      await openSheet(tester, 'feature/login');

      expect(find.text("'feature/login'을(를) 'main'에 병합"), findsOneWidget);
      expect(find.text('들어올 커밋 2개'), findsOneWidget);
      expect(find.text('Add login form'), findsOneWidget);
      expect(find.text('Fix typo'), findsOneWidget);
      expect(find.text('git merge --ff-only feature/login'), findsOneWidget, reason: 'fast-forward가 되면 그것이 기본');
    });

    testWidgets('확인을 누르면 미리 본 명령 그대로 실행한다', (tester) async {
      previewFor('feature/login', incoming: ['one']);
      await openSheet(tester, 'feature/login');
      await tester.tap(find.widgetWithText(FilledButton, '병합'));
      await tester.pumpAndSettle();

      expect(runner.call('git merge --ff-only feature/login'), isNotNull);
      expect(find.textContaining('병합했습니다'), findsOneWidget);
    });

    testWidgets('갈라졌으면 fast-forward를 막고 병합 커밋을 기본으로 한다', (tester) async {
      previewFor('feature/login', incoming: ['one'], ff: false);
      await openSheet(tester, 'feature/login');

      expect(find.textContaining('두 브랜치가 갈라져 있어'), findsOneWidget);
      expect(find.text("git merge --no-ff -m Merge branch 'feature/login' --no-edit feature/login"), findsOneWidget);
    });

    testWidgets('squash: 메시지 칸과 두 단계 명령, 한 커밋일 때 그 제목이 기본 메시지', (tester) async {
      previewFor('feature/login', incoming: ['Add login form'], ff: false);
      await openSheet(tester, 'feature/login');
      await tester.tap(find.text('Squash'));
      await tester.pumpAndSettle();

      expect(find.text('git merge --squash feature/login'), findsOneWidget);
      expect(find.text('git commit -m Add login form'), findsOneWidget);
      expect(find.widgetWithText(TextField, '커밋 메시지'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '커밋 메시지'), 'feat: login');
      await tester.pump();
      expect(find.text('git commit -m feat: login'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, '병합'));
      await tester.pumpAndSettle();
      expect(runner.call('git merge --squash feature/login'), isNotNull);
      expect(runner.call('git commit -m feat: login'), isNotNull);
    });

    testWidgets('rebase: 다시 쌓일 내 커밋을 보여 주고, 원격에 올라간 브랜치면 경고한다', (tester) async {
      previewFor('feature/login', incoming: ['theirs'], ff: false, replayed: ['mine one', 'mine two']);
      await openSheet(tester, 'feature/login');
      await tester.tap(find.text('Rebase'));
      await tester.pumpAndSettle();

      expect(find.text('다시 쌓일 내 커밋 2개'), findsOneWidget);
      expect(find.text('mine one'), findsOneWidget);
      expect(find.text('git rebase feature/login'), findsOneWidget);
      expect(find.textContaining('강제 push'), findsOneWidget, reason: 'main은 origin/main을 추적한다');

      await tester.tap(find.widgetWithText(FilledButton, 'Rebase'));
      await tester.pumpAndSettle();
      expect(runner.call('git rebase feature/login'), isNotNull);
    });

    testWidgets('rebase로 쌓을 내 커밋이 없으면 실행하지 못한다', (tester) async {
      previewFor('feature/login', incoming: ['theirs'], ff: true, replayed: []);
      await openSheet(tester, 'feature/login');
      await tester.tap(find.text('Rebase'));
      await tester.pumpAndSettle();

      expect(find.textContaining('다시 쌓을 내 커밋이 없습니다'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Rebase')).onPressed, isNull);
    });

    testWidgets('합칠 커밋이 없으면 안내만 하고 실행 단추가 없다', (tester) async {
      previewFor('feature/login', incoming: []);
      await openSheet(tester, 'feature/login');
      expect(find.textContaining('이미 최신입니다'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, '병합')).onPressed, isNull);
    });

    testWidgets('원격 브랜치도 합칠 수 있고, 취소하면 아무것도 실행하지 않는다', (tester) async {
      previewFor('origin/feature/shared', incoming: ['remote work']);
      c = BranchesController(runner: runner, listWorktrees: (_) async => const []);
      addTearDown(c.dispose);
      await c.setDir('/repo');
      await tester.pumpWidget(wrap(BranchesTab(controller: c)));
      await tester.pump();
      await tester.tap(find.textContaining('원격 브랜치'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byKey(const ValueKey('branch:origin/feature/shared')), matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('현재 브랜치로 병합…'));
      await tester.pumpAndSettle();

      expect(find.text('git merge --ff-only origin/feature/shared'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(runner.calls.where((c) => c.length > 1 && c[1] == 'merge'), isEmpty, reason: '병합 명령은 실행하지 않았다 (미리 보기용 merge-base는 읽기만)');
    });

    testWidgets('충돌로 멈추면 이유와 다음 행동을 알려 준다', (tester) async {
      previewFor('feature/login', incoming: ['one'], ff: false);
      runner.answers['git merge --no-ff'] = const CommandResult(1, 'CONFLICT (content): Merge conflict in a.txt\nAutomatic merge failed; fix conflicts and then commit the result.\n', '');
      await openSheet(tester, 'feature/login');
      await tester.tap(find.widgetWithText(FilledButton, '병합'));
      await tester.pumpAndSettle();

      expect(find.textContaining('충돌이 났습니다'), findsOneWidget);
      expect(find.textContaining('변경 탭'), findsOneWidget);
    });

    testWidgets('병합·rebase가 진행 중이면 병합 메뉴가 없다', (tester) async {
      // 테스트 본문 안에서는 실제 비동기 입출력을 기다릴 수 없어 동기 버전을 쓴다.
      final gitDir = Directory.systemTemp.createTempSync('fake_gitdir');
      addTearDown(() => gitDir.deleteSync(recursive: true));
      File('${gitDir.path}${Platform.pathSeparator}MERGE_HEAD').writeAsStringSync(_sha);
      runner.gitDir = gitDir.path;
      c = BranchesController(runner: runner, listWorktrees: (_) async => const []);
      addTearDown(c.dispose);
      await tester.runAsync(() => c.setDir('/repo'));
      expect(c.operation, RepoOperation.merging);

      await tester.pumpWidget(wrap(BranchesTab(controller: c)));
      await tester.pump();
      await tester.tap(find.descendant(of: find.byKey(const ValueKey('branch:feature/login')), matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      expect(find.text('현재 브랜치로 병합…'), findsNothing);
    });
  });

  group('Git 패널의 병합·rebase 중 배너', () {
    late Directory gitDir;
    late GitController g;

    setUp(() async {
      gitDir = await Directory.systemTemp.createTemp('fake_gitdir');
      runner.gitDir = gitDir.path;
    });

    tearDown(() async {
      g.dispose();
      await gitDir.delete(recursive: true);
    });

    Future<void> show(WidgetTester tester, {required String marker, int conflicts = 0}) async {
      if (marker.isNotEmpty) {
        final f = marker.contains('/') ? Directory('${gitDir.path}${Platform.pathSeparator}$marker') : File('${gitDir.path}${Platform.pathSeparator}$marker');
        if (f is Directory) {
          f.createSync(recursive: true);
        } else {
          (f as File).writeAsStringSync(_sha);
        }
      }
      runner.status =
          '# branch.oid $_sha\x00# branch.head main\x00${List.generate(conflicts, (i) => 'u UU N... 100644 100644 100644 100644 aaa bbb ccc c$i.txt\x00').join()}';
      g = GitController(runner: runner, store: VerifyStore(runner));
      await g.setDir('/repo');
      await tester.pumpWidget(wrap(GitPanel(controller: g)));
      await tester.pump();
    }

    testWidgets('진행 중인 작업이 없으면 배너가 없다', (tester) async {
      await show(tester, marker: '');
      expect(find.text('계속'), findsNothing);
      expect(find.text('중단'), findsNothing);
    });

    testWidgets('병합 중 + 충돌이 남았으면 개수를 보이고 계속은 막힌다', (tester) async {
      await show(tester, marker: 'MERGE_HEAD', conflicts: 2);
      expect(find.text('병합 중 — 충돌 2개'), findsOneWidget);
      expect(find.textContaining('충돌을 모두 해결하고 스테이지'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, '계속')).onPressed, isNull);
      expect(find.text('건너뛰기'), findsNothing, reason: '병합에는 건너뛰기가 없다');
    });

    testWidgets('충돌을 모두 해결했으면 계속이 풀리고 병합을 마무리하는 명령을 실행한다', (tester) async {
      await show(tester, marker: 'MERGE_HEAD', conflicts: 0);
      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '계속'));
      expect(button.onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FilledButton, '계속'));
      await tester.pump();
      await tester.pump();
      expect(runner.call('git commit --no-edit'), isNotNull);
    });

    testWidgets('rebase 중에는 건너뛰기가 있고 rebase 명령을 쓴다', (tester) async {
      await show(tester, marker: 'rebase-merge/placeholder', conflicts: 1);
      expect(find.text('rebase 중 — 충돌 1개'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);

      await tester.tap(find.text('건너뛰기'));
      await tester.pump();
      await tester.pump();
      expect(runner.call('git -c core.editor=true rebase --skip'), isNotNull);
    });

    testWidgets('중단은 확인창에서 명령과 영향을 알리고, 확인한 뒤에만 실행한다', (tester) async {
      await show(tester, marker: 'MERGE_HEAD', conflicts: 1);
      await tester.tap(find.widgetWithText(OutlinedButton, '중단'));
      await tester.pumpAndSettle();

      expect(find.text('작업 중단'), findsOneWidget);
      expect(find.textContaining('충돌을 해결한 내용도 사라집니다'), findsOneWidget);
      expect(find.text('git merge --abort'), findsOneWidget);
      expect(runner.call('git merge --abort'), isNull, reason: '확인 전에는 실행하지 않는다');

      await tester.tap(find.widgetWithText(FilledButton, '중단'));
      await tester.pumpAndSettle();
      expect(runner.call('git merge --abort'), isNotNull);
    });

    testWidgets('중단 확인창에서 취소하면 아무것도 하지 않는다', (tester) async {
      await show(tester, marker: 'rebase-merge/placeholder', conflicts: 1);
      await tester.tap(find.widgetWithText(OutlinedButton, '중단'));
      await tester.pumpAndSettle();
      expect(find.textContaining('이미 다시 쌓은 커밋도 사라집니다'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(runner.call('git rebase --abort'), isNull);
    });
  });
}
