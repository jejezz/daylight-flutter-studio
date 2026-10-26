// branch-dock-flutter/lib/ui/shortcut_label.dart 에서 옮김 (Studio 규칙: bd 접두어 문구, context.icons, context.mono).
import 'package:flutter/foundation.dart';

/// 단축키 표시: macOS는 `⌘B`, Windows·Linux는 `Ctrl+B` (ui-ux.md §7).
String shortcutLabel(String key, {bool shift = false}) {
  if (defaultTargetPlatform == TargetPlatform.macOS) return '${shift ? '⇧' : ''}⌘$key';
  final name = key == '⏎' ? 'Enter' : key;
  return 'Ctrl+${shift ? 'Shift+' : ''}$name';
}
