import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 열린 Dock의 가로 제목 막대: 닫기 단추(>)와 제목.
class DockHeader extends StatelessWidget {
  const DockHeader({super.key, required this.title, required this.closeTooltip, required this.onClose});

  final String title;
  final String closeTooltip;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: DockBars.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: t.spaceXs),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outlineVariant))),
      child: Row(
        children: [
          IconButton(
            tooltip: closeTooltip,
            visualDensity: VisualDensity.compact,
            icon: Icon(context.icons.chevronRight, size: 18),
            onPressed: onClose,
          ),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// 닫힌 Dock이 남기는 세로 제목 막대: 펼치기 단추(<)와 위에서 아래로 쌓은 제목 글자.
/// 막대 아무 데나 눌러도 펼쳐진다.
class CollapsedDockBar extends StatelessWidget {
  const CollapsedDockBar({super.key, required this.title, required this.openTooltip, required this.onOpen});

  final String title;
  final String openTooltip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelLarge;
    return Tooltip(
      message: openTooltip,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          width: DockBars.collapsedWidth,
          decoration: BoxDecoration(border: Border(left: BorderSide(color: scheme.outlineVariant))),
          child: Column(
            children: [
              SizedBox(height: DockBars.headerHeight, child: Center(child: Icon(context.icons.chevronLeft, size: 18))),
              for (final ch in title.characters) Padding(padding: EdgeInsets.symmetric(vertical: t.spaceXs / 2), child: Text(ch, style: style)),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class DockBars {
  static const headerHeight = 40.0;
  static const collapsedWidth = 32.0;
}
