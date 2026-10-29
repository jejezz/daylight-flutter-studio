import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../doctor/environment_controller.dart';
import '../l10n/app_localizations.dart';
import '../settings/gate_settings.dart';
import '../settings/settings_menus.dart';
import '../settings/editor_settings.dart';
import '../settings/terminal_settings.dart';
import '../theme/app_theme.dart';
import '../theme/font_preview.dart';
import '../theme/font_probe.dart';
import '../theme/font_scan.dart';
import '../theme/studio_icons.dart';
import '../theme/editor_theme.dart';
import '../theme/editor_zoom.dart';
import '../theme/theme_controller.dart';
import 'environment_section.dart';

/// 설정 화면의 구역. 왼쪽 목록에 이 순서로 나온다.
enum SettingsSection {
  appearance,
  editor,
  terminal,
  gate,
  environment;

  IconData icon(StudioIcons icons) => switch (this) {
    appearance => icons.palette,
    editor => icons.editNote,
    terminal => icons.terminal,
    gate => icons.shield,
    environment => icons.build,
  };

  String label(AppLocalizations l10n) => switch (this) {
    appearance => l10n.settingsSectionAppearance,
    editor => l10n.settingsSectionEditor,
    terminal => l10n.settingsSectionTerminal,
    gate => l10n.settingsSectionGate,
    environment => l10n.settingsSectionEnvironment,
  };
}

