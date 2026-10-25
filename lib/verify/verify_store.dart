/// 로컬 검증 기록 — 어느 커밋을 빌드했고 눈으로 확인했는지.
///
/// 커밋 sha가 키다: `<git-common-dir>/dock-verify/<sha>.json`. worktree와 메인 체크아웃이
/// 공유하는 `.git` 안이라 어느 폴더에서 열어도 같은 기록을 보고, 소스 트리는 건드리지 않는다.
/// Branch Dock 쪽 병합 관문이 같은 파일을 읽는다 — 형식을 바꾸면 [VerifyRecord.version]을 올린다.
library;

import 'dart:convert';
import 'dart:io';

import '../core/command_runner.dart';

enum VerifyStatus {
  /// 빌드·설치까지 성공. 눈으로 확인하지는 않았다.
  built,

  /// 사용자가 실행해 보고 괜찮다고 확인했다.
  confirmed,

  /// 확인했더니 문제가 있었다 ([VerifyRecord.note]에 메모).
  problem,
}

class VerifyRecord {
  const VerifyRecord({
    required this.sha,
    required this.branch,
    required this.mode,
    required this.target,
    required this.status,
    required this.at,
    this.note = '',
    this.app = 'Daylight Flutter Studio',
  });

  static const version = 1;

  final String sha;
  final String? branch;

  /// `debug` / `release`.
  final String mode;

  /// 빌드한 대상: `windows`, `macos`, `android`, `ios`.
  final String target;
  final VerifyStatus status;
  final DateTime at;
  final String note;
  final String app;

  VerifyRecord copyWith({VerifyStatus? status, String? note, DateTime? at}) => VerifyRecord(
    sha: sha,
    branch: branch,
    mode: mode,
    target: target,
    status: status ?? this.status,
    at: at ?? this.at,
    note: note ?? this.note,
    app: app,
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'sha': sha,
    'branch': branch,
    'mode': mode,
    'target': target,
    'status': status.name,
    'at': at.toIso8601String(),
    'note': note,
    'app': app,
  };

  static VerifyRecord? fromJson(Map<String, dynamic> m) {
    final status = VerifyStatus.values.asNameMap()[m['status']];
    final sha = m['sha'];
    if (status == null || sha is! String) return null;
    return VerifyRecord(
      sha: sha,
      branch: m['branch'] as String?,
      mode: (m['mode'] as String?) ?? '',
      target: (m['target'] as String?) ?? '',
      status: status,
      at: DateTime.tryParse((m['at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      note: (m['note'] as String?) ?? '',
      app: (m['app'] as String?) ?? '',
    );
  }
}

/// 작업 폴더의 git 상태 한 장면.
class RepoSnapshot {
  const RepoSnapshot({required this.sha, required this.branch, required this.dirty, required this.commonDir});

  final String sha;
  final String? branch;

  /// 커밋하지 않은 수정이 있다. 이 상태의 빌드는 어느 커밋의 것인지 말할 수 없어 기록하지 않는다.
  final bool dirty;
  final String commonDir;

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;
}

class VerifyStore {
  VerifyStore(this.runner);

  final CommandRunner runner;

  /// [dir]의 HEAD 커밋·브랜치·수정 여부. git 저장소가 아니면 null.
  Future<RepoSnapshot?> snapshot(String dir) async {
    final sha = await _git(dir, ['rev-parse', 'HEAD']);
    final common = await _git(dir, ['rev-parse', '--path-format=absolute', '--git-common-dir']);
    if (sha == null || common == null) return null;
    final branch = await _git(dir, ['symbolic-ref', '--quiet', '--short', 'HEAD']);
    final status = await runner.run(['git', 'status', '--porcelain'], workingDirectory: dir, quiet: true);
    if (!status.ok) return null;
    return RepoSnapshot(sha: sha, branch: branch, dirty: status.stdout.trim().isNotEmpty, commonDir: common);
  }

  Future<String?> _git(String dir, List<String> args) async {
    final r = await runner.run(['git', ...args], workingDirectory: dir, quiet: true);
    final out = r.stdout.trim();
    return r.ok && out.isNotEmpty ? out : null;
  }

  File _file(String commonDir, String sha) =>
      File('$commonDir${Platform.pathSeparator}dock-verify${Platform.pathSeparator}$sha.json');

  Future<VerifyRecord?> read(String commonDir, String sha) async {
    try {
      final f = _file(commonDir, sha);
      if (!await f.exists()) return null;
      return VerifyRecord.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> write(String commonDir, VerifyRecord record) async {
    final f = _file(commonDir, record.sha);
    await f.parent.create(recursive: true);
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(record.toJson()));
  }
}
