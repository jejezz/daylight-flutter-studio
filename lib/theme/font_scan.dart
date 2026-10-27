/// 이 컴퓨터에 설치된 글꼴의 이름을 글꼴 파일에서 읽는다 — 편집기·터미널 글꼴은 고정폭만, UI 글꼴은 전부.
///
/// Flutter에는 설치된 글꼴 목록을 묻는 방법이 없어서 OS의 글꼴 폴더를 훑는다. 파일 전체를 읽지 않고
/// 머리말과 `name`(이름)·`post`(고정폭 표시) 표만 읽는다. 글꼴 하나가 수십 MB여도 빠르다.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// OS별 글꼴 폴더.
List<String> systemFontDirectories() {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  if (Platform.isMacOS) {
    return ['/System/Library/Fonts', '/System/Library/Fonts/Supplemental', '/Library/Fonts', '$home/Library/Fonts'];
  }
  if (Platform.isWindows) {
    final windir = Platform.environment['WINDIR'] ?? r'C:\Windows';
    final local = Platform.environment['LOCALAPPDATA'] ?? '';
    return ['$windir\\Fonts', if (local.isNotEmpty) '$local\\Microsoft\\Windows\\Fonts'];
  }
  return ['/usr/share/fonts', '/usr/local/share/fonts', '$home/.fonts', '$home/.local/share/fonts'];
}

List<String>? _cache;
List<String>? _cacheAll;

/// 글꼴 목록을 가져오는 방법(고정폭만, 편집기·터미널 글꼴 고를 때). 테스트에서는 실제 폴더 대신 정해 둔 목록으로 바꿔 끼운다.
Future<List<String>> Function() monospaceFontLoader = installedMonospaceFonts;

/// 글꼴 목록을 가져오는 방법(고정폭 아닌 것도 포함, UI 글꼴 고를 때).
Future<List<String>> Function() proportionalFontLoader = installedFonts;

/// 설치된 고정폭 글꼴 가족 이름 (중복 없이, 가나다·ABC 순). 읽지 못한 폴더는 건너뛴다.
Future<List<String>> installedMonospaceFonts() async {
  _cache ??= await Isolate.run(() => scanFonts(systemFontDirectories(), monospaceOnly: true));
  return _cache!;
}

/// 설치된 글꼴 가족 이름(고정폭 아닌 것도 포함). 읽지 못한 폴더는 건너뛴다.
Future<List<String>> installedFonts() async {
  _cacheAll ??= await Isolate.run(() => scanFonts(systemFontDirectories(), monospaceOnly: false));
  return _cacheAll!;
}

/// 고정폭 글꼴만 찾는다(`scanFonts`의 뒷날 호환용 이름).
List<String> scanMonospaceFonts(List<String> directories) => scanFonts(directories, monospaceOnly: true);

