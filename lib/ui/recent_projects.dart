import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../studio/studio_controller.dart';
import '../theme/app_theme.dart';

String _name(String path) => path.split(RegExp(r'[/\\]')).where((s) => s.isNotEmpty).lastOrNull ?? path;

/// "프로젝트 열기" 옆의 화살표: 최근에 연 프로젝트 목록을 펼쳐 다시 연다.
class RecentProjectsMenu extends StatelessWidget {
  const RecentProjectsMenu({super.key, required this.controller});

  final StudioController controller;

  static const _clear = '\u0000clear';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recents = controller.recentProjects;
    return PopupMenuButton<String>(
      tooltip: l10n.studioRecentTooltip,
      icon: Icon(context.icons.arrowDropDown),
      onSelected: (value) => value == _clear ? controller.clearRecent() : controller.openRecent(value),
      itemBuilder: (_) => [
        PopupMenuItem<String>(enabled: false, height: 32, child: Text(l10n.studioRecentProjects, style: Theme.of(context).textTheme.labelMedium)),
        if (recents.isEmpty) PopupMenuItem<String>(enabled: false, child: Text(l10n.studioRecentNone)),
        for (final path in recents)
          PopupMenuItem<String>(
            value: path,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name(path), overflow: TextOverflow.ellipsis),
                  Text(path, style: context.logText.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        if (recents.isNotEmpty) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(value: _clear, child: Text(l10n.studioRecentClear)),
        ],
      ],
    );
  }
}

/// 프로젝트를 열기 전 첫 화면에 보이는 최근 프로젝트 목록.
class RecentProjectsList extends StatelessWidget {
  const RecentProjectsList({super.key, required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final recents = controller.recentProjects;
    if (recents.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: t.spaceXs),
            child: Row(
              children: [
                Icon(context.icons.history, size: 16),
                SizedBox(width: t.spaceXs),
                Text(l10n.studioRecentProjects, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          for (final path in recents)
            ListTile(
              dense: true,
              leading: Icon(context.icons.folder, size: 18),
              title: Text(_name(path), overflow: TextOverflow.ellipsis),
              subtitle: Text(path, style: context.logText, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                tooltip: l10n.studioRecentForget,
                iconSize: 16,
                icon: Icon(context.icons.close),
                onPressed: () => controller.forgetRecent(path),
              ),
              onTap: () => controller.openRecent(path),
            ),
        ],
      ),
    );
  }
}
