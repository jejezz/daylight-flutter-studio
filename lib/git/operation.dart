/// 끝나지 않은 git 작업(병합·rebase 등) 감지와, 그 작업을 이어 가거나 멈추는 명령.
library;

import 'dart:io';

import '../core/command_runner.dart';

/// 병합·rebase가 끝나지 않은 상태.
enum RepoOperation { none, merging, rebasing, cherryPicking, reverting }

/// [dir]이 속한 작업 폴더(worktree)의 진행 중인 작업. worktree마다 자기 git 폴더를 가지므로
/// `--absolute-git-dir`로 그 폴더를 찾는다 (상대 경로는 이 프로세스의 현재 폴더 기준이 되어 틀린다).
Future<RepoOperation> readRepoOperation(CommandRunner runner, String dir) async {
  final r = await runner.run(['git', 'rev-parse', '--absolute-git-dir'], workingDirectory: dir, quiet: true);
  final gitDir = r.stdout.trim();
  if (!r.ok || gitDir.isEmpty) return RepoOperation.none;
  bool exists(String name) => FileSystemEntity.typeSync('$gitDir${Platform.pathSeparator}$name') != FileSystemEntityType.notFound;
  if (exists('rebase-merge') || exists('rebase-apply')) return RepoOperation.rebasing;
  if (exists('MERGE_HEAD')) return RepoOperation.merging;
  if (exists('CHERRY_PICK_HEAD')) return RepoOperation.cherryPicking;
  if (exists('REVERT_HEAD')) return RepoOperation.reverting;
  return RepoOperation.none;
}

abstract final class OperationCommands {
  /// 병합을 마무리한다: 충돌을 모두 해결(스테이징)한 뒤에 쓴다. 메시지는 병합 때 정해진 그대로.
  static const mergeContinue = ['git', 'commit', '--no-edit'];
  static const mergeAbort = ['git', 'merge', '--abort'];

  // core.editor=true: git이 편집기를 띄우며 멈추지 않게 한다.
  static const rebaseContinue = ['git', '-c', 'core.editor=true', 'rebase', '--continue'];
  static const rebaseSkip = ['git', '-c', 'core.editor=true', 'rebase', '--skip'];
  static const rebaseAbort = ['git', 'rebase', '--abort'];

  static const cherryPickAbort = ['git', 'cherry-pick', '--abort'];
  static const revertAbort = ['git', 'revert', '--abort'];

  static List<String>? abort(RepoOperation op) => switch (op) {
    RepoOperation.merging => mergeAbort,
    RepoOperation.rebasing => rebaseAbort,
    RepoOperation.cherryPicking => cherryPickAbort,
    RepoOperation.reverting => revertAbort,
    RepoOperation.none => null,
  };

  /// "계속" 명령. 병합·rebase만 지원한다 (cherry-pick·revert는 중단만).
  static List<String>? continueWith(RepoOperation op) => switch (op) {
    RepoOperation.merging => mergeContinue,
    RepoOperation.rebasing => rebaseContinue,
    _ => null,
  };
}
