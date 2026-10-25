import 'dart:io';

import 'package:daylight_flutter_studio/problems/diagnostic.dart';
import 'package:daylight_flutter_studio/problems/problems_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late String sub;
  late List<String> pubGetCalls;
  late ProblemsController c;

  void makePackage(String path, {bool withConfig = false}) {
    Directory(path).createSync(recursive: true);
    File('$path/pubspec.yaml').writeAsStringSync('name: x\n');
    if (withConfig) {
      Directory('$path/.dart_tool').createSync();
      File('$path/.dart_tool/package_config.json').writeAsStringSync('{}');
    }
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sub_pkg');
    sub = '${root.path}/packages/fleet_core';
    makePackage(root.path, withConfig: true);
    makePackage(sub);
    File('$sub/test').createSync();
    pubGetCalls = [];
    c = ProblemsController(
      analyze: (packageRoot) async => AnalyzeResult.ok([
        Diagnostic(code: 'uri_does_not_exist', severity: DiagnosticSeverity.error, message: 'm', file: '$sub/test/a_test.dart', line: 5, column: 8),
      ]),
      pubGet: (packageRoot) async {
        pubGetCalls.add(packageRoot);
        // pub get이 패키지 정보를 만든 것처럼.
        makePackage(packageRoot, withConfig: true);
        return true;
      },
    );
  });

  tearDown(() async {
    c.dispose();
    await root.delete(recursive: true);
  });

  test('열린 패키지는 멀쩡해도 문제가 난 서브 패키지에 패키지 정보가 없으면 안내한다', () async {
    await c.setProjectDir(root.path);
    expect(c.needsPubGet, isFalse);
    expect(c.packagesNeedingPubGet, [sub]);
  });

  test('pub get은 서브 패키지에서 돌고, 끝나면 다시 분석해 안내가 사라진다', () async {
    await c.setProjectDir(root.path);
    await c.runPubGet();
    expect(pubGetCalls, [sub]);
    expect(c.packagesNeedingPubGet, isEmpty);
  });

  test('열린 패키지도 없으면 둘 다 받는다 (열린 패키지가 먼저)', () async {
    File('${root.path}/.dart_tool/package_config.json').deleteSync();
    await c.setProjectDir(root.path);
    expect(c.packagesNeedingPubGet, [root.path, sub]);
    await c.runPubGet();
    expect(pubGetCalls, [root.path, sub]);
    expect(c.packagesNeedingPubGet, isEmpty);
  });

  test('서브 패키지에 패키지 정보가 이미 있으면 안내하지 않는다', () async {
    makePackage(sub, withConfig: true);
    await c.setProjectDir(root.path);
    expect(c.packagesNeedingPubGet, isEmpty);
  });
}
