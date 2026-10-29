import 'dart:io';

import 'package:daylight_workbench/flutter/flutter_project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;

  void flutterApp(String path, String name) {
    Directory(path).createSync(recursive: true);
    File('$path/pubspec.yaml').writeAsStringSync('name: $name\nversion: 1.0.0\ndependencies:\n  flutter:\n    sdk: flutter\n');
  }

  setUp(() async => root = await Directory.systemTemp.createTemp('fp_find'));
  tearDown(() => root.delete(recursive: true));

  test('연 폴더가 Flutter 프로젝트면 그대로 쓴다', () async {
    flutterApp(root.path, 'app');
    flutterApp('${root.path}/example', 'example');
    expect((await FlutterProject.findAll(root.path)).map((p) => p.name), ['app']);
  });

  test('Rust 프로젝트 안의 gui/ Flutter 앱을 찾는다', () async {
    File('${root.path}/Cargo.toml').writeAsStringSync('[package]\nname = "tool"\n');
    flutterApp('${root.path}/gui', 'gui_app');
    final found = await FlutterProject.findAll(root.path);
    expect(found.map((p) => p.name), ['gui_app']);
    expect(found.single.path, endsWith('gui'));
  });

  test('Flutter 프로젝트가 둘 이상이면 모두 돌려준다 (고르는 건 사용자)', () async {
    flutterApp('${root.path}/b', 'b');
    flutterApp('${root.path}/a', 'a');
    expect((await FlutterProject.findAll(root.path)).map((p) => p.name), ['a', 'b']);
    flutterApp('${root.path}/a/deep', 'deep');
    expect((await FlutterProject.findAll(root.path)).length, 2);
  });

  test('build·숨김 폴더는 건너뛰고, 없으면 null', () async {
    flutterApp('${root.path}/build', 'x');
    flutterApp('${root.path}/.hidden', 'h');
    Directory('${root.path}/src').createSync();
    expect(await FlutterProject.findAll(root.path), isEmpty);
  });
}
