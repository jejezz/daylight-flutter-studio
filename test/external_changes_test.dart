import 'dart:io';

import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late StudioController c;
  late File file;

  /// 다른 프로그램(Claude Code)이 파일을 고친 것처럼 쓴다. 수정 시각이 겹치지 않게 미래로 민다.
  void externalWrite(String text, {int secondsAhead = 5}) {
    file.writeAsStringSync(text);
    file.setLastModifiedSync(DateTime.now().add(Duration(seconds: secondsAhead)));
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('external_changes');
    file = File('${dir.path}${Platform.pathSeparator}a.txt')..writeAsStringSync('first');
    c = StudioController();
    await c.openFile(file.path);
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  EditorTab tab() => c.activeTab!;

  test('수정하지 않은 탭은 디스크가 바뀌면 조용히 다시 읽는다', () async {
    externalWrite('changed by claude');
    await c.checkExternalChanges();

    expect(tab().controller.text, 'changed by claude');
    expect(tab().dirty, isFalse);
    expect(tab().external, ExternalChange.none);
    expect(c.message, contains('다시 읽었습니다'));
  });

  test('시각만 바뀌고 글이 같으면 아무 일도 하지 않는다', () async {
    externalWrite('first');
    await c.checkExternalChanges();

    expect(tab().external, ExternalChange.none);
    expect(c.message, isNull);
    expect(tab().controller.text, 'first');
  });

  test('줄 끝(CRLF)만 다르면 같은 글로 본다', () async {
    externalWrite('first\r\nsecond\r\n');
    await c.checkExternalChanges();
    // 처음 글('first')과 다르므로 다시 읽는다.
    expect(tab().controller.text.replaceAll('\r\n', '\n'), 'first\nsecond\n');

    c.clearMessage();
    externalWrite('first\nsecond\n', secondsAhead: 10);
    await c.checkExternalChanges();
    expect(c.message, isNull, reason: '줄 끝만 다른 변경은 알리지 않는다');
  });

  test('수정 중인 탭은 내 글을 지키고 표시만 한다', () async {
    tab().controller.text = 'my edit';
    externalWrite('changed by claude');
    await c.checkExternalChanges();

    expect(tab().external, ExternalChange.modified);
    expect(tab().controller.text, 'my edit');
    expect(tab().dirty, isTrue);

    // 저장하면 Claude의 수정을 덮어쓰므로 막는다.
    expect(await c.save(tab()), isFalse);
    expect(file.readAsStringSync(), 'changed by claude');
    expect(c.message, contains('다시 읽기'));
  });

  test('다시 읽기는 내 수정을 버리고 디스크 글을 가져온다', () async {
    tab().controller.text = 'my edit';
    externalWrite('changed by claude');
    await c.checkExternalChanges();

    await c.reloadFromDisk(tab());
    expect(tab().controller.text, 'changed by claude');
    expect(tab().dirty, isFalse);
    expect(tab().external, ExternalChange.none);
  });

  test('내 수정 유지를 고르면 저장이 디스크를 덮어쓴다', () async {
    tab().controller.text = 'my edit';
    externalWrite('changed by claude');
    await c.checkExternalChanges();

    c.keepMine(tab());
    expect(await c.save(tab()), isTrue);
    expect(file.readAsStringSync(), 'my edit');
    expect(tab().dirty, isFalse);

    // 우리가 저장한 것은 외부 변경으로 보지 않는다.
    await c.checkExternalChanges();
    expect(tab().external, ExternalChange.none);
  });

  test('내가 저장한 파일을 외부 변경으로 착각하지 않는다', () async {
    tab().controller.text = 'saved by me';
    expect(await c.save(tab()), isTrue);
    c.clearMessage();

    await c.checkExternalChanges();
    expect(tab().external, ExternalChange.none);
    expect(c.message, isNull);
    expect(tab().controller.text, 'saved by me');
  });

  test('파일이 사라지면 표시하고, 그대로 두고 저장하면 다시 만든다', () async {
    file.deleteSync();
    await c.checkExternalChanges();
    expect(tab().external, ExternalChange.deleted);

    tab().controller.text = 'recreated';
    c.keepMine(tab());
    expect(await c.save(tab()), isTrue);
    expect(file.readAsStringSync(), 'recreated');
    expect(tab().external, ExternalChange.none);
  });

  test('사라졌던 파일이 돌아오면 표시를 거둔다', () async {
    file.deleteSync();
    await c.checkExternalChanges();
    expect(tab().external, ExternalChange.deleted);

    file.writeAsStringSync('first');
    await c.checkExternalChanges();
    expect(tab().external, ExternalChange.none);
  });

  test('트리 새로 고침은 번호를 올린다', () {
    final before = c.treeRevision;
    c.refreshTree();
    expect(c.treeRevision, before + 1);
  });
}
