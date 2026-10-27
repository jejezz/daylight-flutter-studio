import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

import '../problems/diagnostic.dart';
import '../problems/problems_controller.dart';
import '../theme/app_theme.dart';

/// 문제가 있는 글자 밑에 물결 밑줄을 긋는다: 오류는 빨강, 경고는 노랑, 정보는 강조색.
///
/// 들여쓰기 선([IndentGuides])처럼 줄 번호 옆 표시(indicator) 줄의 맨 끝에 폭 0으로 놓고 글 위에 그린다.
/// 글자 위치는 고정폭을 가정하지 않고 앞 글을 같은 글꼴로 재서 구한다(한글처럼 폭이 다른 글자가 있어도 맞는다).
/// 줄 번호 옆 점([ProblemGutter])은 그대로 두고, 이쪽은 어느 글자가 문제인지 알려 준다.
class ProblemSquiggles extends StatelessWidget {
  const ProblemSquiggles({
    super.key,
    required this.editing,
    required this.indicator,
    required this.horizontal,
    required this.problems,
    required this.path,
    required this.textStyle,
    required this.textInset,
  });

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;

  /// 가로 스크롤 — 글이 옆으로 밀리면 밑줄도 같이 밀린다.
  final ScrollController horizontal;
  final ProblemsController problems;
  final String path;

  /// 편집기 글 스타일 (글자 폭을 재는 데 쓴다).
  final TextStyle textStyle;

  /// 이 위젯의 왼쪽 가장자리에서 글의 첫 글자까지의 거리.
  final double textInset;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: const Size(0, double.infinity),
      painter: _SquigglePainter(
        editing: editing,
        indicator: indicator,
        horizontal: horizontal,
        problems: problems,
        path: path,
        textStyle: textStyle,
        textInset: textInset,
        error: t.danger,
        warning: t.warning,
        info: scheme.primary,
      ),
    );
  }
}

/// [x0]부터 [x1]까지 [y] 높이에 놓는 물결선. 꼭짓점이 [period]마다 위아래로 번갈아 [amplitude]만큼 오르내린다.
Path squigglePath(double x0, double x1, double y, {double period = 3, double amplitude = 1.6}) {
  final path = Path()..moveTo(x0, y);
  var x = x0;
  var up = true;
  while (x < x1) {
    x = math.min(x + period, x1);
    path.lineTo(x, up ? y - amplitude : y + amplitude);
    up = !up;
  }
  return path;
}

class _SquigglePainter extends CustomPainter {
  _SquigglePainter({
    required this.editing,
    required this.indicator,
    required this.horizontal,
    required this.problems,
    required this.path,
    required this.textStyle,
    required this.textInset,
    required this.error,
    required this.warning,
    required this.info,
  }) : super(repaint: Listenable.merge([indicator, horizontal, editing, problems]));

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;
  final ScrollController horizontal;
  final ProblemsController problems;
  final String path;
  final TextStyle textStyle;
  final double textInset;
  final Color error;
  final Color warning;
  final Color info;

  double _width(String text) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(text: TextSpan(text: text, style: textStyle), textDirection: TextDirection.ltr)..layout();
    final w = painter.width;
    painter.dispose();
    return w;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final value = indicator.value;
    final byLine = problems.spansFor(path);
    if (value == null || value.paragraphs.isEmpty || byLine.isEmpty) return;
    final scroll = horizontal.hasClients ? horizontal.offset : 0.0;
    final codeLines = editing.codeLines;
    canvas.save();
    // 글 영역 왼쪽(줄 번호·표시 칸)으로 밀려 나간 부분은 그리지 않는다.
    canvas.clipRect(Rect.fromLTRB(0, 0, 100000, size.height));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;
    for (final p in value.paragraphs) {
      if (p.index >= codeLines.length || codeLines[p.index].lineCount != 1) continue; // 접힌 줄은 점으로만 알린다
      final diagnostics = byLine[editing.index2lineIndex(p.index) + 1];
      if (diagnostics == null) continue;
      final text = codeLines[p.index].text;
      for (final d in diagnostics) {
        final start = (d.column - 1).clamp(0, text.length);
        var end = (start + d.length).clamp(start, text.length);
        final x0 = textInset + _width(text.substring(0, start)) - scroll;
        // 줄 끝이거나 길이를 모르는 문제는 글자 하나 폭만큼 그린다.
        final x1 = end > start ? textInset + _width(text.substring(0, end)) - scroll : x0 + _width('0');
        if (x1 < 0) continue;
        final color = switch (d.severity) {
          DiagnosticSeverity.error => error,
          DiagnosticSeverity.warning => warning,
          DiagnosticSeverity.info => info,
        };
        canvas.drawPath(squigglePath(x0, x1, p.top + p.height - 2), paint..color = color);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SquigglePainter old) =>
      old.textStyle != textStyle || old.textInset != textInset || old.path != path || old.error != error || old.warning != warning || old.info != info;
}
