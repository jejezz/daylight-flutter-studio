import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/git/status.dart';
import 'package:daylight_flutter_studio/verify/verify_state.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _git(String dir, List<String> args) async {
  final r = await Process.run('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...args], workingDirectory: dir);
  expect(r.exitCode, 0, reason: '${r.stderr}');
}

void main() {
  test('porcelain v2 상태를 읽는다', () {
    const out = '# branch.oid abc123\x00# branch.head feat\x00# branch.upstream origin/feat\x00# branch.ab +2 -1\x00'
        '1 .M N... 100644 100644 100644 h h lib/a.dart\x00? new file.txt\x00';
    final s = RepoStatus.parse(out);
    expect(s.head, 'feat');
    expect(s.ahead, 2);
    expect(s.behind, 1);
    expect(s.files.map((f) => f.path), ['lib/a.dart', 'new file.txt']);
    expect(s.clean, isFalse);
  });

  test('실제 저장소: 브랜치와 검증 판정을 읽는다 (gh 없이도 동작)', () async {
    final repo = await Directory.systemTemp.createTemp('git_controller');
    addTearDown(() => repo.delete(recursive: true));
    await _git(repo.path, ['init', '-b', 'feat']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('a');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'first']);

    final runner = CommandRunner(CommandLog());
    final store = VerifyStore(runner);
    final c = GitController(runner: runner, store: store);
    addTearDown(c.dispose);

    await c.setDir(repo.path);
    expect(c.status!.head, 'feat');
    expect(c.status!.clean, isTrue);
    expect(c.pr, isNull);
    expect(c.verdict!.state, VerifyState.unverified);
    expect(await c.lastCommitSubject(), 'first');

    final snap = (await store.snapshot(repo.path))!;
    await store.write(
      snap.commonDir,
      VerifyRecord(sha: snap.sha, branch: 'feat', mode: 'debug', target: 'windows', status: VerifyStatus.confirmed, at: DateTime.now()),
    );
    await c.refresh();
    expect(c.verdict!.state, VerifyState.verified);

    // 커밋을 더하면 검증한 뒤 1개가 추가된 stale이 된다.
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('b');
    await _git(repo.path, ['commit', '-am', 'second']);
    await c.refresh();
    expect(c.verdict!.state, VerifyState.stale);
    expect(c.verdict!.commitsSince, 1);
  });

  test('충돌 파일을 읽고(porcelain u), 다시 쓴 뒤 stage하면 해결된다', () async {
    final repo = await Directory.systemTemp.createTemp('git_controller_conflict');
    addTearDown(() => repo.delete(recursive: true));
    final file = File('${repo.path}${Platform.pathSeparator}f.txt');
    await _git(repo.path, ['init', '-b', 'main']);
    file.writeAsStringSync('one\ntwo\n');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'init']);
    await _git(repo.path, ['switch', '-c', 'topic']);
    file.writeAsStringSync('one\ntopic\n');
    await _git(repo.path, ['commit', '-am', 'topic']);
    await _git(repo.path, ['switch', 'main']);
    file.writeAsStringSync('one\nmain\n');
    await _git(repo.path, ['commit', '-am', 'main']);
    final merge = await Process.run('git', ['merge', 'topic'], workingDirectory: repo.path);
    expect(merge.exitCode, isNot(0), reason: '충돌이 나야 테스트가 의미 있다');

    final runner = CommandRunner(CommandLog());
    final c = GitController(runner: runner, store: VerifyStore(runner));
    addTearDown(c.dispose);
    await c.setDir(repo.path);

    expect(c.status!.conflicts.map((f) => f.path), ['f.txt']);
    expect(await c.isRebasing(), isFalse, reason: '충돌의 원인이 merge였으니 rebase는 아니다');

    final conflicted = c.status!.conflicts.single;
    file.writeAsStringSync('one\nresolved\n');
    expect(await c.stage(conflicted), isTrue);
    expect(c.status!.conflicts, isEmpty);
    expect(c.status!.staged.map((f) => f.path), ['f.txt']);
  });

  test('커밋: 스테이지된 것이 없으면 전부 스테이지한 뒤 커밋한다', () async {
    final repo = await Directory.systemTemp.createTemp('git_controller_commit');
    addTearDown(() => repo.delete(recursive: true));
    await _git(repo.path, ['init', '-b', 'main']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('a');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'init']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('b');
    File('${repo.path}${Platform.pathSeparator}new.txt').writeAsStringSync('new');

    final runner = CommandRunner(CommandLog());
    final c = GitController(runner: runner, store: VerifyStore(runner));
    addTearDown(c.dispose);
    await c.setDir(repo.path);

    expect(c.onDefaultBranch, isTrue, reason: '원격이 없으면 main을 기본 브랜치로 본다');
    expect(c.status!.staged, isEmpty);
    expect(await c.commit(''), isFalse, reason: '빈 메시지로는 커밋하지 않는다');
    expect(await c.commit('두 번째'), isTrue);
    expect(c.status!.clean, isTrue);
    expect(await c.lastCommitSubject(), '두 번째');
  });

  test('스테이지·해제: 파일 하나만 콕 집어 올렸다 내렸다 한다', () async {
    final repo = await Directory.systemTemp.createTemp('git_controller_stage');
    addTearDown(() => repo.delete(recursive: true));
    await _git(repo.path, ['init', '-b', 'main']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('a');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'init']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('b');
    File('${repo.path}${Platform.pathSeparator}b.txt').writeAsStringSync('b');

    final runner = CommandRunner(CommandLog());
    final c = GitController(runner: runner, store: VerifyStore(runner));
    addTearDown(c.dispose);
    await c.setDir(repo.path);

    final a = c.status!.files.firstWhere((f) => f.path == 'a.txt');
    expect(await c.stage(a, done: 'ok'), isTrue);
    expect(c.status!.staged.map((f) => f.path), ['a.txt']);

    final staged = c.status!.files.firstWhere((f) => f.path == 'a.txt');
    expect(await c.unstage(staged), isTrue);
    expect(c.status!.staged, isEmpty);

    expect(await c.stageAll(), isTrue);
    expect(c.status!.staged.map((f) => f.path).toSet(), {'a.txt', 'b.txt'});
    expect(await c.unstageAll(), isTrue);
    expect(c.status!.staged, isEmpty);
  });
}
