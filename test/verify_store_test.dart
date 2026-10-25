import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _git(String dir, List<String> args) async {
  final r = await Process.run('git', ['-c', 'user.name=t', '-c', 'user.email=t@t', ...args], workingDirectory: dir);
  expect(r.exitCode, 0, reason: '${r.stderr}');
}

void main() {
  late Directory repo;
  late VerifyStore store;

  setUp(() async {
    repo = await Directory.systemTemp.createTemp('verify_store');
    await _git(repo.path, ['init', '-b', 'main']);
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('a');
    await _git(repo.path, ['add', '-A']);
    await _git(repo.path, ['commit', '-m', 'first']);
    store = VerifyStore(CommandRunner(CommandLog()));
  });

  tearDown(() => repo.delete(recursive: true));

  test('깨끗한 저장소의 HEAD를 읽는다', () async {
    final s = await store.snapshot(repo.path);
    expect(s, isNotNull);
    expect(s!.branch, 'main');
    expect(s.dirty, isFalse);
    expect(s.sha.length, 40);
  });

  test('수정한 파일이 있으면 dirty다', () async {
    File('${repo.path}${Platform.pathSeparator}a.txt').writeAsStringSync('changed');
    expect((await store.snapshot(repo.path))!.dirty, isTrue);
  });

  test('저장소가 아니면 null', () async {
    final dir = await Directory.systemTemp.createTemp('not_repo');
    addTearDown(() => dir.delete(recursive: true));
    expect(await store.snapshot(dir.path), isNull);
  });

  test('기록을 쓰고 읽고 상태를 바꾼다', () async {
    final s = (await store.snapshot(repo.path))!;
    expect(await store.read(s.commonDir, s.sha), isNull);

    final rec = VerifyRecord(sha: s.sha, branch: s.branch, mode: 'debug', target: 'windows', status: VerifyStatus.built, at: DateTime(2026, 10, 25));
    await store.write(s.commonDir, rec);
    expect((await store.read(s.commonDir, s.sha))!.status, VerifyStatus.built);

    await store.write(s.commonDir, rec.copyWith(status: VerifyStatus.problem, note: '버튼이 안 눌려요'));
    final back = (await store.read(s.commonDir, s.sha))!;
    expect(back.status, VerifyStatus.problem);
    expect(back.note, '버튼이 안 눌려요');
    expect(back.target, 'windows');
  });

  test('worktree에서도 같은 기록 폴더를 쓴다', () async {
    final wt = '${repo.path}-wt';
    addTearDown(() => Directory(wt).deleteSync(recursive: true));
    await _git(repo.path, ['worktree', 'add', '-b', 'feat', wt]);
    final main = (await store.snapshot(repo.path))!;
    final linked = (await store.snapshot(wt))!;
    expect(linked.branch, 'feat');
    expect(File(linked.commonDir).absolute.path.toLowerCase(), File(main.commonDir).absolute.path.toLowerCase());
  });

  test('깨진 기록 파일은 없는 것으로 본다', () async {
    final s = (await store.snapshot(repo.path))!;
    final dir = Directory('${s.commonDir}${Platform.pathSeparator}dock-verify')..createSync(recursive: true);
    File('${dir.path}${Platform.pathSeparator}${s.sha}.json').writeAsStringSync('{ not json');
    expect(await store.read(s.commonDir, s.sha), isNull);
  });
}
