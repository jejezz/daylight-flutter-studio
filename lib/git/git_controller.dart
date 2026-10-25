import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../l10n/current_l10n.dart';
import '../core/command_runner.dart';
import '../github/pull_request.dart';
import '../settings/gate_settings.dart';
import '../verify/verify_state.dart';
import '../verify/verify_store.dart';
import 'status.dart';

enum PrMergeMethod { merge, squash, rebase }

/// Git 패널의 상태: 작업 폴더의 git 상태, 현재 브랜치의 PR, 그 PR head 커밋의 검증 판정.
class GitController extends ChangeNotifier {
  GitController({required this.runner, required this.store, this.gate});

  final CommandRunner runner;
  final VerifyStore store;

  /// 병합 관문 설정. 없으면 관문 없이 병합할 수 있다.
  final GateSettings? gate;

  String? dir;

  /// 작업 폴더(worktree)의 최상위 경로 (이 OS의 구분자). 변경 파일의 상대 경로를 절대 경로로 바꿀 때 쓴다.
  String? topLevel;

  /// git 저장소가 아니거나 읽지 못하면 null.
  RepoStatus? status;
  RepoSnapshot? snapshot;

  /// 현재 브랜치의 PR (열렸거나 병합된 것). 없으면 null.
  PullRequest? pr;

  /// PR의 head 커밋. 병합되는 것은 이 커밋이다.
  String? prHeadSha;

  /// `gh`를 실행할 수 없다.
  bool ghMissing = false;

  VerifyVerdict? verdict;
  bool busy = false;

  /// 마지막 동작의 결과 한 줄과 성공 여부. 화면이 보여 준다.
  String? message;
  bool messageOk = true;

  static const _prFields = '${PullRequest.jsonFields},headRefOid';

  /// 로컬 HEAD와 PR head가 다르다 — 아직 push하지 않았거나 원격이 앞서 있다.
  bool get localDiffersFromPr {
    final head = status?.oid;
    final remote = prHeadSha;
    return pr != null && pr!.open && head != null && remote != null && head != remote;
  }

  Future<void> setDir(String? value) async {
    dir = value;
    status = null;
    snapshot = null;
    pr = null;
    prHeadSha = null;
    verdict = null;
    message = null;
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    final d = dir;
    if (d == null) return;
    final s = await runner.run(['git', 'status', '--porcelain=v2', '--branch', '-z'], workingDirectory: d, quiet: true);
    if (dir != d) return;
    status = s.ok ? RepoStatus.parse(s.stdout) : null;
    snapshot = status == null ? null : await store.snapshot(d);
    topLevel = status == null ? null : await _topLevel(d);
    await _loadPr();
    await _judge();
    notifyListeners();
  }

  Future<String?> _topLevel(String d) async {
    final r = await runner.run(['git', 'rev-parse', '--show-toplevel'], workingDirectory: d, quiet: true);
    final out = r.stdout.trim();
    if (!r.ok || out.isEmpty) return null;
    return out.replaceAll('/', Platform.pathSeparator);
  }

  /// 변경 파일의 저장소 기준 상대 경로를 절대 경로로 바꾼다. 최상위 경로를 모르면 null.
  String? absolutePath(String relative) {
    final top = topLevel;
    if (top == null) return null;
    final sep = Platform.pathSeparator;
    return '$top$sep${relative.replaceAll('/', sep)}';
  }

  Future<void> _loadPr() async {
    pr = null;
    prHeadSha = null;
    final branch = status?.head;
    final d = dir;
    if (branch == null || d == null) return;
    final r = await runner.run(['gh', 'pr', 'view', branch, '--json', _prFields], workingDirectory: d, quiet: true);
    ghMissing = r.exitCode == 127;
    if (!r.ok) return;
    final found = PullRequest.parse(r.stdout);
    if (found == null || found.headRef != branch || found.state == PrState.closed) return;
    pr = found;
    try {
      prHeadSha = (jsonDecode(r.stdout) as Map<String, dynamic>)['headRefOid'] as String?;
    } on FormatException {
      prHeadSha = null;
    }
  }

  Future<void> _judge() async {
    final snap = snapshot;
    final d = dir;
    if (snap == null || d == null) {
      verdict = null;
      return;
    }
    final head = prHeadSha ?? snap.sha;
    verdict = await judgeVerification(
      headSha: head,
      branch: pr?.headRef ?? snap.branch,
      records: await store.readAll(snap.commonDir),
      commitsBetween: (from, to) async {
        final r = await runner.run(['git', 'rev-list', '--count', '$from..$to'], workingDirectory: d, quiet: true);
        return r.ok ? int.tryParse(r.stdout.trim()) : null;
      },
    );
  }

