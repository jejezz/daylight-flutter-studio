import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/command_runner.dart';
import 'diagnostics.dart';

/// 이 컴퓨터의 개발 환경: 점검 결과와 도구(flutter, adb) 위치. 프로젝트와 상관없이 하나다.
class EnvironmentController extends ChangeNotifier {
  EnvironmentController({required this.runner, required this.service});

  final CommandRunner runner;
  final DiagnosticsService service;

  static const _toolKeyPrefix = 'tool_path_';

  /// 사용자가 위치를 지정할 수 있는 도구.
  static const configurableTools = ['flutter', 'adb'];

  Diagnostics? diagnostics;
  bool diagnosing = false;

  /// 도구 위치가 바뀌면 부른다 — 기기 목록처럼 그 도구에 기대는 것을 다시 읽는 데 쓴다.
  VoidCallback? onToolPathsChanged;

  /// 저장해 둔 도구 위치를 실행기에 되돌린다. 앱을 시작할 때 다른 명령보다 먼저 부른다.
  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final tool in configurableTools) {
        final saved = prefs.getString('$_toolKeyPrefix$tool');
        if (saved != null && saved.isNotEmpty) runner.toolPaths[tool] = saved;
      }
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
    notifyListeners();
  }

  Future<void> run() async {
    if (diagnosing) return;
    diagnosing = true;
    notifyListeners();
    try {
      diagnostics = await service.collect();
    } finally {
      diagnosing = false;
      notifyListeners();
    }
  }

  bool isCustomTool(String tool) => runner.toolPaths.containsKey(tool);

  /// [tool]을 실제로 실행하게 될 파일. 찾지 못하면 null.
  Future<String?> locateTool(String tool) => runner.locate(tool);

  /// 도구 위치를 직접 지정한다 (null이면 자동 탐색으로 되돌림). 저장하고 점검을 다시 한다.
  Future<void> setToolPath(String tool, String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      runner.toolPaths.remove(tool);
      await prefs.remove('$_toolKeyPrefix$tool');
    } else {
      runner.toolPaths[tool] = path;
      await prefs.setString('$_toolKeyPrefix$tool', path);
    }
    // 이전 경로로 읽은 결과("찾지 못함")를 새 점검이 끝날 때까지 남겨 두지 않는다.
    diagnostics = null;
    notifyListeners();
    onToolPathsChanged?.call();
    await run();
  }
}
