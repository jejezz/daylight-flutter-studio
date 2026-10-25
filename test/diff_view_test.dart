import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/studio/git_base.dart';
import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/change_gutter.dart';
import 'package:daylight_flutter_studio/ui/diff_view.dart';
import 'package:daylight_flutter_studio/ui/editor_pane.dart';
import 'package:daylight_flutter_studio/ui/git_panel.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _sep = Platform.pathSeparator;

Future<void> _git(String dir, List<String> args) async {
  final r = await Process.run('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...args], workingDirectory: dir);
  expect(r.exitCode, 0, reason: '${r.stderr}');
}

String _p(Directory d, String name) => '${d.path}$_sep${name.replaceAll('/', _sep)}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory repo;
  late CommandRunner runner;
  late GitBaseReader reader;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = await Directory.systemTemp.createTemp('diff_view');
    await _git(repo.path, ['init', '-b', 'main']);
    File(_p(repo, 'a.txt')).writeAsStringSync('one\ntwo\nthree\n');
    File(_p(repo, '.gitignore')).writeAsStringSync('ignored.txt\n');
    Directory(_p(repo, 'sub')).createSync();
    File(_p(repo, 'sub/b b.txt')).writeAsStringSync('inside\n');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'first']);
    runner = CommandRunner(CommandLog());
    reader = GitBaseReader(runner);
  });

  tearDown(() async {
    try {
      await repo.delete(recursive: true);
    } on FileSystemException {
      // Windows에서 git이 잡고 있던 파일이 잠깐 남을 수 있다.
    }
  });

  group('GitBaseReader', () {
    test('커밋된 파일은 HEAD 내용을 돌려준다 (작업 폴더에서 고쳐도 HEAD 그대로)', () async {
      File(_p(repo, 'a.txt')).writeAsStringSync('changed\n');
      final base = await reader.read(_p(repo, 'a.txt'));
      expect(base.available, isTrue);
      expect(base.isNew, isFalse);
      expect(base.text.replaceAll('\r\n', '\n'), 'one\ntwo\nthree\n');
    });

    test('하위 폴더와 공백이 든 이름도 읽는다', () async {
      final base = await reader.read(_p(repo, 'sub/b b.txt'));
      expect(base.available, isTrue);
      expect(base.text.trim(), 'inside');
    });

    test('커밋하지 않은 새 파일은 새 파일로 본다', () async {
      File(_p(repo, 'new.txt')).writeAsStringSync('x\n');
      final base = await reader.read(_p(repo, 'new.txt'));
      expect(base.available, isTrue);
      expect(base.isNew, isTrue);
      expect(base.text, isEmpty);
    });

    test('스테이징만 한 새 파일도 새 파일이다', () async {
      File(_p(repo, 'staged.txt')).writeAsStringSync('x\n');
      await _git(repo.path, ['add', 'staged.txt']);
      expect((await reader.read(_p(repo, 'staged.txt'))).isNew, isTrue);
    });

    test('.gitignore로 무시되는 파일은 비교하지 않는다', () async {
      File(_p(repo, 'ignored.txt')).writeAsStringSync('x\n');
      expect((await reader.read(_p(repo, 'ignored.txt'))).available, isFalse);
    });

    test('git 저장소가 아니면 비교하지 않는다', () async {
      final dir = await Directory.systemTemp.createTemp('not_repo');
      addTearDown(() => dir.delete(recursive: true));
      final f = File(_p(dir, 'x.txt'))..writeAsStringSync('x');
      expect((await reader.read(f.path)).available, isFalse);
    });
  });

  group('변경 표시 (컨트롤러)', () {
    late StudioController c;

    setUp(() => c = StudioController(readBase: reader.read));
    tearDown(() => c.dispose());

    Future<EditorTab> open(String name) async {
      await c.openFile(_p(repo, name));
      final tab = c.activeTab!;
      await c.refreshBase(tab);
      return tab;
    }

    /// 편집 뒤 변경 표시가 계산될 때까지(250ms 쉼) 기다린다.
    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 450));

    test('열면 비교 기준을 읽고, 같으면 표시가 없다', () async {
      final tab = await open('a.txt');
      expect(tab.hasBase, isTrue);
      expect(tab.marks.value.isEmpty, isTrue);
    });

    test('줄을 고치고 추가하고 지우면 표시가 따라온다', () async {
      final tab = await open('a.txt');

      tab.controller.text = 'one\nTWO\nthree\nfour\n';
      await settle();
      expect(tab.marks.value.modified, {1});
      expect(tab.marks.value.added, {3});

      tab.controller.text = 'one\nthree\n';
      await settle();
      expect(tab.marks.value.deletedBefore, {1});
      expect(tab.marks.value.added, isEmpty);

      // 원래대로 돌리면 표시가 사라진다.
      tab.controller.text = 'one\ntwo\nthree\n';
      await settle();
      expect(tab.marks.value.isEmpty, isTrue);
    });

    test('커서만 움직이면 다시 계산하지 않는다', () async {
      final tab = await open('a.txt');
      tab.controller.text = 'one\nTWO\nthree\n';
      await settle();
      final before = tab.marks.value;
      tab.controller.selection = CodeLineSelection.collapsed(index: 2, offset: 1);
      await settle();
      expect(identical(tab.marks.value, before), isTrue);
    });

    test('새 파일은 모든 줄이 추가로 보인다', () async {
      File(_p(repo, 'new.txt')).writeAsStringSync('x\ny\n');
      final tab = await open('new.txt');
      tab.recomputeMarks();
      expect(tab.baseIsNew, isTrue);
      expect(tab.marks.value.added, {0, 1});
    });

    test('무시되는 파일은 비교 기준이 없다', () async {
      File(_p(repo, 'ignored.txt')).writeAsStringSync('x\n');
      final tab = await open('ignored.txt');
      expect(tab.hasBase, isFalse);
      expect(tab.marks.value.isEmpty, isTrue);
    });

    test('커밋하면 기준을 다시 읽어 표시가 사라진다', () async {
      final tab = await open('a.txt');
      tab.controller.text = 'one\nTWO\nthree\n';
      await c.save(tab);
      await settle();
      expect(tab.marks.value.isEmpty, isFalse);

      await _git(repo.path, ['commit', '-am', 'second']);
      await c.refreshBases();
      expect(tab.marks.value.isEmpty, isTrue);
    });

    test('openDiff는 파일을 열고 변경점 보기로 바꾼다', () async {
      await c.openDiff(_p(repo, 'a.txt'));
      expect(c.activeTab!.diffMode, isTrue);
      c.toggleDiff(c.activeTab!);
      expect(c.activeTab!.diffMode, isFalse);
    });
  });

  group('화면', () {
    late StudioController c;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      c = StudioController(readBase: reader.read);
    });
    tearDown(() => c.dispose());

    Widget app(Widget body) => MaterialApp(
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      home: Scaffold(body: body),
    );

    /// 변경 표시를 다시 계산하는 짧은 대기(250ms)와 애니메이션이 끝나도록 시간을 흘린 뒤 트리를 내린다.
    Future<void> unmount(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    }

    testWidgets('변경점 보기: +/- 개수, 바뀐 줄, 접힌 줄 펼치기', (tester) async {
      final lines = List.generate(30, (i) => 'line$i');
      File(_p(repo, 'big.txt')).writeAsStringSync('${lines.join('\n')}\n');
      await tester.runAsync(() async {
        await _git(repo.path, ['add', '-A']);
        await _git(repo.path, ['commit', '-m', 'big']);
        await c.openFile(_p(repo, 'big.txt'));
        await c.refreshBase(c.activeTab!);
      });
      final tab = c.activeTab!;
      tab.controller.text = '${(lines..[15] = 'CHANGED').join('\n')}\n';

      await tester.pumpWidget(app(DiffView(tab: tab)));
      await tester.pump();

      expect(find.text('+1'), findsOneWidget);
      expect(find.text('−1'), findsOneWidget);
      expect(find.text('CHANGED'), findsOneWidget);
      expect(find.text('line15'), findsOneWidget, reason: '지워진 옛 줄');
      expect(find.textContaining('같은 줄'), findsNWidgets(2));
      expect(find.text('line0'), findsNothing, reason: '먼 줄은 접혀 있다');

      await tester.tap(find.textContaining('같은 줄').first);
      await tester.pump();
      expect(find.text('line0'), findsOneWidget);
      expect(find.textContaining('같은 줄'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('변경이 없으면 안내를 보여 준다', (tester) async {
      await tester.runAsync(() async {
        await c.openFile(_p(repo, 'a.txt'));
        await c.refreshBase(c.activeTab!);
      });
      await tester.pumpWidget(app(DiffView(tab: c.activeTab!)));
      await tester.pump();
      expect(find.textContaining('HEAD와 같습니다'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('비교할 수 없는 파일은 이유를 알려 준다', (tester) async {
      File(_p(repo, 'ignored.txt')).writeAsStringSync('x\n');
      await tester.runAsync(() async {
        await c.openFile(_p(repo, 'ignored.txt'));
        await c.refreshBase(c.activeTab!);
      });
      await tester.pumpWidget(app(DiffView(tab: c.activeTab!)));
      await tester.pump();
      expect(find.textContaining('git으로 비교할 수 없습니다'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('편집기 도구 막대: 변경점 보기 단추로 전환하고 돌아온다', (tester) async {
      await tester.runAsync(() async {
        await c.openFile(_p(repo, 'a.txt'));
        await c.refreshBase(c.activeTab!);
      });
      c.activeTab!.controller.text = 'one\nTWO\nthree\n';

      await tester.pumpWidget(
        app(
          ListenableBuilder(
            listenable: c,
            builder: (context, _) => EditorPane(controller: c),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CodeEditor), findsOneWidget);

      await tester.tap(find.byIcon(Icons.difference_outlined));
      await tester.pump();
      expect(find.byType(DiffView), findsOneWidget);
      expect(find.byType(CodeEditor), findsNothing);
      expect(find.text('TWO'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.difference_outlined));
      await tester.pump();
      expect(find.byType(CodeEditor), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('줄 번호 옆 변경 막대가 바뀐 줄·새 줄을 테마 색으로 그린다', (tester) async {
      await tester.runAsync(() async {
        await c.openFile(_p(repo, 'a.txt'));
        await c.refreshBase(c.activeTab!);
      });
      final tab = c.activeTab!;
      // 2번째 줄 수정, 4번째 줄 추가
      tab.controller.text = 'one\nTWO\nthree\nfour\n';
      tab.recomputeMarks();
      expect(tab.marks.value.modified, {1});
      expect(tab.marks.value.added, {3});

      await tester.pumpWidget(
        app(
          ListenableBuilder(
            listenable: c,
            builder: (context, _) => EditorPane(controller: c),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final theme = AppTheme.build(StudioPalette.saturn, Brightness.light);
      final tokens = theme.extension<StudioTokens>()!;
      final gutter = tester.renderObject(find.descendant(of: find.byType(ChangeGutter), matching: find.byType(CustomPaint)).last);
      expect(gutter, paints..rect(color: theme.colorScheme.primary)..rect(color: tokens.success));

      // 원래대로 돌리면 막대가 사라진다.
      tab.controller.text = 'one\ntwo\nthree\n';
      tab.recomputeMarks();
      await tester.pump(const Duration(milliseconds: 100));
      expect(gutter, isNot(paints..rect(color: theme.colorScheme.primary)));
      await unmount(tester);
    });

    testWidgets('기준이 없는 파일에는 변경점 단추가 없다', (tester) async {
      File(_p(repo, 'ignored.txt')).writeAsStringSync('x\n');
      await tester.runAsync(() async {
        await c.openFile(_p(repo, 'ignored.txt'));
        await c.refreshBase(c.activeTab!);
      });
      await tester.pumpWidget(
        app(
          ListenableBuilder(
            listenable: c,
            builder: (context, _) => EditorPane(controller: c),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.difference_outlined), findsNothing);
      await unmount(tester);
    });

    testWidgets('Git 패널의 변경 파일을 누르면 절대 경로로 변경점 보기를 연다', (tester) async {
      File(_p(repo, 'a.txt')).writeAsStringSync('one\nTWO\nthree\n');
      final git = GitController(runner: runner, store: VerifyStore(runner));
      addTearDown(git.dispose);
      await tester.runAsync(() => git.setDir(repo.path));

      String? opened;
      await tester.pumpWidget(app(GitPanel(controller: git, onOpenDiff: (p) => opened = p)));
      await tester.pump();

      expect(find.text('a.txt'), findsOneWidget);
      await tester.tap(find.text('a.txt'));
      await tester.pump();

      expect(opened, isNotNull);
      expect(opened!.toLowerCase(), endsWith('${_sep}a.txt'));
      expect(File(opened!).existsSync(), isTrue, reason: '열 수 있는 실제 경로여야 한다');
      await unmount(tester);
    });
  });
}
