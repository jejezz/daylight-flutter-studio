import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';

import '../diff/line_diff.dart';
import '../studio/dart_chunk_analyzer.dart';
import '../studio/fold_plan.dart';
import '../studio/studio_controller.dart';
import '../theme/app_theme.dart';
import '../theme/editor_theme.dart';
import '../theme/editor_zoom.dart';
import '../problems/problems_controller.dart';
import 'change_gutter.dart';
import 'diff_view.dart';
import 'markdown_view.dart';
import 'problem_gutter.dart';

/// 탭 막대 + 도구 막대 + 편집 영역. Markdown은 편집/보기를 전환한다.
class EditorPane extends StatelessWidget {
  const EditorPane({super.key, required this.controller, this.problems});

  final StudioController controller;

  /// Dart 문제. 있으면 줄 번호 왼쪽에 문제가 있는 줄을 점으로 표시한다.
  final ProblemsController? problems;

  @override
  Widget build(BuildContext context) {
    final tab = controller.activeTab;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabBar(controller: controller),
        const Divider(),
        if (tab != null && tab.external != ExternalChange.none) _ExternalBanner(controller: controller, tab: tab),
        if (tab != null) ...[_Toolbar(controller: controller, tab: tab), const Divider()],
        Expanded(
          child: tab == null
              ? const Center(child: Text('왼쪽 트리에서 파일을 여세요'))
              : CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () => controller.save(tab),
                    const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () => controller.save(tab),
                    const SingleActivator(LogicalKeyboardKey.keyL, control: true, alt: true): controller.formatActive,
                    const SingleActivator(LogicalKeyboardKey.keyF, shift: true, alt: true): controller.formatActive,
                    ..._zoomBindings(EditorZoomScope.maybeOf(context)),
                  },
                  child: tab.diffMode && tab.hasBase
                      ? DiffView(key: ValueKey('${tab.path}#diff'), tab: tab)
                      : tab.language.isMarkdown && tab.preview
                      ? MarkdownView(
                          key: ValueKey('${tab.path}#preview'),
                          text: tab.controller.text,
                          baseDir: tab.path.substring(0, tab.path.lastIndexOf(RegExp(r'[/\\]'))),
                        )
                      : _CodeView(key: ValueKey(tab.path), tab: tab, problems: problems),
                ),
        ),
      ],
    );
  }
}

/// 글자 크기 단축키: Ctrl(macOS는 Cmd)+`+`/`=`, `-`, `0`. 숫자패드 `+`/`-`도 받는다.
Map<ShortcutActivator, VoidCallback> _zoomBindings(EditorZoom? zoom) {
  if (zoom == null) return const {};
  return {
    for (final ctrl in [true, false])
      ...{
        SingleActivator(LogicalKeyboardKey.equal, control: ctrl, meta: !ctrl): zoom.zoomIn,
        SingleActivator(LogicalKeyboardKey.equal, control: ctrl, meta: !ctrl, shift: true): zoom.zoomIn,
        SingleActivator(LogicalKeyboardKey.numpadAdd, control: ctrl, meta: !ctrl): zoom.zoomIn,
        SingleActivator(LogicalKeyboardKey.minus, control: ctrl, meta: !ctrl): zoom.zoomOut,
        SingleActivator(LogicalKeyboardKey.numpadSubtract, control: ctrl, meta: !ctrl): zoom.zoomOut,
        SingleActivator(LogicalKeyboardKey.digit0, control: ctrl, meta: !ctrl): zoom.reset,
      },
  };
}

/// 열린 파일이 디스크에서 바뀌었을 때, 수정 중인 탭에서 어떻게 할지 고르게 한다.
class _ExternalBanner extends StatelessWidget {
  const _ExternalBanner({required this.controller, required this.tab});

  final StudioController controller;
  final EditorTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final deleted = tab.external == ExternalChange.deleted;
    return Container(
      color: t.warning.withValues(alpha: 0.14),
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceXs),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: t.warning),
          SizedBox(width: t.spaceSm),
          Expanded(
            child: Text(
              deleted ? '이 파일이 디스크에서 사라졌습니다.' : '디스크의 파일이 바뀌었습니다. 저장하면 그쪽 수정을 덮어씁니다.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (deleted) ...[
            TextButton(onPressed: () => controller.closeTab(controller.tabs.indexOf(tab)), child: const Text('탭 닫기')),
            TextButton(onPressed: () => controller.keepMine(tab), child: const Text('그대로 두기')),
          ] else ...[
            TextButton(onPressed: () => controller.reloadFromDisk(tab), child: const Text('다시 읽기 (내 수정 버림)')),
            TextButton(onPressed: () => controller.keepMine(tab), child: const Text('내 수정 유지')),
          ],
        ],
      ),
    );
  }
}

class _CodeView extends StatefulWidget {
  const _CodeView({super.key, required this.tab, this.problems});

  final EditorTab tab;
  final ProblemsController? problems;