/// 설정 대화상자: 왼쪽에서 구역을 고르고 오른쪽에서 바꾼다. 바꾼 값은 바로 적용되고 저장된다.
Future<void> showSettingsDialog(
  BuildContext context, {
  required ThemeController theme,
  GateSettings? gate,
  EnvironmentController? environment,
  TerminalSettings? terminal,
  SettingsSection initial = SettingsSection.appearance,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        SettingsDialog(theme: theme, gate: gate, environment: environment, terminal: terminal, initial: initial),
  );
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.theme,
    this.gate,
    this.environment,
    this.terminal,
    this.initial = SettingsSection.appearance,
  });

  final ThemeController theme;
  final GateSettings? gate;
  final EnvironmentController? environment;
  final TerminalSettings? terminal;
  final SettingsSection initial;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsSection _section = widget.initial;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
                    if ((s != SettingsSection.terminal || widget.terminal != null) &&
                        (s != SettingsSection.gate || widget.gate != null) &&
                        (s != SettingsSection.environment || widget.environment != null))
                      _SectionTile(
                        selected: s == _section,
                        icon: s.icon(context.icons),
                        label: s.label(AppLocalizations.of(context)),
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
                  SettingsSection.terminal => _TerminalSection(settings: widget.terminal!),
                  SettingsSection.gate => _GateSection(gate: widget.gate!),
                  SettingsSection.environment => EnvironmentSection(
                    controller: widget.environment!,
                    hostIsMac: Platform.isMacOS,
                    hostIsWindows: Platform.isWindows,
                  ),
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

/// 설정 왼쪽 구역 목록의 줄 하나. 고른 구역은 배경을 채우는 대신 왼쪽에 굵은 선을 그어 표시한다 —
/// 배경을 채우면 글자색과 겹칠 수 있어서다(고대비 테마에서 실제로 그랬다). 탭 줄의 밑줄과 같은 생각이다.
class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.selected, required this.icon, required this.label, required this.onTap});

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _barWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = context.tokens;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.spaceSm, horizontal: t.spaceMd),
        decoration: BoxDecoration(
          // 선택 안 됐을 때도 같은 폭을 비워 둬서, 고를 때 글자가 옆으로 밀리지 않게 한다.
          border: Border(left: BorderSide(width: _barWidth, color: selected ? scheme.primary : scheme.primary.withValues(alpha: 0))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: t.spaceSm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 글꼴 이름을 고르는 콤보 상자(입력해서 가까운 항목을 찾아가기).
/// 설치된 글꼴이 수백 개여도(특히 UI 글꼴처럼 고정폭이 아닌 것까지 다 보여 줄 때) 단추를 쭉 늘어놓지 않는다.
class _FontPicker extends StatefulWidget {
  const _FontPicker({required this.value, required this.onChanged, required this.loader, required this.presets, required this.missingText});

  final String? value;
  final ValueChanged<String?> onChanged;
  final Future<List<String>> Function() loader;
  final List<String> presets;

  /// 저장된 글꼴이 이 컴퓨터에 없을 때 보여 줄 경고.
  final String missingText;

  @override
  State<_FontPicker> createState() => _FontPickerState();
}

class _FontPickerState extends State<_FontPicker> {
  late final Future<List<String>> _fonts = _load();

  /// 목록이 길면(한 화면을 넘어설 만큼) 펼친 목록 높이를 제한한다 — 안 그러면 화면을 거의 다 덮는다.
  /// 짧은 목록까지 제한하면 빈 자리가 생겨 항목을 짚는 자리가 어긋난다(실제로 그랬다).
  static const _longListThreshold = 8;
  static const _cappedMenuHeight = 320.0;

  Future<List<String>> _load() async {
    final found = <String>{...await widget.loader(), ...widget.presets};
    final installed = found.where(FontProbe.isInstalled).toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    // 저장된 글꼴이 지금은 없어도(지웠거나 다른 컴퓨터에서 썼던 이름) 목록에 그대로 두어 보여 준다
    // — 아래 경고와 함께 "무엇이 저장되어 있는지"는 알 수 있게.
    final current = widget.value;
    if (current != null && !installed.contains(current)) installed.insert(0, current);
    return installed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    final missing = widget.value != null && !FontProbe.isInstalled(widget.value!);
    return FutureBuilder<List<String>>(
      future: _fonts,
      builder: (context, snapshot) {
        final fonts = snapshot.data ?? const <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownMenu<String?>(
              // expandedInsets(부모 너비에 맞춰 늘이기) 대신 칸 너비를 못 박는다 — 설정 창처럼 내용 칸이
              // SingleChildScrollView 등으로 겹겹이면 늘이기 계산이 어긋나 펼친 목록이 창 밖까지 넘친 적이 있다.
              width: 460,
              menuHeight: fonts.length > _longListThreshold ? _cappedMenuHeight : null,
              // enableFilter(걸러서 줄이기)는 다시 열었을 때 방금 고른 글꼴 이름으로 목록이 걸러져 "기본"
              // 같은 다른 항목이 숨는다 — 대신 기본 enableSearch로 입력한 글자와 가까운 항목을 찾아간다.
              hintText: l10n.settingsEditorFontHint,
              textStyle: fontPreviewStyle(widget.value),
              initialSelection: widget.value,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: l10n.settingsEditorFontDefault, style: fontMenuEntryStyle()),
                for (final f in fonts) DropdownMenuEntry(value: f, label: f, style: fontMenuEntryStyle(f)),
              ],
              onSelected: widget.onChanged,
            ),
            SizedBox(height: t.spaceXs),
            if (missing)
              Text(widget.missingText, style: TextStyle(color: t.warning))
            else
              Text(l10n.settingsEditorFontNote, style: theme.textTheme.bodySmall),
          ],
        );
      },
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.theme});

  final ThemeController theme;

  static String _iconSetLabel(AppLocalizations l10n, StudioIconSet set) => switch (set) {
    StudioIconSet.rounded => l10n.settingsIconSetRounded,
    StudioIconSet.outlined => l10n.settingsIconSetOutlined,
    StudioIconSet.filled => l10n.settingsIconSetFilled,
  };

  static String _palette(AppLocalizations l10n, StudioPalette p) => switch (p) {
    StudioPalette.saturn => l10n.settingsPaletteSaturn,
    StudioPalette.teal => l10n.settingsPaletteTeal,
    StudioPalette.amber => l10n.settingsPaletteAmber,
    StudioPalette.rose => l10n.settingsPaletteRose,
    StudioPalette.slate => l10n.settingsPaletteSlate,
    StudioPalette.highContrast => l10n.settingsPaletteHighContrast,
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
                icon: Icon(context.icons.brightnessAuto, size: 16),
                label: Text(l10n.settingsBrightnessSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(context.icons.lightMode, size: 16),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(context.icons.darkMode, size: 16),
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
                  // 고대비는 주색 하나가 아니라 배경·글자 전부를 바꾸므로 색 원 대신 아이콘으로 구분한다.
                  avatar: p == StudioPalette.highContrast
                      ? Icon(context.icons.contrast, size: 14, color: Theme.of(context).colorScheme.onSurface)
                      : Icon(context.icons.circle, size: 14, color: p.primaryFor(Theme.of(context).brightness)),
                  label: Text(_palette(l10n, p)),
                  onSelected: (_) => theme.setPalette(p),
                ),
            ],
          ),
          SizedBox(height: t.spaceMd),
          _Heading(l10n.languageMenuTooltip),
          const LanguageSegmentedButton(),
          SizedBox(height: t.spaceMd),
          _Heading(l10n.settingsIconSet),
          Wrap(
            spacing: t.spaceSm,
            runSpacing: t.spaceSm,
            children: [
              for (final set in StudioIconSet.values)
                ChoiceChip(
                  selected: theme.iconSet == set,
                  showCheckmark: false,
                  // 세트마다 모양 차이가 뚜렷한(채운 사각형 · 윤곽선 · 둥근 모서리) 아이콘으로 미리 보여 준다.
                  avatar: Icon(StudioIcons(set).checkBox, size: 18),
                  label: Text(_iconSetLabel(l10n, set)),
                  onSelected: (_) => theme.setIconSet(set),
                ),
            ],
          ),
          SizedBox(height: t.spaceMd),
          _UiFontSettings(theme: theme),
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

