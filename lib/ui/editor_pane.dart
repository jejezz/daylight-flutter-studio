import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../studio/studio_controller.dart';
import '../theme/app_theme.dart';

/// 탭 막대 + 글 편집 영역. Ctrl/Cmd+S로 저장한다.
class EditorPane extends StatelessWidget {
  const EditorPane({super.key, required this.controller});

  final StudioController controller;

  @override
  Widget build(BuildContext context) {
    final tab = controller.activeTab;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabBar(controller: controller),
        const Divider(height: 1),
        Expanded(
          child: tab == null
              ? const Center(child: Text('왼쪽 트리에서 파일을 여세요'))
              : CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () => controller.save(tab),
                    const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () => controller.save(tab),
                  },
                  child: TextField(
                    key: ValueKey(tab.path),
                    controller: tab.controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: context.tokens.editorText,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(context.tokens.spaceMd)),
                  ),
                ),
        ),
      ],
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
