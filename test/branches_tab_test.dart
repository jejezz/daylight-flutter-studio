import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/branches_controller.dart';
import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/settings/app_settings.dart';
import 'package:daylight_flutter_studio/studio/worktree.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/branches_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명령을 기록하고, 앞부분이 맞는 명령에는 정해 둔 답을 돌려준다.
class FakeRunner extends CommandRunner {
  FakeRunner() : super(CommandLog());

  final calls = <List<String>>[];
  final answers = <String, CommandResult>{};
  String refs = '';

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
    if (args.length > 1 && args[1] == 'for-each-ref') return CommandResult(0, refs, '');
    for (final e in answers.entries) {
      if (args.join(' ').startsWith(e.key)) return e.value;
    }
    return const CommandResult(0, '', '');
  }
}

String _ref(
  String name, {
  bool remote = false,
  String upstream = '',
  String track = '',
  bool current = false,
  String subject = 'a commit',
  int seconds = 1760000000,
}) {
  final full = remote ? 'refs/remotes/$name' : 'refs/heads/$name';
  return '$full\x00$name\x00$upstream\x00$track\x00$seconds\x00$subject\x00${current ? '*' : ' '}\n';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettings settings;
  late FakeRunner runner;
  late BranchesController c;
  late List<Worktree> worktrees;
  late int changed;
  Worktree? opened;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    runner = FakeRunner()
      ..refs =
          _ref('main', current: true, upstream: 'origin/main', track: '[ahead 2]', subject: 'latest work') +
          _ref('feature/login', upstream: 'origin/feature/login', track: '[behind 1]') +
          _ref('old-topic', upstream: 'origin/old-topic', track: '[gone]') +
          _ref('scratch') +
          _ref('origin/main', remote: true) +
          _ref('origin/feature/shared', remote: true);
    worktrees = [const Worktree(path: '/repo', branch: 'main', main: true)];
    changed = 0;
    opened = null;
    c = BranchesController(runner: runner, listWorktrees: (_) async => worktrees)..onChanged = () => changed++;
    await c.setDir('/repo');
  });

  tearDown(() => c.dispose());

  Widget app() => AppSettingsScope(
    settings: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      home: Scaffold(
        body: SizedBox(width: 420, height: 800, child: BranchesTab(controller: c, onOpenWorktree: (w) => opened = w)),
      ),
    ),
  );

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
  }

  Future<void> expandRemote(WidgetTester tester) async {
    await tester.tap(find.textContaining('원격 브랜치'));
    await tester.pumpAndSettle();
  }

  Future<void> openRowMenu(WidgetTester tester, String branch) async {
    final row = find.byKey(ValueKey('branch:$branch'));
    await tester.tap(find.descendant(of: row, matching: find.byType(PopupMenuButton<String>)));
    await tester.pumpAndSettle();
  }

  group('목록', () {
    testWidgets('로컬은 펼쳐 있고 원격은 접혀 있으며, 개수가 보인다', (tester) async {
      await show(tester);
      expect(find.text('로컬 브랜치 (4)'), findsOneWidget);
      expect(find.text('원격 브랜치 (2)'), findsOneWidget);
      expect(find.text('main'), findsOneWidget);
      expect(find.text('feature/login'), findsOneWidget);
      expect(find.text('origin/feature/shared'), findsNothing, reason: '원격 브랜치는 접혀 있다');

      await expandRemote(tester);
      expect(find.text('origin/feature/shared'), findsOneWidget);
    });

    testWidgets('현재 브랜치 표시, 앞서거나 뒤처진 커밋, 사라진 추적 브랜치, 추적 없음', (tester) async {
      await show(tester);
      expect(find.text('현재'), findsOneWidget);
      expect(find.text('↑2'), findsOneWidget);
      expect(find.text('↓1'), findsOneWidget);
      expect(find.text('원격에서 사라짐'), findsOneWidget);
      expect(find.text('추적 브랜치 없음'), findsOneWidget, reason: 'scratch만 추적 브랜치가 없다');
      expect(find.textContaining('latest work'), findsOneWidget);
    });

    testWidgets('현재 브랜치에는 전환 단추가 없고 나머지에는 있다', (tester) async {
      await show(tester);
      expect(find.text('전환'), findsNWidgets(3));
    });

    testWidgets('검색은 로컬·원격 모두 걸러 내고, 없으면 알려 준다', (tester) async {
      await show(tester);
      await tester.enterText(find.byType(TextField), 'shared');
      await tester.pumpAndSettle();
      expect(find.text('로컬 브랜치 (0)'), findsOneWidget);
      expect(find.text('원격 브랜치 (1)'), findsOneWidget);
      expect(find.text('origin/feature/shared'), findsOneWidget, reason: '검색 중에는 원격이 펼쳐진다');
      expect(find.text('main'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz-none');
      await tester.pumpAndSettle();
      expect(find.text('검색과 맞는 브랜치가 없습니다'), findsWidgets);
    });

    testWidgets('git 저장소가 아니면 안내한다', (tester) async {
      final empty = BranchesController(runner: runner, listWorktrees: (_) async => const []);
      addTearDown(empty.dispose);
      await tester.pumpWidget(
        AppSettingsScope(
          settings: settings,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ko'),
            theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
            home: Scaffold(body: BranchesTab(controller: empty)),
          ),
        ),
      );
      expect(find.text('열린 폴더가 git 저장소가 아닙니다'), findsOneWidget);
    });
  });

  group('전환', () {
    testWidgets('행 안의 단추 탭이 삼켜지지 않는다 (메뉴가 바로 열린다)', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'scratch');
      expect(find.byType(PopupMenuItem<String>), findsWidgets);
    });

    testWidgets('전환 단추는 git switch를 실행하고 결과와 변경 알림이 온다', (tester) async {
      await show(tester);
      await tester.tap(find.widgetWithText(TextButton, '전환').first);
      await tester.pump();
      await tester.pump();

      expect(runner.call('git switch feature/login'), isNotNull);
      expect(find.textContaining('전환했습니다'), findsOneWidget);
      expect(changed, 1);
    });

    testWidgets('원격 브랜치는 로컬 추적 브랜치를 만들어 전환한다', (tester) async {
      await show(tester);
      await expandRemote(tester);
      await tester.tap(find.widgetWithText(TextButton, '로컬로 가져와 전환').last);
      await tester.pump();
      await tester.pump();
      expect(runner.call('git switch --track origin/feature/shared'), isNotNull);
    });

    testWidgets('커밋하지 않은 변경 때문에 실패하면 이유를 알려 주고 변경을 알리지 않는다', (tester) async {
      runner.answers['git switch'] = const CommandResult(1, '', 'error: Your local changes to the following files would be overwritten by checkout:\n\ta.txt');
      await show(tester);
      await tester.tap(find.widgetWithText(TextButton, '전환').first);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('커밋하지 않은 변경'), findsOneWidget);
      expect(changed, 0);
    });
  });

  group('새 브랜치', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.byTooltip('새 브랜치'));
      await tester.pumpAndSettle();
    }

    testWidgets('이름이 비어 있거나 규칙에 어긋나면 만들기가 막힌다', (tester) async {
      await show(tester);
      await openDialog(tester);
      FilledButton create() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, '만들기'));
      expect(create().onPressed, isNull, reason: '이름이 비어 있다');

      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'bad name');
      await tester.pump();
      expect(find.textContaining('공백'), findsOneWidget);
      expect(create().onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'scratch');
      await tester.pump();
      expect(find.text('이미 있는 이름입니다'), findsOneWidget);
      expect(create().onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'good-name');
      await tester.pump();
      expect(create().onPressed, isNotNull);
    });

    testWidgets('접두어 단추와 실행될 명령 미리보기', (tester) async {
      await show(tester);
      await openDialog(tester);
      await tester.tap(find.widgetWithText(ActionChip, 'feature/'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'feature/x');
      await tester.pump();
      // + 단추는 현재 브랜치(main)를 기준으로 연다.
      expect(find.text('git switch -c feature/x main'), findsOneWidget);

      await tester.tap(find.text('만든 뒤 바로 전환'));
      await tester.pump();
      expect(find.text('git branch feature/x main'), findsOneWidget, reason: '전환하지 않으면 명령도 바뀐다');
    });

    testWidgets('만들기를 누르면 그 명령을 실행한다 (현재 브랜치에서 시작)', (tester) async {
      await show(tester);
      await openDialog(tester);
      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'feature/new-thing');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '만들기'));
      await tester.pumpAndSettle();

      expect(runner.call('git switch -c feature/new-thing main'), isNotNull, reason: '+ 단추는 현재 브랜치를 기준으로 연다');
      expect(find.textContaining('만들었습니다'), findsOneWidget);
      expect(changed, 1);
    });

    testWidgets('행 메뉴의 "여기서 새 브랜치"는 그 브랜치를 기준으로 연다', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'feature/login');
      await tester.tap(find.text('여기서 새 브랜치'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'child');
      await tester.pump();
      expect(find.text('git switch -c child feature/login'), findsOneWidget);
    });
  });

  group('이름 바꾸기·삭제', () {
    testWidgets('이름을 바꾼다 (같은 이름이면 단추가 막힌다)', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'scratch');
      await tester.tap(find.text('이름 바꾸기').last);
      await tester.pumpAndSettle();

      FilledButton action() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, '이름 바꾸기'));
      expect(action().onPressed, isNull, reason: '바꾸지 않았다');

      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'main');
      await tester.pump();
      expect(find.text('이미 있는 이름입니다'), findsOneWidget);
      expect(action().onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, '브랜치 이름'), 'renamed');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '이름 바꾸기'));
      await tester.pumpAndSettle();
      expect(runner.call('git branch -m scratch renamed'), isNotNull);
    });

    testWidgets('삭제는 명령을 보여 주고 확인한 뒤에만 실행한다', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'scratch');
      await tester.tap(find.text('삭제').last);
      await tester.pumpAndSettle();
      expect(find.text('git branch -d scratch'), findsOneWidget);
      expect(runner.call('git branch -d'), isNull, reason: '확인 전에는 실행하지 않는다');

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(runner.call('git branch -d'), isNull);

      await openRowMenu(tester, 'scratch');
      await tester.tap(find.text('삭제').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await tester.pumpAndSettle();
      expect(runner.call('git branch -d scratch'), isNotNull);
      expect(find.textContaining('삭제했습니다'), findsOneWidget);
    });

    testWidgets('병합되지 않았으면 한 번 더 묻고, 그래도 삭제하면 -D로 지운다', (tester) async {
      runner.answers['git branch -d'] = const CommandResult(1, '', "error: The branch 'scratch' is not fully merged.\nIf you are sure you want to delete it, run 'git branch -D scratch'.");
      await show(tester);
      await openRowMenu(tester, 'scratch');
      await tester.tap(find.text('삭제').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await tester.pumpAndSettle();

      expect(find.text('병합되지 않은 브랜치'), findsOneWidget);
      expect(find.text('git branch -D scratch'), findsOneWidget);
      expect(runner.call('git branch -D'), isNull, reason: '두 번째 확인 전에는 강제 삭제하지 않는다');

      await tester.tap(find.text('그래도 삭제 (-D)'));
      await tester.pumpAndSettle();
      expect(runner.call('git branch -D scratch'), isNotNull);
    });

    testWidgets('병합되지 않은 브랜치에서 두 번째 확인을 취소하면 지우지 않는다', (tester) async {
      runner.answers['git branch -d'] = const CommandResult(1, '', "error: The branch 'scratch' is not fully merged.");
      await show(tester);
      await openRowMenu(tester, 'scratch');
      await tester.tap(find.text('삭제').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(runner.call('git branch -D'), isNull);
    });

    testWidgets('현재 브랜치의 메뉴에는 삭제가 없다', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'main');
      expect(find.text('삭제'), findsNothing);
      expect(find.text('이름 바꾸기'), findsOneWidget);
    });

    testWidgets('원격 브랜치 삭제는 영향 범위를 알리고 확인 후 실행한다', (tester) async {
      await show(tester);
      await expandRemote(tester);
      await openRowMenu(tester, 'origin/feature/shared');
      await tester.tap(find.text('원격 브랜치 삭제').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('다른 사람에게도 영향'), findsOneWidget);
      expect(find.text('git push origin --delete feature/shared'), findsOneWidget);
      expect(runner.call('git push'), isNull);

      await tester.tap(find.widgetWithText(FilledButton, '원격 브랜치 삭제'));
      await tester.pumpAndSettle();
      expect(runner.call('git push origin --delete feature/shared'), isNotNull);
    });
  });

  group('다른 worktree가 쥔 브랜치', () {
    setUp(() async {
      worktrees = [
        const Worktree(path: '/repo', branch: 'main', main: true),
        const Worktree(path: '/repo/.claude/worktrees/fix-a', branch: 'feature/login'),
      ];
      await c.refresh();
    });

    testWidgets('표시하고 전환 단추를 막는다', (tester) async {
      await show(tester);
      expect(find.text('worktree'), findsOneWidget);

      final switchButtons = tester.widgetList<TextButton>(find.widgetWithText(TextButton, '전환')).toList();
      expect(switchButtons.where((b) => b.onPressed == null).length, 1, reason: 'feature/login만 막힌다');
      expect(find.byTooltip('다른 worktree에서 사용 중: /repo/.claude/worktrees/fix-a'), findsOneWidget);
    });

    testWidgets('행 메뉴에서 그 worktree를 열 수 있다', (tester) async {
      await show(tester);
      await openRowMenu(tester, 'feature/login');
      await tester.tap(find.text('그 worktree 열기'));
      await tester.pumpAndSettle();
      expect(opened?.path, '/repo/.claude/worktrees/fix-a');
    });

    testWidgets('git이 거부하면 이유와 "그 worktree 열기" 단추가 나온다', (tester) async {
      worktrees = [const Worktree(path: '/repo', branch: 'main', main: true), const Worktree(path: '/wt/other', branch: 'scratch')];
      await c.refresh();
      runner.answers['git switch scratch'] = const CommandResult(1, '', "fatal: 'scratch' is already used by worktree at '/wt/other'");
      await show(tester);

      // scratch 행의 전환은 이미 막혀 있으니, 컨트롤러를 직접 불러 git의 거부를 흉내 낸다.
      await tester.runAsync(() => c.switchTo(c.local.firstWhere((b) => b.name == 'scratch')));
      await tester.pump();

      expect(find.textContaining('다른 worktree에서 쓰고 있어'), findsOneWidget);
      expect(c.blockingWorktreePath, '/wt/other');
      await tester.tap(find.widgetWithText(TextButton, '그 worktree 열기'));
      expect(opened?.path, '/wt/other');
    });
  });
}
