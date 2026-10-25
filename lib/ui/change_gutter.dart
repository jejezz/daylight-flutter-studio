import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

import '../diff/line_diff.dart';
import '../theme/app_theme.dart';

/// 줄 번호 옆의 얇은 변경 표시: 새 줄은 초록, 바뀐 줄은 강조색, 지워진 자리는 빨간 삼각형.
/// 색은 모두 현재 테마에서 가져온다.
class ChangeGutter extends StatelessWidget {
  const ChangeGutter({super.key, required this.editing, required this.indicator, required this.marks});

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;
  final ValueNotifier<ChangeMarks> marks;

  static const double width = 4;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: CustomPaint(
        size: const Size(width, double.infinity),
        painter: _ChangePainter(
          editing: editing,
          indicator: indicator,
          marks: marks,
          added: t.success,
          modified: scheme.primary,
          deleted: t.danger,
        ),
      ),
    );
  }
}

class _ChangePainter extends CustomPainter {
  _ChangePainter({
    required this.editing,
    required this.indicator,
    required this.marks,
    required this.added,
    required this.modified,
    required this.deleted,
  }) : super(repaint: Listenable.merge([indicator, marks]));

  final CodeLineEditingController editing;
  final CodeIndicatorValueNotifier indicator;
  final ValueNotifier<ChangeMarks> marks;
  final Color added;
  final Color modified;
  final Color deleted;

  @override
  void paint(Canvas canvas, Size size) {
    final value = indicator.value;
    final m = marks.value;
    if (value == null || value.paragraphs.isEmpty || m.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final paint = Paint();
    for (final p in value.paragraphs) {
      final first = editing.index2lineIndex(p.index);
      final count = editing.codeLines[p.index].lineCount;
      final color = m.touches(m.added, first, count)
          ? added
          : m.touches(m.modified, first, count)
          ? modified
          : null;
      if (color != null) canvas.drawRect(Rect.fromLTWH(0, p.top, width, p.height), paint..color = color);
      if (m.touches(m.deletedBefore, first, 1)) _triangle(canvas, p.top, paint..color = deleted);
    }
    // 파일 끝의 줄이 지워졌으면 마지막 줄 아래에 표시한다.
    final last = value.paragraphs.last;
    final total = editing.lineCount;
    if (last.index == editing.codeLines.length - 1 && m.deletedBefore.any((d) => d >= total)) {
      _triangle(canvas, last.bottom, paint..color = deleted);
    }
    canvas.restore();
  }

  void _triangle(Canvas canvas, double y, Paint paint) {
    final path = Path()
      ..moveTo(0, y - 3)
      ..lineTo(width, y)
      ..lineTo(0, y + 3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChangePainter old) =>
      old.added != added ||
      old.modified != modified ||
      old.deleted != deleted ||
      old.editing != editing ||
      old.indicator != indicator ||
      old.marks != marks;

  static const double width = ChangeGutter.width;
}
