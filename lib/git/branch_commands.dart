/// 브랜치 탭이 실행하는 git 명령 인자. 실행 전에 "실행될 명령"으로 그대로 보여 주므로
/// 화면과 실행이 같은 함수를 쓴다 (Branch Dock의 `GitCommands`에서 브랜치 부분만 가져왔다).
library;

import 'refs.dart';

abstract final class BranchCommands {
  static const list = ['git', 'for-each-ref', '--format=$branchFormat', 'refs/heads', 'refs/remotes'];
  static const worktrees = ['git', 'worktree', 'list', '--porcelain'];

  static List<String> switchTo(String branch) => ['git', 'switch', branch];

  /// 원격 브랜치를 골랐을 때: 같은 이름의 로컬 추적 브랜치를 만들어 전환한다.
  static List<String> switchTrack(String remoteBranch) => ['git', 'switch', '--track', remoteBranch];

  static List<String> create(String name, {String? base, bool switchAfter = true}) =>
      switchAfter ? ['git', 'switch', '-c', name, ?base] : ['git', 'branch', name, ?base];

  static List<String> rename(String from, String to) => ['git', 'branch', '-m', from, to];

  /// [force]가 아니면 병합된 브랜치만 지운다(`-d`). 병합되지 않았으면 git이 거부한다.
  static List<String> delete(String name, {bool force = false}) => ['git', 'branch', force ? '-D' : '-d', name];

  static List<String> deleteRemote(String remote, String branch) => ['git', 'push', remote, '--delete', branch];
}
