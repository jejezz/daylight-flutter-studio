import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/command_runner.dart';
import '../git/status.dart';
import '../github/pull_request.dart';
import '../settings/gate_settings.dart';
import 'verify_state.dart';
import 'verify_store.dart';

/// 병합 관문의 판정: 작업 폴더의 git 상태, 현재 브랜치의 PR, 그 PR head 커밋의 검증 판정.
///
/// 이전에는 Studio 자체 Git 패널(스테이지·커밋·push·PR·병합)의 컨트롤러였다. 그 기능은 Branch Dock 패널
/// (`lib/branchdock/`)이 맡으므로, 여기에는 Branch Dock의 PR 카드에 관문을 연결하는 데 필요한 읽기 전용 판정만 남았다
/// (`lib/ui/git_merge_gate.dart`가 연결한다).
class VerifyGateController extends ChangeNotifier {
  VerifyGateController({required this.runner, required this.store, this.gate});

  final CommandRunner runner;
  final VerifyStore store;

  /// 병합 관문 설정. 없으면 관문 없이 병합할 수 있다.
  final GateSettings? gate;

  String? dir;

  /// git 저장소가 아니거나 읽지 못하면 null.
  RepoStatus? status;
  RepoSnapshot? snapshot;

  /// 현재 브랜치의 PR (열렸거나 병합된 것). 없으면 null.
  PullRequest? pr;

  /// PR의 head 커밋. 병합되는 것은 이 커밋이다.
  String? prHeadSha;

  VerifyVerdict? verdict;

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
    await _loadPr();
    await _judge();
    notifyListeners();
  }

  Future<void> _loadPr() async {
    pr = null;
    prHeadSha = null;
    final branch = status?.head;
    final d = dir;
    if (branch == null || d == null) return;
    final r = await runner.run(['gh', 'pr', 'view', branch, '--json', _prFields], workingDirectory: d, quiet: true);
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

  /// 지금 병합해도 되는지. 관문 설정이 없으면 항상 허용한다.
  GateDecision get gateDecision => gate?.decide(verdict) ?? const GateDecision.allow();

  /// 검증 기록만 다시 읽어 판정을 새로 한다 (`gh`나 git 상태는 다시 부르지 않는다).
  /// Run 탭에서 "확인함"을 누른 직후처럼 기록만 바뀐 경우에 쓴다.
  Future<void> refreshVerdict() async {
    await _judge();
    notifyListeners();
  }
}
