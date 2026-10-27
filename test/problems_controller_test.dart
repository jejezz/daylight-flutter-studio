import 'dart:async';
import 'dart:io';

import 'package:daylight_workbench/core/command_log.dart';
import 'package:daylight_workbench/core/command_runner.dart';
import 'package:daylight_workbench/problems/dart_analyzer.dart';
import 'package:daylight_workbench/problems/diagnostic.dart';
import 'package:daylight_workbench/problems/problems_controller.dart';
import 'package:flutter_test/flutter_test.dart';

final _sep = Platform.pathSeparator;

Diagnostic _d(String file, int line, DiagnosticSeverity s, {String code = 'c', String message = 'm', int column = 1}) =>
    Diagnostic(code: code, severity: s, message: message, file: file, line: line, column: column);

const _sampleJson = r'''{"version":1,"diagnostics":[
{"code":"invalid_assignment","severity":"ERROR","type":"COMPILE_TIME_ERROR",
 "location":{"file":"C:\\p\\lib\\bad.dart","range":{"start":{"offset":42,"line":3,"column":11},"end":{"offset":45,"line":3,"column":14}}},
 "problemMessage":"A value of type 'String' can't be assigned to a variable of type 'int'.",
 "correctionMessage":"Try changing the type of the variable."},
{"code":"unused_local_variable","severity":"WARNING","type":"STATIC_WARNING",
 "location":{"file":"C:\\p\\lib\\bad.dart","range":{"start":{"offset":38,"line":3,"column":7},"end":{"offset":39,"line":3,"column":8}}},
 "problemMessage":"The value of the local variable 'x' isn't used."},
{"code":"prefer_const","severity":"INFO","type":"LINT",
 "location":{"file":"C:\\p\\lib\\other.dart","range":{"start":{"offset":0,"line":10,"column":2},"end":{"offset":5,"line":10,"column":7}}},
 "problemMessage":"Use const."}
]}''';

