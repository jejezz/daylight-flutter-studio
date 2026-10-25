import 'package:flutter/material.dart';

import '../settings/gate_settings.dart';
import '../theme/app_theme.dart';
import '../theme/editor_theme.dart';
import '../theme/editor_zoom.dart';
import '../theme/theme_controller.dart';

/// 설정 화면의 구역. 왼쪽 목록에 이 순서로 나온다.
enum SettingsSection {
  appearance('외형', Icons.palette_outlined),
  editor('편집기', Icons.edit_note_outlined),
  gate('병합 관문', Icons.shield_outlined);

  const SettingsSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// 설정 대화상자: 왼쪽에서 구역을 고르고 오른쪽에서 바꾼다. 바꾼 값은 바로 적용되고 저장된다.
Future<void> showSettingsDialog(
  BuildContext context, {
  required ThemeController theme,
  GateSettings? gate,
  SettingsSection initial = SettingsSection.appearance,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        SettingsDialog(theme: theme, gate: gate, initial: initial),
  );
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.theme,
    this.gate,
    this.initial = SettingsSection.appearance,
  });

  final ThemeController theme;
  final GateSettings? gate;
  final SettingsSection initial;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsSection _section = widget.initial;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('설정'),
      contentPadding: EdgeInsets.fromLTRB(0, t.spaceSm, t.spaceLg, 0),
      content: SizedBox(
        width: 720,
        height: 440,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 170,
              child: ListView(
                children: [
                  for (final s in SettingsSection.values)
                    if (s != SettingsSection.gate || widget.gate != null)
                      ListTile(
                        selected: s == _section,
                        selectedTileColor: scheme.secondaryContainer,
                        leading: Icon(s.icon, size: 20),
                        title: Text(s.label),
                        onTap: () => setState(() => _section = s),
                      ),
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: t.spaceMd, bottom: t.spaceMd),
                child: switch (_section) {
                  SettingsSection.appearance => _AppearanceSection(
                    theme: widget.theme,
                  ),
                  SettingsSection.editor => const _EditorSection(),
                  SettingsSection.gate => _GateSection(gate: widget.gate!),
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.only(top: t.spaceMd, bottom: t.spaceSm),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.theme});

  final ThemeController theme;

  static String _palette(StudioPalette p) => switch (p) {
    StudioPalette.indigo => '인디고',
    StudioPalette.teal => '청록',
    StudioPalette.amber => '호박',
    StudioPalette.rose => '장미',
    StudioPalette.slate => '슬레이트',
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading('밝기'),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined, size: 16),
                label: Text('시스템'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined, size: 16),
                label: Text('라이트'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined, size: 16),
                label: Text('다크'),
              ),
            ],
            selected: {theme.mode},
            onSelectionChanged: (s) => theme.setMode(s.first),
          ),
          const _Heading('색 구성'),
          Wrap(
            spacing: t.spaceSm,
            runSpacing: t.spaceSm,
            children: [
              for (final p in StudioPalette.values)
                ChoiceChip(
                  selected: theme.palette == p,
                  showCheckmark: false,
                  avatar: Icon(Icons.circle, size: 14, color: p.seed),
                  label: Text(_palette(p)),
                  onSelected: (_) => theme.setPalette(p),
                ),
            ],
          ),
          SizedBox(height: t.spaceMd),
          Text(
            '바꾼 값은 바로 적용되고 다음 실행에도 유지됩니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _GateSection extends StatelessWidget {
  const _GateSection({required this.gate});

  final GateSettings gate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: gate,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading('PR 병합 전 검증'),
          Text(
            '빌드해서 눈으로 확인한 커밋만 병합하게 합니다. 확인하지 않고 병합하면 GitHub에서 모든 OS 빌드가 돌고, '
            '문제가 나오면 고쳐서 릴리스를 다시 해야 합니다.',
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: t.spaceMd),
          SegmentedButton<GateMode>(
            showSelectedIcon: false,
            segments: [
              for (final m in GateMode.values)
                ButtonSegment(value: m, label: Text(m.label)),
            ],
            selected: {gate.mode},
            onSelectionChanged: (s) => gate.setMode(s.first),
          ),
          SizedBox(height: t.spaceSm),
          Text(gate.mode.description),
          SizedBox(height: t.spaceMd),
          Text(
            '"확인함"은 Run 탭에서 앱을 실행해 본 뒤 직접 누르는 단추입니다. 빌드만 성공한 것은 확인으로 치지 않습니다.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection();

  static const _sample = "void main() {\n  print('Hello, Flutter');\n}";

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final zoom = EditorZoomScope.maybeOf(context);
    if (zoom == null) return const Text('편집기 설정을 불러올 수 없습니다.');
    return ListenableBuilder(
      listenable: zoom,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading('글자 크기'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: EditorZoom.min,
                  max: EditorZoom.max,
                  divisions:
                      ((EditorZoom.max - EditorZoom.min) / EditorZoom.step)
                          .round(),
                  value: zoom.value,
                  label: '${zoom.percent}%',
                  onChanged: zoom.setValue,
                ),
              ),
              SizedBox(
                width: 56,
                child: Text('${zoom.percent}%', textAlign: TextAlign.end),
              ),
              IconButton(
                tooltip: '100%로',
                icon: const Icon(Icons.restart_alt, size: 18),
                onPressed: zoom.isDefault ? null : zoom.reset,
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(t.spaceMd),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(t.radius),
            ),
            child: Text(
              _sample,
              style: editorTextStyle(context).copyWith(color: scheme.onSurface),
            ),
          ),
          SizedBox(height: t.spaceSm),
          Text(
            '편집기와 Markdown 보기, 변경점 보기에만 적용됩니다. 편집기에서는 Ctrl+스크롤이나 Ctrl +/-/0으로도 바꿀 수 있습니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
