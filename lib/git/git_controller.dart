import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../l10n/current_l10n.dart';
import '../core/command_runner.dart';
import '../github/pull_request.dart';
import '../settings/gate_settings.dart';
import '../verify/verify_state.dart';
import '../verify/verify_store.dart';
import 'operation.dart';
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

  /// 끝나지 않은 병합·rebase 등. 있으면 화면이 계속·건너뛰기·중단을 보여 준다.
  RepoOperation operation = RepoOperation.none;

  /// 병합·rebase를 이어 가거나 멈춰서 작업 폴더의 파일이 바뀌었을 때 부른다 (열린 파일·트리를 새로 읽게 한다).
  VoidCallback? onFilesChanged;

  /// git 저장소가 아니거나 읽지 못하면 null.
  RepoStatus? status;
  RepoSnapshot? snapshot;

  /// 현재 브랜치의 PR (열렸거나 병합된 것). 없으면 null.
  PullRequest? pr;

  /// PR의 head 커밋. 병합되는 것은 이 커밋이다.
  String? prHeadSha;

  /// 기본 브랜치 이름 (원격 HEAD 기준, 모르면 'main'). `refresh()`마다 다시 읽는다 —
  /// 지금 브랜치가 기본 브랜치 자신이면 PR 만들기를 보여 주지 않는 데 쓴다.
  String defaultBranchName = 'main';

  /// `gh`를 실행할 수 없다.
  bool ghMissing = false;

  VerifyVerdict? verdict;
  bool busy = false;

  /// 마지막 동작의 결과 한 줄과 성공 여부. 화면이 보여 준다.
  String? message;
  bool messageOk = true;

  static const _prFields = '${PullRequest.jsonFields},headRefOid';

  /// 지금 브랜치가 기본 브랜치 자신이다 — 여기서는 PR을 만들 수 없다(자기 자신에게 PR).
  bool get onDefaultBranch => status?.head != null && status!.head == defaultBranchName;

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
    operation = status == null ? RepoOperation.none : await readRepoOperation(runner, d);
    defaultBranchName = await defaultBranch();
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

  /// 지금 rebase 중인지 (충돌 해결 시트가 "내 것/들어오는 것" 쪽을 맞게 보여 주는 데 쓴다).
  Future<bool> isRebasing() {
    final d = dir;
    return d == null ? Future.value(false) : readRepoOperation(runner, d).then((op) => op == RepoOperation.rebasing);
  }

  /// 충돌 구간을 골라 다시 쓴 파일을 `git add`로 해결됨 표시한다. 보통의 스테이지에도 쓴다.
  Future<bool> stage(FileChange file, {String? done}) =>
      _do(['git', 'add', '--', file.path], done: done ?? CurrentL10n.value.doneConflictResolved(file.fileName));

  Future<bool> unstage(FileChange file) => _doSteps([
    ['git', 'restore', '--staged', '--', file.path],
  ], done: CurrentL10n.value.gitDoneUnstaged);

  Future<bool> stageAll() => _doSteps([
    ['git', 'add', '-A'],
  ], done: CurrentL10n.value.gitDoneStaged);

  Future<bool> unstageAll() => _doSteps([
    ['git', 'restore', '--staged', '--', '.'],
  ], done: CurrentL10n.value.gitDoneUnstaged);

  /// 스테이지된 변경이 없으면 먼저 전부 스테이지한 뒤 커밋한다(Branch Dock과 같은 편의).
  Future<bool> commit(String message) {
    final s = status;
    final text = message.trim();
    if (s == null || text.isEmpty || s.clean) return Future.value(false);
    final stageAll = s.staged.isEmpty;
    return _doSteps([
      if (stageAll) ['git', 'add', '-A'],
      ['git', 'commit', '-m', text],
    ], done: CurrentL10n.value.gitDoneCommit);
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

  /// 끝나지 않은 작업(병합·rebase)을 이어 간다. 충돌이 남아 있으면 git이 거부한다.
  Future<bool> continueOperation() async {
    final cmd = OperationCommands.continueWith(operation);
    if (cmd == null) return false;
    final ok = await _do(cmd, done: CurrentL10n.value.opDoneContinue);
    if (ok) onFilesChanged?.call();
    return ok;
  }

  /// rebase 중 지금 커밋을 건너뛴다.
  Future<bool> skipOperation() async {
    if (operation != RepoOperation.rebasing) return false;
    final ok = await _do(OperationCommands.rebaseSkip, done: CurrentL10n.value.opDoneSkip);
    if (ok) onFilesChanged?.call();
    return ok;
  }

  /// 작업을 중단하고 시작 전 상태로 되돌린다.
  Future<bool> abortOperation() async {
    final cmd = OperationCommands.abort(operation);
    if (cmd == null) return false;
    final ok = await _do(cmd, done: CurrentL10n.value.opDoneAbort);
    if (ok) onFilesChanged?.call();
    return ok;
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

  /// [steps]를 순서대로 실행하고 하나라도 실패하면 거기서 멈춘다 (예: 스테이지 → 커밋).
  Future<bool> _doSteps(List<List<String>> steps, {required String done}) async {
    final d = dir;
    if (d == null || busy || steps.isEmpty) return false;
    busy = true;
    message = null;
    notifyListeners();
    var r = const CommandResult(0, '', '');
    for (final args in steps) {
      r = await runner.run(args, workingDirectory: d);
      if (!r.ok) break;
    }
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
