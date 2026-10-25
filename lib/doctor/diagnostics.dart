import 'dart:io';

import '../core/command_runner.dart';
import 'signing_info.dart';

/// 명령줄 도구 하나: 찾았으면 버전, 못 찾았으면 [version]이 null.
class ToolInfo {
  const ToolInfo(this.version, {this.error});

  final String? version;

  /// 실행은 했지만 실패했을 때 도구가 남긴 첫 줄들. 못 찾은 경우엔 비어 있다.
  final String? error;
  bool get found => version != null;
}

/// Windows에서만 읽는 환경: 플러그인 링크에 쓰는 개발자 모드와 Windows 앱 빌드용 Visual Studio.
class WindowsEnv {
  const WindowsEnv({this.developerMode, this.visualStudio});

  /// Windows 개발자 모드가 켜져 있는지. 읽지 못했으면 null.
  final bool? developerMode;

  /// C++ 데스크톱 도구가 있는 Visual Studio의 버전. 없으면 null.
  final String? visualStudio;
}

/// `reg query ... AllowDevelopmentWithoutDevLicense` 출력에서 개발자 모드가 켜져 있는지 읽는다.
/// 값이 0x1이면 켜짐, 그 밖이면 꺼짐.
bool parseDeveloperMode(String output) => RegExp(r'AllowDevelopmentWithoutDevLicense\s+REG_DWORD\s+0x1\b').hasMatch(output);

/// `vswhere -property installationVersion` 출력의 첫 줄(버전). 비어 있으면 null.
String? parseVsWhereVersion(String output) {
  for (final line in output.split(RegExp(r'\r?\n'))) {
    final t = line.trim();
    if (t.isNotEmpty) return t;
  }
  return null;
}

/// 한 번 모은 이 컴퓨터의 개발 환경 정보 (프로젝트·기기와 무관한 것만).
class Diagnostics {
  const Diagnostics({
    required this.flutter,
    required this.xcode,
    required this.adb,
    this.certs = const [],
    this.windows,
    required this.collectedAt,
  });

  final ToolInfo flutter;
  final ToolInfo xcode;
  final ToolInfo adb;
  final List<SigningCert> certs;

  /// 이름·Team이 같은 인증서를 하나로 합친 목록.
  List<SigningCert> get distinctCerts => uniqueCerts(certs);

  /// Windows 호스트에서만 채워진다.
  final WindowsEnv? windows;
  final DateTime collectedAt;
}

abstract class DiagnosticsService {
  Future<Diagnostics> collect();
}

class ProcessDiagnosticsService implements DiagnosticsService {
  ProcessDiagnosticsService(this.runner);

  final CommandRunner runner;

  Future<ToolInfo> _tool(List<String> args, RegExp pattern) async {
    final r = await runner.run(args, quiet: true);
    if (!r.ok) {
      final lines = r.combined.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).take(2).join(' ');
      // 실행 파일을 못 찾은 경우(127)는 '못 찾음'이지 '실행 실패'가 아니다.
      return ToolInfo(null, error: r.exitCode == 127 || lines.isEmpty ? null : lines);
    }
    return ToolInfo(pattern.firstMatch(r.combined)?[1] ?? '?');
  }

  @override
  Future<Diagnostics> collect() async {
    final results = await Future.wait([
      _tool(['flutter', '--version'], RegExp(r'Flutter (\S+)')),
      Platform.isMacOS ? _tool(['xcodebuild', '-version'], RegExp(r'Xcode (\S+)')) : Future.value(const ToolInfo(null)),
      _tool(['adb', 'version'], RegExp(r'Version (\S+)')),
      if (Platform.isMacOS) _certs() else Future.value(const <SigningCert>[]),
      if (Platform.isWindows) _windowsEnv() else Future.value(null),
    ]);
    return Diagnostics(
      flutter: results[0] as ToolInfo,
      xcode: results[1] as ToolInfo,
      adb: results[2] as ToolInfo,
      certs: results[3] as List<SigningCert>,
      windows: results[4] as WindowsEnv?,
      collectedAt: DateTime.now(),
    );
  }

  Future<WindowsEnv> _windowsEnv() async {
    final results = await Future.wait<Object?>([_windowsDeveloperMode(), _visualStudio()]);
    return WindowsEnv(developerMode: results[0] as bool?, visualStudio: results[1] as String?);
  }

  /// 레지스트리의 개발자 모드 값. reg.exe를 못 찾으면 null(모름), 키가 없으면 꺼짐.
  Future<bool?> _windowsDeveloperMode() async {
    final root = Platform.environment['SystemRoot'] ?? r'C:\Windows';
    final r = await runner.run([
      '$root\\System32\\reg.exe',
      'query',
      r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
      '/v',
      'AllowDevelopmentWithoutDevLicense',
    ], quiet: true);
    if (r.exitCode == 127) return null;
    return r.ok && parseDeveloperMode(r.stdout);
  }

  /// `vswhere`로 "C++ x64/x86 빌드 도구"가 있는 가장 최신 Visual Studio의 버전. 없으면 null.
  Future<String?> _visualStudio() async {
    final x86 = Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';
    final vswhere = '$x86\\Microsoft Visual Studio\\Installer\\vswhere.exe';
    if (!await File(vswhere).exists()) return null;
    final r = await runner.run([
      vswhere,
      '-latest',
      '-products',
      '*',
      '-requires',
      'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
      '-property',
      'installationVersion',
    ], quiet: true);
    return r.ok ? parseVsWhereVersion(r.stdout) : null;
  }

  Future<List<SigningCert>> _certs() async {
    final identities = await runner.run(['security', 'find-identity', '-v', '-p', 'codesigning'], quiet: true);
    final names = parseIdentityNames(identities.stdout);
    final pems = await runner.run(['security', 'find-certificate', '-a', '-c', 'Apple Development', '-p'], quiet: true);
    final out = <SigningCert>[];
    for (final pem in splitPems(pems.stdout)) {
      final r = await runner.run(['openssl', 'x509', '-noout', '-subject', '-enddate', '-nameopt', 'RFC2253'], stdin: pem, quiet: true);
      final cert = parseOpenSslCert(r.stdout, identityNames: names);
      if (cert != null) out.add(cert);
    }
    return out;
  }
}
