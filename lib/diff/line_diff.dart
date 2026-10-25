/// 줄 단위 diff (Myers). 편집기의 변경 표시와 변경점 보기가 함께 쓴다.
library;

import 'package:flutter/foundation.dart';

enum BlockKind { equal, change }

/// 같은 줄 묶음, 또는 바뀐 묶음. 바뀐 묶음은 옛 글의 [aLen]줄이 새 글의 [bLen]줄로 바뀐 것이다
/// ([aLen]이 0이면 추가, [bLen]이 0이면 삭제, 둘 다 있으면 수정).
@immutable
class DiffBlock {
  const DiffBlock(this.kind, this.aStart, this.aLen, this.bStart, this.bLen);

  final BlockKind kind;
  final int aStart;
  final int aLen;
  final int bStart;
  final int bLen;

  int get aEnd => aStart + aLen;
  int get bEnd => bStart + bLen;

  bool get isChange => kind == BlockKind.change;

  @override
  bool operator ==(Object other) =>
      other is DiffBlock &&
      other.kind == kind &&
      other.aStart == aStart &&
      other.aLen == aLen &&
      other.bStart == bStart &&
      other.bLen == bLen;

  @override
  int get hashCode => Object.hash(kind, aStart, aLen, bStart, bLen);

  @override
  String toString() => '${kind.name}(a:$aStart+$aLen, b:$bStart+$bLen)';
}

/// 글을 줄로 나눈다. 끝의 줄바꿈은 빈 줄을 만들지 않고, 줄 끝의 `\r`은 뗀다 (CRLF/LF 차이는 변경이 아니다).
List<String> splitLines(String text) {
  if (text.isEmpty) return const [];
  final lines = text.split('\n');
  if (lines.last.isEmpty) lines.removeLast();
  return [for (final l in lines) l.endsWith('\r') ? l.substring(0, l.length - 1) : l];
}

/// [a]에서 [b]로 바뀐 곳을 찾는다.
///
/// 앞뒤의 같은 줄을 먼저 떼어 내고 가운데만 Myers로 비교한다. 바뀐 줄 수가 [maxEdits]를 넘으면
/// (거의 다른 파일) 가운데 전체를 하나의 변경으로 본다.
List<DiffBlock> diffLines(List<String> a, List<String> b, {int maxEdits = 1000}) {
  var prefix = 0;
  while (prefix < a.length && prefix < b.length && a[prefix] == b[prefix]) {
    prefix++;
  }
  var aEnd = a.length;
  var bEnd = b.length;
  while (aEnd > prefix && bEnd > prefix && a[aEnd - 1] == b[bEnd - 1]) {
    aEnd--;
    bEnd--;
  }

  final blocks = <DiffBlock>[];
  void add(BlockKind kind, int aStart, int aLen, int bStart, int bLen) {
    if (aLen == 0 && bLen == 0) return;
    if (blocks.isNotEmpty) {
      final last = blocks.last;
      if (last.kind == kind && last.aEnd == aStart && last.bEnd == bStart) {
        blocks[blocks.length - 1] = DiffBlock(kind, last.aStart, last.aLen + aLen, last.bStart, last.bLen + bLen);
        return;
      }
    }
    blocks.add(DiffBlock(kind, aStart, aLen, bStart, bLen));
  }

  add(BlockKind.equal, 0, prefix, 0, prefix);
  final n = aEnd - prefix;
  final m = bEnd - prefix;
  if (n > 0 || m > 0) {
    final script = (n == 0 || m == 0) ? null : _myers(a, b, prefix, n, m, maxEdits);
    if (script == null) {
      add(BlockKind.change, prefix, n, prefix, m);
    } else {
      var ia = prefix;
      var ib = prefix;
      for (final op in script) {
        switch (op) {
          case _equal:
            add(BlockKind.equal, ia, 1, ib, 1);
            ia++;
            ib++;
          case _delete:
            add(BlockKind.change, ia, 1, ib, 0);
            ia++;
          default:
            add(BlockKind.change, ia, 0, ib, 1);
            ib++;
        }
      }
    }
  }
  add(BlockKind.equal, aEnd, a.length - aEnd, bEnd, b.length - bEnd);
  return blocks;
}

const _equal = 0;
const _delete = 1;
const _insert = 2;

/// 가운데 구간 [off, off+n) / [off, off+m)의 편집 순서. 바뀐 줄이 [cap]를 넘으면 null.
List<int>? _myers(List<String> a, List<String> b, int off, int n, int m, int cap) {
  final max = (n + m) < cap ? n + m : cap;
  final offset = max + 1;
  final v = List<int>.filled(2 * max + 3, 0);
  final trace = <List<int>>[];
  for (var d = 0; d <= max; d++) {
    trace.add(List<int>.of(v));
    for (var k = -d; k <= d; k += 2) {
      int x;
      if (k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1])) {
        x = v[offset + k + 1];
      } else {
        x = v[offset + k - 1] + 1;
      }
      var y = x - k;
      while (x < n && y < m && a[off + x] == b[off + y]) {
        x++;
        y++;
      }
      v[offset + k] = x;
      if (x >= n && y >= m) return _backtrack(trace, d, n, m, offset);
    }
  }
  return null;
}

