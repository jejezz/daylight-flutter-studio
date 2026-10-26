import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/branch_commands.dart';
import 'package:daylight_flutter_studio/git/branches_controller.dart';
import 'package:daylight_flutter_studio/git/error_hints.dart';
import 'package:daylight_flutter_studio/git/refs.dart';
import 'package:flutter_test/flutter_test.dart';

final _sep = Platform.pathSeparator;

Future<String> _git(String dir, List<String> args) async {
  final r = await Process.run('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', '-c', 'commit.gpgsign=false', ...args], workingDirectory: dir);
  expect(r.exitCode, 0, reason: 'git ${args.join(' ')}: ${r.stderr}');
  return (r.stdout as String).trim();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('refs 파싱', () {
    const line = 'refs/heads/feature/x\x00feature/x\x00origin/feature/x\x00[ahead 2, behind 1]\x001700000000\x00Add x\x00*\n'
        'refs/remotes/origin/main\x00origin/main\x00\x00\x001690000000\x00Init\x00 \n'
        'refs/remotes/origin/HEAD\x00origin\x00\x00\x001690000000\x00Init\x00 \n'
        'refs/heads/old\x00old\x00origin/old\x00[gone]\x001600000000\x00Old\x00 \n';

    test('로컬·원격, 현재, 추적 브랜치, ahead/behind, gone을 읽는다', () {
      final list = Branch.parse(line);
      expect(list.map((b) => b.name), ['feature/x', 'origin/main', 'old'], reason: 'origin/HEAD 기호 참조는 뺀다');

      final x = list[0];
      expect(x.current, isTrue);
      expect(x.remote, isFalse);
      expect(x.upstream, 'origin/feature/x');
      expect((x.ahead, x.behind), (2, 1));
      expect(x.subject, 'Add x');

      final main = list[1];
      expect(main.remote, isTrue);
      expect(main.remoteName, 'origin');
      expect(main.shortName, 'main');

      expect(list[2].upstreamGone, isTrue);
    });

    test('필드가 모자란 줄은 건너뛴다', () {
      expect(Branch.parse('garbage\n\n'), isEmpty);
    });
  });

  group('validateBranchName', () {
    test('흔한 규칙 위반을 알려 준다', () {
      expect(validateBranchName(''), BranchNameProblem.empty);
      expect(validateBranchName('   '), BranchNameProblem.empty);
      expect(validateBranchName('a b'), BranchNameProblem.invalidCharacter);
      expect(validateBranchName('a~b'), BranchNameProblem.invalidCharacter);
      expect(validateBranchName('-x'), BranchNameProblem.startsWithDash);
      expect(validateBranchName('a..b'), BranchNameProblem.invalidSequence);
      expect(validateBranchName('a//b'), BranchNameProblem.invalidSequence);
      expect(validateBranchName('/a'), BranchNameProblem.invalidEdge);
      expect(validateBranchName('a/'), BranchNameProblem.invalidEdge);
      expect(validateBranchName('a.'), BranchNameProblem.invalidEdge);
      expect(validateBranchName('a/.b'), BranchNameProblem.invalidSequence);
      expect(validateBranchName('a.lock'), BranchNameProblem.invalidSequence);
    });

    test('올바른 이름은 통과한다', () {
      for (final ok in ['main', 'feature/login', 'fix/bug-12', 'release/v1.2.3', 'a_b']) {
        expect(validateBranchName(ok), isNull, reason: ok);
      }
    });
  });

  group('BranchCommands', () {
    test('명령 인자', () {
      expect(BranchCommands.switchTo('a'), ['git', 'switch', 'a']);
      expect(BranchCommands.switchTrack('origin/a'), ['git', 'switch', '--track', 'origin/a']);
      expect(BranchCommands.create('n'), ['git', 'switch', '-c', 'n']);
      expect(BranchCommands.create('n', base: 'main'), ['git', 'switch', '-c', 'n', 'main']);
      expect(BranchCommands.create('n', base: 'main', switchAfter: false), ['git', 'branch', 'n', 'main']);
      expect(BranchCommands.rename('a', 'b'), ['git', 'branch', '-m', 'a', 'b']);
      expect(BranchCommands.delete('a'), ['git', 'branch', '-d', 'a']);
      expect(BranchCommands.delete('a', force: true), ['git', 'branch', '-D', 'a']);
      expect(BranchCommands.deleteRemote('origin', 'a'), ['git', 'push', 'origin', '--delete', 'a']);
    });
  });

  group('classifyError', () {
    test('브랜치 작업에서 나오는 오류를 알아본다', () {
      expect(classifyError("fatal: 'x' is already used by worktree at 'C:/w'"), GitErrorKind.branchInOtherWorktree);
      expect(worktreePathFromError("fatal: 'x' is already checked out at '/tmp/w'"), '/tmp/w');
      expect(classifyError("error: The branch 'x' is not fully merged."), GitErrorKind.branchNotMerged);
      expect(classifyError("fatal: a branch named 'x' already exists"), GitErrorKind.alreadyExists);
      expect(classifyError('error: Your local changes to the following files would be overwritten by checkout'), GitErrorKind.localChangesWouldBeOverwritten);
      expect(classifyError('something else'), isNull);
    });
  });

  /// 실제 git 저장소: 원격(bare)이 있고, main과 feature/a(원격에만도 있는 feature/remote-only)를 가진다.
  group('BranchesController (실제 git)', () {
    late Directory root;
    late String repo;
    late String remote;
    late BranchesController c;
    late int changed;

    Future<void> commitFile(String name, String text, String message) async {
      File('$repo$_sep$name').writeAsStringSync(text);
      await _git(repo, ['add', '-A']);
      await _git(repo, ['commit', '-m', message]);
    }

    setUp(() async {
      root = await Directory.systemTemp.createTemp('branches');
      remote = '${root.path}${_sep}remote.git';
      repo = '${root.path}${_sep}repo';
      Directory(repo).createSync();
      await _git(root.path, ['init', '--bare', '-b', 'main', remote]);
      await _git(repo, ['init', '-b', 'main']);
      await commitFile('a.txt', 'one\n', 'first');
      await _git(repo, ['remote', 'add', 'origin', remote]);
      await _git(repo, ['push', '-u', 'origin', 'main']);
      // 원격에만 있는 브랜치 하나.
      await _git(repo, ['switch', '-c', 'feature/remote-only']);
      await commitFile('r.txt', 'remote\n', 'remote only');
      await _git(repo, ['push', '-u', 'origin', 'feature/remote-only']);
      await _git(repo, ['switch', 'main']);
      await _git(repo, ['branch', '-D', 'feature/remote-only']);
      await _git(repo, ['fetch', '--prune']);

      changed = 0;
      c = BranchesController(runner: CommandRunner(CommandLog()))..onChanged = () => changed++;
      addTearDown(c.dispose);
      await c.setDir(repo);
    });

    tearDown(() async {
      try {
        await root.delete(recursive: true);
      } on FileSystemException {
        // Windows에서 git이 파일을 잠깐 잡고 있을 수 있다 — 임시 폴더라 남겨 둬도 된다.
      }
    });

    List<String> names(List<Branch> l) => [for (final b in l) b.name];

    test('로컬·원격 목록과 현재 브랜치를 읽는다', () async {
      expect(names(c.local), ['main']);
      expect(c.current?.name, 'main');
      expect(c.current?.upstream, 'origin/main');
      expect(names(c.remote), containsAll(['origin/main', 'origin/feature/remote-only']));
      expect(c.remote.every((b) => b.remote && b.remoteName == 'origin'), isTrue);
    });

    test('만들고 바로 전환한다', () async {
      expect(await c.create('feature/a'), isTrue);
      expect(c.current?.name, 'feature/a');
      expect(c.message, contains('feature/a'));
      expect(c.messageOk, isTrue);
      expect(changed, 1);
    });

    test('전환하지 않고 만들기, 기준 브랜치 지정', () async {
      expect(await c.create('base-x', switchAfter: false), isTrue);
      expect(c.current?.name, 'main', reason: '전환하지 않았다');
      expect(names(c.local), containsAll(['main', 'base-x']));

      await _git(repo, ['switch', '-c', 'work']);
      await commitFile('w.txt', 'w\n', 'work commit');
      await _git(repo, ['switch', 'main']);
      expect(await c.create('from-work', base: 'work', switchAfter: false), isTrue);
      final head = await _git(repo, ['rev-parse', 'from-work']);
      expect(head, await _git(repo, ['rev-parse', 'work']), reason: '기준 브랜치의 끝에서 만든다');
    });

    test('이미 있는 이름으로 만들면 실패하고 이유를 알려 준다', () async {
      expect(await c.create('main'), isFalse);
      expect(c.messageOk, isFalse);
      expect(c.errorKind, GitErrorKind.alreadyExists);
      expect(c.message, contains('main'));
      expect(changed, 0, reason: '실패하면 변경을 알리지 않는다');
    });

    test('로컬 브랜치로 전환한다', () async {
      await c.create('other', switchAfter: false);
      final other = c.local.firstWhere((b) => b.name == 'other');
      expect(await c.switchTo(other), isTrue);
      expect(c.current?.name, 'other');
    });

    test('원격 브랜치를 고르면 로컬 추적 브랜치를 만들어 전환한다', () async {
      final r = c.remote.firstWhere((b) => b.name == 'origin/feature/remote-only');
      expect(await c.switchTo(r), isTrue);
      expect(c.current?.name, 'feature/remote-only');
      expect(c.current?.upstream, 'origin/feature/remote-only');
      expect(File('$repo${_sep}r.txt').existsSync(), isTrue, reason: '그 브랜치의 파일이 작업 폴더에 나타난다');
    });

    test('이름을 바꾼다', () async {
      await c.create('old-name', switchAfter: false);
      expect(await c.rename('old-name', 'new-name'), isTrue);
      expect(names(c.local), contains('new-name'));
      expect(names(c.local), isNot(contains('old-name')));
      expect(c.message, contains('new-name'));
    });

    test('병합된 브랜치는 그냥 삭제된다', () async {
      await c.create('merged', switchAfter: false);
      expect(await c.deleteLocal('merged'), isTrue);
      expect(names(c.local), ['main']);
    });

    test('병합되지 않은 브랜치는 막고, 강제하면 삭제한다', () async {
      await _git(repo, ['switch', '-c', 'unmerged']);
      await commitFile('u.txt', 'u\n', 'unmerged work');
      await _git(repo, ['switch', 'main']);
      await c.refresh();

      expect(await c.deleteLocal('unmerged'), isFalse);
      expect(c.errorKind, GitErrorKind.branchNotMerged);
      expect(names(c.local), contains('unmerged'), reason: '지워지지 않았다');

      expect(await c.deleteLocal('unmerged', force: true), isTrue);
      expect(names(c.local), isNot(contains('unmerged')));
    });

    test('지금 쓰는 브랜치는 지울 수 없다', () async {
      expect(await c.deleteLocal('main', force: true), isFalse);
      expect(c.messageOk, isFalse);
      expect(names(c.local), ['main']);
    });

    test('원격 브랜치를 삭제한다', () async {
      final r = c.remote.firstWhere((b) => b.name == 'origin/feature/remote-only');
      expect(await c.deleteRemote(r), isTrue);
      expect(names(c.remote), isNot(contains('origin/feature/remote-only')));
      final remoteBranches = await _git(remote, ['branch', '--list']);
      expect(remoteBranches, isNot(contains('remote-only')), reason: '원격 저장소에서 실제로 사라졌다');
    });

    test('로컬 브랜치에는 원격 삭제를 하지 않는다', () async {
      expect(await c.deleteRemote(c.local.first), isFalse);
    });

    test('다른 worktree가 쥔 브랜치는 표시하고, 전환·삭제는 이유와 함께 막힌다', () async {
      await c.create('in-wt', switchAfter: false);
      final wt = '${root.path}${_sep}wt';
      await _git(repo, ['worktree', 'add', wt, 'in-wt']);
      await c.refresh();

      final holder = c.worktreeHolding('in-wt');
      expect(holder, isNotNull);
      expect(holder!.path.toLowerCase().replaceAll(r'\', '/'), endsWith('/wt'));
      expect(c.worktreeHolding('main'), isNull, reason: '이 폴더가 쥔 브랜치는 "다른 worktree"가 아니다');

      final branch = c.local.firstWhere((b) => b.name == 'in-wt');
      expect(await c.switchTo(branch), isFalse);
      expect(c.errorKind, GitErrorKind.branchInOtherWorktree);
      expect(c.message, contains('worktree'));
      expect(c.message, contains('in-wt'));

      expect(await c.deleteLocal('in-wt', force: true), isFalse);
      expect(c.errorKind, GitErrorKind.branchInOtherWorktree);
    });

    test('커밋하지 않은 변경이 덮어써질 때는 이유를 알려 주고 전환하지 않는다', () async {
      await _git(repo, ['switch', '-c', 'conflicting']);
      await commitFile('a.txt', 'changed on branch\n', 'change a');
      await _git(repo, ['switch', 'main']);
      File('$repo${_sep}a.txt').writeAsStringSync('dirty local edit\n');
      await c.refresh();

      final target = c.local.firstWhere((b) => b.name == 'conflicting');
      expect(await c.switchTo(target), isFalse);
      expect(c.errorKind, GitErrorKind.localChangesWouldBeOverwritten);
      expect(c.message, contains('커밋'));
      expect(c.current?.name, 'main');
    });

    test('동작 중에는 다른 동작을 시작하지 않는다', () async {
      final first = c.create('p1', switchAfter: false);
      final second = c.create('p2', switchAfter: false);
      expect(await second, isFalse);
      expect(await first, isTrue);
      expect(names(c.local), isNot(contains('p2')));
    });

    test('폴더가 없으면 아무것도 하지 않는다', () async {
      final empty = BranchesController(runner: CommandRunner(CommandLog()));
      addTearDown(empty.dispose);
      expect(await empty.create('x'), isFalse);
      expect(empty.branches, isEmpty);
    });
  });
}
