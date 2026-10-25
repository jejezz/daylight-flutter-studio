import 'dart:io';

import 'package:daylight_flutter_studio/studio/dart_chunk_analyzer.dart';
import 'package:daylight_flutter_studio/studio/fold_plan.dart';
import 'package:daylight_flutter_studio/studio/studio_controller.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/editor_pane.dart';
import 'package:daylight_flutter_studio/ui/markdown_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dart = '''
class A {
  void a() {
    print(1);
  }

  void b() {
    if (true) {
      print(2);
    }
  }
}
''';

Widget _app(StudioController c, {Brightness brightness = Brightness.light}) => MaterialApp(
  theme: AppTheme.build(StudioPalette.indigo, brightness),
  home: Scaffold(
    body: ListenableBuilder(
      listenable: c,
      builder: (context, _) => EditorPane(controller: c),
    ),
  ),
);

/// 편집기는 커서 깜빡임 타이머를 쓴다 — 트리를 내려야 타이머가 정리된다.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  late Directory dir;
  late StudioController c;

  setUp(() async {
    // 테스트의 기본 플랫폼은 Android다 — 편집기가 모바일용 지연 타이머를 만들지 않게 데스크톱으로 맞춘다.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('editor_pane');
    c = StudioController();
  });

  tearDown(() async {
    c.dispose();
    await dir.delete(recursive: true);
  });

  File write(String name, String text) => File('${dir.path}${Platform.pathSeparator}$name')..writeAsStringSync(text);

  testWidgets('Dart 파일을 열면 편집기와 정렬 단추가 보이고, 줄 끝(CRLF)을 유지한다', (tester) async {
    final f = write('a.dart', _dart.replaceAll('\n', '\r\n'));
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(find.byTooltip('Dart 정렬 (Ctrl+Alt+L)'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(c.activeTab!.dirty, isFalse);
    expect(c.activeTab!.controller.text.contains('\r\n'), isTrue);

    await tester.runAsync(() => c.save(c.activeTab!));
    expect(f.readAsStringSync().contains('\r\n'), isTrue, reason: '저장해도 CRLF가 LF로 바뀌면 안 된다');
    await _unmount(tester);
  });

  testWidgets('모두 접기 → 모두 펴기', (tester) async {
    final f = write('a.dart', _dart);
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    // 접기 구간은 별도 isolate에서 계산된다.
    final tab = c.activeTab!;
    expect(tab.chunks, isNotNull);
    // 접기 구간은 편집기가 별도 isolate에서 계산한다 — 테스트에서는 같은 분석기를 직접 돌려 넣는다.
    tab.chunks!.value = const DartChunkAnalyzer().run(tab.controller.codeLines);
    expect(tab.chunks!.value, isNotEmpty);

    foldAll(tab.chunks);
    await tester.pump();
    final folded = [for (var i = 0; i < tab.controller.codeLines.length; i++) tab.controller.codeLines[i]].where((l) => l.chunkParent);
    expect(folded.length, 2, reason: 'a(), b() 몸통 두 개가 접힌다');

    unfoldAll(tab.controller, tab.chunks);
    await tester.pump();
    expect([for (var i = 0; i < tab.controller.codeLines.length; i++) tab.controller.codeLines[i]].any((l) => l.chunkParent), isFalse);
    await _unmount(tester);
  });

  testWidgets('Markdown은 편집과 보기를 전환한다', (tester) async {
    final f = write('README.md', '# 제목\n\n본문 **굵게**\n');
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c));
    await tester.pump();

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(find.byType(MarkdownView), findsNothing);
    expect(find.byTooltip('Dart 정렬 (Ctrl+Alt+L)'), findsNothing);

    await tester.tap(find.text('보기'));
    await tester.pump();
    expect(find.byType(MarkdownView), findsOneWidget);
    expect(find.byType(CodeEditor), findsNothing);
    expect(find.text('제목'), findsOneWidget);

    await tester.tap(find.text('편집'));
    await tester.pump();
    expect(find.byType(CodeEditor), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('다크 테마에서도 편집기가 그려진다', (tester) async {
    final f = write('a.dart', _dart);
    await tester.runAsync(() => c.openFile(f.path));
    await tester.pumpWidget(_app(c, brightness: Brightness.dark));
    await tester.pump();
    expect(find.byType(CodeEditor), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });
}