List<int> _backtrack(List<List<int>> trace, int total, int n, int m, int offset) {
  final script = <int>[];
  var x = n;
  var y = m;
  for (var d = total; d > 0; d--) {
    final prev = trace[d];
    final k = x - y;
    final int prevK;
    if (k == -d || (k != d && prev[offset + k - 1] < prev[offset + k + 1])) {
      prevK = k + 1;
    } else {
      prevK = k - 1;
    }
    final prevX = prev[offset + prevK];
    final prevY = prevX - prevK;
    while (x > prevX && y > prevY) {
      script.add(_equal);
      x--;
      y--;
    }
    if (x == prevX) {
      script.add(_insert);
      y--;
    } else {
      script.add(_delete);
      x--;
    }
  }
  while (x > 0 && y > 0) {
    script.add(_equal);
    x--;
    y--;
  }
  return script.reversed.toList();
}

/// 편집기 줄 번호 옆에 그릴 변경 표시. 줄 번호는 새 글 기준의 0부터다.
@immutable
class ChangeMarks {
  const ChangeMarks({this.added = const {}, this.modified = const {}, this.deletedBefore = const {}});

  static const empty = ChangeMarks();

  /// 새로 생긴 줄.
  final Set<int> added;

  /// 바뀐 줄.
  final Set<int> modified;

  /// 이 줄 바로 앞에서 줄이 지워졌다 (파일 끝이면 줄 수와 같은 번호).
  final Set<int> deletedBefore;

  bool get isEmpty => added.isEmpty && modified.isEmpty && deletedBefore.isEmpty;

  /// [first, first+count) 줄 중 하나라도 새로 생겼거나 바뀌었는가.
  bool touches(Set<int> set, int first, int count) {
    for (var i = first; i < first + count; i++) {
      if (set.contains(i)) return true;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is ChangeMarks &&
      setEquals(other.added, added) &&
      setEquals(other.modified, modified) &&
      setEquals(other.deletedBefore, deletedBefore);

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(added), Object.hashAllUnordered(modified), Object.hashAllUnordered(deletedBefore));
}

ChangeMarks marksFromBlocks(List<DiffBlock> blocks) {
  final added = <int>{};
  final modified = <int>{};
  final deleted = <int>{};
  for (final b in blocks) {
    if (!b.isChange) continue;
    if (b.bLen == 0) {
      deleted.add(b.bStart);
    } else {
      final target = b.aLen == 0 ? added : modified;
      for (var i = b.bStart; i < b.bEnd; i++) {
        target.add(i);
      }
    }
  }
  return ChangeMarks(added: added, modified: modified, deletedBefore: deleted);
}

/// 변경점 보기의 한 줄.
enum DiffRowKind { context, added, removed, gap }

@immutable
class DiffRow {
  const DiffRow(this.kind, {this.oldNo, this.newNo, this.text = '', this.hidden = 0, this.gapId = -1});

  final DiffRowKind kind;

  /// 1부터 시작하는 줄 번호 (해당 쪽에 없으면 null).
  final int? oldNo;
  final int? newNo;
  final String text;

  /// gap일 때 접힌 줄 수와, 펼칠 때 쓰는 번호.
  final int hidden;
  final int gapId;
}

/// 통합(unified) 보기의 줄 목록. 바뀐 곳 둘레 [context]줄만 보이고 나머지는 gap 한 줄로 접는다.
/// [expandedGaps]에 든 gap은 펼쳐서 모든 줄을 보여 준다. 바뀐 곳이 없으면 빈 목록.
List<DiffRow> buildUnifiedRows(
  List<String> a,
  List<String> b,
  List<DiffBlock> blocks, {
  int context = 3,
  Set<int> expandedGaps = const {},
}) {
  if (!blocks.any((x) => x.isChange)) return const [];
  final rows = <DiffRow>[];
  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i];
    if (block.isChange) {
      for (var j = 0; j < block.aLen; j++) {
        rows.add(DiffRow(DiffRowKind.removed, oldNo: block.aStart + j + 1, text: a[block.aStart + j]));
      }
      for (var j = 0; j < block.bLen; j++) {
        rows.add(DiffRow(DiffRowKind.added, newNo: block.bStart + j + 1, text: b[block.bStart + j]));
      }
      continue;
    }
    DiffRow line(int j) => DiffRow(DiffRowKind.context, oldNo: block.aStart + j + 1, newNo: block.bStart + j + 1, text: b[block.bStart + j]);
    final first = i == 0;
    final last = i == blocks.length - 1;
    final keepHead = first ? 0 : context;
    final keepTail = last ? 0 : context;
    if (expandedGaps.contains(i) || block.aLen <= keepHead + keepTail + 1) {
      for (var j = 0; j < block.aLen; j++) {
        rows.add(line(j));
      }
      continue;
    }
    for (var j = 0; j < keepHead; j++) {
      rows.add(line(j));
    }
    rows.add(DiffRow(DiffRowKind.gap, hidden: block.aLen - keepHead - keepTail, gapId: i));
    for (var j = block.aLen - keepTail; j < block.aLen; j++) {
      rows.add(line(j));
    }
  }
  return rows;
}

/// 추가·삭제된 줄 수.
({int added, int removed}) countChanges(List<DiffBlock> blocks) {
  var added = 0;
  var removed = 0;
  for (final b in blocks) {
    if (!b.isChange) continue;
    added += b.bLen;
    removed += b.aLen;
  }
  return (added: added, removed: removed);
}
