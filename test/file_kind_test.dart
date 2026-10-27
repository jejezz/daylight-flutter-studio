import 'dart:io';

import 'package:daylight_workbench/l10n/app_localizations.dart';
import 'package:daylight_workbench/studio/file_kind.dart';
import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/studio_icons.dart';
import 'package:daylight_workbench/theme/syntax_theme.dart';
import 'package:daylight_workbench/ui/file_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fileKindOf', () {
    test('확장자로 종류를 정한다 (대소문자 무시, 경로 구분자 무관)', () {
      expect(fileKindOf('lib/main.dart'), FileKind.dart);
      expect(fileKindOf(r'C:\p\lib\MAIN.DART'), FileKind.dart);
      expect(fileKindOf('a/b.yml'), FileKind.yaml);
      expect(fileKindOf('lib/l10n/app_ko.arb'), FileKind.json);
      expect(fileKindOf('data.json'), FileKind.json);
      expect(fileKindOf('README.md'), FileKind.document);
      expect(fileKindOf('logo.PNG'), FileKind.image);
      expect(fileKindOf('web/index.html'), FileKind.markup);
      expect(fileKindOf('android/app/build.gradle'), FileKind.source);
      expect(fileKindOf('ios/Runner/AppDelegate.swift'), FileKind.source);
      expect(fileKindOf('run.sh'), FileKind.script);
      expect(fileKindOf('gradle.properties'), FileKind.config);
    });

    test('이름으로 정하는 특별한 파일', () {
      expect(fileKindOf('pubspec.yaml'), FileKind.package);
      expect(fileKindOf('pubspec.lock'), FileKind.package);
      expect(fileKindOf('analysis_options.yaml'), FileKind.settings);
      expect(fileKindOf('a/CMakeLists.txt'), FileKind.source);
      expect(fileKindOf('Dockerfile'), FileKind.source);
      expect(fileKindOf('LICENSE'), FileKind.document);
      expect(fileKindOf('.gitignore'), FileKind.config);
    });

    test('모르는 파일은 other', () {
      expect(fileKindOf('data.bin'), FileKind.other);
      expect(fileKindOf('noextension'), FileKind.other);
      expect(fileKindOf(''), FileKind.other);
    });
  });

  group('파일 트리의 아이콘', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('file_icons'));
    tearDown(() => dir.deleteSync(recursive: true));

    Widget app(StudioIconSet set) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light, iconSet: set),
      home: Scaffold(body: FileTree(root: dir.path, onOpenFile: (_) {})),
    );

    Future<void> load(WidgetTester tester, StudioIconSet set) async {
      await tester.pumpWidget(app(set));
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
    }

    testWidgets('파일 종류마다 다른 아이콘과 테마의 구문 강조 색을 쓴다', (tester) async {
      File('${dir.path}/a.dart').writeAsStringSync('');
      File('${dir.path}/b.json').writeAsStringSync('');
      File('${dir.path}/c.png').writeAsStringSync('');
      File('${dir.path}/d.bin').writeAsStringSync('');
      await load(tester, StudioIconSet.rounded);

      const rounded = StudioIcons(StudioIconSet.rounded);
      final syntax = AppTheme.build(StudioPalette.saturn, Brightness.light).extension<SyntaxTokens>()!;
      Icon iconAt(IconData data) => tester.widget<Icon>(find.byIcon(data));

      expect(iconAt(rounded.code).color, syntax.title); // a.dart
      expect(iconAt(rounded.dataObject).color, syntax.classType); // b.json
      expect(iconAt(rounded.image).color, syntax.string); // c.png
      expect(find.byIcon(rounded.insertDriveFile), findsOneWidget); // d.bin
    });

    testWidgets('아이콘 세트를 바꾸면 같은 종류의 아이콘이 그 세트의 모양으로 바뀐다', (tester) async {
      File('${dir.path}/a.dart').writeAsStringSync('');
      await load(tester, StudioIconSet.outlined);
      expect(find.byIcon(const StudioIcons(StudioIconSet.outlined).code), findsOneWidget);
      expect(find.byIcon(const StudioIcons(StudioIconSet.rounded).code), findsNothing);
    });
  });
}