  @override
  State<_CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<_CodeView> {
  final _vertical = ScrollController();
  final _horizontal = ScrollController();
  late final CodeScrollController _scroll = CodeScrollController(verticalScroller: _vertical, horizontalScroller: _horizontal);

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final t = context.tokens;
    final mode = tab.language.mode;
    return ZoomWheel(
      scrollers: [_vertical, _horizontal],
      child: CodeEditor(
        controller: tab.controller,
        scrollController: _scroll,
        wordWrap: false,
        padding: EdgeInsets.all(t.spaceSm),
        chunkAnalyzer: tab.language.isDart ? const DartChunkAnalyzer() : const DefaultCodeChunkAnalyzer(),
        style: buildEditorStyle(context, languageId: tab.language.id, mode: mode),
        indicatorBuilder: (context, editing, chunks, notifier) {
          tab.chunks = chunks;
          return Row(
            children: [
              if (widget.problems != null)
                ProblemGutter(editing: editing, indicator: notifier, problems: widget.problems!, path: tab.path),
              DefaultCodeLineNumber(
                controller: editing,
                notifier: notifier,
                textStyle: editorLineNumberStyle(context, focused: false),
                focusedTextStyle: editorLineNumberStyle(context, focused: true),
              ),
              ChangeGutter(editing: editing, indicator: notifier, marks: tab.marks),
              DefaultCodeChunkIndicator(width: 20, controller: chunks, notifier: notifier),
            ],
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller, required this.tab});

  final StudioController controller;
  final EditorTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final showingDiff = tab.diffMode && tab.hasBase;
    final editing = !(tab.language.isMarkdown && tab.preview) && !showingDiff;
    final zoom = EditorZoomScope.maybeOf(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.spaceSm, vertical: t.spaceXs),
      child: Row(
        children: [
          Text(tab.language.label, style: theme.textTheme.labelMedium),
          const Spacer(),
          if (zoom != null)
            Tooltip(
              message: 'Ctrl+스크롤 또는 Ctrl +/- 로 글자 크기 조절 · 클릭하면 100%',
              child: TextButton(
                onPressed: zoom.isDefault ? null : zoom.reset,
                child: Text('${zoom.percent}%'),
              ),
            ),
          if (editing) ...[
            IconButton(
              tooltip: '모두 접기',
              icon: const Icon(Icons.unfold_less, size: 18),
              onPressed: () => foldAll(tab.chunks),
            ),
            IconButton(
              tooltip: '모두 펴기',
              icon: const Icon(Icons.unfold_more, size: 18),
              onPressed: () => unfoldAll(tab.controller, tab.chunks),
            ),
          ],
          if (tab.hasBase)
            ValueListenableBuilder<ChangeMarks>(
              valueListenable: tab.marks,
              builder: (context, marks, _) => IconButton(
                tooltip: showingDiff ? '편집으로 돌아가기' : (marks.isEmpty ? '변경점 보기 (HEAD와 같음)' : '변경점 보기 (HEAD와 비교)'),
                isSelected: showingDiff,
                icon: Icon(
                  Icons.difference_outlined,
                  size: 18,
                  color: !showingDiff && !marks.isEmpty ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: () => controller.toggleDiff(tab),
              ),
            ),
          if (tab.language.isDart)
            IconButton(
              tooltip: 'Dart 정렬 (Ctrl+Alt+L)',
              icon: const Icon(Icons.format_align_left, size: 18),
              onPressed: controller.formatActive,
            ),
          if (tab.language.isMarkdown)
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, icon: Icon(Icons.edit_outlined, size: 16), label: Text('편집')),
                ButtonSegment(value: true, icon: Icon(Icons.visibility_outlined, size: 16), label: Text('보기')),
              ],
              selected: {tab.preview},
              onSelectionChanged: (_) => controller.togglePreview(tab),
            ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tabs.length,
        itemBuilder: (context, i) {
          final t = controller.tabs[i];
          final active = i == controller.activeIndex;
          return Tooltip(
            message: t.path,
            child: InkWell(
              onTap: () => controller.selectTab(i),
              child: Container(
                padding: const EdgeInsets.only(left: 12, right: 4),
                decoration: BoxDecoration(
                  color: active ? theme.colorScheme.surfaceContainerHighest : null,
                  border: Border(bottom: BorderSide(width: 2, color: theme.colorScheme.primary.withValues(alpha: active ? 1 : 0))),
                ),
                child: Row(
                  children: [
                    Text(t.dirty ? '● ${t.name}' : t.name),
                    IconButton(
                      iconSize: 14,
                      visualDensity: VisualDensity.compact,
                      tooltip: '닫기',
                      icon: const Icon(Icons.close),
                      onPressed: () => _close(context, i),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _close(BuildContext context, int i) async {
    final t = controller.tabs[i];
    if (!t.dirty) return controller.closeTab(i);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${t.name} 저장할까요?'),
        content: const Text('저장하지 않은 수정이 있습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'cancel'), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, 'discard'), child: const Text('저장 안 함')),
          FilledButton(onPressed: () => Navigator.pop(context, 'save'), child: const Text('저장')),
        ],
      ),
    );
    if (choice == 'save') {
      if (await controller.save(t)) controller.closeTab(i);
    } else if (choice == 'discard') {
      controller.closeTab(i);
    }
  }
}
