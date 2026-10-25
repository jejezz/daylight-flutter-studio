import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../problems/diagnostic.dart';
import '../problems/problems_controller.dart';
import '../theme/app_theme.dart';

/// 문제 패널: `dart analyze` 결과를 파일별로 묶어 보여 주고, 누르면 그 줄로 이동한다.
class ProblemsPanel extends StatefulWidget {
  const ProblemsPanel({super.key, required this.controller, required this.onOpen});

  final ProblemsController controller;

  /// 문제를 눌렀을 때: 그 파일의 그 줄을 연다.
  final void Function(Diagnostic diagnostic) onOpen;

  @override
  State<ProblemsPanel> createState() => _ProblemsPanelState();
}

class _ProblemsPanelState extends State<ProblemsPanel> {
  final _shown = <DiagnosticSeverity>{...DiagnosticSeverity.values};

  ProblemsController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        if (c.packageRoot == null) {
          return Center(child: Text(AppLocalizations.of(context).problemsNoPackage));
        }
        final groups = c.grouped(only: _shown);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(controller: c, shown: _shown, onToggle: _toggle),
            if (c.needsPubGet) _PubGetBanner(controller: c),
            if (c.error != null) _ErrorBanner(message: c.error!),
            const Divider(),
            Expanded(
              child: groups.isEmpty
                  ? _Empty(controller: c, filtered: c.diagnostics.isNotEmpty)
                  : ListView(
                      padding: EdgeInsets.only(bottom: t.spaceLg),
                      children: [
                        for (final entry in groups.entries) ...[
                          _FileHeader(path: entry.key, root: c.packageRoot!, count: entry.value.length),
                          for (final d in entry.value) _Row(diagnostic: d, onTap: () => widget.onOpen(d)),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  void _toggle(DiagnosticSeverity s) => setState(() => _shown.contains(s) ? _shown.remove(s) : _shown.add(s));
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.shown, required this.onToggle});

  final ProblemsController controller;
  final Set<DiagnosticSeverity> shown;
  final void Function(DiagnosticSeverity) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    Widget chip(DiagnosticSeverity s, String label, Color color) => FilterChip(
      selected: shown.contains(s),
      showCheckmark: false,
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text('$label ${controller.count(s)}'),
      onSelected: (_) => onToggle(s),
    );
    return Padding(
      padding: EdgeInsets.all(t.spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: t.spaceXs,
              children: [
                chip(DiagnosticSeverity.error, l10n.problemsError, t.danger),
                chip(DiagnosticSeverity.warning, l10n.problemsWarning, t.warning),
                chip(DiagnosticSeverity.info, l10n.problemsInfo, scheme.primary),
              ],
            ),
          ),
          if (controller.running)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(tooltip: l10n.problemsReanalyze, icon: const Icon(Icons.refresh, size: 18), onPressed: controller.refresh),
        ],
      ),
    );
  }
}

class _PubGetBanner extends StatelessWidget {
  const _PubGetBanner({required this.controller});

  final ProblemsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return Container(
      color: t.warning.withValues(alpha: 0.14),
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: t.warning),
          SizedBox(width: t.spaceSm),
          Expanded(child: Text(l10n.problemsNoPackageInfo)),
          controller.gettingPackages
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton(onPressed: controller.runPubGet, child: const Text('flutter pub get')),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      color: t.danger.withValues(alpha: 0.12),
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: t.danger),
          SizedBox(width: t.spaceSm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.controller, required this.filtered});

  final ProblemsController controller;

  /// 문제는 있지만 필터로 모두 가려졌다.
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final (icon, text, color) = !controller.analyzed
        ? (Icons.hourglass_empty, controller.running ? l10n.problemsAnalyzing : l10n.problemsNotAnalyzed, Theme.of(context).colorScheme.outline)
        : filtered
        ? (Icons.filter_alt_outlined, l10n.problemsFilteredOut, Theme.of(context).colorScheme.outline)
        : controller.error != null
        ? (Icons.help_outline, l10n.problemsUnknown, t.warning)
        : (Icons.check_circle_outline, l10n.problemsNone, t.success);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: t.spaceSm),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FileHeader extends StatelessWidget {
  const _FileHeader({required this.path, required this.root, required this.count});

  final String path;
  final String root;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final rel = pathKey(path).startsWith('${pathKey(root)}/') ? path.substring(root.length + 1) : path;
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 14),
          SizedBox(width: t.spaceSm),
          Expanded(child: Text(rel, style: theme.textTheme.labelMedium, overflow: TextOverflow.ellipsis)),
          Text('$count', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.diagnostic, required this.onTap});

  final Diagnostic diagnostic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final (icon, color) = switch (diagnostic.severity) {
      DiagnosticSeverity.error => (Icons.error, t.danger),
      DiagnosticSeverity.warning => (Icons.warning_amber_rounded, t.warning),
      DiagnosticSeverity.info => (Icons.info_outline, theme.colorScheme.primary),
    };
    return Tooltip(
      message: diagnostic.correction.isEmpty ? diagnostic.code : '${diagnostic.code}\n${diagnostic.correction}',
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs + 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: t.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diagnostic.message, style: theme.textTheme.bodySmall),
                    Text('${diagnostic.line}:${diagnostic.column} · ${diagnostic.code}', style: t.logText.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
