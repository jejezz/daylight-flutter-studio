import 'package:daylight_flutter_studio/verify/verify_state.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter_test/flutter_test.dart';

VerifyRecord _rec(String sha, VerifyStatus status, {String branch = 'feat', int minute = 0}) => VerifyRecord(
  sha: sha,
  branch: branch,
  mode: 'debug',
  target: 'windows',
  status: status,
  at: DateTime(2026, 10, 25, 12, minute),
);

void main() {
  test('기록이 없으면 unverified', () async {
    final v = await judgeVerification(headSha: 'a', branch: 'feat', records: const []);
    expect(v.state, VerifyState.unverified);
    expect(v.passes, isFalse);
  });

  test('head 커밋을 확인했으면 verified', () async {
    final v = await judgeVerification(headSha: 'a', branch: 'feat', records: [_rec('a', VerifyStatus.confirmed)]);
    expect(v.state, VerifyState.verified);
    expect(v.passes, isTrue);
  });

  test('빌드만 했으면 builtOnly이고 통과하지 못한다', () async {
    final v = await judgeVerification(headSha: 'a', branch: 'feat', records: [_rec('a', VerifyStatus.built)]);
    expect(v.state, VerifyState.builtOnly);
    expect(v.passes, isFalse);
  });

  test('문제가 있다고 기록했으면 problem', () async {
    final v = await judgeVerification(headSha: 'a', branch: 'feat', records: [_rec('a', VerifyStatus.problem)]);
    expect(v.state, VerifyState.problem);
  });

  test('같은 sha의 기록은 가장 나중 것을 쓴다', () async {
    final v = await judgeVerification(
      headSha: 'a',
      branch: 'feat',
      records: [_rec('a', VerifyStatus.problem, minute: 1), _rec('a', VerifyStatus.confirmed, minute: 2)],
    );
    expect(v.state, VerifyState.verified);
  });

  test('이전 커밋만 확인했으면 stale이고 커밋 수를 알려 준다', () async {
    final v = await judgeVerification(
      headSha: 'b',
      branch: 'feat',
      records: [_rec('a', VerifyStatus.confirmed)],
      commitsBetween: (from, to) async => from == 'a' && to == 'b' ? 2 : null,
    );
    expect(v.state, VerifyState.stale);
    expect(v.commitsSince, 2);
    expect(v.passes, isFalse);
  });

  test('다른 브랜치의 기록은 stale 근거가 아니다', () async {
    final v = await judgeVerification(headSha: 'b', branch: 'feat', records: [_rec('a', VerifyStatus.confirmed, branch: 'other')]);
    expect(v.state, VerifyState.unverified);
  });

  test('이전 커밋이 빌드만 된 것은 stale이 아니다', () async {
    final v = await judgeVerification(headSha: 'b', branch: 'feat', records: [_rec('a', VerifyStatus.built)]);
    expect(v.state, VerifyState.unverified);
  });
}
