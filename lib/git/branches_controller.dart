import 'package:flutter/foundation.dart';

import '../core/command_runner.dart';
import '../l10n/current_l10n.dart';
import '../studio/worktree.dart';
import 'branch_commands.dart';
import 'error_hints.dart';
import 'refs.dart';

/// 브랜치 탭의 상태: 로컬·원격 브랜치 목록, worktree가 쥔 브랜치, 그리고 만들기·전환·이름 바꾸기·삭제.
///
/// 명령은 `LC_ALL=C`로 실행해 git 오류를 영어 원문으로 받아 [classifyError]로 알아본다.
class BranchesController extends ChangeNotifier {
  BranchesController({required this.runner, Future<List<Worktree>> Function(String dir)? listWorktrees})
    : _listWorktrees = listWorktrees ?? Worktree.list;

  final CommandRunner runner;
  final Future<List<Worktree>> Function(String dir) _listWorktrees;

  String? dir;
  List<Branch> branches = const [];
  List<Worktree> worktrees = const [];
  bool loading = false;
  bool busy = false;

  /// 마지막 동작의 결과 한 줄과 성공 여부.
  String? message;
  bool messageOk = true;

  /// 마지막 실패의 종류. 화면이 "병합되지 않음 → 그래도 삭제" 같은 후속 선택을 보여 줄 때 쓴다.
  GitErrorKind? errorKind;

  /// 다른 worktree가 브랜치를 쥐고 있어 실패했다면 그 worktree 폴더 (화면이 "그 worktree 열기"를 보여 줄 때 쓴다).
  String? blockingWorktreePath;

  /// 브랜치가 바뀌었을 때(전환·만들기·이름 바꾸기·삭제) 부른다. 작업 폴더의 파일과 HEAD가 바뀌었을 수 있다.
  VoidCallback? onChanged;

  static const _env = {'LC_ALL': 'C'};

  List<Branch> get local => [for (final b in branches) if (!b.remote) b];
  List<Branch> get remote => [for (final b in branches) if (b.remote) b];
  Branch? get current => branches.where((b) => b.current && !b.remote).firstOrNull;

  /// 이 폴더가 아닌 **다른** worktree가 [branch]를 쥐고 있으면 그 worktree. 전환·삭제가 거부되는 경우다.
  Worktree? worktreeHolding(String branch) {
    final here = worktrees.where((w) => w.branch == branch);
    final mineIsCurrent = current?.name == branch;
    for (final w in here) {
      if (!mineIsCurrent || !_isThisWorktree(w)) return w;
    }
    return null;
  }

  bool _isThisWorktree(Worktree w) {
    final d = dir;
    if (d == null) return false;
    String key(String p) => p.replaceAll(r'\', '/').toLowerCase();
    return key(d) == key(w.path) || key(d).startsWith('${key(w.path)}/');
  }

  Future<void> setDir(String? value) async {
    dir = value;
    branches = const [];
    worktrees = const [];
    message = null;
    errorKind = null;
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    final d = dir;
    if (d == null) return;
    loading = true;
    notifyListeners();
    final r = await runner.run(BranchCommands.list, workingDirectory: d, quiet: true, environment: _env);
    if (dir != d) return;
    branches = r.ok ? Branch.parse(r.stdout) : const [];
    worktrees = await _listWorktrees(d);
    loading = false;
    notifyListeners();
  }

  // --- 동작 ---------------------------------------------------------------

  /// 로컬 브랜치면 그 브랜치로, 원격 브랜치면 로컬 추적 브랜치를 만들어 전환한다.
  Future<bool> switchTo(Branch b) => _run(
    b.remote ? BranchCommands.switchTrack(b.name) : BranchCommands.switchTo(b.name),
    done: CurrentL10n.value.branchDoneSwitch(b.remote ? b.shortName : b.name),
    branchNames: [b.remote ? b.shortName : b.name],
  );

  Future<bool> create(String name, {String? base, bool switchAfter = true}) => _run(
    BranchCommands.create(name, base: base, switchAfter: switchAfter),
    done: CurrentL10n.value.branchDoneCreate(name),
    branchNames: [name],
  );

  Future<bool> rename(String from, String to) => _run(
    BranchCommands.rename(from, to),
    done: CurrentL10n.value.branchDoneRename(from, to),
    branchNames: [from, to],
  );

  /// [force]가 아니면 병합된 브랜치만 지운다. 병합되지 않았으면 false이고 [errorKind]가
  /// [GitErrorKind.branchNotMerged]가 되어, 화면이 "그래도 삭제"를 물을 수 있다.
  Future<bool> deleteLocal(String name, {bool force = false}) => _run(
    BranchCommands.delete(name, force: force),
    done: CurrentL10n.value.branchDoneDelete(name),
    branchNames: [name],
  );

  Future<bool> deleteRemote(Branch b) {
    final remoteName = b.remoteName;
    if (!b.remote || remoteName == null) return Future.value(false);
    return _run(
      BranchCommands.deleteRemote(remoteName, b.shortName),
      done: CurrentL10n.value.branchDoneDeleteRemote(b.name),
      branchNames: [b.shortName],
    );
  }

  Future<bool> _run(List<String> args, {required String done, required List<String> branchNames}) async {
    final d = dir;
    if (d == null || busy) return false;
    busy = true;
    message = null;
    errorKind = null;
    blockingWorktreePath = null;
    notifyListeners();
    final r = await runner.run(args, workingDirectory: d, environment: _env);
    messageOk = r.ok;
    if (r.ok) {
      message = done;
    } else {
      errorKind = classifyError(r.combined, exitCode: r.exitCode);
      if (errorKind == GitErrorKind.branchInOtherWorktree) blockingWorktreePath = worktreePathFromError(r.combined);
      message = _failure(r, errorKind, branchNames);
    }
    busy = false;
    await refresh();
    if (r.ok) onChanged?.call();
    return r.ok;
  }

  /// 실패를 사용자가 이해할 한 줄로 바꾼다. 모르는 오류는 git의 마지막 줄을 그대로 보여 준다.
  static String _failure(CommandResult r, GitErrorKind? kind, List<String> names) {
    final l10n = CurrentL10n.value;
    final name = names.isEmpty ? '' : names.first;
    switch (kind) {
      case GitErrorKind.branchInOtherWorktree:
        return l10n.branchErrInOtherWorktree(name, worktreePathFromError(r.combined) ?? '');
      case GitErrorKind.localChangesWouldBeOverwritten:
        return l10n.branchErrLocalChanges;
      case GitErrorKind.branchNotMerged:
        return l10n.branchErrNotMerged(name);
      case GitErrorKind.alreadyExists:
        return l10n.branchErrExists(name);
      case GitErrorKind.authFailed:
      case GitErrorKind.network:
      case GitErrorKind.repositoryNotFound:
        return l10n.branchErrRemote;
      case GitErrorKind.notInstalled:
        return l10n.branchErrNoGit;
      default:
        final lines = r.combined.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
        return lines.isEmpty ? l10n.branchErrGeneric('${r.exitCode}') : lines.last.trim();
    }
  }
}
