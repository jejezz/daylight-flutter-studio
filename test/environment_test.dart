import 'package:daylight_flutter_studio/core/command_log.dart';
import 'package:daylight_flutter_studio/core/command_runner.dart';
import 'package:daylight_flutter_studio/doctor/checks.dart';
import 'package:daylight_flutter_studio/doctor/diagnostics.dart';
import 'package:daylight_flutter_studio/doctor/environment_controller.dart';
import 'package:daylight_flutter_studio/doctor/signing_info.dart';
import 'package:daylight_flutter_studio/l10n/app_localizations.dart';
import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:daylight_flutter_studio/theme/theme_controller.dart';
import 'package:daylight_flutter_studio/ui/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 10, 25);

Diagnostics _diag({ToolInfo flutter = const ToolInfo('3.47.1'), ToolInfo adb = const ToolInfo('1.0.41'), List<SigningCert> certs = const [], WindowsEnv? windows}) =>
    Diagnostics(flutter: flutter, xcode: const ToolInfo('26.0'), adb: adb, certs: certs, windows: windows, collectedAt: _now);

class _Service implements DiagnosticsService {
  int calls = 0;

  @override
  Future<Diagnostics> collect() async {
    calls++;
    return _diag();
  }
}

CheckStatus _status(List<CheckItem> items, CheckId id) => items.firstWhere((i) => i.id == id).status;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildEnvironmentChecks', () {
    test('flutter가 없으면 실패, adb가 없으면 경고', () {
      final items = buildEnvironmentChecks(
        diagnostics: _diag(flutter: const ToolInfo(null), adb: const ToolInfo(null)),
        hostIsMac: false,
        hostIsWindows: false,
        now: _now,
      );
      expect(_status(items, CheckId.flutter), CheckStatus.fail);
      expect(_status(items, CheckId.adb), CheckStatus.warn);
      expect(items.any((i) => i.id == CheckId.xcode), isFalse, reason: 'Mac이 아니면 Xcode는 점검하지 않는다');
    });

    test('Mac: 서명 인증서와 만료일을 본다', () {
      final items = buildEnvironmentChecks(
        diagnostics: _diag(
          certs: [
            SigningCert(name: 'Apple Development: A (T1)', teamId: 'T1', expires: _now.add(const Duration(days: 10)), hasPrivateKey: true),
            SigningCert(name: 'Apple Development: B (T2)', teamId: 'T2', expires: _now.subtract(const Duration(days: 1)), hasPrivateKey: true),
            const SigningCert(name: 'Apple Development: C (T3)', teamId: 'T3'),
          ],
        ),
        hostIsMac: true,
        hostIsWindows: false,
        now: _now,
      );
      expect(_status(items, CheckId.certificate), CheckStatus.ok);
      final expiry = items.where((i) => i.id == CheckId.certificateExpiry).toList();
      expect(expiry.map((i) => i.status), [CheckStatus.warn, CheckStatus.fail]);
      expect(_status(items, CheckId.xcode), CheckStatus.ok);
    });

    test('Mac에 쓸 수 있는 인증서가 없으면 경고 (iOS를 안 쓰면 문제가 아니다)', () {
      final items = buildEnvironmentChecks(diagnostics: _diag(), hostIsMac: true, hostIsWindows: false, now: _now);
      expect(_status(items, CheckId.certificate), CheckStatus.warn);
    });

    test('Windows: 개발자 모드와 Visual Studio', () {
      final items = buildEnvironmentChecks(
        diagnostics: _diag(windows: const WindowsEnv(developerMode: false, visualStudio: '17.9')),
        hostIsMac: false,
        hostIsWindows: true,
        now: _now,
      );
      expect(_status(items, CheckId.windowsDeveloperMode), CheckStatus.warn);
      expect(_status(items, CheckId.visualStudio), CheckStatus.ok);
    });
  });

  group('EnvironmentController', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('도구 위치는 저장되고 다음 실행에 실행기로 되돌아온다', () async {
      final runner = CommandRunner(CommandLog(), path: '/usr/bin');
      final c = EnvironmentController(runner: runner, service: _Service());
      var notified = 0;
      c.onToolPathsChanged = () => notified++;
      await c.setToolPath('flutter', '/opt/flutter/bin/flutter');
      expect(runner.executableFor('flutter'), '/opt/flutter/bin/flutter');
      expect(c.isCustomTool('flutter'), isTrue);
      expect(notified, 1);

      final runner2 = CommandRunner(CommandLog(), path: '/usr/bin');
      await EnvironmentController(runner: runner2, service: _Service()).restore();
      expect(runner2.executableFor('flutter'), '/opt/flutter/bin/flutter');

      await c.setToolPath('flutter', null);
      expect(c.isCustomTool('flutter'), isFalse);
      c.dispose();
    });
  });

  testWidgets('설정에 환경 점검 구역이 있고, 열면 점검한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = _Service();
    final env = EnvironmentController(runner: CommandRunner(CommandLog(), path: '/usr/bin'), service: service);
    final theme = ThemeController();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        theme: AppTheme.build(StudioPalette.saturn, Brightness.light),
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showSettingsDialog(context, theme: theme, environment: env, initial: SettingsSection.environment),
            child: const Text('열기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.text('환경 점검'), findsWidgets);
    expect(service.calls, 1);
    expect(find.textContaining('3.47.1'), findsOneWidget);
    env.dispose();
    theme.dispose();
  });
}
