import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../studio/symbol_index.dart';
import '../theme/app_theme.dart';

/// 심볼로 이동 (Ctrl/Cmd+Shift+O): 클래스·함수·메서드 이름 일부를 치면 맞는 선언이 나온다.
/// [initialQuery]로 시작하면 바로 그 이름으로 걸러 보여 준다 (정의로 이동에서 같은 이름이 여럿일 때).
/// 고른 선언을 돌려준다. 취소하면 null.
Future<DartSymbol?> showSymbolSearch(
  BuildContext context, {
  required String root,
  required Future<List<DartSymbol>> symbols,
  String initialQuery = '',
}) {
  return showDialog<DartSymbol>(
    context: context,
    builder: (context) => _SymbolSearch(root: root, symbols: symbols, initialQuery: initialQuery),
  );
}

class _SymbolSearch extends StatefulWidget {
  const _SymbolSearch({required this.root, required this.symbols, required this.initialQuery});

  final String root;
  final Future<List<DartSymbol>> symbols;
  final String initialQuery;

  @override
  State<_SymbolSearch> createState() => _SymbolSearchState();
}

class _SymbolSearchState extends State<_SymbolSearch> {
  late final _query = TextEditingController(text: widget.initialQuery);
  List<DartSymbol>? _all;
  List<DartSymbol> _shown = const [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    widget.symbols.then((all) {
      if (!mounted) return;
      setState(() {
        _all = all;
        _refilter();
      });
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _refilter() {
    _shown = rankSymbols(_query.text, _all ?? const []);
    _selected = 0;
  }

  void _move(int delta) {
    if (_shown.isEmpty) return;
    setState(() => _selected = (_selected + delta).clamp(0, _shown.length - 1));
  }

  String _relative(String path) =>
      path.startsWith(widget.root) ? path.substring(widget.root.length).replaceFirst(RegExp(r'^[/\\]'), '').replaceAll('\\', '/') : path;

  String _kindLabel(AppLocalizations l10n, SymbolKind kind) => switch (kind) {
    SymbolKind.classType => l10n.symbolKindClass,
    SymbolKind.mixin => l10n.symbolKindMixin,
    SymbolKind.enumType => l10n.symbolKindEnum,
    SymbolKind.extension => l10n.symbolKindExtension,
    SymbolKind.typedef => l10n.symbolKindTypedef,
    SymbolKind.function => l10n.symbolKindFunction,
    SymbolKind.method => l10n.symbolKindMethod,
    SymbolKind.getter => l10n.symbolKindGetter,
    SymbolKind.setter => l10n.symbolKindSetter,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.only(top: 80, left: t.spaceLg, right: t.spaceLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 460),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
          },
          child: Padding(
            padding: EdgeInsets.all(t.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _query,
                  autofocus: true,
                  decoration: InputDecoration(hintText: l10n.symbolSearchHint, prefixIcon: Icon(context.icons.search, size: 18)),
                  onChanged: (_) => setState(_refilter),
                  onSubmitted: (_) {
                    if (_shown.isNotEmpty) Navigator.of(context).pop(_shown[_selected]);
                  },
                ),
                SizedBox(height: t.spaceSm),
                Flexible(
                  child: _all == null
                      ? Padding(padding: EdgeInsets.all(t.spaceMd), child: Text(l10n.symbolSearchLoading, style: theme.textTheme.bodySmall))
                      : _shown.isEmpty
                      ? Padding(padding: EdgeInsets.all(t.spaceMd), child: Text(l10n.symbolSearchNoMatch, style: theme.textTheme.bodySmall))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _shown.length,
                          itemBuilder: (context, i) {
                            final s = _shown[i];
                            return ListTile(
                              dense: true,
                              selected: i == _selected,
                              selectedTileColor: theme.colorScheme.secondaryContainer,
                              title: Text(s.container == null ? s.name : '${s.container}.${s.name}'),
                              subtitle: Text('${_kindLabel(l10n, s.kind)} · ${_relative(s.path)}:${s.line}', style: context.logText),
                              onTap: () => Navigator.of(context).pop(s),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
