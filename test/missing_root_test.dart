import 'dart:io';

import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/studio/worktree.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late StudioController c;
  final sep = Platform.pathSeparator;

  Directory dir(String name) => Directory('${tmp.path}$sep$name')..createSync(recursive: true);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tmp = await Directory.systemTemp.createTemp('missing_root');
    c = StudioController();
  });

  tearDown(() async {
    c.dispose();
    await tmp.delete(recursive: true);
  });

  test('열어 둔 폴더가 있으면 아무 일도 하지 않는다', () async {
    await c.openProject(dir('a').path);
    expect(await c.checkRootExists(), isFalse);
    expect(c.message, isNull);
  });

  test('대체할 곳이 없으면 프로젝트를 닫고 안내하며, 사라진 파일의 탭과 마지막 프로젝트 기록을 정리한다', () async {
    final a = dir('a');
    final f = File('${a.path}${sep}x.txt')..writeAsStringSync('hi');
    await c.openProject(a.path);
    await c.openFile(f.path);
    expect(c.tabs, hasLength(1));

    a.deleteSync(recursive: true);
    expect(await c.checkRootExists(), isTrue);

    expect(c.root, isNull);
    expect(c.tabs, isEmpty);
    expect(c.activeIndex, -1);
    expect(c.message, contains(a.path));
    expect((await SharedPreferences.getInstance()).getString('last_project'), isNull);
  });

  test('같은 저장소의 다른 worktree가 남아 있으면 그쪽으로 옮긴다', () async {
    final main = dir('main'), gone = dir('gone');
    await c.openProject(gone.path);
    c.worktrees = [Worktree(path: main.path, branch: 'main', main: true), Worktree(path: gone.path, branch: 'x')];
    final f = File('${gone.path}${sep}x.txt')..writeAsStringSync('hi');
    await c.openFile(f.path);

    gone.deleteSync(recursive: true);
    expect(await c.checkRootExists(), isTrue);

    expect(c.root, main.path);
    expect(c.tabs, isEmpty);
    expect(c.message, allOf(contains(gone.path), contains(main.path)));
  });

  test('고치던 탭은 잃지 않게 남겨 둔다', () async {
    final a = dir('a');
    final f = File('${a.path}${sep}x.txt')..writeAsStringSync('hi');
    await c.openProject(a.path);
    await c.openFile(f.path);
    c.activeTab!.controller.text = 'edited';

    a.deleteSync(recursive: true);
    await c.checkRootExists();

    expect(c.root, isNull);
    expect(c.tabs, hasLength(1));
  });

  test('주기 확인(checkExternalChanges)도 사라진 폴더를 처리한다', () async {
    final a = dir('a');
    await c.openProject(a.path);
    a.deleteSync(recursive: true);
    await c.checkExternalChanges();
    expect(c.root, isNull);
  });
}
