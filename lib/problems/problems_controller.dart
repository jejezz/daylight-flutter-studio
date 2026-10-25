import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'diagnostic.dart';

import '../l10n/current_l10n.dart';

/// Dart 문제(오류·경고·정보) 목록의 상태. 패키지 하나를 `dart analyze`로 분석한 결과를 들고 있다.
///
/// 분석은 한 번에 하나만 돌고, 도는 중에 다시 요청되면 끝난 뒤 한 번 더 돈다.
/// 파일을 저장하면 잠시 뒤 자동으로 다시 분석한다.
class ProblemsController extends ChangeNotifier {
  ProblemsController({required this.analyze, required this.pubGet, this.saveDelay = const Duration(milliseconds: 800)});

  final Future<AnalyzeResult> Function(String packageRoot) analyze;
  final Future<bool> Function(String packageRoot) pubGet;
  final Duration saveDelay;

  String? packageRoot;
  List<Diagnostic> diagnostics = const [];
  bool running = false;

  /// 분석 자체가 실패한 이유 (dart를 못 찾음 등). 문제가 없다는 뜻이 아니다.
  String? error;

  /// 한 번이라도 분석을 마쳤는가 (아직 안 했으면 "문제 없음"이라고 말하지 않는다).
  bool analyzed = false;
  DateTime? lastRun;

  /// `flutter pub get` 실행 중.
  bool gettingPackages = false;

  bool _again = false;
  bool _disposed = false;
  Timer? _saveTimer;
  Map<String, Map<int, DiagnosticSeverity>> _byFile = const {};

  int count(DiagnosticSeverity s) => diagnostics.where((d) => d.severity == s).length;

  int get errors => count(DiagnosticSeverity.error);
  int get warnings => count(DiagnosticSeverity.warning);
  int get infos => count(DiagnosticSeverity.info);

  /// 패키지 정보(`.dart_tool/package_config.json`)가 없다 — 분석 결과에 가짜 오류가 섞인다.
  bool get needsPubGet {
    final root = packageRoot;
    if (root == null) return false;
    return !File('$root${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}package_config.json').existsSync();
  }

  /// 열린 폴더가 바뀔 때 부른다. 다른 패키지면 결과를 비우고 새로 분석한다.
  Future<void> setProjectDir(String? dir) async {
    final root = dir == null ? null : findPackageRoot(dir);
    if (root == packageRoot) return;
    packageRoot = root;
    diagnostics = const [];
    _byFile = const {};
    error = null;
    analyzed = false;
    notifyListeners();
    if (root != null) await refresh();
  }

  /// 지금 패키지를 분석한다. 이미 분석 중이면 끝난 뒤 한 번 더 한다.
  Future<void> refresh() async {
    final root = packageRoot;
    if (root == null) return;
    if (running) {
      _again = true;
      return;
    }
    running = true;
    notifyListeners();
    do {
      _again = false;
      final r = await analyze(root);
      if (_disposed) return;
      if (root != packageRoot) break; // 분석하는 사이 다른 패키지로 바뀌었다 — 이 결과는 버린다.
      if (r.ok) {
        diagnostics = r.diagnostics;
        error = null;
      } else {
        error = r.error;
      }
      _byFile = _index(diagnostics);
      analyzed = true;
      lastRun = DateTime.now();
    } while (_again && !_disposed);
    running = false;
    notifyListeners();
    // 분석하는 사이 다른 패키지로 바뀌었다면 새 패키지를 이어서 분석한다.
    if (!_disposed && packageRoot != null && packageRoot != root) await refresh();
  }

  /// 마지막 분석이 [age]보다 오래됐을 때만 다시 분석한다 (창이 다시 활성화될 때 쓴다).
  Future<void> refreshIfStale(Duration age) async {
    final last = lastRun;
    if (running || (last != null && DateTime.now().difference(last) < age)) return;
    await refresh();
  }

  /// 파일을 저장했을 때. Dart 파일이고 이 패키지 안에 있으면 잠시 뒤 다시 분석한다.
  void onSaved(String path) {
    final root = packageRoot;
    if (root == null || !path.endsWith('.dart')) return;
    if (!pathKey(path).startsWith('${pathKey(root)}/')) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, refresh);
  }

  /// `flutter pub get`을 돌린 뒤 다시 분석한다.
  Future<void> runPubGet() async {
    final root = packageRoot;
    if (root == null || gettingPackages) return;
    gettingPackages = true;
    notifyListeners();
    final ok = await pubGet(root);
    if (_disposed) return;
    gettingPackages = false;
    if (!ok) error = CurrentL10n.value.problemsPubGetFailed;
    notifyListeners();
    await refresh();
  }

  /// [path] 파일의 줄(1부터)별로 가장 심각한 문제. 편집기 줄 번호 옆 표시에 쓴다.
  Map<int, DiagnosticSeverity> linesFor(String path) => _byFile[pathKey(path)] ?? const {};

  /// 파일별로 묶은 문제 목록 (심각한 것·위쪽 줄 먼저). 파일은 경로 순서.
  Map<String, List<Diagnostic>> grouped({Set<DiagnosticSeverity>? only}) {
    final out = <String, List<Diagnostic>>{};
    for (final d in diagnostics) {
      if (only != null && !only.contains(d.severity)) continue;
      (out[d.file] ??= []).add(d);
    }
    for (final list in out.values) {
      list.sort((a, b) {
        final bySeverity = b.severity.rank - a.severity.rank;
        return bySeverity != 0 ? bySeverity : (a.line != b.line ? a.line - b.line : a.column - b.column);
      });
    }
    final keys = out.keys.toList()..sort((a, b) => pathKey(a).compareTo(pathKey(b)));
    return {for (final k in keys) k: out[k]!};
  }

  static Map<String, Map<int, DiagnosticSeverity>> _index(List<Diagnostic> all) {
    final out = <String, Map<int, DiagnosticSeverity>>{};
    for (final d in all) {
      final lines = out[pathKey(d.file)] ??= {};
      final current = lines[d.line];
      if (current == null || d.severity.rank > current.rank) lines[d.line] = d.severity;
    }
    return out;
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();
    super.dispose();
  }
}
