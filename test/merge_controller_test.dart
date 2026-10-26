import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/branches_controller.dart';
import 'package:daylight_flutter_studio/git/error_hints.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/git/merge_commands.dart';
import 'package:daylight_flutter_studio/git/operation.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';

final _sep = Platform.pathSeparator;

Future<String> _git(String dir, List<String> args, {bool allowFail = false}) async {
  final r = await Process.run('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', '-c', 'commit.gpgsign=false', '-c', 'core.editor=true', ...args], workingDirectory: dir);
  if (!allowFail) expect(r.exitCode, 0, reason: 'git ${args.join(' ')}: ${r.stderr}');
  return (r.stdout as String).trim();
}

/// Windows의 autocrlf가 체크아웃 때 줄 끝을 CRLF로 바꿀 수 있어, 줄 끝을 맞춰 읽는다.
String _read(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MergeCommands', () {
    test('방식별 명령', () {
      expect(MergeCommands.start('x', MergeMode.fastForward), [
        ['git', 'merge', '--ff-only', 'x'],
      ]);
      expect(MergeCommands.start('x', MergeMode.mergeCommit, message: 'm'), [
        ['git', 'merge', '--no-ff', '-m', 'm', '--no-edit', 'x'],
      ]);
      expect(MergeCommands.start('x', MergeMode.mergeCommit), [
        ['git', 'merge', '--no-ff', '--no-edit', 'x'],
      ]);
      expect(MergeCommands.start('x', MergeMode.squash, message: 'msg'), [
        ['git', 'merge', '--squash', 'x'],
        ['git', 'commit', '-m', 'msg'],
      ]);
      expect(MergeCommands.start('x', MergeMode.rebase), [
        ['git', 'rebase', 'x'],
      ]);
    });

    test('들어올 커밋·다시 쌓일 커밋·조상 검사', () {
      expect(MergeCommands.incoming('x').sublist(0, 2), ['git', 'log']);
      expect(MergeCommands.incoming('x').last, 'HEAD..x');
      expect(MergeCommands.replayed('x').last, 'x..HEAD');
      expect(MergeCommands.isAncestor('HEAD', 'x'), ['git', 'merge-base', '--is-ancestor', 'HEAD', 'x']);
    });

    test('작업 중단·계속 명령', () {
      expect(OperationCommands.abort(RepoOperation.merging), ['git', 'merge', '--abort']);
      expect(OperationCommands.abort(RepoOperation.rebasing), ['git', 'rebase', '--abort']);
      expect(OperationCommands.abort(RepoOperation.none), isNull);
      expect(OperationCommands.continueWith(RepoOperation.merging), ['git', 'commit', '--no-edit']);
      expect(OperationCommands.continueWith(RepoOperation.cherryPicking), isNull, reason: 'cherry-pick은 중단만 지원한다');
    });
  });

  group('실제 git: 병합·rebase', () {
    late Directory root;
    late String repo;
    late CommandRunner runner;
    late BranchesController b;
    late GitController g;
    late int branchChanges;
    late int fileChanges;

    Future<void> commitFile(String name, String text, String message, {String? dir}) async {
      File('${dir ?? repo}$_sep$name').writeAsStringSync(text);
      await _git(dir ?? repo, ['add', '-A']);
      await _git(dir ?? repo, ['commit', '-m', message]);
    }

    Future<int> parents(String ref) async => (await _git(repo, ['rev-list', '--parents', '-n', '1', ref])).split(' ').length - 1;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('merge');
      repo = '${root.path}${_sep}repo';
      Directory(repo).createSync();
      await _git(repo, ['init', '-b', 'main']);
      await commitFile('base.txt', 'base\n', 'base');
      runner = CommandRunner(CommandLog());
      branchChanges = 0;
      fileChanges = 0;
      b = BranchesController(runner: runner)..onChanged = () => branchChanges++;
      g = GitController(runner: runner, store: VerifyStore(runner))..onFilesChanged = () => fileChanges++;
      addTearDown(b.dispose);
      addTearDown(g.dispose);
    });

    Future<void> open() async {
      await b.setDir(repo);
      await g.setDir(repo);
    }

    tearDown(() async {
      try {
        await root.delete(recursive: true);
      } on FileSystemException {
        // Windows에서 git이 파일을 잠깐 잡고 있을 수 있다 — 임시 폴더라 남겨 둬도 된다.
      }
    });

    /// main(base) → feature(f1, f2)로 갈라지지 않은 상태: main이 feature의 조상.
    Future<void> linearFeature() async {
      await _git(repo, ['switch', '-c', 'feature']);
      await commitFile('f1.txt', '1\n', 'feature one');
      await commitFile('f2.txt', '2\n', 'feature two');
      await _git(repo, ['switch', 'main']);
    }

    /// main에도 새 커밋이 있어 feature와 갈라진 상태.
    Future<void> divergedFeature() async {
      await linearFeature();
      await commitFile('m1.txt', 'm\n', 'main moved on');
    }

    /// 같은 줄을 서로 다르게 고쳐서 병합하면 충돌이 나는 두 브랜치.
    Future<void> conflictingFeature() async {
      await _git(repo, ['switch', '-c', 'feature']);
      await commitFile('base.txt', 'feature side\n', 'feature edits base');
      await _git(repo, ['switch', 'main']);
      await commitFile('base.txt', 'main side\n', 'main edits base');
    }

    test('미리 보기: 들어올 커밋, fast-forward 가능 여부, 다시 쌓일 내 커밋', () async {
      await divergedFeature();
      await open();

      var p = await b.preview('feature');
      expect(p.incoming.map((c) => c.subject), ['feature two', 'feature one']);
      expect(p.canFastForward, isFalse, reason: 'main에도 새 커밋이 있다');
      expect(p.replayed.map((c) => c.subject), ['main moved on']);

      await _git(repo, ['reset', '--hard', 'HEAD~1']);
      p = await b.preview('feature');
      expect(p.canFastForward, isTrue);
      expect(p.replayed, isEmpty);
    });

    test('이미 최신이면 들어올 커밋이 없다', () async {
      await linearFeature();
      await _git(repo, ['switch', 'feature']);
      await open();
      final p = await b.preview('main');
      expect(p.incoming, isEmpty);
    });

    test('fast-forward: 브랜치 끝만 옮기고 병합 커밋을 만들지 않는다', () async {
      await linearFeature();
      await open();
      expect(await b.merge('feature', MergeMode.fastForward), isTrue);
      expect(await _git(repo, ['rev-parse', 'HEAD']), await _git(repo, ['rev-parse', 'feature']));
      expect(await parents('HEAD'), 1);
      expect(b.message, contains('feature'));
      expect(b.message, contains('main'));
      expect(branchChanges, 1);
    });

    test('갈라진 브랜치를 fast-forward로 합치려 하면 이유를 알려 주고 아무것도 바꾸지 않는다', () async {
      await divergedFeature();
      await open();
      final before = await _git(repo, ['rev-parse', 'HEAD']);
      expect(await b.merge('feature', MergeMode.fastForward), isFalse);
      expect(b.errorKind, GitErrorKind.notFastForward);
      expect(b.message, contains('fast-forward'));
      expect(await _git(repo, ['rev-parse', 'HEAD']), before);
      expect(branchChanges, 0);
    });

    test('병합 커밋: 부모가 둘이고 메시지를 쓴다', () async {
      await divergedFeature();
      await open();
      expect(await b.merge('feature', MergeMode.mergeCommit, message: 'Merge feature work'), isTrue);
      expect(await parents('HEAD'), 2);
      expect(await _git(repo, ['log', '-1', '--format=%s']), 'Merge feature work');
      expect(File('$repo${_sep}f1.txt').existsSync() && File('$repo${_sep}m1.txt').existsSync(), isTrue);
    });

    test('squash: 커밋 하나로 묶고, 원래 커밋은 기록에 들어오지 않는다', () async {
      await divergedFeature();
      await open();
      final countBefore = int.parse(await _git(repo, ['rev-list', '--count', 'HEAD']));
      expect(await b.merge('feature', MergeMode.squash, message: 'feat: feature work'), isTrue);
      expect(int.parse(await _git(repo, ['rev-list', '--count', 'HEAD'])), countBefore + 1);
      expect(await parents('HEAD'), 1);
      expect(await _git(repo, ['log', '-1', '--format=%s']), 'feat: feature work');
      expect(await _git(repo, ['log', '--format=%s']), isNot(contains('feature one')));
      expect(File('$repo${_sep}f2.txt').existsSync(), isTrue);
    });

    test('rebase: 내 커밋을 상대 끝에 다시 쌓아 기록이 한 줄이 된다', () async {
      await divergedFeature();
      await _git(repo, ['switch', 'feature']);
      await open();
      expect(await b.merge('main', MergeMode.rebase), isTrue);
      expect(await _git(repo, ['log', '--format=%s']), 'feature two\nfeature one\nmain moved on\nbase');
      expect(await parents('HEAD'), 1);
      expect(b.message, contains('rebase'));
    });

    test('충돌: 실패로 돌려주고 병합 중 상태가 되며, 파일에 충돌 표시가 남고 변경을 알린다', () async {
      await conflictingFeature();
      await open();
      expect(await b.merge('feature', MergeMode.mergeCommit), isFalse);
      expect(b.errorKind, GitErrorKind.conflict);
      expect(b.message, contains('충돌'));
      expect(b.operation, RepoOperation.merging);
      expect(File('$repo${_sep}base.txt').readAsStringSync(), contains('<<<<<<<'));
      expect(branchChanges, 1, reason: '충돌 표시가 파일에 쓰였으니 화면이 새로 읽어야 한다');

      await g.refresh();
      expect(g.operation, RepoOperation.merging);
      expect(g.status!.conflicts.length, 1);
    });

    test('충돌 중 중단하면 병합 전 상태로 돌아온다', () async {
      await conflictingFeature();
      await open();
      await b.merge('feature', MergeMode.mergeCommit);
      await g.refresh();

      expect(await g.abortOperation(), isTrue);
      expect(g.operation, RepoOperation.none);
      expect(g.status!.conflicts, isEmpty);
      expect(_read('$repo${_sep}base.txt'), 'main side\n');
      expect(fileChanges, 1);
      expect(g.message, contains('중단'));
    });

    test('충돌을 해결하지 않고 계속하려 하면 git이 거부하고 상태는 그대로다', () async {
      await conflictingFeature();
      await open();
      await b.merge('feature', MergeMode.mergeCommit);
      await g.refresh();

      expect(await g.continueOperation(), isFalse);
      expect(g.operation, RepoOperation.merging);
      expect(fileChanges, 0);
    });

    test('충돌을 해결하고 스테이지한 뒤 계속하면 병합 커밋이 만들어진다', () async {
      await conflictingFeature();
      await open();
      await b.merge('feature', MergeMode.mergeCommit);
      File('$repo${_sep}base.txt').writeAsStringSync('resolved\n');
      await _git(repo, ['add', 'base.txt']);
      await g.refresh();
      expect(g.status!.conflicts, isEmpty);

      expect(await g.continueOperation(), isTrue);
      expect(g.operation, RepoOperation.none);
      expect(await parents('HEAD'), 2);
      expect(_read('$repo${_sep}base.txt'), 'resolved\n');
      expect(fileChanges, 1);
    });

    test('rebase 충돌: rebase 중 상태이고, 건너뛰기·중단·계속이 동작한다', () async {
      // feature: base.txt를 고침(충돌), 그리고 별도 파일 커밋 하나
      await _git(repo, ['switch', '-c', 'feature']);
      await commitFile('base.txt', 'feature side\n', 'feature edits base');
      await commitFile('after.txt', 'after\n', 'feature adds after');
      await _git(repo, ['switch', 'main']);
      await commitFile('base.txt', 'main side\n', 'main edits base');
      await _git(repo, ['switch', 'feature']);
      await open();

      expect(await b.merge('main', MergeMode.rebase), isFalse);
      expect(b.errorKind, GitErrorKind.conflict);
      await g.refresh();
      expect(g.operation, RepoOperation.rebasing);

      // 충돌난 첫 커밋을 건너뛰면 다음 커밋이 적용되며 끝난다.
      expect(await g.skipOperation(), isTrue);
      expect(g.operation, RepoOperation.none);
      expect(File('$repo${_sep}after.txt').existsSync(), isTrue);
      expect(_read('$repo${_sep}base.txt'), 'main side\n');
    });

    test('rebase 중단: 시작 전으로 돌아간다', () async {
      await _git(repo, ['switch', '-c', 'feature']);
      await commitFile('base.txt', 'feature side\n', 'feature edits base');
      final before = await _git(repo, ['rev-parse', 'HEAD']);
      await _git(repo, ['switch', 'main']);
      await commitFile('base.txt', 'main side\n', 'main edits base');
      await _git(repo, ['switch', 'feature']);
      await open();
      await b.merge('main', MergeMode.rebase);
      await g.refresh();

      expect(await g.abortOperation(), isTrue);
      expect(g.operation, RepoOperation.none);
      expect(await _git(repo, ['rev-parse', 'HEAD']), before);
    });

    test('rebase 중에는 건너뛰기만, 병합 중에는 건너뛰기를 허용하지 않는다', () async {
      await conflictingFeature();
      await open();
      await b.merge('feature', MergeMode.mergeCommit);
      await g.refresh();
      expect(await g.skipOperation(), isFalse, reason: '병합에는 건너뛰기가 없다');
      expect(g.operation, RepoOperation.merging);
    });

    test('커밋하지 않은 변경이 병합과 겹치면 이유를 알려 주고 병합하지 않는다', () async {
      await conflictingFeature();
      File('$repo${_sep}base.txt').writeAsStringSync('dirty local edit\n');
      await open();
      expect(await b.merge('feature', MergeMode.mergeCommit), isFalse);
      expect(b.errorKind, GitErrorKind.localChangesWouldBeOverwritten);
      expect(b.message, contains('커밋하지 않은 변경'));
      expect(b.operation, RepoOperation.none);
    });

    test('작업 폴더가 하위 폴더여도, 연결된 worktree여도 진행 중인 작업을 찾는다', () async {
      await conflictingFeature();
      await open();
      await b.merge('feature', MergeMode.mergeCommit);

      Directory('$repo${_sep}sub').createSync();
      expect(await readRepoOperation(runner, '$repo${_sep}sub'), RepoOperation.merging, reason: '상대 경로 git 폴더에 속지 않는다');

      // 다른 worktree에서 병합 중이면 그 worktree의 git 폴더를 본다 (메인 작업 폴더는 영향 없음).
      await _git(repo, ['merge', '--abort']);
      final wt = '${root.path}${_sep}wt';
      await _git(repo, ['worktree', 'add', '-b', 'wt-branch', wt, 'main']);
      await commitFile('base.txt', 'wt side\n', 'wt edits base', dir: wt);
      await _git(wt, ['merge', 'feature'], allowFail: true);
      expect(await readRepoOperation(runner, wt), RepoOperation.merging);
      expect(await readRepoOperation(runner, repo), RepoOperation.none);
    });

    test('진행 중인 작업이 없으면 none', () async {
      expect(await readRepoOperation(runner, repo), RepoOperation.none);
    });
  });
}
