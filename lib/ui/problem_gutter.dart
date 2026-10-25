import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

import '../problems/diagnostic.dart';
import '../problems/problems_controller.dart';
import '../theme/app_theme.dart';

/// 줄 번호 왼쪽에 문제가 있는 줄을 점으로 표시한다: 오류는 빨강, 경고는 노랑, 정보는 강조색.
/// 한 줄에 문제가 여러 개면 가장 심각한 것의 색이다. 색은 모두 현재 테마에서 가져온다.
class ProblemGutter extends StatelessWidget {
  const ProblemGutter({super.key, required this.editing, required this.indicator, required this.problems, required this.path});

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;
  final ProblemsController problems;
  final String path;

  static const double width = 12;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: const Size(width, double.infinity),
      painter: _ProblemPainter(
        editing: editing,
        indicator: indicator,
        problems: problems,
        path: path,
        error: t.danger,
        warning: t.warning,
        info: scheme.primary,
      ),
    );
  }
}

class _ProblemPainter extends CustomPainter {
  _ProblemPainter({
    required this.editing,
    required this.indicator,
    required this.problems,
    required this.path,
    required this.error,
    required this.warning,
    required this.info,
  }) : super(repaint: Listenable.merge([indicator, problems]));

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;
  final ProblemsController problems;
  final String path;
  final Color error;
  final Color warning;
  final Color info;

  @override
  void paint(Canvas canvas, Size size) {
    final value = indicator.value;
    final lines = problems.linesFor(path);
    if (value == null || value.paragraphs.isEmpty || lines.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final paint = Paint();
    for (final p in value.paragraphs) {
      final first = editing.index2lineIndex(p.index);
      final count = editing.codeLines[p.index].lineCount;
      // 접힌 구간 안의 문제도 접힌 줄에 보이게 가장 심각한 것을 고른다.
      DiagnosticSeverity? worst;
      for (var i = first; i < first + count; i++) {
        final s = lines[i + 1]; // 문제의 줄 번호는 1부터
        if (s != null && (worst == null || s.rank > worst.rank)) worst = s;
      }
      if (worst == null) continue;
      final color = switch (worst) {
        DiagnosticSeverity.error => error,
        DiagnosticSeverity.warning => warning,
        DiagnosticSeverity.info => info,
      };
      canvas.drawCircle(Offset(size.width / 2, p.top + p.height / 2), 3, paint..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ProblemPainter old) =>
      old.error != error ||
      old.warning != warning ||
      old.info != info ||
      old.path != path ||
      old.editing != editing ||
      old.indicator != indicator ||
      old.problems != problems;
}
