import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:daylight_flutter_studio/theme/font_scan.dart';
import 'package:flutter_test/flutter_test.dart';

/// 글꼴 파일의 머리말과 `name`·`post` 표만 가진 아주 작은 TTF를 만든다 (설치된 글꼴에 기대지 않으려고).
Uint8List _font({
  required String family,
  required bool fixedPitch,
  bool utf16 = true,
  bool typographic = false,
}) {
  Uint8List name() {
    final records = <(int id, Uint8List text)>[
      (
        typographic ? 16 : 1,
        utf16
            ? Uint8List.fromList([
                for (final u in family.codeUnits) ...[u >> 8, u & 0xff],
              ])
            : Uint8List.fromList(latin1.encode(family)),
      ),
    ];
    if (typographic)
      records.add((
        1,
        Uint8List.fromList(
          latin1.encode('Wrong').toList().expand((c) => [0, c]).toList(),
        ),
      ));
    final header = ByteData(6 + 12 * records.length);
    header.setUint16(2, records.length);
    var stringsAt = 6 + 12 * records.length;
    header.setUint16(4, stringsAt);
    final strings = BytesBuilder();
    for (var i = 0; i < records.length; i++) {
      final at = 6 + 12 * i;
      header.setUint16(at, utf16 ? 3 : 1); // platform
      header.setUint16(at + 4, utf16 ? 0x409 : 0); // language
      header.setUint16(at + 6, records[i].$1);
      header.setUint16(at + 8, records[i].$2.length);
      header.setUint16(at + 10, strings.length);
      strings.add(records[i].$2);
    }
    return (BytesBuilder()
          ..add(header.buffer.asUint8List())
          ..add(strings.toBytes()))
        .toBytes();
  }

  final nameBytes = name();
  final post = ByteData(32)..setUint32(12, fixedPitch ? 1 : 0);
  const tableCount = 2;
  final dir = ByteData(12 + 16 * tableCount)
    ..setUint32(0, 0x00010000)
    ..setUint16(4, tableCount);
  final nameAt = 12 + 16 * tableCount;
  final postAt = nameAt + nameBytes.length;
  void record(int i, String tag, int offset, int length) {
    for (var k = 0; k < 4; k++) {
      dir.setUint8(12 + 16 * i + k, tag.codeUnitAt(k));
    }
    dir.setUint32(12 + 16 * i + 8, offset);
    dir.setUint32(12 + 16 * i + 12, length);
  }

  record(0, 'name', nameAt, nameBytes.length);
  record(1, 'post', postAt, 32);
  return (BytesBuilder()
        ..add(dir.buffer.asUint8List())
        ..add(nameBytes)
        ..add(post.buffer.asUint8List()))
      .toBytes();
}

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('font_scan'));
  tearDown(() => dir.delete(recursive: true));

  String write(String name, Uint8List bytes) {
    final f = File('${dir.path}/$name')..writeAsBytesSync(bytes);
    return f.path;
  }

  test('고정폭 글꼴의 가족 이름을 읽는다 (UTF-16 · MacRoman)', () {
    expect(
      monospaceFamiliesInFile(
        write('a.ttf', _font(family: 'Fira Code', fixedPitch: true)),
      ),
      ['Fira Code'],
    );
    expect(
      monospaceFamiliesInFile(
        write(
          'b.ttf',
          _font(family: 'Old Mono', fixedPitch: true, utf16: false),
        ),
      ),
      ['Old Mono'],
    );
  });

  test('고정폭이 아니면 빈 목록, 타이포그래피 가족(16)이 있으면 그것을 쓴다', () {
    expect(
      monospaceFamiliesInFile(
        write('p.ttf', _font(family: 'Prop', fixedPitch: false)),
      ),
      isEmpty,
    );
    expect(
      monospaceFamiliesInFile(
        write(
          't.ttf',
          _font(family: 'JetBrains Mono', fixedPitch: true, typographic: true),
        ),
      ),
      ['JetBrains Mono'],
    );
  });

  test('폴더를 훑어 중복 없이 정렬하고, 깨진 파일과 점으로 시작하는 이름은 건너뛴다', () {
    write('x.ttf', _font(family: 'Zed Mono', fixedPitch: true));
    write('x2.otf', _font(family: 'Zed Mono', fixedPitch: true));
    write('y.ttf', _font(family: 'Ace Mono', fixedPitch: true));
    write('hidden.ttf', _font(family: '.System Mono', fixedPitch: true));
    write('broken.ttf', Uint8List.fromList([1, 2, 3]));
    write('note.txt', Uint8List.fromList([1, 2, 3]));
    expect(scanMonospaceFonts([dir.path, '/no/such/dir']), [
      'Ace Mono',
      'Zed Mono',
    ]);
  });

  test('UI 글꼴처럼 고정폭이 아닌 것도 찾으려면 monospaceOnly를 끈다', () {
    write('prop.ttf', _font(family: 'Prop Sans', fixedPitch: false));
    write('mono.ttf', _font(family: 'Ace Mono', fixedPitch: true));

    expect(scanFonts([dir.path], monospaceOnly: true), ['Ace Mono']);
    expect(scanFonts([dir.path], monospaceOnly: false), ['Ace Mono', 'Prop Sans']);
    expect(
      monospaceFamiliesInFile('${dir.path}/prop.ttf', requireFixedPitch: false),
      ['Prop Sans'],
    );
  });
}
