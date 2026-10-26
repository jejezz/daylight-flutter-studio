/// 병합·rebase 시작 명령. 실행 전에 "실행될 명령"으로 그대로 보여 준다 (Branch Dock의 병합 시트와 같은 규칙).
library;

import 'commits.dart';

/// 다른 브랜치를 현재 브랜치로 합치는 방식.
enum MergeMode { fastForward, mergeCommit, squash, rebase }

abstract final class MergeCommands {
  /// [base]에 없는 [branch]의 커밋 (병합으로 들어올 커밋).
  static List<String> incoming(String branch, {String base = 'HEAD'}) =>
      ['git', 'log', '--format=$commitFormat', '$base..$branch'];

  /// rebase로 다시 쌓일 내 커밋: [onto]에 없는 현재 브랜치의 커밋.
  static List<String> replayed(String onto) => incoming('HEAD', base: onto);

  /// 종료 코드 0이면 [ancestor]가 [of]의 조상 — fast-forward 가능.
  static List<String> isAncestor(String ancestor, String of) => ['git', 'merge-base', '--is-ancestor', ancestor, of];

  /// squash는 병합 결과를 스테이징만 하므로 커밋이 한 번 더 필요하다.
  static List<List<String>> start(String source, MergeMode mode, {String message = ''}) => switch (mode) {
    MergeMode.fastForward => [
      ['git', 'merge', '--ff-only', source],
    ],
    MergeMode.mergeCommit => [
      ['git', 'merge', '--no-ff', if (message.isNotEmpty) ...['-m', message], '--no-edit', source],
    ],
    MergeMode.squash => [
      ['git', 'merge', '--squash', source],
      ['git', 'commit', '-m', message],
    ],
    MergeMode.rebase => [
      ['git', 'rebase', source],
    ],
  };
}