List<String> scanFonts(List<String> directories, {required bool monospaceOnly}) {
  final families = <String>{};
  for (final dir in directories) {
    final d = Directory(dir);
    if (!d.existsSync()) continue;
    try {
      for (final e in d.listSync(recursive: true, followLinks: false)) {
        if (e is! File) continue;
        final lower = e.path.toLowerCase();
        if (!(lower.endsWith('.ttf') || lower.endsWith('.otf') || lower.endsWith('.ttc') || lower.endsWith('.otc'))) continue;
        families.addAll(monospaceFamiliesInFile(e.path, requireFixedPitch: monospaceOnly));
      }
    } on FileSystemException {
      continue;
    }
  }
  // `.SF NS Mono`처럼 점으로 시작하는 이름은 OS 내부용이라 이름으로 고를 수 없다.
  families.removeWhere((f) => f.startsWith('.'));
  return families.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

/// 글꼴 파일(컬렉션이면 안의 모든 글꼴)에서 가족 이름. [requireFixedPitch]면 고정폭인 것만. 읽을 수 없으면 빈 목록.
List<String> monospaceFamiliesInFile(String path, {bool requireFixedPitch = true}) {
  RandomAccessFile? f;
  try {
    f = File(path).openSync();
    final head = f.readSync(12);
    if (head.length < 12) return const [];
    final b = ByteData.sublistView(Uint8List.fromList(head));
    final tag = String.fromCharCodes(head.sublist(0, 4));
    final offsets = <int>[];
    if (tag == 'ttcf') {
      final n = b.getUint32(8);
      if (n > 64) return const [];
      f.setPositionSync(12);
      final table = ByteData.sublistView(Uint8List.fromList(f.readSync(4 * n)));
      for (var i = 0; i < n; i++) {
        offsets.add(table.getUint32(4 * i));
      }
    } else {
      offsets.add(0);
    }
    return [
      for (final o in offsets) ?_familyInFile(f, o, requireFixedPitch: requireFixedPitch),
    ];
  } on Object {
    return const [];
  } finally {
    f?.closeSync();
  }
}

String? _familyInFile(RandomAccessFile f, int offset, {required bool requireFixedPitch}) {
  f.setPositionSync(offset);
  final head = f.readSync(12);
  if (head.length < 12) return null;
  final numTables = ByteData.sublistView(Uint8List.fromList(head)).getUint16(4);
  if (numTables == 0 || numTables > 200) return null;
  final records = ByteData.sublistView(Uint8List.fromList(f.readSync(16 * numTables)));
  int? nameOffset, nameLength, postOffset;
  for (var i = 0; i < numTables; i++) {
    final tag = String.fromCharCodes([for (var k = 0; k < 4; k++) records.getUint8(16 * i + k)]);
    if (tag == 'name') {
      nameOffset = records.getUint32(16 * i + 8);
      nameLength = records.getUint32(16 * i + 12);
    } else if (tag == 'post') {
      postOffset = records.getUint32(16 * i + 8);
    }
  }
  if (nameOffset == null || nameLength == null || postOffset == null || nameLength > 1 << 20) return null;

  if (requireFixedPitch) {
    f.setPositionSync(postOffset);
    final post = f.readSync(16);
    if (post.length < 16 || ByteData.sublistView(Uint8List.fromList(post)).getUint32(12) == 0) return null; // 고정폭이 아니다
  }

  f.setPositionSync(nameOffset);
  return _familyName(Uint8List.fromList(f.readSync(nameLength)));
}

/// `name` 표에서 가족 이름. 타이포그래피 가족(16)이 있으면 그것, 없으면 가족(1). 영어 이름을 먼저 본다.
String? _familyName(Uint8List data) {
  if (data.length < 6) return null;
  final b = ByteData.sublistView(data);
  final count = b.getUint16(2);
  final stringsAt = b.getUint16(4);
  String? best;
  var bestScore = -1;
  for (var i = 0; i < count; i++) {
    final at = 6 + 12 * i;
    if (at + 12 > data.length) break;
    final platform = b.getUint16(at);
    final language = b.getUint16(at + 4);
    final id = b.getUint16(at + 6);
    final length = b.getUint16(at + 8);
    final start = stringsAt + b.getUint16(at + 10);
    if ((id != 1 && id != 16) || start + length > data.length) continue;
    final raw = data.sublist(start, start + length);
    final String text;
    if (platform == 1) {
      text = latin1.decode(raw, allowInvalid: true);
    } else {
      final units = [for (var k = 0; k + 1 < raw.length; k += 2) (raw[k] << 8) | raw[k + 1]];
      text = String.fromCharCodes(units);
    }
    final english = (platform == 3 && language == 0x409) || (platform == 1 && language == 0);
    final score = (id == 16 ? 2 : 0) + (english ? 1 : 0);
    if (text.trim().isNotEmpty && score > bestScore) {
      best = text.trim();
      bestScore = score;
    }
  }
  return best;
}