/// UI 글꼴 이름과 글자 크기 배율. 이 설정 화면 자체가 바로 바뀐 글꼴로 다시 그려지므로 따로 미리보기를
/// 두지 않는다(편집기 글꼴은 편집기만의 글꼴이라 미리보기가 따로 필요하다).
class _UiFontSettings extends StatelessWidget {
  const _UiFontSettings({required this.theme});

  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        final percent = (theme.uiFontScale * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Heading(l10n.settingsUiFont),
            _FontPicker(
              value: theme.uiFontFamily,
              onChanged: theme.setUiFontFamily,
              loader: proportionalFontLoader,
              presets: ThemeController.presetUiFonts,
              missingText: l10n.settingsUiFontMissing,
            ),
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsUiFontScale),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: AppTheme.minUiFontScale,
                    max: AppTheme.maxUiFontScale,
                    divisions: ((AppTheme.maxUiFontScale - AppTheme.minUiFontScale) / 0.05).round(),
                    value: theme.uiFontScale,
                    label: '$percent%',
                    onChanged: theme.setUiFontScale,
                  ),
                ),
                SizedBox(width: 56, child: Text('$percent%', textAlign: TextAlign.end)),
                IconButton(
                  tooltip: l10n.settingsResetZoom,
                  icon: Icon(context.icons.restartAlt, size: 18),
                  onPressed: theme.uiFontScale == AppTheme.defaultUiFontScale
                      ? null
                      : () => theme.setUiFontScale(AppTheme.defaultUiFontScale),
                ),
              ],
            ),
            SizedBox(height: t.spaceXs),
            Text(l10n.settingsUiFontScaleNote, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      },
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
          Text(l10n.settingsGateIntro, style: theme.textTheme.bodySmall),
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
          Text(l10n.settingsGateConfirmNote, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
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
                icon: Icon(context.icons.restartAlt, size: 18),
                onPressed: zoom.isDefault ? null : zoom.reset,
              ),
            ],
          ),
          SizedBox(height: t.spaceSm),
          Text(
            l10n.settingsZoomNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (editor != null) _FontSettings(editor: editor),
          SizedBox(height: t.spaceMd),
          _Heading(l10n.settingsPreview),
          const _Preview(),
          if (editor != null)
            ListenableBuilder(
              listenable: editor,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: t.spaceMd),
                  _Heading(l10n.settingsIndentGuides),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: editor.indentGuides,
                    onChanged: editor.setIndentGuides,
                    title: Text(l10n.settingsIndentGuides),
                    subtitle: Text(l10n.settingsIndentGuidesNote),
                  ),
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

class _TerminalSection extends StatelessWidget {
  const _TerminalSection({required this.settings});

