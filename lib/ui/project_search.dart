import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../studio/project_index.dart';
import '../theme/app_theme.dart';

/// 프로젝트에서 찾기 (Ctrl/Cmd+Shift+F). 결과를 누르면 [onOpen]이 그 줄을 연다 (대화상자는 열어 둔다).
Future<void> showProjectSearch(
  BuildContext context, {
  required String root,
  required Future<List<String>> files,
  required void Function(String path, int line, int column) onOpen,
  SearchFn search = searchProject,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ProjectSearch(root: root, files: files, onOpen: onOpen, search: search),
  );
}

typedef SearchFn = Future<SearchResult> Function(String root, List<String> files, String query, {bool caseSensitive, bool regex});

class _ProjectSearch extends StatefulWidget {
  const _ProjectSearch({required this.root, required this.files, required this.onOpen, required this.search});

  final String root;
  final Future<List<String>> files;
  final void Function(String path, int line, int column) onOpen;
  final SearchFn search;

  @override
  State<_ProjectSearch> createState() => _ProjectSearchState();
}

class _ProjectSearchState extends State<_ProjectSearch> {
  final _query = TextEditingController();
  bool _caseSensitive = false;
  bool _regex = false;
  bool _searching = false;
  SearchResult? _result;
  int _run = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final q = _query.text;
    if (q.isEmpty) return;
    final run = ++_run;
    setState(() => _searching = true);
    final files = await widget.files;
    final r = await widget.search(widget.root, files, q, caseSensitive: _caseSensitive, regex: _regex);
    if (!mounted || run != _run) return;
    setState(() {
      _result = r;
      _searching = false;
    });
  }

  String _relative(String path) =>
      path.startsWith(widget.root) ? path.substring(widget.root.length).replaceFirst(RegExp(r'^[/\\]'), '') : path;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final theme = Theme.of(context);
    final r = _result;
    final String? status = _searching
        ? l10n.searchSearching
        : r == null
        ? null
        : r.invalidPattern
        ? l10n.searchInvalidPattern
        : r.hits.isEmpty
        ? l10n.searchNoResults
        : r.truncated
        ? l10n.searchTruncated(r.hits.length)
        : l10n.searchResultCount(r.hits.length);
    return AlertDialog(
      title: Text(l10n.searchTitle),
      content: SizedBox(
        width: 720,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    autofocus: true,
                    decoration: InputDecoration(hintText: l10n.searchHint, prefixIcon: const Icon(Icons.search, size: 18)),
                    onSubmitted: (_) => _go(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.findMatchCase,
                  isSelected: _caseSensitive,
                  icon: const Icon(Icons.text_fields),
                  onPressed: () => setState(() => _caseSensitive = !_caseSensitive),
                ),
                IconButton(
                  tooltip: l10n.findRegex,
                  isSelected: _regex,
                  icon: const Icon(Icons.code),
                  onPressed: () => setState(() => _regex = !_regex),
                ),
              ],
            ),
            SizedBox(height: t.spaceSm),
            if (status != null) Text(status, style: theme.textTheme.bodySmall),
            SizedBox(height: t.spaceXs),
            Expanded(
              child: r == null
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: r.hits.length,
                      itemBuilder: (context, i) {
                        final h = r.hits[i];
                        return ListTile(
                          dense: true,
                          title: Text(h.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.logText),
                          subtitle: Text('${_relative(h.path)}:${h.line}', style: theme.textTheme.bodySmall),
                          onTap: () => widget.onOpen(h.path, h.line, h.column),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonClose))],
    );
  }
}
