import 'package:daylight_workbench/theme/app_theme.dart';
import 'package:daylight_workbench/theme/syntax_theme.dart';
import 'package:daylight_workbench/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('고대비 팔레트', () {
    test('다크는 순흑, 라이트는 순백 — 새턴과 다른 ColorScheme', () {
      final dark = AppTheme.build(StudioPalette.highContrast, Brightness.dark);
      final light = AppTheme.build(StudioPalette.highContrast, Brightness.light);
      expect(dark.colorScheme.surface, Colors.black);
      expect(dark.colorScheme.onSurface, Colors.white);
      expect(light.colorScheme.surface, Colors.white);
      expect(light.colorScheme.onSurface, Colors.black);

      final saturnDark = AppTheme.build(StudioPalette.saturn, Brightness.dark);
      expect(dark.colorScheme.surface, isNot(saturnDark.colorScheme.surface));
    });

    test('구문 강조 색도 고대비 전용이고 밝기마다 다르다', () {
      final darkTokens = AppTheme.build(StudioPalette.highContrast, Brightness.dark).extension<SyntaxTokens>()!;
      final lightTokens = AppTheme.build(StudioPalette.highContrast, Brightness.light).extension<SyntaxTokens>()!;
      final saturnDarkTokens = AppTheme.build(StudioPalette.saturn, Brightness.dark).extension<SyntaxTokens>()!;
      expect(darkTokens.keyword, isNot(lightTokens.keyword));
      expect(darkTokens.keyword, isNot(saturnDarkTokens.keyword));
    });

    test('선택된 목록 항목(설정 왼쪽 목록 등) 글자색이 배경과 같은 색으로 묻히지 않는다', () {
      // ListTile의 기본 selectedColor(colorScheme.primary)는 고대비에서 secondaryContainer(= primary와
      // 같은 색)와 겹쳐 글자가 안 보이게 된다 — onSecondaryContainer로 맞춰서 Chip·SegmentedButton과
      // 같은 색 규칙을 쓰게 고쳤다.
      for (final brightness in Brightness.values) {
        final theme = AppTheme.build(StudioPalette.highContrast, brightness);
        expect(theme.listTileTheme.selectedColor, theme.colorScheme.onSecondaryContainer);
        expect(theme.listTileTheme.selectedColor, isNot(theme.colorScheme.secondaryContainer));
      }
    });

    test('고대비 색 구성 선택 자체는 주색 재질(apply)을 거치지 않는다', () {
      // StudioPalette.apply는 saturn·highContrast일 때 원본 scheme을 그대로 돌려준다 — 고대비는
      // _HighContrastTheme이 완전히 새로 만든 scheme을 쓰므로 apply를 거쳐도 안전해야 한다.
      final scheme = const ColorScheme.light();
      expect(StudioPalette.highContrast.apply(scheme), same(scheme));
    });
  });

  group('UI 글꼴', () {
    test('글꼴 이름을 안 주면 기본 글꼴을 쓴다', () {
      final theme = AppTheme.build(StudioPalette.saturn, Brightness.light);
      expect(theme.textTheme.bodyMedium!.fontFamily, AppFonts.family);
    });

    test('글꼴 이름을 주면 그 글꼴을 쓰고, 대체 목록에 한글 글꼴이 남는다', () {
      final theme = AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontFamily: 'Segoe UI');
      final body = theme.textTheme.bodyMedium!;
      expect(body.fontFamily, 'Segoe UI');
      expect(body.fontFamilyFallback, containsAll(AppFonts.fallback));
    });

    test('배율은 글자 크기에만 곱하고 범위 밖이면 가장 가까운 값으로 맞춘다', () {
      final base = AppTheme.build(StudioPalette.saturn, Brightness.light);
      final scaled = AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontScale: 1.2);
      expect(scaled.textTheme.bodyMedium!.fontSize, closeTo(base.textTheme.bodyMedium!.fontSize! * 1.2, 0.001));

      final tooSmall = AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontScale: 0.1);
      final tooBig = AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontScale: 9.0);
      expect(tooSmall.textTheme.bodyMedium!.fontSize, closeTo(base.textTheme.bodyMedium!.fontSize! * AppTheme.minUiFontScale, 0.001));
      expect(tooBig.textTheme.bodyMedium!.fontSize, closeTo(base.textTheme.bodyMedium!.fontSize! * AppTheme.maxUiFontScale, 0.001));
    });

    test('appBar 제목·단추 글꼴도 같이 바뀐다', () {
      final theme = AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontFamily: 'Segoe UI');
      expect(theme.appBarTheme.titleTextStyle!.fontFamily, 'Segoe UI');
      expect(theme.filledButtonTheme.style!.textStyle!.resolve(<WidgetState>{})!.fontFamily, 'Segoe UI');
    });
  });

  group('최대 배율에서도 레이아웃이 깨지지 않는다', () {
    testWidgets('앱 바·탭·단추가 최대 UI 글꼴 배율(125%)에서도 넘치지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(StudioPalette.saturn, Brightness.light, uiFontScale: AppTheme.maxUiFontScale),
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('아주 긴 프로젝트 이름 예시 daylight-workbench'),
                bottom: const TabBar(tabs: [Tab(text: 'Run'), Tab(text: '문제'), Tab(text: '터미널')]),
              ),
              body: Center(child: FilledButton(onPressed: () {}, child: const Text('설정 열기'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('overflowed'), findsNothing);
    });
  });

  group('ThemeController', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('기본값은 앱 기본 글꼴·100% 배율', () {
      final c = ThemeController();
      expect(c.uiFontFamily, isNull);
      expect(c.uiFontScale, AppTheme.defaultUiFontScale);
    });

    test('UI 글꼴 이름·배율을 바꾸면 다음에도 기억한다', () async {
      final c = ThemeController();
      await c.setUiFontFamily('Segoe UI');
      await c.setUiFontScale(1.15);
      expect(c.uiFontFamily, 'Segoe UI');
      expect(c.uiFontScale, 1.15);

      final restored = ThemeController();
      await restored.restore();
      expect(restored.uiFontFamily, 'Segoe UI');
      expect(restored.uiFontScale, 1.15);
    });

    test('빈 이름으로 되돌리면 기본 글꼴로, 배율은 범위로 맞춘다', () async {
      final c = ThemeController();
      await c.setUiFontFamily('Segoe UI');
      await c.setUiFontFamily('   ');
      expect(c.uiFontFamily, isNull);

      await c.setUiFontScale(5.0);
      expect(c.uiFontScale, AppTheme.maxUiFontScale);
    });

    test('고대비를 고르면 light/dark 테마가 바로 고대비로 바뀐다', () async {
      final c = ThemeController();
      await c.setPalette(StudioPalette.highContrast);
      expect(c.dark.colorScheme.surface, Colors.black);
      expect(c.light.colorScheme.surface, Colors.white);
    });
  });
}
