import 'dart:io';

import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/studio/worktree.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('worktree list --porcelain 출력을 읽는다', () {
    const out = 'worktree C:/repo\nHEAD abc\nbranch refs/heads/main\n\n'
        'worktree C:/repo/.claude/worktrees/fix-a\nHEAD def\nbranch refs/heads/claude/fix-a\n\n'
        'worktree C:/repo/detached\nHEAD 123\ndetached\n';
    final list = Worktree.parse(out);
    expect(list.length, 3);
    expect(list[0].main, isTrue);
    expect(list[0].branch, 'main');
    expect(list[1].byClaude, isTrue);
    expect(list[1].branch, 'claude/fix-a');
    expect(list[2].branch, isNull);
  });

  test('가장 깊은 worktree를 고른다', () {
    final list = [
      const Worktree(path: 'C:/repo', branch: 'main', main: true),
      const Worktree(path: 'C:/repo/.claude/worktrees/a', branch: 'a'),
    ];
    expect(worktreeContaining(list, 'C:/repo/.claude/worktrees/a/lib')?.branch, 'a');
    expect(worktreeContaining(list, 'C:/repo/lib')?.branch, 'main');
    expect(worktreeContaining(list, 'D:/other'), isNull);
  });

  test('파일을 열어 수정하고 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('studio_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}a.txt')..writeAsStringSync('hello');

    final c = StudioController();
    addTearDown(c.dispose);
    await c.openFile(file.path);
    final tab = c.activeTab!;
    expect(tab.dirty, isFalse);

    tab.controller.text = 'bye';
    expect(tab.dirty, isTrue);
    expect(await c.save(tab), isTrue);
    expect(tab.dirty, isFalse);
    expect(file.readAsStringSync(), 'bye');
  });

  test('글자 파일이 아니면 열지 않고 알린다', () async {
    final dir = await Directory.systemTemp.createTemp('studio_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}b.bin')..writeAsBytesSync([0xff, 0xfe, 0x00, 0xc3]);

    final c = StudioController();
    addTearDown(c.dispose);
    await c.openFile(file.path);
    expect(c.tabs, isEmpty);
    expect(c.message, isNotNull);
  });
}
