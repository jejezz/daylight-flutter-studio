/// `git worktree list --porcelain` 한 항목: 폴더와 그 폴더에 체크아웃된 브랜치.
library;

import 'dart:io';

class Worktree {
  const Worktree({required this.path, this.branch, this.main = false});

  final String path;

  /// `refs/heads/`를 뗀 브랜치 이름. 분리된 HEAD면 null.
  final String? branch;

  /// 목록의 첫 항목(저장소를 처음 만든 작업 폴더).
  final bool main;

  /// Claude Code가 작업마다 만드는 폴더 (`<저장소>/.claude/worktrees/<이름>`).
  bool get byClaude => path.replaceAll(r'\', '/').contains('/.claude/worktrees/');

  String get name => path.split(RegExp(r'[/\\]')).where((s) => s.isNotEmpty).last;

  String get label => branch ?? '($name)';

  @override
  bool operator ==(Object other) => other is Worktree && other.path == path && other.branch == branch;

  @override
  int get hashCode => Object.hash(path, branch);

  static List<Worktree> parse(String output) {
    final result = <Worktree>[];
    for (final block in output.split(RegExp(r'\n\s*\n'))) {
      String? path;
      String? branch;
      for (final raw in block.split('\n')) {
        final line = raw.trimRight();
        if (line.startsWith('worktree ')) {
          final p = line.substring('worktree '.length);
          path = Platform.isWindows ? p.replaceAll('/', r'\') : p;
        } else if (line.startsWith('branch ')) {
          final ref = line.substring('branch '.length);
          branch = ref.startsWith('refs/heads/') ? ref.substring('refs/heads/'.length) : ref;
        }
      }
      if (path != null) result.add(Worktree(path: path, branch: branch, main: result.isEmpty));
    }
    return result;
  }

  /// [dir]이 속한 저장소의 worktree 목록. 저장소가 아니거나 git이 없으면 빈 목록.
  static Future<List<Worktree>> list(String dir) async {
    try {
      final r = await Process.run('git', ['worktree', 'list', '--porcelain'], workingDirectory: dir);
      return r.exitCode == 0 ? parse(r.stdout as String) : const [];
    } on ProcessException {
      return const [];
    }
  }
}

/// [path]를 포함하는 worktree 중 가장 깊은 것.
Worktree? worktreeContaining(List<Worktree> all, String path) {
  String norm(String p) => p.replaceAll(r'\', '/').toLowerCase();
  final target = norm(path);
  Worktree? best;
  for (final w in all) {
    final root = norm(w.path);
    final inside = target == root || target.startsWith('$root/');
    if (inside && (best == null || root.length > norm(best.path).length)) best = w;
  }
  return best;
}
