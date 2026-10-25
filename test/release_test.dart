import 'dart:io';

import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/git/git_controller.dart';
import 'package:daylight_flutter_studio/release/release_check.dart';
import 'package:daylight_flutter_studio/release/release_controller.dart';
import 'package:daylight_flutter_studio/release/semver.dart';
import 'package:daylight_flutter_studio/settings/gate_settings.dart';
import 'package:daylight_flutter_studio/verify/verify_state.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SemVer', () {
    test('읽기: v 접두어와 build number를 무시한다', () {
      expect(SemVer.tryParse('v1.4.2')!.toString(), '1.4.2');
      expect(SemVer.tryParse('1.5.0-rc.1+40')!.tag, 'v1.5.0-rc.1');
      expect(SemVer.tryParse('1.4'), isNull);
      expect(pubspecVersion('name: x\nversion: 0.1.0-rc.1+1 # 첫 태그\n')!.tag, 'v0.1.0-rc.1');
    });

    test('비교: 프리릴리스는 같은 숫자의 정식 버전보다 낮고, rc.2는 rc.1보다 높다', () {
      int cmp(String a, String b) => SemVer.tryParse(a)!.compareTo(SemVer.tryParse(b)!);
      expect(cmp('1.0.0', '1.0.0-rc.1'), greaterThan(0));
      expect(cmp('1.0.0-rc.2', '1.0.0-rc.1'), greaterThan(0));
      expect(cmp('1.0.0-rc.10', '1.0.0-rc.9'), greaterThan(0));
      expect(cmp('0.1.0', '0.0.9'), greaterThan(0));
      expect(cmp('1.2.3', '1.2.3+9'), 0);
    });
  });

  group('evaluateRelease', () {
    ReleaseFacts facts({bool clean = true, String? branch = 'main', int ahead = 0, int behind = 0, String? version = '1.1.0', String? last = '1.0.0', bool exists = false, bool verified = true}) =>
        ReleaseFacts(
          clean: clean,
          branch: branch,
          defaultBranch: 'main',
          hasUpstream: true,
          ahead: ahead,
          behind: behind,
          version: version == null ? null : SemVer.tryParse(version),
          lastTag: last == null ? null : SemVer.tryParse(last),
          tagExists: exists,
          verdict: VerifyVerdict(verified ? VerifyState.verified : VerifyState.unverified),
        );

    test('모두 통과', () {
      expect(evaluateRelease(facts()).values.every((v) => v), isTrue);
    });

    test('항목별로 실패한다', () {
      expect(evaluateRelease(facts(clean: false))[ReleaseCheck.cleanTree], isFalse);
      expect(evaluateRelease(facts(branch: 'feat'))[ReleaseCheck.onDefaultBranch], isFalse);
      expect(evaluateRelease(facts(ahead: 1))[ReleaseCheck.synced], isFalse);
      expect(evaluateRelease(facts(behind: 2))[ReleaseCheck.synced], isFalse);
      expect(evaluateRelease(facts(version: '1.0.0'))[ReleaseCheck.versionBumped], isFalse);
      expect(evaluateRelease(facts(version: null))[ReleaseCheck.versionBumped], isFalse);
      expect(evaluateRelease(facts(exists: true))[ReleaseCheck.tagFree], isFalse);
      expect(evaluateRelease(facts(verified: false))[ReleaseCheck.verified], isFalse);
    });

    test('태그가 하나도 없으면 첫 버전도 높은 것으로 본다', () {
      expect(evaluateRelease(facts(last: null, version: '0.1.0-rc.1'))[ReleaseCheck.versionBumped], isTrue);
    });
  });

  group('ReleaseController (실제 git)', () {
    late Directory root;
    late String work;
    late String origin;
    late GitController git;
    late VerifyStore store;
    late CommandRunner runner;

    Future<void> sh(List<String> args, {String? cwd}) async {
      final r = await Process.run('git', args, workingDirectory: cwd ?? work);
      if (r.exitCode != 0) fail('git ${args.join(' ')}: ${r.stderr}');
    }

    Future<String> head() async => (await Process.run('git', ['rev-parse', 'HEAD'], workingDirectory: work)).stdout.toString().trim();

    Future<void> commitVersion(String v) async {
      File('$work/pubspec.yaml').writeAsStringSync('name: sample_app\nversion: $v+1\n');
      await sh(['add', '-A']);
      await sh(['commit', '-m', 'chore(release): v$v']);
      await sh(['push', 'origin', 'main']);
    }

    Future<void> confirm(String sha) async {
      final snap = (await store.snapshot(work))!;
      await store.write(
        snap.commonDir,
        VerifyRecord(sha: sha, branch: 'main', mode: 'release', target: 'macos', status: VerifyStatus.confirmed, at: DateTime(2026, 10, 25)),
      );
    }

    setUp(() async {
      root = await Directory.systemTemp.createTemp('release_test');
      origin = '${root.path}/origin.git';
      work = '${root.path}/work';
      await sh(['init', '--bare', '-b', 'main', origin], cwd: root.path);
      await sh(['init', '-b', 'main', work], cwd: root.path);
      await sh(['config', 'user.email', 't@example.com']);
      await sh(['config', 'user.name', 'Tester']);
      await sh(['config', 'commit.gpgsign', 'false']);
      await sh(['config', 'tag.gpgsign', 'false']);
      await sh(['remote', 'add', 'origin', origin]);
      File('$work/pubspec.yaml').writeAsStringSync('name: sample_app\nversion: 1.0.0+1\n');
      await sh(['add', '-A']);
      await sh(['commit', '-m', 'init']);
      await sh(['push', '-u', 'origin', 'main']);
      runner = CommandRunner(CommandLog());
      store = VerifyStore(runner);
      git = GitController(runner: runner, store: store, gate: GateSettings());
      await git.setDir(work);
    });

    tearDown(() async {
      git.dispose();
      await root.delete(recursive: true);
    });

    test('검증이 없으면 태그를 막고, 확인하면 annotated 태그를 만들어 올린다', () async {
      final c = ReleaseController(git);
      await c.load();
      expect(c.tag, 'v1.0.0');
      expect(c.checks[ReleaseCheck.verified], isFalse);
      expect(c.othersPass, isTrue);
      expect(c.canTag, isFalse);
      expect(c.canTagWithoutVerification, isTrue);
      expect(await c.createTag(), isFalse);
      expect((await Process.run('git', ['tag', '-l'], workingDirectory: work)).stdout.toString().trim(), isEmpty);

      await confirm(await head());
      await c.load();
      expect(c.canTag, isTrue);
      expect(await c.createTag(), isTrue);

      final msg = (await Process.run('git', ['tag', '-l', '--format=%(contents:subject)', 'v1.0.0'], workingDirectory: work)).stdout.toString().trim();
      expect(msg, 'sample_app 1.0.0');
      final remote = (await Process.run('git', ['ls-remote', '--tags', origin])).stdout.toString();
      expect(remote, contains('refs/tags/v1.0.0'));

      await c.load();
      expect(c.checks[ReleaseCheck.tagFree], isFalse);
      expect(c.checks[ReleaseCheck.versionBumped], isFalse);
      c.dispose();
    });

    test('"검증 없이 태그"는 명시적으로 허용할 때만 된다', () async {
      await commitVersion('1.0.1');
      final c = ReleaseController(git);
      await c.load();
      expect(c.checks[ReleaseCheck.verified], isFalse);
      expect(await c.createTag(), isFalse);
      expect(await c.createTag(overrideGate: true), isTrue);
      c.dispose();
    });

    test('작업 브랜치나 수정 중인 폴더에서는 다른 항목이 막는다', () async {
      File('$work/dirty.txt').writeAsStringSync('x');
      var c = ReleaseController(git);
      await c.load();
      expect(c.checks[ReleaseCheck.cleanTree], isFalse);
      expect(c.othersPass, isFalse);
      expect(c.canTagWithoutVerification, isFalse);
      c.dispose();

      File('$work/dirty.txt').deleteSync();
      await sh(['switch', '-c', 'feat']);
      await git.refresh();
      c = ReleaseController(git);
      await c.load();
      expect(c.checks[ReleaseCheck.onDefaultBranch], isFalse);
      c.dispose();
    });
  });
}
