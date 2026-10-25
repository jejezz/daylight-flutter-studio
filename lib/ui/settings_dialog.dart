import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/gate_settings.dart';
import '../settings/editor_settings.dart';
import '../theme/app_theme.dart';
import '../theme/editor_theme.dart';
import '../theme/editor_zoom.dart';
import '../theme/theme_controller.dart';

/// 설정 화면의 구역. 왼쪽 목록에 이 순서로 나온다.
enum SettingsSection {
  appearance(Icons.palette_outlined),
  editor(Icons.edit_note_outlined),
  gate(Icons.shield_outlined);

  const SettingsSection(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    appearance => l10n.settingsSectionAppearance,
    editor => l10n.settingsSectionEditor,
    gate => l10n.settingsSectionGate,
  };
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
      title: Text(AppLocalizations.of(context).settingsTitle),
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
                        title: Text(s.label(AppLocalizations.of(context))),
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
          child: Text(AppLocalizations.of(context).commonClose),
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

  static String _palette(AppLocalizations l10n, StudioPalette p) => switch (p) {
    StudioPalette.saturn => l10n.settingsPaletteSaturn,
    StudioPalette.teal => l10n.settingsPaletteTeal,
    StudioPalette.amber => l10n.settingsPaletteAmber,
    StudioPalette.rose => l10n.settingsPaletteRose,
    StudioPalette.slate => l10n.settingsPaletteSlate,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(l10n.settingsBrightness),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined, size: 16),
                label: Text(l10n.settingsBrightnessSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined, size: 16),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined, size: 16),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {theme.mode},
            onSelectionChanged: (s) => theme.setMode(s.first),
          ),
          _Heading(l10n.settingsPalette),
          Wrap(
            spacing: t.spaceSm,
            runSpacing: t.spaceSm,
            children: [
              for (final p in StudioPalette.values)
                ChoiceChip(
                  selected: theme.palette == p,
                  showCheckmark: false,
                  avatar: Icon(Icons.circle, size: 14, color: p.primaryFor(Theme.of(context).brightness)),
                  label: Text(_palette(l10n, p)),
                  onSelected: (_) => theme.setPalette(p),
                ),
            ],
          ),
          SizedBox(height: t.spaceMd),
          Text(
            l10n.settingsAppliedNote,
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
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: gate,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(l10n.settingsGateHeading),
          Text(
            l10n.settingsGateIntro,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: t.spaceMd),
          SegmentedButton<GateMode>(
            showSelectedIcon: false,
            segments: [
              for (final m in GateMode.values)
                ButtonSegment(value: m, label: Text(m.label(l10n))),
            ],
            selected: {gate.mode},
            onSelectionChanged: (s) => gate.setMode(s.first),
          ),
          SizedBox(height: t.spaceSm),
          Text(gate.mode.description(l10n)),
          SizedBox(height: t.spaceMd),
          Text(
            l10n.settingsGateConfirmNote,
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
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final zoom = EditorZoomScope.maybeOf(context);
    final editor = EditorSettingsScope.maybeOf(context);
    if (zoom == null) return Text(l10n.settingsEditorUnavailable);
    return ListenableBuilder(
      listenable: zoom,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(l10n.settingsFontSize),
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
                tooltip: l10n.settingsResetZoom,
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
            l10n.settingsZoomNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (editor != null) _FontSettings(editor: editor),
          if (editor != null)
            ListenableBuilder(
              listenable: editor,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: t.spaceMd),
                  _Heading(l10n.settingsFormatOnSave),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: editor.formatOnSave,
                    onChanged: editor.setFormatOnSave,
                    title: Text(l10n.settingsFormatOnSave),
                    subtitle: Text(l10n.settingsFormatOnSaveNote),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


/// 편집기 글꼴 이름과 줄 간격. 위의 미리보기가 바로 따라 바뀐다.
class _FontSettings extends StatefulWidget {
  const _FontSettings({required this.editor});

  final EditorSettings editor;

  @override
  State<_FontSettings> createState() => _FontSettingsState();
}

class _FontSettingsState extends State<_FontSettings> {
  late final _name = TextEditingController(text: widget.editor.fontName ?? '');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pick(String? family) {
    _name.text = family ?? '';
    widget.editor.setFontName(family);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final editor = widget.editor;
    return ListenableBuilder(
      listenable: editor,
      builder: (context, _) {
        final lineHeight = editor.lineHeight ?? t.editorText.height ?? 1.45;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsEditorFont),
            TextField(
              controller: _name,
              decoration: InputDecoration(hintText: l10n.settingsEditorFontHint),
              onChanged: editor.setFontName,
            ),
            SizedBox(height: t.spaceSm),
            Wrap(
              spacing: t.spaceSm,
              runSpacing: t.spaceXs,
              children: [
                ChoiceChip(
                  selected: editor.fontName == null,
                  showCheckmark: false,
                  label: Text(l10n.settingsEditorFontDefault),
                  onSelected: (_) => _pick(null),
                ),
                for (final f in EditorSettings.presetFonts)
                  ChoiceChip(
                    selected: editor.fontName == f,
                    showCheckmark: false,
                    label: Text(f),
                    onSelected: (_) => _pick(f),
                  ),
              ],
            ),
            SizedBox(height: t.spaceXs),
            Text(l10n.settingsEditorFontNote, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsLineHeight),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: EditorSettings.minLineHeight,
                    max: EditorSettings.maxLineHeight,
                    divisions: 16,
                    value: lineHeight.clamp(EditorSettings.minLineHeight, EditorSettings.maxLineHeight),
                    label: lineHeight.toStringAsFixed(2),
                    onChanged: editor.setLineHeight,
                  ),
                ),
                SizedBox(width: 56, child: Text(lineHeight.toStringAsFixed(2), textAlign: TextAlign.end)),
                IconButton(
                  tooltip: l10n.settingsLineHeightReset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  onPressed: editor.lineHeight == null ? null : () => editor.setLineHeight(null),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
