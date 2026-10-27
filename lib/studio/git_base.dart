import '../core/command_runner.dart';

/// 파일을 비교할 기준(git HEAD)의 글.
class GitBase {
  const GitBase.unavailable() : available = false, text = '', isNew = false;
  const GitBase.tracked(this.text) : available = true, isNew = false;

  /// 아직 커밋되지 않은 새 파일 — 기준은 빈 글이라 모든 줄이 추가로 보인다.
  const GitBase.newFile() : available = true, text = '', isNew = true;

  /// git 저장소가 아니거나 `.gitignore`로 무시되는 파일이면 false (변경 표시를 하지 않는다).
  final bool available;
  final String text;
  final bool isNew;
}

/// 비교 기준으로 쓸 수 있는 이름: 브랜치·태그·해시와 `HEAD~1`, `origin/main`, `@` 꼴. Windows에서는 명령이 셸을 거치므로(`cmd`)
/// 셸 문자(`&`, `|`, `^`, `%` 등)와 옵션처럼 보이는 `-`로 시작하는 이름은 처음부터 받지 않는다.
final _safeRef = RegExp(r'^[A-Za-z0-9._/@~+][A-Za-z0-9._/@~+-]*$');

/// 비교 기준으로 고를 수 있는 것들: 브랜치(로컬·원격)와 최근 커밋.
class CompareChoices {
  const CompareChoices({this.branches = const [], this.commits = const []});

  final List<String> branches;
  final List<({String hash, String subject})> commits;

  bool get isEmpty => branches.isEmpty && commits.isEmpty;
}

/// 열린 파일의 HEAD 커밋 내용을 읽는다 (`git show HEAD:./이름`).
/// 파일이 있는 폴더에서 실행하므로 worktree와 하위 폴더 어디서든 같은 방식으로 동작한다.
class GitBaseReader {
  GitBaseReader(this.runner);

  final CommandRunner runner;

  Future<GitBase> read(String path) async {
    final sep = path.lastIndexOf(RegExp(r'[/\\]'));
    if (sep < 0) return const GitBase.unavailable();
    final dir = path.substring(0, sep);
    final name = path.substring(sep + 1);

    Future<CommandResult> git(List<String> args) => runner.run(['git', ...args], workingDirectory: dir, quiet: true);

    final inside = await git(['rev-parse', '--is-inside-work-tree']);
    if (!inside.ok || inside.stdout.trim() != 'true') return const GitBase.unavailable();

    final tracked = await git(['ls-files', '--error-unmatch', '--', name]);
    if (tracked.ok) {
      final head = await git(['show', 'HEAD:./$name']);
      // HEAD에 없으면(스테이징만 한 새 파일, 커밋이 아직 없는 저장소) 새 파일로 본다.
      return head.ok ? GitBase.tracked(head.stdout) : const GitBase.newFile();
    }
    final ignored = await git(['check-ignore', '-q', '--', name]);
    return ignored.ok ? const GitBase.unavailable() : const GitBase.newFile();
  }

  /// 파일이 [ref](브랜치·태그·커밋 해시 등)에서 가졌던 내용. 그 시점에 파일이 없었으면 새 파일처럼 빈 글이고,
  /// [ref]가 없는 이름이면 `unavailable`이다.
  Future<GitBase> readAt(String path, String ref) async {
    if (!_safeRef.hasMatch(ref)) return const GitBase.unavailable();
    final sep = path.lastIndexOf(RegExp(r'[/\\]'));
    if (sep < 0) return const GitBase.unavailable();
    final dir = path.substring(0, sep);
    final name = path.substring(sep + 1);

    Future<CommandResult> git(List<String> args) => runner.run(['git', ...args], workingDirectory: dir, quiet: true);

    final known = await git(['rev-parse', '--verify', '--quiet', ref]);
    if (!known.ok) return const GitBase.unavailable();
    final shown = await git(['show', '$ref:./$name']);
    return shown.ok ? GitBase.tracked(shown.stdout) : const GitBase.newFile();
  }

  /// [path]가 있는 저장소의 브랜치와 최근 커밋 [commitCount]개.
  Future<CompareChoices> choices(String path, {int commitCount = 30}) async {
    final sep = path.lastIndexOf(RegExp(r'[/\\]'));
    if (sep < 0) return const CompareChoices();
    final dir = path.substring(0, sep);
    Future<CommandResult> git(List<String> args) => runner.run(['git', ...args], workingDirectory: dir, quiet: true);

    final heads = await git(['for-each-ref', '--format=%(refname:short)', 'refs/heads', 'refs/remotes']);
    final log = await git(['log', '-n', '$commitCount', '--format=%h%x09%s']);
    return CompareChoices(
      branches: heads.ok
          ? [for (final l in heads.stdout.split('\n')) if (l.trim().isNotEmpty && !l.trim().endsWith('/HEAD')) l.trim()]
          : const [],
      commits: log.ok
          ? [
              for (final l in log.stdout.split('\n'))
                if (l.contains('\t')) (hash: l.substring(0, l.indexOf('\t')), subject: l.substring(l.indexOf('\t') + 1).trim()),
            ]
          : const [],
    );
  }
}
