import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../studio/project_index.dart';
import '../studio/project_replace.dart';
import '../theme/app_theme.dart';

/// 프로젝트에서 찾기 (Ctrl/Cmd+Shift+F). 결과를 누르면 [onOpen]이 그 줄을 연다 (대화상자는 열어 둔다).
///
/// 바꾸기를 켜면 결과를 줄 단위로 골라 바꿀 수 있다. [isBusy]가 true인 파일(수정 중인 탭이 열려 있는 파일)은
/// 건너뛰고, 파일을 바꾸거나 되돌린 뒤에는 [onReplaced]를 불러 화면이 디스크를 다시 읽게 한다.
Future<void> showProjectSearch(
  BuildContext context, {
  required String root,
  required Future<List<String>> files,
  required void Function(String path, int line, int column) onOpen,
  SearchFn search = searchProject,
  bool Function(String path)? isBusy,
  VoidCallback? onReplaced,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ProjectSearch(root: root, files: files, onOpen: onOpen, search: search, isBusy: isBusy, onReplaced: onReplaced),
  );
}

typedef SearchFn = Future<SearchResult> Function(String root, List<String> files, String query, {bool caseSensitive, bool regex});

class _ProjectSearch extends StatefulWidget {
  const _ProjectSearch({
    required this.root,
    required this.files,
    required this.onOpen,
    required this.search,
    required this.isBusy,
    required this.onReplaced,
  });

  final String root;
  final Future<List<String>> files;
  final void Function(String path, int line, int column) onOpen;
  final SearchFn search;
  final bool Function(String path)? isBusy;
  final VoidCallback? onReplaced;

  @override
  State<_ProjectSearch> createState() => _ProjectSearchState();
}

class _ProjectSearchState extends State<_ProjectSearch> {
  final _query = TextEditingController();
  final _replace = TextEditingController();
  bool _caseSensitive = false;
  bool _regex = false;
  bool _replaceMode = false;
  bool _searching = false;
  bool _working = false;
  SearchResult? _result;
  int _run = 0;

  /// 검색을 실행한 때의 설정 — 그 뒤에 입력칸을 고쳐도 미리보기·바꾸기는 이 패턴으로 한다.
  RegExp? _pattern;
  bool _ranRegex = false;

  /// 바꿀 줄로 고른 결과 번호.
  Set<int> _selected = {};

  /// 마지막 바꾸기·되돌리기 결과 안내, 그리고 되돌릴 기록.
  String? _note;
  ReplaceSession? _undo;

  @override
  void dispose() {
    _query.dispose();
    _replace.dispose();
    super.dispose();
  }

  Future<void> _go({bool keepNote = false}) async {
    final q = _query.text;
    if (q.isEmpty) return;
    final run = ++_run;
    setState(() {
      _searching = true;
      if (!keepNote) _note = null;
    });
    final files = await widget.files;
    final r = await widget.search(widget.root, files, q, caseSensitive: _caseSensitive, regex: _regex);
    if (!mounted || run != _run) return;
    setState(() {
      _result = r;
      _pattern = buildSearchPattern(q, caseSensitive: _caseSensitive, regex: _regex);
      _ranRegex = _regex;
      _selected = {for (var i = 0; i < r.hits.length; i++) i};
      _searching = false;
    });
  }

  String _relative(String path) =>
      path.startsWith(widget.root) ? path.substring(widget.root.length).replaceFirst(RegExp(r'^[/\\]'), '') : path;

  /// 결과를 파일별로 묶는다 (결과는 이미 파일 순서대로다).
  List<(String, List<int>)> _groups(List<SearchHit> hits) {
    final out = <(String, List<int>)>[];
    for (var i = 0; i < hits.length; i++) {
      if (out.isEmpty || out.last.$1 != hits[i].path) {
        out.add((hits[i].path, [i]));
      } else {
        out.last.$2.add(i);
      }
    }
    return out;
  }

  void _toggleGroup(List<int> indexes) {
    setState(() {
      if (indexes.every(_selected.contains)) {
        _selected = {..._selected}..removeAll(indexes);
      } else {
        _selected = {..._selected, ...indexes};
      }
    });
  }

  void _toggle(int i) => setState(() => _selected = _selected.contains(i) ? ({..._selected}..remove(i)) : {..._selected, i});

