import 'diagnostics.dart';

enum CheckStatus { ok, warn, fail, info }

/// 이 컴퓨터 전체에 대한 점검 항목. 프로젝트·기기별 문제(연결, 개발자 모드, Team ID …)는 Run 패널이 알려 준다.
enum CheckId { flutter, xcode, adb, certificate, certificateExpiry, windowsDeveloperMode, visualStudio }

/// 점검 결과 한 줄. 문구는 화면이 [id]와 [params]로 만든다.
class CheckItem {
  const CheckItem(this.id, this.status, [this.params = const {}]);

  final CheckId id;
  final CheckStatus status;
  final Map<String, String> params;
}

/// 환경 정보에서 점검 목록을 만든다. 실행하지 않고 판단만 한다.
List<CheckItem> buildEnvironmentChecks({
  required Diagnostics? diagnostics,
  required bool hostIsMac,
  required bool hostIsWindows,
  required DateTime now,
}) {
  final d = diagnostics;
  if (d == null) return const [];
  final items = <CheckItem>[
    CheckItem(CheckId.flutter, d.flutter.found ? CheckStatus.ok : CheckStatus.fail, {
      'version': d.flutter.version ?? '',
      if (d.flutter.error != null) 'error': d.flutter.error!,
    }),
    if (hostIsMac) CheckItem(CheckId.xcode, d.xcode.found ? CheckStatus.ok : CheckStatus.fail, {'version': d.xcode.version ?? ''}),
    CheckItem(CheckId.adb, d.adb.found ? CheckStatus.ok : CheckStatus.warn, {'version': d.adb.version ?? ''}),
  ];

  // Windows: 개발자 모드가 꺼져 있으면 플러그인 링크를 만들지 못해 빌드가 실패할 수 있다(경고).
  final win = d.windows;
  if (hostIsWindows && win != null) {
    if (win.developerMode != null) {
      items.add(CheckItem(CheckId.windowsDeveloperMode, win.developerMode! ? CheckStatus.ok : CheckStatus.warn));
    }
    items.add(CheckItem(CheckId.visualStudio, win.visualStudio != null ? CheckStatus.ok : CheckStatus.warn, {'version': win.visualStudio ?? ''}));
  }

  if (hostIsMac) {
    final usable = d.distinctCerts.where((c) => c.hasPrivateKey).toList();
    items.add(CheckItem(CheckId.certificate, usable.isNotEmpty ? CheckStatus.ok : CheckStatus.warn, {'count': '${usable.length}'}));
    for (final c in usable) {
      final days = c.daysLeft(now);
      if (days == null) continue;
      items.add(
        CheckItem(CheckId.certificateExpiry, days < 0 ? CheckStatus.fail : (days <= 30 ? CheckStatus.warn : CheckStatus.ok), {
          'name': c.name,
          'days': '$days',
        }),
      );
    }
  }
  return items;
}
