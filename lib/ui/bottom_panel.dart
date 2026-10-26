import 'package:flutter/material.dart';

import '../core/command_log.dart';
import '../l10n/app_localizations.dart';
import '../problems/diagnostic.dart';
import '../problems/problems_controller.dart';
import '../run/run_controller.dart';
import '../settings/panel_layout.dart';
import '../theme/app_theme.dart';
import 'problems_panel.dart';
import 'run_panel.dart';

/// 편집기 아래의 패널: Run과 문제. 넓고 낮은 모양이라 목록·출력을 가로로 길게 볼 수 있다.
/// 선택된 탭은 [PanelLayout]이 쥐고 있어서, 상태 막대의 문제 개수를 눌러도 이 패널이 문제 탭으로 바뀐다.
class BottomPanel extends StatefulWidget {
  const BottomPanel({
    super.key,
    required this.layout,
    required this.run,
    required this.log,
    required this.problems,
    required this.onOpenProblem,
  });

  final PanelLayout layout;
  final RunController run;
  final CommandLog log;
  final ProblemsController problems;
  final void Function(Diagnostic diagnostic) onOpenProblem;

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: BottomTab.values.length, vsync: this, initialIndex: widget.layout.bottomTab.index);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTabChanged);
    widget.layout.addListener(_onLayoutChanged);
  }

  @override
  void dispose() {
    widget.layout.removeListener(_onLayoutChanged);
    _tabs.dispose();
    super.dispose();
  }

  /// 사용자가 탭을 누르면 선택을 레이아웃에 알린다 (애니메이션 도중의 중간 값은 무시).
  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    widget.layout.setBottomTab(BottomTab.values[_tabs.index]);
  }

  /// 다른 곳(상태 막대)에서 탭이 바뀌면 탭 막대도 따라간다.
  void _onLayoutChanged() {
    final want = widget.layout.bottomTab.index;
    if (_tabs.index != want && !_tabs.indexIsChanging) _tabs.animateTo(want);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  const Tab(text: 'Run'),
                  // 오류가 있으면 탭 이름에 개수를 붙여 Run 탭을 보고 있어도 알아챌 수 있게 한다.
                  ListenableBuilder(
                    listenable: widget.problems,
                    builder: (context, _) {
                      final errors = widget.problems.errors;
                      final warnings = widget.problems.warnings;
                      final badge = errors > 0 ? ' $errors' : (warnings > 0 ? ' $warnings' : '');
                      final color = errors > 0 ? context.tokens.danger : context.tokens.warning;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.studioProblemsTab),
                            if (badge.isNotEmpty) Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.studioBottomPanelHide,
              icon: Icon(context.icons.expandMore, size: 18),
              onPressed: widget.layout.toggleBottom,
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            // 탭을 옆으로 쓸어서 바꾸는 동작은 끈다 — 목록·출력을 가로로 스크롤하다 탭이 바뀌면 곤란하다.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              RunPanel(controller: widget.run, log: widget.log),
              ProblemsPanel(controller: widget.problems, onOpen: widget.onOpenProblem),
            ],
          ),
        ),
      ],
    );
  }
}