  /// 마지막 커밋의 제목 — PR 제목의 기본값.
  Future<String> lastCommitSubject() async {
    final d = dir;
    if (d == null) return '';
    final r = await runner.run(['git', 'log', '-1', '--format=%s'], workingDirectory: d, quiet: true);
    return r.ok ? r.stdout.trim() : '';
  }

  /// PR의 base로 쓸 기본 브랜치.
  Future<String> defaultBranch() async {
    final d = dir;
    if (d != null) {
      final r = await runner.run(['git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD'], workingDirectory: d, quiet: true);
      final name = r.stdout.trim();
      if (r.ok && name.startsWith('origin/')) return name.substring('origin/'.length);
    }
    return 'main';
  }

  Future<bool> fetch() => _do(['git', 'fetch', '--prune'], done: CurrentL10n.value.gitDoneFetch);

  Future<bool> pull() {
    if (status?.behind == 0 || !(status?.clean ?? false)) return Future.value(false);
    return _do(['git', 'pull', '--ff-only'], done: CurrentL10n.value.gitDonePull);
  }

  Future<bool> push() {
    final s = status;
    if (s?.head == null) return Future.value(false);
    return _do(
      s!.hasUpstream ? ['git', 'push'] : ['git', 'push', '-u', 'origin', s.head!],
      done: CurrentL10n.value.gitDonePush,
    );
  }

  Future<bool> createPr(String title, {bool draft = false}) async {
    final s = status;
    if (s?.head == null || title.trim().isEmpty) return false;
    return _do(
      ['gh', 'pr', 'create', '--base', await defaultBranch(), '--head', s!.head!, '--title', title.trim(), '--body-file', '-', if (draft) '--draft'],
      stdin: '',
      done: CurrentL10n.value.gitDonePrCreated,
    );
  }

  /// PR을 병합한다. worktree에서는 기본 브랜치로 전환하지 않는다 — 다른 폴더가 이미 쓰고 있을 수 있다.
  /// 지금 병합해도 되는지. 관문 설정이 없으면 항상 허용한다.
  GateDecision get gateDecision => gate?.decide(verdict) ?? const GateDecision.allow();

  /// 검증 기록만 다시 읽어 판정을 새로 한다 (`gh`나 git 상태는 다시 부르지 않는다).
  /// Run 탭에서 "확인함"을 누른 직후처럼 기록만 바뀐 경우에 쓴다.
  Future<void> refreshVerdict() async {
    await _judge();
    notifyListeners();
  }

  /// PR을 병합한다. 관문이 막으면(또는 확인이 필요하면) [overrideGate]가 true일 때만 병합한다 —
  /// 화면이 사용자의 명시적 확인("검증 없이 병합")을 받은 뒤에만 true로 부른다.
  Future<bool> merge(PrMergeMethod method, {bool deleteBranch = true, bool overrideGate = false}) async {
    final number = pr?.number;
    if (number == null) return false;
    // 화면의 판정이 낡았을 수 있으니, 병합 직전에 기록을 다시 읽어 판정한다.
    await _judge();
    final decision = gateDecision;
    if (!decision.allowed && !overrideGate) {
      messageOk = false;
      message = CurrentL10n.value.gitNotMerged(decision.message);
      notifyListeners();
      return false;
    }
    final overridden = !decision.allowed;
    return _do(
      ['gh', 'pr', 'merge', '$number', '--${method.name}', if (deleteBranch) '--delete-branch'],
      done: overridden ? CurrentL10n.value.gitDoneMergedUnverified(number) : CurrentL10n.value.gitDoneMerged(number),
    );
  }

  Future<bool> _do(List<String> args, {String? stdin, required String done}) async {
    final d = dir;
    if (d == null || busy) return false;
    busy = true;
    message = null;
    notifyListeners();
    final r = await runner.run(args, workingDirectory: d, stdin: stdin);
    ghMissing = r.exitCode == 127 && args.first == 'gh';
    messageOk = r.ok;
    message = r.ok ? done : _failure(r);
    busy = false;
    await refresh();
    return r.ok;
  }

  static String _failure(CommandResult r) {
    if (r.exitCode == 127) return CurrentL10n.value.gitCommandNotFound;
    final lines = r.combined.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.isEmpty ? CurrentL10n.value.gitFailedExit(r.exitCode) : lines.last.trim();
  }
}