void main() {
  group('parseAnalyzeJson', () {
    test('오류·경고·정보와 위치, 고치는 방법을 읽는다', () {
      final list = parseAnalyzeJson(_sampleJson)!;
      expect(list.length, 3);
      expect(list[0].severity, DiagnosticSeverity.error);
      expect(list[0].code, 'invalid_assignment');
      expect(list[0].line, 3);
      expect(list[0].column, 11);
      expect(list[0].length, 3);
      expect(list[0].file, r'C:\p\lib\bad.dart');
      expect(list[0].correction, 'Try changing the type of the variable.');
      expect(list[1].severity, DiagnosticSeverity.warning);
      expect(list[1].correction, isEmpty);
      expect(list[2].severity, DiagnosticSeverity.info);
    });

    test('문제가 없으면 빈 목록, 깨진 출력은 null', () {
      expect(parseAnalyzeJson('{"version":1,"diagnostics":[]}'), isEmpty);
      expect(parseAnalyzeJson('Analyzing...\n{"version":1,"diagnostics":[]}'), isEmpty, reason: 'JSON 앞에 다른 글이 있어도 읽는다');
      expect(parseAnalyzeJson('not json'), isNull);
      expect(parseAnalyzeJson('{ broken'), isNull);
      expect(parseAnalyzeJson('{"diagnostics": 5}'), isNull);
    });

    test('위치가 없는 항목은 건너뛴다', () {
      final list = parseAnalyzeJson('{"diagnostics":[{"code":"x","severity":"ERROR"},{"code":"y","severity":"INFO","location":{"file":"a.dart","range":{"start":{"offset":1,"line":2,"column":3},"end":{"offset":2}}},"problemMessage":"m"}]}')!;
      expect(list.length, 1);
      expect(list.single.line, 2);
    });
  });

  group('findPackageRoot / pathKey', () {
    test('가까운 pubspec.yaml이 있는 폴더를 찾는다', () async {
      final dir = await Directory.systemTemp.createTemp('pkg_root');
      addTearDown(() => dir.delete(recursive: true));
      File('${dir.path}${_sep}pubspec.yaml').writeAsStringSync('name: x');
      Directory('${dir.path}${_sep}lib${_sep}src').createSync(recursive: true);
      final file = File('${dir.path}${_sep}lib${_sep}src${_sep}a.dart')..writeAsStringSync('');

      expect(findPackageRoot(file.path), dir.path);
      expect(findPackageRoot('${dir.path}${_sep}lib'), dir.path);
      expect(findPackageRoot(dir.path), dir.path);
    });

    test('경로 비교는 구분자 차이를 무시한다', () {
      expect(pathKey(r'C:\a\b.dart'), pathKey('C:/a/b.dart'));
    });
  });

  group('ProblemsController', () {
    late Directory pkg;
    late List<String> analyzed;
    late AnalyzeResult next;
    late ProblemsController c;

    setUp(() async {
      pkg = await Directory.systemTemp.createTemp('problems');
      File('${pkg.path}${_sep}pubspec.yaml').writeAsStringSync('name: x');
      analyzed = [];
      next = const AnalyzeResult.ok([]);
      c = ProblemsController(
        analyze: (root) async {
          analyzed.add(root);
          return next;
        },
        pubGet: (root) async => true,
        saveDelay: const Duration(milliseconds: 50),
      );
    });

    tearDown(() async {
      c.dispose();
      await pkg.delete(recursive: true);
    });

    String file(String name) => '${pkg.path}${_sep}lib$_sep$name';

    test('폴더를 열면 패키지를 찾아 분석하고 개수를 센다', () async {
      next = AnalyzeResult.ok([
        _d(file('a.dart'), 3, DiagnosticSeverity.error),
        _d(file('a.dart'), 5, DiagnosticSeverity.warning),
        _d(file('b.dart'), 1, DiagnosticSeverity.info),
      ]);
      await c.setProjectDir(pkg.path);

      expect(c.packageRoot, pkg.path);
      expect(analyzed, [pkg.path]);
      expect(c.analyzed, isTrue);
      expect((c.errors, c.warnings, c.infos), (1, 1, 1));
      expect(c.running, isFalse);
    });

    test('pubspec이 없는 폴더는 분석하지 않는다', () async {
      final empty = await Directory.systemTemp.createTemp('no_pkg');
      addTearDown(() => empty.delete(recursive: true));
      // 임시 폴더의 상위에 pubspec이 있을 수 있어 같은 결과를 기대하지 않고, 있으면 건너뛴다.
      await c.setProjectDir(empty.path);
      if (c.packageRoot == null) expect(analyzed, isEmpty);
    });

    test('줄별로 가장 심각한 문제만 돌려준다 (경로 표기가 달라도)', () async {
      final f = file('a.dart');
      next = AnalyzeResult.ok([
        _d(f, 3, DiagnosticSeverity.info),
        _d(f, 3, DiagnosticSeverity.error),
        _d(f, 3, DiagnosticSeverity.warning),
        _d(f, 9, DiagnosticSeverity.warning),
      ]);
      await c.setProjectDir(pkg.path);

      final lines = c.linesFor(f.replaceAll(_sep, '/'));
      expect(lines[3], DiagnosticSeverity.error);
      expect(lines[9], DiagnosticSeverity.warning);
      expect(c.linesFor(file('none.dart')), isEmpty);
    });

    test('파일별로 묶고 심각한 것·위쪽 줄 순서로 정렬한다', () async {
      next = AnalyzeResult.ok([
        _d(file('b.dart'), 1, DiagnosticSeverity.info),
        _d(file('a.dart'), 9, DiagnosticSeverity.warning),
        _d(file('a.dart'), 20, DiagnosticSeverity.error),
        _d(file('a.dart'), 2, DiagnosticSeverity.warning),
      ]);
      await c.setProjectDir(pkg.path);

      final g = c.grouped();
      expect(g.keys.toList(), [file('a.dart'), file('b.dart')]);
      expect([for (final d in g[file('a.dart')]!) d.line], [20, 2, 9]);

      final onlyErrors = c.grouped(only: {DiagnosticSeverity.error});
      expect(onlyErrors.keys.toList(), [file('a.dart')]);
      expect(onlyErrors[file('a.dart')]!.length, 1);
    });

    test('분석이 실패하면 이유를 남기고 "문제 없음"으로 보이지 않는다', () async {
      next = const AnalyzeResult.failed('dart 명령을 찾을 수 없습니다.');
      await c.setProjectDir(pkg.path);
      expect(c.error, contains('dart'));
      expect(c.diagnostics, isEmpty);

      next = const AnalyzeResult.ok([]);
      await c.refresh();
      expect(c.error, isNull);
    });

    test('분석 중에 다시 요청하면 끝난 뒤 한 번만 더 돈다', () async {
      final gate = Completer<void>();
      var runs = 0;
      c.dispose();
      c = ProblemsController(
        analyze: (root) async {
          runs++;
          if (runs == 1) await gate.future;
          return const AnalyzeResult.ok([]);
        },
        pubGet: (_) async => true,
      );
      c.packageRoot = pkg.path;

      final first = c.refresh();
      await c.refresh();
      await c.refresh();
      expect(runs, 1, reason: '도는 중에는 새로 시작하지 않는다');
      gate.complete();
      await first;
      expect(runs, 2, reason: '요청이 여러 번이어도 한 번만 더 돈다');
      expect(c.running, isFalse);
    });

    test('Dart 파일을 저장하면 잠시 뒤 다시 분석한다 (연속 저장은 한 번)', () async {
      await c.setProjectDir(pkg.path);
      analyzed.clear();

      c.onSaved(file('a.dart'));
      c.onSaved(file('a.dart'));
      c.onSaved(file('b.dart'));
      expect(analyzed, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(analyzed.length, 1);
    });

    test('Dart가 아니거나 패키지 밖 파일의 저장은 무시한다', () async {
      await c.setProjectDir(pkg.path);
      analyzed.clear();
      c.onSaved(file('readme.md'));
      c.onSaved('${pkg.parent.path}${_sep}elsewhere${_sep}x.dart');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(analyzed, isEmpty);
    });

    test('최근에 분석했으면 refreshIfStale은 건너뛴다', () async {
      await c.setProjectDir(pkg.path);
      analyzed.clear();
      await c.refreshIfStale(const Duration(minutes: 1));
      expect(analyzed, isEmpty);
      await c.refreshIfStale(Duration.zero);
      expect(analyzed.length, 1);
    });

    test('패키지 정보가 없으면 pub get이 필요하다고 알린다', () async {
      await c.setProjectDir(pkg.path);
      expect(c.needsPubGet, isTrue);
      Directory('${pkg.path}$_sep.dart_tool').createSync();
      File('${pkg.path}$_sep.dart_tool${_sep}package_config.json').writeAsStringSync('{}');
      expect(c.needsPubGet, isFalse);
    });

    test('pub get 뒤에 다시 분석한다', () async {
      await c.setProjectDir(pkg.path);
      analyzed.clear();
      await c.runPubGet();
      expect(analyzed.length, 1);
      expect(c.gettingPackages, isFalse);
    });

    test('분석하는 사이 다른 패키지로 바뀌면 새 패키지를 분석한다', () async {
      final other = await Directory.systemTemp.createTemp('problems_other');
      addTearDown(() => other.delete(recursive: true));
      File('${other.path}${_sep}pubspec.yaml').writeAsStringSync('name: y');

      final gate = Completer<void>();
      final seen = <String>[];
      c.dispose();
      c = ProblemsController(
        analyze: (root) async {
          seen.add(root);
          if (seen.length == 1) await gate.future;
          return AnalyzeResult.ok([_d('$root${_sep}lib${_sep}x.dart', 1, DiagnosticSeverity.error)]);
        },
        pubGet: (_) async => true,
      );
      final first = c.setProjectDir(pkg.path);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final second = c.setProjectDir(other.path);
      gate.complete();
      await Future.wait([first, second]);

      expect(seen, [pkg.path, other.path]);
      expect(c.packageRoot, other.path);
      expect(c.diagnostics.single.file, startsWith(other.path), reason: '이전 패키지의 결과는 버려진다');
    });
  });

  group('DartAnalyzer (실제 dart analyze)', () {
    late Directory pkg;

    setUp(() async {
      pkg = await Directory.systemTemp.createTemp('real_analyze');
      File('${pkg.path}${_sep}pubspec.yaml').writeAsStringSync('name: probe_pkg\nenvironment:\n  sdk: ^3.0.0\n');
      Directory('${pkg.path}${_sep}lib').createSync();
    });

    tearDown(() => pkg.delete(recursive: true));

    test('오류와 경고를 찾아 위치를 돌려준다', () async {
      File('${pkg.path}${_sep}lib${_sep}bad.dart').writeAsStringSync("void main() {\n  int x = 'a';\n  undefinedCall();\n}\n");
      final r = await DartAnalyzer(CommandRunner(CommandLog())).run(pkg.path);

      expect(r.ok, isTrue, reason: r.error);
      final errors = r.diagnostics.where((d) => d.severity == DiagnosticSeverity.error).toList();
      expect(errors.map((d) => d.code), containsAll(['invalid_assignment', 'undefined_function']));
      final undefinedCall = errors.firstWhere((d) => d.code == 'undefined_function');
      expect(undefinedCall.line, 3);
      expect(undefinedCall.column, 3);
      expect(undefinedCall.length, 13);
      expect(pathKey(undefinedCall.file), endsWith('lib/bad.dart'));
    }, timeout: const Timeout(Duration(seconds: 90)));

    test('깨끗한 패키지는 빈 목록', () async {
      File('${pkg.path}${_sep}lib${_sep}ok.dart').writeAsStringSync('void main() {}\n');
      final r = await DartAnalyzer(CommandRunner(CommandLog())).run(pkg.path);
      expect(r.ok, isTrue, reason: r.error);
      expect(r.diagnostics, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 90)));
  });
}
