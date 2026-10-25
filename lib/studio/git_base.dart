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
}