  final TerminalSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.shareEditorFont,
            onChanged: settings.setShareEditorFont,
            title: Text(l10n.settingsTerminalShareFont),
            subtitle: Text(l10n.settingsTerminalShareFontNote),
          ),
          if (!settings.shareEditorFont) ...[
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsTerminalFont),
            _FontPicker(
              value: settings.fontName,
              onChanged: settings.setFontName,
              loader: monospaceFontLoader,
              presets: EditorSettings.presetFonts,
              missingText: l10n.settingsEditorFontMissing,
            ),
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsTerminalFontSize),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: TerminalSettings.minSize,
                    max: TerminalSettings.maxSize,
                    divisions: (TerminalSettings.maxSize - TerminalSettings.minSize).round(),
                    value: settings.size,
                    label: settings.size.toStringAsFixed(0),
                    onChanged: settings.setSize,
                  ),
                ),
                SizedBox(width: 40, child: Text(settings.size.toStringAsFixed(0), textAlign: TextAlign.end)),
              ],
            ),
          ],
          SizedBox(height: t.spaceMd),
          _Heading(l10n.settingsTerminalScrollback),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: TerminalSettings.minScrollback.toDouble(),
                  max: TerminalSettings.maxScrollback.toDouble(),
                  value: settings.scrollback.toDouble(),
                  label: '${settings.scrollback}',
                  onChanged: (v) => settings.setScrollback((v / 500).round() * 500),
                ),
              ),
              SizedBox(width: 56, child: Text('${settings.scrollback}', textAlign: TextAlign.end)),
            ],
          ),
          SizedBox(height: t.spaceSm),
          Text(l10n.settingsTerminalScrollbackNote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

const _previewSample = "void main() {\n  print('Hello, Flutter');\n  if (a != b && c >= d) return;\n}";

/// 글자 크기·글꼴·줄 간격이 바뀌면 바로 따라 바뀌는 편집기 미리보기.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(t.radius),
      ),
      child: Text(
        _previewSample,
        strutStyle: editorStrutStyle(context),
        style: editorTextStyle(context).copyWith(color: scheme.onSurface),
      ),
    );
  }
}

/// 편집기 글꼴 이름과 줄 간격. 위의 미리보기가 바로 따라 바뀐다.
class _FontSettings extends StatelessWidget {
  const _FontSettings({required this.editor});

  final EditorSettings editor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: editor,
      builder: (context, _) {
        final lineHeight = editor.lineHeight ?? t.editorText.height ?? 1.45;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsEditorFont),
            // 코드 미리보기는 아래 _Preview가 따로 보여 주므로 여기서는 미리보기 글을 두지 않는다.
            _FontPicker(
              value: editor.fontName,
              onChanged: editor.setFontName,
              loader: monospaceFontLoader,
              presets: EditorSettings.presetFonts,
              missingText: l10n.settingsEditorFontMissing,
            ),
            SizedBox(height: t.spaceMd),
            _Heading(l10n.settingsLineHeight),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: EditorSettings.minLineHeight,
                    max: EditorSettings.maxLineHeight,
                    divisions: 16,
                    value: lineHeight.clamp(
                      EditorSettings.minLineHeight,
                      EditorSettings.maxLineHeight,
                    ),
                    label: lineHeight.toStringAsFixed(2),
                    onChanged: editor.setLineHeight,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    lineHeight.toStringAsFixed(2),
                    textAlign: TextAlign.end,
                  ),
                ),
                IconButton(
                  tooltip: l10n.settingsLineHeightReset,
                  icon: Icon(context.icons.restartAlt, size: 18),
                  onPressed: editor.lineHeight == null
                      ? null
                      : () => editor.setLineHeight(null),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: editor.ligatures,
              onChanged: editor.setLigatures,
              title: Text(l10n.settingsLigatures),
              subtitle: Text(l10n.settingsLigaturesNote),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: editor.logFollowsEditor,
              onChanged: editor.setLogFollowsEditor,
              title: Text(l10n.settingsLogShareFont),
              subtitle: Text(l10n.settingsLogShareFontNote),
            ),
          ],
        );
      },
    );
  }
}
