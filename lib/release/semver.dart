/// `MAJOR.MINOR.PATCH[-prerelease][+build]` 버전 (conventions/versioning.md). 앞의 `v`는 있어도 없어도 된다.
class SemVer implements Comparable<SemVer> {
  const SemVer(this.major, this.minor, this.patch, [this.pre = const []]);

  final int major;
  final int minor;
  final int patch;

  /// 프리릴리스 식별자 (`rc.1` → [rc, 1]). 정식 버전이면 비어 있다.
  final List<String> pre;

  static final _re = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$');

  static SemVer? tryParse(String text) {
    final m = _re.firstMatch(text.trim());
    if (m == null) return null;
    return SemVer(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!), m[4] == null ? const [] : m[4]!.split('.'));
  }

  bool get isPrerelease => pre.isNotEmpty;

  /// 태그 이름. build number는 넣지 않는다.
  String get tag => 'v$this';

  @override
  String toString() => '$major.$minor.$patch${pre.isEmpty ? '' : '-${pre.join('.')}'}';

  @override
  int compareTo(SemVer other) {
    for (final (a, b) in [(major, other.major), (minor, other.minor), (patch, other.patch)]) {
      if (a != b) return a.compareTo(b);
    }
    // 프리릴리스는 같은 숫자의 정식 버전보다 낮다.
    if (pre.isEmpty || other.pre.isEmpty) return other.pre.isEmpty == pre.isEmpty ? 0 : (pre.isEmpty ? 1 : -1);
    for (var i = 0; i < pre.length && i < other.pre.length; i++) {
      final a = pre[i], b = other.pre[i];
      final an = int.tryParse(a), bn = int.tryParse(b);
      final c = an != null && bn != null ? an.compareTo(bn) : (an != null ? -1 : bn != null ? 1 : a.compareTo(b));
      if (c != 0) return c;
    }
    return pre.length.compareTo(other.pre.length);
  }

  @override
  bool operator ==(Object other) => other is SemVer && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, pre.join('.'));
}

/// `pubspec.yaml`의 `version:` (build number 제외). 없거나 읽을 수 없으면 null.
SemVer? pubspecVersion(String pubspecText) {
  final m = RegExp(r'^version:\s*([^\s#]+)', multiLine: true).firstMatch(pubspecText);
  return m == null ? null : SemVer.tryParse(m[1]!);
}
