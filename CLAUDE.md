# Daylight Flutter Studio

Claude Code로 Flutter 앱을 만드는 사람을 위한 통합 작업대 (Windows / macOS).
프로젝트 트리 + 간단 편집기 + Flutty Dock(빌드·설치) + Branch Dock(PR·병합·릴리스)을 한 창에 묶고,
**작업 → 로컬 검증 → 병합 → 릴리스** 순서를 건너뛸 수 없게 하는 것이 목적이다.
daylight-commander 계열 앱.

릴리스·버전·패키징·정보 창·아이콘·라이선스·UI/UX·글꼴·언어·테마는
https://github.com/jejezz/application-release-templates/tree/main/conventions
규약을 따른다. 이 앱에 적용할 규약 버전: conventions-v1 (아직 미적용)

- 표시 이름 `Daylight Flutter Studio`, 패키지 `daylight_flutter_studio`, 식별자 `art.zoomon.daylightflutterstudio`.
- 이름에 "Flutter"가 들어 있다. 개인용으로 운영하는 동안은 두되, 공개 배포 전에 이름을 다시 정한다 (Flutter 상표).
- 기존 앱 flutty-dock-flutter, branch-dock-flutter는 **수정하지 않는다.** 필요한 코드는 이 프로젝트로 복사해서 쓴다.
- 기능 범위와 순서는 [PLAN.md](PLAN.md).

## 테마 규칙 (모든 컨트롤은 테마로 바꿀 수 있어야 한다)

- 색·글꼴·간격·모양 값은 `lib/theme/`에만 둔다 (`app_theme.dart`의 `AppTheme`, `StudioTokens`, `StudioPalette`).
- 화면 코드는 `Colors.*`, `Color(0x…)`, `fontSize:`, `fontFamily`를 직접 쓰지 않는다.
  `Theme.of(context)`(`colorScheme`, `textTheme`)와 `context.tokens`(성공·경고·위험 색, 편집기·로그 글꼴, 간격)에서 읽는다.
- 새 컨트롤 모양이 필요하면 먼저 `AppTheme.build`의 컴포넌트 테마나 `StudioTokens`에 추가한다.
- 사용자가 고르는 것은 밝기(시스템/라이트/다크)와 색 구성(`ThemeController`, 앱 바의 팔레트 단추).
- `test/theme_rules_test.dart`가 위 규칙을 검사한다.

## 코드 출처

- `lib/core`, `lib/devices`, `lib/flutter`, `lib/install`(plan·build_options)은 flutty-dock-flutter에서 복사한 것이다.
  이쪽에서 고쳐 가며 쓰고 원본에는 되돌리지 않는다.
- 검증 기록(`lib/verify/verify_store.dart`)의 파일 형식은 Branch Dock 쪽 병합 관문과 공유한다. 바꾸면 `VerifyRecord.version`을 올린다.
