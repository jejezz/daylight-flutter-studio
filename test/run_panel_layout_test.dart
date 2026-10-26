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
    final divider = tester.getRect(find.byType(VerticalDivider));
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

  testWidgets('도구 막대: 대상 드롭다운에서 기기를 고르고, 실행 단추는 맨 위에 있다', (tester) async {
    controller
      ..devices = const [
        MobileDevice(id: 'p1', name: 'Pixel 8', platform: DevicePlatform.android, link: DeviceLink.usb),
        MobileDevice(id: 'p2', name: 'Galaxy S24', platform: DevicePlatform.android, link: DeviceLink.usb),
      ]
      ..selectedId = 'p1';
    await tester.pumpWidget(app(1200));
    await tester.pump();

    expect(find.text('Pixel 8'), findsOneWidget);
    expect(find.text('Debug'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing, reason: '탭 줄을 더 두지 않는다');
    final bar = tester.getRect(find.text('Debug')).top;
    final run = tester.getRect(find.text('디버그 실행')).top;
    expect(run, closeTo(bar, 30), reason: '실행 단추는 모드와 같은 줄에 있다');

    await tester.tap(find.text('Pixel 8'));
    await tester.pumpAndSettle();
    expect(find.text('Galaxy S24'), findsOneWidget);
    await tester.tap(find.text('Galaxy S24'));
    await tester.pumpAndSettle();
    expect(controller.selectedId, 'p2');
  });

  testWidgets('기기가 없으면 드롭다운에 연결 안내가 나온다', (tester) async {
    // 이 컴퓨터(데스크톱) 대상이 목록에 끼지 않도록 Android만 지원하는 프로젝트로 한다.
    controller.project = const FlutterProject(path: '/p', name: 'demo_app', version: '1.2.3+4', hasIos: false, hasAndroid: true);
    await tester.pumpWidget(app(1200));
    await tester.pump();
    await tester.tap(find.text('대상을 고르지 않았습니다'));
    await tester.pumpAndSettle();
    expect(find.text('연결된 기기가 없습니다'), findsOneWidget);
    expect(find.textContaining('USB 케이블'), findsOneWidget);
    expect(find.text('기기 다시 찾기'), findsOneWidget);
  });
}
