import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// 앱 바의 테마 메뉴: 밝기(시스템/라이트/다크)와 색 구성.
class ThemeMenu extends StatelessWidget {
  const ThemeMenu({super.key, required this.controller});

  final ThemeController controller;

  static String _modeLabel(ThemeMode m) => switch (m) {
    ThemeMode.system => '시스템',
    ThemeMode.light => '라이트',
    ThemeMode.dark => '다크',
  };

  static String _paletteLabel(StudioPalette p) => switch (p) {
    StudioPalette.indigo => '인디고',
    StudioPalette.teal => '청록',
    StudioPalette.amber => '호박',
    StudioPalette.rose => '장미',
    StudioPalette.slate => '슬레이트',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MenuAnchor(
        builder: (context, menu, _) => IconButton(
          tooltip: '테마',
          icon: const Icon(Icons.palette_outlined),
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        ),
        menuChildren: [
          for (final m in ThemeMode.values)
            MenuItemButton(
              leadingIcon: Icon(controller.mode == m ? Icons.radio_button_checked : Icons.radio_button_off, size: 18),
              onPressed: () => controller.setMode(m),
              child: Text(_modeLabel(m)),
            ),
          const Divider(),
          for (final p in StudioPalette.values)
            MenuItemButton(
              leadingIcon: Icon(Icons.circle, size: 18, color: p.seed),
              trailingIcon: controller.palette == p ? const Icon(Icons.check, size: 18) : null,
              onPressed: () => controller.setPalette(p),
              child: Text(_paletteLabel(p)),
            ),
        ],
      ),
    );
  }
}
