import 'dart:io';

import 'package:flutter/foundation.dart';

import '../git/git_controller.dart';
import '../l10n/current_l10n.dart';
import '../settings/gate_settings.dart';
import '../verify/verify_state.dart';
import 'release_check.dart';
import 'semver.dart';

/// 릴리스 태그 단계: 점검 → (버전은 pubspec에서 정해져 있다) → 태그 만들기·올리기.
///
/// 버전 올림 커밋은 PR로 `main`에 병합해 두었다고 본다 (`scripts/bump-version.sh`).
/// 여기서는 그 병합 커밋에 태그를 달고 올릴 뿐이다 — CI(`release.yml`)가 나머지를 한다.
class ReleaseController extends ChangeNotifier {
  ReleaseController(this.git);

  final GitController git;

  bool loading = false;
  ReleaseFacts? facts;
  Map<ReleaseCheck, bool> checks = const {};

  /// 마지막 동작의 결과 한 줄과 성공 여부.
  String? message;
  bool messageOk = true;
  bool busy = false;
  bool tagged = false;

  /// 점검을 통과해도 `scripts/bump-version.sh`가 없는 저장소 — 버전 올림 안내를 바꾼다.
  bool hasBumpScript = false;

  String? get tag => facts?.tag;

  /// 검증 관문이 막는 것을 뺀 나머지 점검이 모두 통과했는가.
  bool get othersPass => checks.entries.where((e) => e.key != ReleaseCheck.verified).every((e) => e.value);

  GateDecision get decision => git.gate?.decide(facts?.verdict) ?? const GateDecision.allow();

  /// 지금 태그를 달 수 있는가 (검증 관문 포함).
  bool get canTag => !tagged && !busy && othersPass && decision.allowed;

  /// 검증이 없어서만 막혀 있다 — "검증 없이 태그" 예외가 가능한 상태.
  bool get canTagWithoutVerification => !tagged && !busy && othersPass && !decision.allowed;

  Future<void> load() async {
    final d = git.dir;
    if (d == null) return;
    loading = true;
    message = null;
    notifyListeners();
    await git.refresh();
    final s = git.status;
    final top = git.topLevel ?? d;
    if (s == null) {
      facts = null;
      checks = const {};
      loading = false;
      notifyListeners();
      return;
    }
    final defaultBranch = await git.defaultBranch();
    final pubspec = File('$top${Platform.pathSeparator}pubspec.yaml');
    final version = pubspec.existsSync() ? pubspecVersion(pubspec.readAsStringSync()) : null;
    hasBumpScript = File('$top${Platform.pathSeparator}scripts${Platform.pathSeparator}bump-version.sh').existsSync();

    final tagList = await git.runner.run(['git', 'tag', '--list', 'v*'], workingDirectory: d, quiet: true);
    final localTags = tagList.ok ? tagList.stdout.split('\n').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet() : <String>{};
    SemVer? last;
    for (final t in localTags) {
      final v = SemVer.tryParse(t);
      if (v != null && (last == null || v.compareTo(last) > 0)) last = v;
    }
    var exists = version != null && localTags.contains(version.tag);
    if (version != null && !exists) {
      // 원격에만 있는 태그도 같은 이름이면 안 된다.
      final remote = await git.runner.run(['git', 'ls-remote', '--tags', 'origin', 'refs/tags/${version.tag}'], workingDirectory: d, quiet: true);
      exists = remote.ok && remote.stdout.trim().isNotEmpty;
    }

    final verdict = await _verdictForHead(d, s.oid);
    facts = ReleaseFacts(
      clean: s.clean,
      branch: s.head,
      defaultBranch: defaultBranch,
      hasUpstream: s.hasUpstream,
      ahead: s.ahead,
      behind: s.behind,
      version: version,
      lastTag: last,
      tagExists: exists,
      verdict: verdict,
    );
    checks = evaluateRelease(facts!);
    loading = false;
    notifyListeners();
  }

  /// 태그를 다는 커밋(HEAD)의 검증 판정. 병합 방식(squash 등) 때문에 HEAD에 기록이 없으면,
  /// 그 커밋을 만든 PR의 head 커밋 기록을 본다 — 눈으로 확인한 것은 PR head이기 때문이다.
  Future<VerifyVerdict?> _verdictForHead(String dir, String? headSha) async {
    final snap = git.snapshot;
    if (snap == null || headSha == null) return null;
    final records = await git.store.readAll(snap.commonDir);
    final candidates = <String>[headSha];
    final pulls = await git.runner.run(
      ['gh', 'api', 'repos/{owner}/{repo}/commits/$headSha/pulls', '--jq', '.[].head.sha'],
      workingDirectory: dir,
      quiet: true,
    );
    if (pulls.ok) candidates.addAll(pulls.stdout.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty));
    VerifyVerdict? best;
    for (final sha in candidates) {
      final v = await judgeVerification(headSha: sha, branch: snap.branch, records: records);
      if (v.passes) return v;
      best ??= v;
    }
    return best;
  }

  /// 태그를 만들고 올린다. 검증 관문이 막으면 [overrideGate]일 때만 진행한다 —
  /// 화면이 사용자의 명시적 확인을 받은 뒤에만 true로 부른다.
  Future<bool> createTag({bool overrideGate = false}) async {
    final f = facts;
    final d = git.dir;
    final name = f?.tag;
    if (f == null || d == null || name == null || busy || tagged) return false;
    await load(); // 화면이 낡았을 수 있으니 직전에 다시 판정한다.
    if (!othersPass || (!decision.allowed && !overrideGate)) {
      messageOk = false;
      message = CurrentL10n.value.releaseNotReady;
      notifyListeners();
      return false;
    }
    busy = true;
    message = null;
    notifyListeners();
    final top = git.topLevel ?? d;
    final made = await git.runner.run(['git', 'tag', '-a', name, '-m', '${projectDisplayName(top)} ${f.version}'], workingDirectory: d);
    if (!made.ok) {
      busy = false;
      messageOk = false;
      message = made.combined.trim().split('\n').last;
      notifyListeners();
      return false;
    }
    final pushed = await git.runner.run(['git', 'push', 'origin', name], workingDirectory: d);
    busy = false;
    messageOk = pushed.ok;
    tagged = pushed.ok;
    message = pushed.ok ? CurrentL10n.value.releaseTagged(name) : CurrentL10n.value.releaseTagPushFailed(pushed.combined.trim().split('\n').last);
    notifyListeners();
    return pushed.ok;
  }
}

/// 태그 메시지에 쓸 표시 이름 (conventions/identity.md §2): `lib/app_identity.dart`의 displayName,
/// 없으면 macOS `PRODUCT_NAME`, 그것도 없으면 pubspec의 `name`, 마지막으로 폴더 이름.
String projectDisplayName(String top) {
  String? read(String rel, RegExp re) {
    final f = File('$top${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}');
    if (!f.existsSync()) return null;
    return re.firstMatch(f.readAsStringSync())?[1]?.trim();
  }

  return read('lib/app_identity.dart', RegExp(r"displayName\s*=\s*'([^']+)'")) ??
      read('macos/Runner/Configs/AppInfo.xcconfig', RegExp(r'^PRODUCT_NAME\s*=\s*(.+)$', multiLine: true)) ??
      read('pubspec.yaml', RegExp(r'^name:\s*(\S+)', multiLine: true)) ??
      top.split(RegExp(r'[/\\]')).last;
}
