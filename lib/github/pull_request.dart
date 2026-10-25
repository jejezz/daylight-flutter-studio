/// `gh pr view --json` 출력 모델 (branch-dock-flutter의 models.dart에서 PR 부분만 복사).
library;

import 'dart:convert';

Map<String, dynamic>? _obj(String json) {
  try {
    final v = jsonDecode(json);
    return v is Map<String, dynamic> ? v : null;
  } on FormatException {
    return null;
  }
}

List<dynamic> _list(String json) {
  try {
    final v = jsonDecode(json);
    return v is List ? v : const [];
  } on FormatException {
    return const [];
  }
}

DateTime? _date(Object? v) => v is String && v.isNotEmpty && !v.startsWith('0001') ? DateTime.tryParse(v) : null;

/// 검사(checks) 결과 요약.
class CheckSummary {
  const CheckSummary({this.passed = 0, this.failed = 0, this.pending = 0, this.failedNames = const []});

  final int passed;
  final int failed;
  final int pending;
  final List<String> failedNames;

  int get total => passed + failed + pending;

  /// statusCheckRollup: CheckRun(status, conclusion) 또는 StatusContext(state).
  static CheckSummary parse(List<dynamic> rollup) {
    var passed = 0, failed = 0, pending = 0;
    final names = <String>[];
    for (final item in rollup.whereType<Map<String, dynamic>>()) {
      final state = ((item['conclusion'] ?? item['state'] ?? '') as String).toUpperCase();
      final status = ((item['status'] ?? '') as String).toUpperCase();
      final name = (item['name'] ?? item['context'] ?? '') as String;
      if (status.isNotEmpty && status != 'COMPLETED') {
        pending++;
      } else if (const {'SUCCESS', 'NEUTRAL', 'SKIPPED'}.contains(state)) {
        passed++;
      } else if (const {'PENDING', 'EXPECTED', ''}.contains(state)) {
        pending++;
      } else {
        failed++;
        names.add(name);
      }
    }
    return CheckSummary(passed: passed, failed: failed, pending: pending, failedNames: names);
  }
}

enum PrState { open, merged, closed }

class PullRequest {
  const PullRequest({
    required this.number,
    required this.title,
    required this.url,
    required this.state,
    required this.headRef,
    required this.baseRef,
    this.draft = false,
    this.mergeable = 'UNKNOWN',
    this.mergeStateStatus = 'UNKNOWN',
    this.reviewDecision = '',
    this.checks = const CheckSummary(),
    this.mergeCommit,
    this.author = '',
    this.updated,
  });

  static const jsonFields =
      'number,title,url,state,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,headRefName,baseRefName,mergeCommit,author';

  /// 리뷰와 코멘트 (PLAN.md 3.9 P2).
  static const activityFields = 'reviews,comments';

  /// 목록용 (mergeable은 목록에서 계산 비용이 커서 뺀다).
  static const listFields =
      'number,title,url,state,isDraft,reviewDecision,statusCheckRollup,headRefName,baseRefName,author,updatedAt';

  final int number;
  final String title;
  final String url;
  final PrState state;
  final String headRef;
  final String baseRef;
  final bool draft;

  /// MERGEABLE / CONFLICTING / UNKNOWN
  final String mergeable;

  /// CLEAN / BLOCKED / BEHIND / DIRTY / UNSTABLE / HAS_HOOKS / UNKNOWN
  final String mergeStateStatus;

  /// APPROVED / CHANGES_REQUESTED / REVIEW_REQUIRED / ''
  final String reviewDecision;
  final CheckSummary checks;
  final String? mergeCommit;
  final String author;
  final DateTime? updated;

  bool get open => state == PrState.open;
  bool get merged => state == PrState.merged;
  bool get conflicting => mergeable == 'CONFLICTING' || mergeStateStatus == 'DIRTY';
  bool get reviewRequired => reviewDecision == 'REVIEW_REQUIRED' || reviewDecision == 'CHANGES_REQUESTED';

  /// 병합 버튼을 켤 수 있는가. BLOCKED(보호 규칙)여도 관리자는 병합할 수 있지만
  /// 그 판단은 gh에 맡기고, 알려진 막힘만 미리 보여 준다.
  bool get canMerge => open && !draft && !conflicting && checks.failed == 0 && checks.pending == 0;

  static PullRequest? parse(String json) {
    final m = _obj(json);
    return m == null ? null : fromJson(m);
  }

  static List<PullRequest> parseList(String json) =>
      _list(json).whereType<Map<String, dynamic>>().map(fromJson).toList();

  static PullRequest fromJson(Map<String, dynamic> m) => PullRequest(
        number: (m['number'] ?? 0) as int,
        title: (m['title'] ?? '') as String,
        url: (m['url'] ?? '') as String,
        state: switch ((m['state'] ?? '') as String) {
          'MERGED' => PrState.merged,
          'CLOSED' => PrState.closed,
          _ => PrState.open,
        },
        headRef: (m['headRefName'] ?? '') as String,
        baseRef: (m['baseRefName'] ?? '') as String,
        draft: (m['isDraft'] ?? false) as bool,
        mergeable: (m['mergeable'] ?? 'UNKNOWN') as String,
        mergeStateStatus: (m['mergeStateStatus'] ?? 'UNKNOWN') as String,
        reviewDecision: (m['reviewDecision'] ?? '') as String,
        checks: CheckSummary.parse((m['statusCheckRollup'] ?? const []) as List<dynamic>),
        mergeCommit: (m['mergeCommit'] as Map<String, dynamic>?)?['oid'] as String?,
        author: ((m['author'] as Map<String, dynamic>?)?['login'] ?? '') as String,
        updated: _date(m['updatedAt']),
      );
}

