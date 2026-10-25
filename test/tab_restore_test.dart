import 'dart:io';

import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('tab_restore');
    for (final n in ['a.txt', 'b.txt', 'c.txt']) {
      File('${dir.path}${Platform.pathSeparator}$n').writeAsStringSync(n);
    }
  });

  tearDown(() => dir.delete(recursive: true));

  String p(String n) => '${dir.path}${Platform.pathSeparator}$n';

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('다시 시작하면 열어 둔 탭과 활성 탭이 돌아온다', () async {
    final first = StudioController();
    await first.openProject(dir.path);
    await first.openFile(p('a.txt'));
    await first.openFile(p('b.txt'));
    await first.openFile(p('c.txt'));
    first.selectTab(1);
    await settle();
    first.dispose();

    final second = StudioController();
    await second.restore();
    expect(second.tabs.map((t) => t.name), ['a.txt', 'b.txt', 'c.txt']);
    expect(second.activeTab?.name, 'b.txt');
    second.dispose();
  });

  test('닫은 탭은 돌아오지 않고, 사라진 파일은 조용히 건너뛴다', () async {
    final first = StudioController();
    await first.openProject(dir.path);
    await first.openFile(p('a.txt'));
    await first.openFile(p('b.txt'));
    first.closeTab(0);
    await settle();
    first.dispose();
    File(p('b.txt')).deleteSync();

    final second = StudioController();
    await second.restore();
    expect(second.tabs, isEmpty);
    expect(second.message, isNull);
    second.dispose();
  });
}
