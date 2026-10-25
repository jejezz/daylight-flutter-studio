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
}
