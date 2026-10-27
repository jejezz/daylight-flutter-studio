import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../diff/line_diff.dart';
import '../studio/studio_controller.dart';
import 'compare_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/editor_theme.dart';
import '../theme/editor_zoom.dart';

/// HEAD 커밋과 지금 글의 차이를 통합(unified) 형식으로 보여 준다. 읽기 전용이다.
/// 바뀐 곳 둘레 3줄만 보이고 나머지는 접혀 있다 (눌러서 펼침). 글자 크기는 편집기 배율을 따른다.
class DiffView extends StatefulWidget {
  const DiffView({super.key, required this.tab, this.controller});

  final EditorTab tab;

  /// 비교 기준을 바꾸는 데 쓴다. 없으면 기준 바꾸기 단추를 두지 않는다 (HEAD와만 비교).
  final StudioController? controller;

  @override
  State<DiffView> createState() => _DiffViewState();
}

class _DiffViewState extends State<DiffView> {
  final _scroll = ScrollController();
  final _expanded = <int>{};

  // 같은 글이면 다시 계산하지 않는다.
  List<String>? _cachedBase;
  String? _cachedText;
  List<String> _current = const [];
  List<DiffBlock> _blocks = const [];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _compute(List<String> base) {
    final text = widget.tab.controller.text;
    if (identical(_cachedBase, base) && _cachedText == text) return;
    _cachedBase = base;
    _cachedText = text;
    _current = splitLines(text);
    _blocks = diffLines(base, _current);
    _expanded.clear();
  }

  Future<void> _changeBase() async {
    final controller = widget.controller!;
    final tab = widget.tab;
    final ref = await showCompareDialog(context, choices: controller.compareChoices(tab), current: tab.compareRef);
    if (ref == null) return;
    await controller.setCompareRef(tab, ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = context.tokens;
    final tab = widget.tab;
    final ref = tab.compareRef;
    final base = tab.diffBase;
    if (base == null) {
      return _Message(icon: context.icons.block, text: l10n.diffNotComparable);
    }
    _compute(base);
    final counts = countChanges(_blocks);
    final rows = buildUnifiedRows(base, _current, _blocks, expandedGaps: _expanded);
    final style = editorTextStyle(context);
    final charWidth = (style.fontSize ?? 13) * 0.62;
    final digits = [base.length, _current.length].reduce((a, b) => a > b ? a : b).toString().length;
    final numWidth = charWidth * (digits < 3 ? 3 : digits) + t.spaceSm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
          child: Row(
            children: [
              Text(ref == null ? l10n.diffAgainstHead : l10n.diffAgainstRef(ref), style: theme.textTheme.labelMedium),
              SizedBox(width: t.spaceMd),
              Text('+${counts.added}', style: theme.textTheme.labelMedium?.copyWith(color: t.success)),
              SizedBox(width: t.spaceSm),
              Text('−${counts.removed}', style: theme.textTheme.labelMedium?.copyWith(color: t.danger)),
              if (tab.diffBaseIsNew) ...[
                SizedBox(width: t.spaceMd),
                Text(ref == null ? l10n.diffNewFile : l10n.diffNotInRef, style: theme.textTheme.labelMedium?.copyWith(color: t.warning)),
              ],
              const Spacer(),
              if (widget.controller != null)
                TextButton.icon(
                  onPressed: _changeBase,
                  icon: Icon(context.icons.callSplit, size: 16),
                  label: Text(l10n.diffChangeBase),
                ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: rows.isEmpty
              ? _Message(icon: context.icons.checkCircle, text: ref == null ? l10n.diffSameAsHead : l10n.diffSameAsRef(ref))
              : ZoomWheel(
                  scrollers: [_scroll],
                  child: SelectionArea(
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: rows.length,
                      itemBuilder: (context, i) => _RowView(
                        row: rows[i],
                        style: style,
                        numWidth: numWidth,
                        onExpand: () => setState(() => _expanded.add(rows[i].gapId)),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.outline),
            SizedBox(height: t.spaceSm),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// 줄의 글을 그린다. [changed] 범위(글자 위치 [start, end))는 [highlight] 배경으로 도드라지게 한다.
TextSpan diffLineSpan(String text, List<(int, int)> changed, TextStyle style, Color highlight) {
  if (changed.isEmpty) return TextSpan(text: text, style: style);
  final marked = style.copyWith(backgroundColor: highlight);
  final spans = <TextSpan>[];
  var at = 0;
  for (final (start, end) in changed) {
    final s = start.clamp(at, text.length);
    final e = end.clamp(s, text.length);
    if (s > at) spans.add(TextSpan(text: text.substring(at, s)));
    if (e > s) spans.add(TextSpan(text: text.substring(s, e), style: marked));
    at = e;
  }
  if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
  return TextSpan(style: style, children: spans);
}

class _RowView extends StatelessWidget {
  const _RowView({required this.row, required this.style, required this.numWidth, required this.onExpand});

  final DiffRow row;
  final TextStyle style;
  final double numWidth;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.tokens;

    if (row.kind == DiffRowKind.gap) {
      return InkWell(
        onTap: onExpand,
        child: Container(
          color: scheme.surfaceContainerHigh,
          padding: EdgeInsets.symmetric(vertical: t.spaceXs, horizontal: t.spaceMd),
          child: Row(
            children: [
              Icon(context.icons.unfoldMore, size: 16, color: scheme.onSurfaceVariant),
              SizedBox(width: t.spaceSm),
              Text(l10n.diffHiddenLines(row.hidden), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    final (background, marker, markerColor) = switch (row.kind) {
      DiffRowKind.added => (t.success.withValues(alpha: 0.14), '+', t.success),
      DiffRowKind.removed => (t.danger.withValues(alpha: 0.14), '−', t.danger),
      _ => (null, ' ', scheme.outline),
    };
    final strut = editorStrutStyle(context);
    final numStyle = style.copyWith(color: scheme.outline);
    Widget number(int? n) => SizedBox(
      width: numWidth,
      child: Text(n?.toString() ?? '', textAlign: TextAlign.right, strutStyle: strut, style: numStyle),
    );

    return Container(
      color: background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: t.spaceXs),
          number(row.oldNo),
          SizedBox(width: t.spaceXs),
          number(row.newNo),
          SizedBox(width: t.spaceSm),
          Text(marker, strutStyle: strut, style: style.copyWith(color: markerColor, fontWeight: FontWeight.bold)),
          SizedBox(width: t.spaceSm),
          Expanded(
            child: Text.rich(
              diffLineSpan(row.text.isEmpty ? ' ' : row.text, row.changed, style.copyWith(color: scheme.onSurface), markerColor.withValues(alpha: 0.38)),
              strutStyle: strut,
            ),
          ),
        ],
      ),
    );
  }
}
