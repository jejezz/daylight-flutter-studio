import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../studio/project_index.dart';
import '../theme/app_theme.dart';

/// 빠른 열기 (Ctrl/Cmd+P): 파일 이름 일부를 치면 맞는 파일이 점수 순으로 나온다.
/// 고른 파일의 절대 경로를 돌려준다. 취소하면 null.
Future<String?> showQuickOpen(BuildContext context, {required String root, required Future<List<String>> files}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _QuickOpen(root: root, files: files),
  );
}

class _QuickOpen extends StatefulWidget {
  const _QuickOpen({required this.root, required this.files});

  final String root;
  final Future<List<String>> files;

  @override
  State<_QuickOpen> createState() => _QuickOpenState();
}

class _QuickOpenState extends State<_QuickOpen> {
  final _query = TextEditingController();
  List<String>? _all;
  List<String> _shown = const [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    widget.files.then((f) {
      if (!mounted) return;
      setState(() {
        _all = f;
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
    final all = _all ?? const [];
    _shown = rankFiles(_query.text.trim(), all);
    _selected = 0;
  }

  void _move(int delta) {
    if (_shown.isEmpty) return;
    setState(() => _selected = (_selected + delta).clamp(0, _shown.length - 1));
  }

  void _open(String rel) {
    final sep = Platform.pathSeparator;
    Navigator.of(context).pop('${widget.root}$sep${rel.replaceAll('/', sep)}');
  }

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
                  decoration: InputDecoration(hintText: l10n.quickOpenHint, prefixIcon: Icon(context.icons.search, size: 18)),
                  onChanged: (_) => setState(_refilter),
                  onSubmitted: (_) {
                    if (_shown.isNotEmpty) _open(_shown[_selected]);
                  },
                ),
                SizedBox(height: t.spaceSm),
                Flexible(
                  child: _all == null
                      ? Padding(padding: EdgeInsets.all(t.spaceMd), child: Text(l10n.quickOpenLoading, style: theme.textTheme.bodySmall))
                      : _shown.isEmpty
                      ? Padding(padding: EdgeInsets.all(t.spaceMd), child: Text(l10n.quickOpenNoMatch, style: theme.textTheme.bodySmall))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _shown.length,
                          itemBuilder: (context, i) {
                            final rel = _shown[i];
                            final slash = rel.lastIndexOf('/');
                            return ListTile(
                              dense: true,
                              selected: i == _selected,
                              selectedTileColor: theme.colorScheme.secondaryContainer,
                              title: Text(slash < 0 ? rel : rel.substring(slash + 1)),
                              subtitle: slash < 0 ? null : Text(rel.substring(0, slash), style: context.logText),
                              onTap: () => _open(rel),
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
