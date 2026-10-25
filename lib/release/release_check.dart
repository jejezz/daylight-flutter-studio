import '../verify/verify_state.dart';
import 'semver.dart';

/// 태그를 달기 전에 확인하는 것 (conventions/tagging.md §2 + 이 앱의 검증 관문).
enum ReleaseCheck {
  /// 작업 폴더에 커밋하지 않은 수정이 없다.
  cleanTree,

  /// 기본 브랜치(main)에 있다 — 작업 브랜치에는 태그를 달지 않는다.
  onDefaultBranch,

  /// 원격과 같다 (푸시·받기가 남아 있지 않다).
  synced,

  /// pubspec의 버전이 마지막 태그보다 높다 (버전 올림 커밋이 병합됐다).
  versionBumped,

  /// 같은 이름의 태그가 아직 없다.
  tagFree,

  /// 이 커밋(또는 병합된 PR의 head)을 빌드해서 눈으로 확인했다.
  verified,
}

/// 태그를 달기 위한 사실들. 화면·컨트롤러가 모으고, 판정은 [evaluateRelease]가 한다.
class ReleaseFacts {
  const ReleaseFacts({
    required this.clean,
    required this.branch,
    required this.defaultBranch,
    required this.hasUpstream,
    required this.ahead,
    required this.behind,
    required this.version,
    required this.lastTag,
    required this.tagExists,
    required this.verdict,
  });

  final bool clean;
  final String? branch;
  final String defaultBranch;
  final bool hasUpstream;
  final int ahead;
  final int behind;

  /// pubspec의 버전. 읽지 못하면 null.
  final SemVer? version;

  /// 이미 있는 가장 높은 정식·프리릴리스 태그. 없으면 null.
  final SemVer? lastTag;

  /// 만들려는 태그(`v<version>`)가 로컬이나 원격에 이미 있다.
  final bool tagExists;

  final VerifyVerdict? verdict;

  String? get tag => version?.tag;
}

/// 각 항목의 통과 여부. 순서는 [ReleaseCheck.values]를 따른다.
Map<ReleaseCheck, bool> evaluateRelease(ReleaseFacts f) {
  final v = f.version;
  final last = f.lastTag;
  return {
    ReleaseCheck.cleanTree: f.clean,
    ReleaseCheck.onDefaultBranch: f.branch != null && f.branch == f.defaultBranch,
    ReleaseCheck.synced: f.hasUpstream && f.ahead == 0 && f.behind == 0,
    ReleaseCheck.versionBumped: v != null && (last == null || v.compareTo(last) > 0),
    ReleaseCheck.tagFree: v != null && !f.tagExists,
    ReleaseCheck.verified: f.verdict?.passes ?? false,
  };
}
