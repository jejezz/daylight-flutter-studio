import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/problems/diagnostic.dart';
import 'package:daylight_workbench/problems/problems_controller.dart';
import 'package:daylight_workbench/studio/studio_controller.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/ui/editor_pane.dart';
import 'package:daylight_workbench/ui/problem_gutter.dart';
import 'package:daylight_workbench/ui/problem_squiggles.dart';
import 'package:daylight_workbench/ui/problems_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _sep = Platform.pathSeparator;

Diagnostic _d(String file, int line, DiagnosticSeverity s, {String code = 'some_code', String message = 'message', int column = 1, int length = 0, String correction = ''}) =>
    Diagnostic(code: code, severity: s, message: message, file: file, line: line, column: column, length: length, correction: correction);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory pkg;
  late AnalyzeResult next;
  late ProblemsController problems;

  String file(String name) => '${pkg.path}${_sep}lib$_sep$name';

  Widget app(Widget body) => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ko'), 
    theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
    home: Scaffold(body: body),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pkg = await Directory.systemTemp.createTemp('problems_ui');
    Directory('${pkg.path}${_sep}lib').createSync();
    File('${pkg.path}${_sep}pubspec.yaml').writeAsStringSync('name: x');
    File(file('a.dart')).writeAsStringSync('line1\nline2\nline3\nline4\nline5\n');
    next = const AnalyzeResult.ok([]);
    problems = ProblemsController(analyze: (_) async => next, pubGet: (_) async => true, saveDelay: const Duration(milliseconds: 10));
  });

  tearDown(() async {
    problems.dispose();
    await pkg.delete(recursive: true);
  });

  group('문제 패널', () {
    Future<void> load(WidgetTester tester, List<Diagnostic> list) async {
      next = AnalyzeResult.ok(list);
      await tester.runAsync(() => problems.setProjectDir(pkg.path));
    }

    testWidgets('서브 패키지에 패키지 정보가 없으면 배너가 그 패키지 이름을 알려 주고 pub get 단추가 있다', (tester) async {
      // 열린 패키지는 멀쩡하다(패키지 정보 있음) — 문제는 packages/sub 안의 파일에서 난다.
      Directory('${pkg.path}$_sep.dart_tool').createSync();
      File('${pkg.path}$_sep.dart_tool${_sep}package_config.json').writeAsStringSync('{}');
      final sub = '${pkg.path}${_sep}packages${_sep}sub';
      Directory('$sub${_sep}test').createSync(recursive: true);
      File('$sub${_sep}pubspec.yaml').writeAsStringSync('name: sub');
      File('$sub${_sep}test${_sep}a_test.dart').writeAsStringSync('x\n');
      await load(tester, [_d('$sub${_sep}test${_sep}a_test.dart', 5, DiagnosticSeverity.error, message: 'Target of URI doesn\'t exist')]);
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (_) {})));
      await tester.pump();

      expect(find.textContaining('packages/sub의 패키지 정보'), findsOneWidget);
      expect(find.text('flutter pub get'), findsOneWidget);
    });

    testWidgets('파일별로 묶어 보여 주고, 누르면 그 문제를 연다', (tester) async {
      await load(tester, [
        _d(file('a.dart'), 3, DiagnosticSeverity.error, message: '정의되지 않은 함수', column: 7),
        _d(file('a.dart'), 1, DiagnosticSeverity.warning, message: '쓰지 않는 변수'),
        _d(file('b.dart'), 9, DiagnosticSeverity.info, message: 'const를 쓰세요'),
      ]);

      Diagnostic? opened;
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (d) => opened = d)));
      await tester.pump();

      expect(find.text('lib$_sep${'a.dart'}'), findsOneWidget, reason: '파일 이름은 패키지 기준 상대 경로');
      expect(find.text('lib${_sep}b.dart'), findsOneWidget);
      expect(find.text('정의되지 않은 함수'), findsOneWidget);
      expect(find.text('3:7 · some_code'), findsOneWidget);

      // 같은 파일 안에서는 오류가 경고보다 위에 있다.
      final errorY = tester.getTopLeft(find.text('정의되지 않은 함수')).dy;
      final warningY = tester.getTopLeft(find.text('쓰지 않는 변수')).dy;
      expect(errorY, lessThan(warningY));

      await tester.tap(find.text('정의되지 않은 함수'));
      expect(opened?.line, 3);
      expect(opened?.column, 7);
    });

    testWidgets('종류 필터로 숨기고 다시 보인다', (tester) async {
      await load(tester, [
        _d(file('a.dart'), 3, DiagnosticSeverity.error, message: '오류 메시지'),
        _d(file('a.dart'), 4, DiagnosticSeverity.info, message: '정보 메시지'),
      ]);
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (_) {})));
      await tester.pump();
      expect(find.text('정보 메시지'), findsOneWidget);

      await tester.tap(find.textContaining('정보 1'));
      await tester.pump();
      expect(find.text('정보 메시지'), findsNothing);
      expect(find.text('오류 메시지'), findsOneWidget);

      await tester.tap(find.textContaining('오류 1'));
      await tester.pump();
      expect(find.textContaining('선택한 종류의 문제가 없습니다'), findsOneWidget);
    });

    testWidgets('문제가 없으면 분명히 알려 준다', (tester) async {
      await load(tester, []);
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (_) {})));
      await tester.pump();
      expect(find.text('문제가 없습니다'), findsOneWidget);
    });

    testWidgets('분석이 실패하면 "문제 없음"이라고 하지 않는다', (tester) async {
      next = const AnalyzeResult.failed('dart 명령을 찾을 수 없습니다.');
      await tester.runAsync(() => problems.setProjectDir(pkg.path));
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (_) {})));
      await tester.pump();
      expect(find.text('문제가 없습니다'), findsNothing);
      expect(find.textContaining('문제 여부를 알 수 없습니다'), findsOneWidget);
      expect(find.text('dart 명령을 찾을 수 없습니다.'), findsOneWidget);
    });

    testWidgets('패키지 정보가 없으면 pub get 안내와 단추가 뜬다', (tester) async {
      await load(tester, []);
      await tester.pumpWidget(app(ProblemsPanel(controller: problems, onOpen: (_) {})));
      await tester.pump();
      expect(find.textContaining('패키지 정보(.dart_tool)가 없어서'), findsOneWidget);
      expect(find.text('flutter pub get'), findsOneWidget);

      Directory('${pkg.path}$_sep.dart_tool').createSync();
      File('${pkg.path}$_sep.dart_tool${_sep}package_config.json').writeAsStringSync('{}');
      await tester.runAsync(problems.refresh); // 다시 분석하면 화면이 패키지 정보를 다시 확인한다
      await tester.pump();
      expect(find.text('flutter pub get'), findsNothing);
    });

    testWidgets('Dart 패키지가 없는 폴더라면 안내한다', (tester) async {
      final empty = ProblemsController(analyze: (_) async => next, pubGet: (_) async => true);
      addTearDown(empty.dispose);
      await tester.pumpWidget(app(ProblemsPanel(controller: empty, onOpen: (_) {})));
      await tester.pump();
      expect(find.textContaining('pubspec.yaml'), findsOneWidget);
    });
  });

  group('편집기 줄 번호 옆 문제 점', () {
    late StudioController c;

    setUp(() {
      // 테스트의 기본 플랫폼은 Android다 — 편집기가 모바일용 지연 타이머를 만들지 않게 데스크톱으로 맞춘다.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      c = StudioController(onSaved: (p) => problems.onSaved(p));
    });
    tearDown(() => c.dispose());

    Widget editor() => app(
      ListenableBuilder(
        listenable: c,
        builder: (context, _) => EditorPane(controller: c, problems: problems),
      ),
    );

    Future<void> unmount(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null; // 테스트가 끝나기 전에 되돌려야 한다
    }

    testWidgets('오류·경고 줄에 테마 색 점을 그린다', (tester) async {
      next = AnalyzeResult.ok([_d(file('a.dart'), 2, DiagnosticSeverity.error), _d(file('a.dart'), 4, DiagnosticSeverity.warning)]);
      await tester.runAsync(() async {
        await problems.setProjectDir(pkg.path);
        await c.openFile(file('a.dart'));
      });
      await tester.pumpWidget(editor());
      await tester.pump(const Duration(milliseconds: 100));

      final tokens = AppTheme.build(StudioPalette.saturn, Brightness.light).extension<StudioTokens>()!;
      final gutter = tester.renderObject(find.descendant(of: find.byType(ProblemGutter), matching: find.byType(CustomPaint)).last);
      expect(gutter, paints..circle(color: tokens.danger)..circle(color: tokens.warning));
      await unmount(tester);
    });

    testWidgets('문제가 없는 파일에는 점이 없다', (tester) async {
      next = AnalyzeResult.ok([_d(file('other.dart'), 2, DiagnosticSeverity.error)]);
      await tester.runAsync(() async {
        await problems.setProjectDir(pkg.path);
        await c.openFile(file('a.dart'));
      });
      await tester.pumpWidget(editor());
      await tester.pump(const Duration(milliseconds: 100));

      final gutter = tester.renderObject(find.descendant(of: find.byType(ProblemGutter), matching: find.byType(CustomPaint)).last);
      expect(gutter, isNot(paints..circle()));
      await unmount(tester);
    });

    testWidgets('문제가 있는 글자 밑에 테마 색 물결 밑줄을 긋는다', (tester) async {
      next = AnalyzeResult.ok([_d(file('a.dart'), 2, DiagnosticSeverity.error, column: 2, length: 3), _d(file('a.dart'), 4, DiagnosticSeverity.warning, column: 1, length: 5)]);
      await tester.runAsync(() async {
        await problems.setProjectDir(pkg.path);
        await c.openFile(file('a.dart'));
      });
      await tester.pumpWidget(editor());
      await tester.pump(const Duration(milliseconds: 100));

      final tokens = AppTheme.build(StudioPalette.saturn, Brightness.light).extension<StudioTokens>()!;
      final squiggles = tester.renderObject(find.descendant(of: find.byType(ProblemSquiggles), matching: find.byType(CustomPaint)).last);
      expect(squiggles, paints..path(color: tokens.danger)..path(color: tokens.warning));
      await unmount(tester);
    });

    testWidgets('문제가 없는 파일에는 물결 밑줄이 없다', (tester) async {
      next = AnalyzeResult.ok([_d(file('other.dart'), 2, DiagnosticSeverity.error, length: 3)]);
      await tester.runAsync(() async {
        await problems.setProjectDir(pkg.path);
        await c.openFile(file('a.dart'));
      });
      await tester.pumpWidget(editor());
      await tester.pump(const Duration(milliseconds: 100));

      final squiggles = tester.renderObject(find.descendant(of: find.byType(ProblemSquiggles), matching: find.byType(CustomPaint)).last);
      expect(squiggles, isNot(paints..path()));
      await unmount(tester);
    });

    testWidgets('분석이 끝나면 열려 있는 편집기에 점이 나타난다', (tester) async {
      await tester.runAsync(() async {
        await problems.setProjectDir(pkg.path);
        await c.openFile(file('a.dart'));
      });
      await tester.pumpWidget(editor());
      await tester.pump(const Duration(milliseconds: 100));
      final gutter = tester.renderObject(find.descendant(of: find.byType(ProblemGutter), matching: find.byType(CustomPaint)).last);
      expect(gutter, isNot(paints..circle()));

      next = AnalyzeResult.ok([_d(file('a.dart'), 1, DiagnosticSeverity.error)]);
      await tester.runAsync(problems.refresh);
      await tester.pump(const Duration(milliseconds: 100));
      expect(gutter, paints..circle());
      await unmount(tester);
    });
  });

  test('물결선은 시작과 끝 사이를 위아래로 번갈아 오르내린다', () {
    final bounds = squigglePath(10, 25, 20).getBounds();
    expect(bounds.left, 10);
    expect(bounds.right, 25);
    expect(bounds.top, lessThan(20));
    expect(bounds.bottom, greaterThan(20));
    expect(squigglePath(10, 10, 20).getBounds().width, 0, reason: '길이가 없으면 선도 없다');
  });

  group('문제 위치로 이동 (StudioController.openAt)', () {
    late StudioController c;

    setUp(() => c = StudioController());
    tearDown(() => c.dispose());

    test('파일을 열고 줄·열에 커서를 둔다 (1부터)', () async {
      await c.openAt(file('a.dart'), 3, 4);
      final sel = c.activeTab!.controller.selection;
      expect(sel.extentIndex, 2);
      expect(sel.extentOffset, 3);
      expect(c.activeTab!.diffMode, isFalse);
    });

    test('범위를 벗어난 줄·열은 끝으로 맞춘다', () async {
      await c.openAt(file('a.dart'), 999, 999);
      final sel = c.activeTab!.controller.selection;
      expect(sel.extentIndex, c.activeTab!.controller.codeLines.length - 1);
      expect(sel.extentOffset, lessThanOrEqualTo(c.activeTab!.controller.codeLines.last.text.length));
    });

    test('변경점 보기 중인 탭도 편집 화면으로 돌려 보여 준다', () async {
      await c.openDiff(file('a.dart'));
      c.activeTab!.diffMode = true;
      await c.openAt(file('a.dart'), 2, 1);
      expect(c.activeTab!.diffMode, isFalse);
    });

    test('경로 표기가 달라도 같은 파일이면 탭을 새로 만들지 않는다', () async {
      await c.openFile(file('a.dart'));
      final alt = file('a.dart').replaceAll(_sep, '/');
      await c.openAt(alt, 2, 1);
      expect(c.tabs.length, 1);
      expect(c.tabFor(alt), same(c.activeTab));
    });

    test('저장하면 onSaved가 불린다', () async {
      final saved = <String>[];
      final c2 = StudioController(onSaved: saved.add);
      addTearDown(c2.dispose);
      await c2.openFile(file('a.dart'));
      c2.activeTab!.controller.text = 'changed\n';
      expect(await c2.save(c2.activeTab!), isTrue);
      expect(saved, [file('a.dart')]);
    });
  });
}
