import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/devices/device_service.dart';
import 'package:daylight_flutter_studio/devices/mobile_device.dart';
import 'package:daylight_flutter_studio/flutter/flutter_project.dart';
import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/run/run_controller.dart';
import 'package:daylight_flutter_studio/settings/app_settings.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/ui/run_panel.dart';
import 'package:daylight_flutter_studio/verify/verify_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoDevices implements DeviceService {
  @override
  Future<List<MobileDevice>> list() async => const [];
}

/// Run 패널은 좁은 곳(세로 한 줄)과 넓은 곳(아래 패널: 고르는 것 | 결과 두 칸)에서 다르게 배치된다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettings settings;
  late CommandLog log;
  late RunController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    log = CommandLog();
    final runner = CommandRunner(log);
    controller = RunController(runner: runner, deviceService: _NoDevices(), store: VerifyStore(runner));
    controller.project = const FlutterProject(
      path: '/p',
      name: 'demo_app',
      version: '1.2.3+4',
      hasIos: false,
      hasAndroid: false,
      hasWindows: true,
      windowsBinaryName: 'demo_app',
    );
  });

  tearDown(() {
    controller.dispose();
    log.dispose();
  });

  Widget app(double width) => AppSettingsScope(
    settings: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
      home: Scaffold(body: SizedBox(width: width, height: 320, child: RunPanel(controller: controller, log: log))),
    ),
  );

  testWidgets('좁으면(Dock 폭) 한 줄로 쌓는다', (tester) async {
    await tester.pumpWidget(app(RunPanel.wideWidth - 100));
    await tester.pump();
    expect(find.byType(VerticalDivider), findsNothing);
    expect(find.textContaining('demo_app'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('넓으면(아래 패널) 왼쪽 고르는 칸 | 오른쪽 결과 칸으로 나눈다', (tester) async {
    await tester.pumpWidget(app(1200));
    await tester.pump();

    expect(find.byType(VerticalDivider), findsOneWidget);
    final title = tester.getRect(find.textContaining('demo_app'));
    final divider = tester.getRect(find.byType(VerticalDivider));
    expect(title.right, lessThanOrEqualTo(RunPanel.wideControlsWidth), reason: '프로젝트 이름은 왼쪽 칸 안');
    expect(divider.left, closeTo(RunPanel.wideControlsWidth, 1));
    expect(tester.takeException(), isNull, reason: '넓은 배치에서도 넘치지 않는다');
  });

  testWidgets('기준 너비를 넘나들면 배치가 바로 바뀐다', (tester) async {
    await tester.pumpWidget(app(RunPanel.wideWidth + 40));
    await tester.pump();
    expect(find.byType(VerticalDivider), findsOneWidget);

    await tester.pumpWidget(app(RunPanel.wideWidth - 40));
    await tester.pump();
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('Flutter 프로젝트가 아니면 두 배치 모두 안내만 보인다', (tester) async {
    controller.project = null;
    await tester.pumpWidget(app(1200));
    await tester.pump();
    expect(find.byType(VerticalDivider), findsNothing);
    expect(find.textContaining('Flutter'), findsWidgets);
  });
}
