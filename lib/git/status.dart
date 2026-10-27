/// `git status --porcelain=v2 --branch -z`에서 헤더(브랜치·HEAD 커밋)만 읽는다.
/// 변경 파일 목록은 Branch Dock 패널이 읽으므로 여기서는 파싱하지 않는다.
/// https://git-scm.com/docs/git-status#_porcelain_format_version_2
library;

class RepoStatus {
  const RepoStatus({this.head, this.oid});

  /// 현재 브랜치 이름. 분리된 HEAD면 null.
  final String? head;

  /// HEAD 커밋. 아직 커밋이 없으면 null.
  final String? oid;

  static RepoStatus parse(String output) {
    String? head;
    String? oid;
    for (final r in output.split('\x00')) {
      if (!r.startsWith('# ')) continue;
      final header = r.substring(2);
      if (header.startsWith('branch.oid ')) {
        final v = header.substring(11);
        oid = v == '(initial)' ? null : v;
      } else if (header.startsWith('branch.head ')) {
        final v = header.substring(12);
        head = v == '(detached)' ? null : v;
      }
    }
    return RepoStatus(head: head, oid: oid);
  }
}
