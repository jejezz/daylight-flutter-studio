import '../l10n/current_l10n.dart';
import '../core/command_runner.dart';
import 'diagnostic.dart';

/// 패키지 폴더에서 `dart analyze --format=json`을 실행해 문제 목록을 읽는다.
class DartAnalyzer {
  DartAnalyzer(this.runner);

  final CommandRunner runner;

  Future<AnalyzeResult> run(String packageRoot) async {
    final r = await runner.run(['dart', 'analyze', '--format=json'], workingDirectory: packageRoot, quiet: true);
    if (r.exitCode == 127) {
      return AnalyzeResult.failed(CurrentL10n.value.formatNoDart);
    }
    // 문제가 있으면 종료 코드가 0이 아니다 — 출력이 읽히면 결과로 본다.
    final parsed = parseAnalyzeJson(r.stdout);
    if (parsed != null) return AnalyzeResult.ok(parsed);
    final detail = r.combined.split('\n').map((l) => l.trim()).firstWhere((l) => l.isNotEmpty, orElse: () => '');
    return AnalyzeResult.failed(detail.isEmpty ? CurrentL10n.value.analyzeFailedRead : CurrentL10n.value.analyzeFailedDetail(detail));
  }

  /// `flutter pub get`. 새 worktree처럼 패키지 정보가 없는 폴더에서 분석·빌드 전에 필요하다.
  Future<bool> pubGet(String packageRoot) async {
    final r = await runner.run(['flutter', 'pub', 'get'], workingDirectory: packageRoot);
    return r.ok;
  }
}
