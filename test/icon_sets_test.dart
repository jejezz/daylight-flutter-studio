import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/studio_icons.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('세트마다 같은 의미의 다른 모양 아이콘을 준다', () {
    const filled = StudioIcons(StudioIconSet.filled);
    const outlined = StudioIcons(StudioIconSet.outlined);
    const rounded = StudioIcons(StudioIconSet.rounded);
    expect(filled.settings, Icons.settings);
    expect(outlined.settings, Icons.settings_outlined);
    expect(rounded.settings, Icons.settings_rounded);
    expect({filled.folderOpen, outlined.folderOpen, rounded.folderOpen}, hasLength(3));
  });

  test('아이콘 세트는 저장되고 다시 읽힌다', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ThemeController();
    await a.setIconSet(StudioIconSet.outlined);
    final b = ThemeController();
    await b.restore();
    expect(b.iconSet, StudioIconSet.outlined);
    expect(b.light.extension<StudioTokens>()!.icons.set, StudioIconSet.outlined);
    a.dispose();
    b.dispose();
  });

  testWidgets('설정에서 아이콘 모양을 고르면 화면의 아이콘이 따라 바뀐다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final theme = ThemeController();
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: theme,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          theme: theme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  Icon(context.icons.settings, key: const Key('probe')),
                  FilledButton(onPressed: () => showSettingsDialog(context, theme: theme), child: const Text('열기')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.widget<Icon>(find.byKey(const Key('probe'))).icon, Icons.settings_rounded);
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('윤곽선'));
    await tester.tap(find.text('윤곽선'));
    await tester.pumpAndSettle();
    expect(theme.iconSet, StudioIconSet.outlined);
    expect(tester.widget<Icon>(find.byKey(const Key('probe'))).icon, Icons.settings_outlined);
    theme.dispose();
  });
}
