/// PR의 head 커밋이 로컬에서 검증됐는지 판정한다. 병합·릴리스 관문(4단계)이 이 값을 쓴다.
library;

import 'verify_store.dart';

enum VerifyState {
  /// head 커밋을 실행해 보고 확인했다.
  verified,

  /// head 커밋을 빌드·설치까지만 했다. 눈으로 확인하지는 않았다.
  builtOnly,

  /// head 커밋을 확인했더니 문제가 있었다.
  problem,

  /// 같은 브랜치의 이전 커밋은 검증했지만 그 뒤에 커밋이 더해졌다.
  stale,

  /// 기록이 없다.
  unverified,
}

class VerifyVerdict {
  const VerifyVerdict(this.state, {this.record, this.commitsSince});

  final VerifyState state;

  /// 판정의 근거가 된 기록 (unverified면 null).
  final VerifyRecord? record;

  /// stale일 때, 검증한 커밋 뒤로 더해진 커밋 수 (알 수 없으면 null).
  final int? commitsSince;

  /// 병합해도 되는 상태인가. 빌드만 한 것은 눈으로 본 것이 아니므로 포함하지 않는다.
  bool get passes => state == VerifyState.verified;
}

/// [headSha]가 검증됐는지. [branch]는 이전 커밋의 기록을 찾는 데 쓴다.
/// [commitsBetween]은 두 커밋 사이의 커밋 수를 알려 준다 (stale일 때만 부른다).
Future<VerifyVerdict> judgeVerification({
  required String headSha,
  required String? branch,
  required List<VerifyRecord> records,
  Future<int?> Function(String fromSha, String toSha)? commitsBetween,
}) async {
  for (final r in records.reversed) {
    if (r.sha != headSha) continue;
    return VerifyVerdict(
      switch (r.status) {
        VerifyStatus.confirmed => VerifyState.verified,
        VerifyStatus.built => VerifyState.builtOnly,
        VerifyStatus.problem => VerifyState.problem,
      },
      record: r,
    );
  }
  if (branch != null) {
    for (final r in records.reversed) {
      if (r.branch != branch || r.status != VerifyStatus.confirmed) continue;
      return VerifyVerdict(VerifyState.stale, record: r, commitsSince: await commitsBetween?.call(r.sha, headSha));
    }
  }
  return const VerifyVerdict(VerifyState.unverified);
}
