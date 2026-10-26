import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 메뉴 막대에 들어가는 한 칸. 플랫폼에 따라 Material [MenuBar](Windows·Linux)나
/// [PlatformMenuBar](macOS)로 그려진다.
sealed class MenuNode {
  const MenuNode();
}

class MenuAction extends MenuNode {
  const MenuAction(this.label, {this.onPressed, this.shortcut, this.nativeShortcut = true});

  final String label;

  /// null이면 비활성.
  final VoidCallback? onPressed;

  /// 단축키 표시. 실제 동작은 화면의 단축키 바인딩이 한다.
  final SingleActivator? shortcut;

  /// macOS에서 단축키를 시스템 메뉴에 등록할지. 편집 메뉴는 false로 둔다 —
  /// 등록하면 Cmd+C/V가 메뉴에 먼저 잡혀서 대화상자의 입력 칸까지 복사·붙여넣기가 안 된다.
  final bool nativeShortcut;
}

class MenuDivider extends MenuNode {
  const MenuDivider();
}

class SubMenu extends MenuNode {
  const SubMenu(this.label, this.children);

  final String label;
  final List<MenuNode> children;
}

/// 메뉴 막대의 최상위 메뉴 하나 (파일, 편집 …).
class MenuSpec {
  const MenuSpec(this.label, this.children);

  final String label;
  final List<MenuNode> children;
}

/// `Ctrl+Shift+F` 같은 단축키 표시 글. macOS는 기호(⌘⇧⌥⌃)를 쓴다.
String shortcutLabel(SingleActivator a, {required bool mac}) {
  final key = _keyLabel(a.trigger);
  if (mac) return '${a.control ? '⌃' : ''}${a.alt ? '⌥' : ''}${a.shift ? '⇧' : ''}${a.meta ? '⌘' : ''}$key';
  return [if (a.control) 'Ctrl', if (a.alt) 'Alt', if (a.shift) 'Shift', if (a.meta) 'Win', key].join('+');
}

String _keyLabel(LogicalKeyboardKey k) {
  if (k == LogicalKeyboardKey.comma) return ',';
  if (k == LogicalKeyboardKey.equal) return '+';
  if (k == LogicalKeyboardKey.minus) return '-';
  return k.keyLabel.length == 1 ? k.keyLabel.toUpperCase() : k.keyLabel;
}

/// Windows·Linux의 창 안 메뉴 막대. 단축키는 글자로만 보여 준다 — 실제 단축키는 화면이 이미 처리하므로
/// Material 메뉴에 등록하면 한 번 누른 키가 두 번 실행된다.
class StudioMenuBar extends StatelessWidget {
  const StudioMenuBar({super.key, required this.menus});

  final List<MenuSpec> menus;

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [for (final m in menus) SubmenuButton(menuChildren: _items(context, m.children), child: Text(m.label))],
    );
  }

  List<Widget> _items(BuildContext context, List<MenuNode> nodes) {
    final text = Theme.of(context).textTheme.bodySmall;
    return [
      for (final n in nodes)
        switch (n) {
          MenuAction() => MenuItemButton(
            onPressed: n.onPressed,
            trailingIcon: n.shortcut == null ? null : Text(shortcutLabel(n.shortcut!, mac: false), style: text),
            child: Text(n.label),
          ),
          MenuDivider() => const Divider(height: 1),
          SubMenu() => SubmenuButton(menuChildren: _items(context, n.children), child: Text(n.label)),
        },
    ];
  }
}

/// macOS 메뉴 막대용 변환. 구분선은 [PlatformMenuItemGroup]의 경계가 된다.
List<PlatformMenu> toPlatformMenus(List<MenuSpec> menus) => [for (final m in menus) PlatformMenu(label: m.label, menus: _platformItems(m.children))];

List<PlatformMenuItem> _platformItems(List<MenuNode> nodes) {
  final groups = <List<PlatformMenuItem>>[[]];
  for (final n in nodes) {
    switch (n) {
      case MenuDivider():
        if (groups.last.isNotEmpty) groups.add([]);
      case MenuAction():
        groups.last.add(PlatformMenuItem(label: n.label, onSelected: n.onPressed, shortcut: n.nativeShortcut ? n.shortcut : null));
      case SubMenu():
        groups.last.add(PlatformMenu(label: n.label, menus: _platformItems(n.children)));
    }
  }
  return [for (final g in groups) if (g.isNotEmpty) PlatformMenuItemGroup(members: g)];
}

/// 화면이 만든 메뉴를 앱 맨 위의 macOS 메뉴 막대(`AppMenuBar`)에 전해 주는 통로.
/// 메뉴 막대는 Navigator 위에 있어서 화면의 콜백을 직접 볼 수 없다.
class StudioMenuHost extends InheritedWidget {
  const StudioMenuHost({super.key, required this.menus, required super.child});

  final ValueNotifier<List<PlatformMenu>> menus;

  static ValueNotifier<List<PlatformMenu>>? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<StudioMenuHost>()?.menus;

  @override
  bool updateShouldNotify(StudioMenuHost oldWidget) => menus != oldWidget.menus;
}