  Future<void> _apply() async {
    final r = _result;
    final re = _pattern;
    if (r == null || re == null || _selected.isEmpty || _working) return;
    final byFile = <String, Set<int>>{};
    for (final i in _selected) {
      (byFile[r.hits[i].path] ??= {}).add(r.hits[i].line);
    }
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.findReplaceOne),
        content: Text(l10n.searchConfirmBody(byFile.length, _selected.length)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.findReplaceOne)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _working = true);
    final out = await ReplaceSession.apply(byFile, re, _replace.text, regex: _ranRegex, isBusy: widget.isBusy);
    if (!mounted) return;
    widget.onReplaced?.call();
    final parts = <String>[
      if (out.changes.isEmpty) l10n.searchNothingReplaced else l10n.searchReplaceDone(out.files, out.lines),
      if (out.skippedFiles > 0) l10n.searchSkippedBusy(out.skippedFiles),
      if (out.failedFiles > 0) l10n.searchReplaceFailed(out.failedFiles),
    ];
    setState(() {
      _working = false;
      _note = parts.join('\n');
      // 아무것도 바꾸지 못했으면 이전 기록은 그대로 되돌릴 수 있다.
      if (out.changes.isNotEmpty) _undo = ReplaceSession(out.changes);
    });
    await _go(keepNote: true);
  }

  Future<void> _undoLast() async {
    final session = _undo;
    if (session == null || _working) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _working = true);
    final out = await session.undo();
    if (!mounted) return;
    widget.onReplaced?.call();
    setState(() {
      _working = false;
      _undo = null;
      _note = [l10n.searchUndoDone(out.restored), if (out.skipped > 0) l10n.searchUndoSkipped(out.skipped)].join('\n');
    });
    await _go(keepNote: true);
  }

  Widget _hitRow(BuildContext context, SearchHit h, int i) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final re = _pattern;
    final after = _replaceMode && re != null ? replaceInLine(h.text, re, _replace.text, regex: _ranRegex) : null;
    return InkWell(
      onTap: () => widget.onOpen(h.path, h.line, h.column),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.spaceXs / 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replaceMode)
              Checkbox(
                value: _selected.contains(i),
                visualDensity: VisualDensity.compact,
                onChanged: (_) => _toggle(i),
              )
            else
              SizedBox(width: t.spaceLg),
            SizedBox(width: 44, child: Text('${h.line}', textAlign: TextAlign.end, style: theme.textTheme.bodySmall)),
            SizedBox(width: t.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.logText),
                  if (after != null && after != h.text)
                    Text(after, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.logText.copyWith(color: t.success)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupHeader(BuildContext context, String path, List<int> indexes) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final all = indexes.every(_selected.contains);
    final none = !indexes.any(_selected.contains);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.symmetric(vertical: t.spaceXs / 2),
      child: Row(
        children: [
          if (_replaceMode)
            Checkbox(
              value: all ? true : (none ? false : null),
              tristate: true,
              visualDensity: VisualDensity.compact,
              onChanged: (_) => _toggleGroup(indexes),
            )
          else
            SizedBox(width: t.spaceLg),
          Expanded(child: Text(_relative(path), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge)),
          Text('${indexes.length}', style: theme.textTheme.bodySmall),
          SizedBox(width: t.spaceSm),
        ],
      ),
    );
  }

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
    final groups = r == null ? const <(String, List<int>)>[] : _groups(r.hits);
    // 머리줄과 결과 줄을 한 목록으로 펼친다.
    final rows = <Widget>[
      if (r != null)
        for (final (path, indexes) in groups) ...[
          _groupHeader(context, path, indexes),
          for (final i in indexes) _hitRow(context, r.hits[i], i),
        ],
    ];
    return AlertDialog(
      title: Text(l10n.searchTitle),
      content: SizedBox(
        width: 760,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.findToggleReplace,
                  icon: Icon(_replaceMode ? context.icons.keyboardArrowDown : context.icons.keyboardArrowRight),
                  onPressed: () => setState(() => _replaceMode = !_replaceMode),
                ),
                Expanded(
                  child: TextField(
                    controller: _query,
                    autofocus: true,
                    decoration: InputDecoration(hintText: l10n.searchHint, prefixIcon: Icon(context.icons.search, size: 18)),
                    onSubmitted: (_) => _go(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.findMatchCase,
                  isSelected: _caseSensitive,
                  icon: Icon(context.icons.textFields),
                  onPressed: () => setState(() => _caseSensitive = !_caseSensitive),
                ),
                IconButton(
                  tooltip: l10n.findRegex,
                  isSelected: _regex,
                  icon: Icon(context.icons.code),
                  onPressed: () => setState(() => _regex = !_regex),
                ),
              ],
            ),
            if (_replaceMode) ...[
              SizedBox(height: t.spaceSm),
              Row(
                children: [
                  SizedBox(width: 48),
                  Expanded(
                    child: TextField(
                      controller: _replace,
                      decoration: InputDecoration(hintText: l10n.findReplaceHint),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: t.spaceSm),
                  FilledButton(
                    onPressed: _selected.isEmpty || _pattern == null || _working || _searching ? null : _apply,
                    child: Text(l10n.searchReplaceSelected(_selected.length)),
                  ),
                ],
              ),
            ],
            SizedBox(height: t.spaceSm),
            if (status != null) Text(status, style: theme.textTheme.bodySmall),
            if (_note != null || _undo != null)
              Padding(
                padding: EdgeInsets.only(top: t.spaceXs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(_note ?? '', style: theme.textTheme.bodySmall)),
                    if (_undo != null) TextButton(onPressed: _working ? null : _undoLast, child: Text(l10n.searchUndo)),
                  ],
                ),
              ),
            SizedBox(height: t.spaceXs),
            Expanded(child: r == null ? const SizedBox.shrink() : ListView(children: rows)),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonClose))],
    );
  }
}
