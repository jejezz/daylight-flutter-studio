# Daylight Workbench

Claude Code로 Flutter 앱을 만드는 사람을 위한 통합 작업대 (Windows / macOS).
프로젝트 트리 + 간단 편집기 + Flutty Dock(빌드·설치) + Branch Dock(PR·병합·릴리스)을 한 창에 묶고,
**작업 → 로컬 검증 → 병합 → 릴리스** 순서를 건너뛸 수 없게 하는 것이 목적이다.
daylight-commander 계열 앱.

릴리스·버전·패키징·정보 창·아이콘·라이선스·UI/UX·글꼴·언어·테마는
https://github.com/jejezz/application-release-templates/tree/main/conventions
규약을 따른다. 이 앱에 적용할 규약 버전: conventions-v1 (미적용: README 스크린샷)

- 표시 이름 `Daylight Workbench`, 패키지 `daylight_workbench`, 식별자 `art.zoomon.daylightworkbench` (macOS Debug 빌드는 `.dev`).
- 이름에 "Flutter"·"Dart"를 넣지 않는다(둘 다 Google 상표). Flutter 전용이라는 설명은 부제·설명 문구로만 쓴다. 저장소·폴더 이름은 `daylight-workbench`다.
- 기존 앱 flutty-dock-flutter, branch-dock-flutter는 **수정하지 않는다.** 필요한 코드는 이 프로젝트로 복사해서 쓴다.
- 앞으로 할 일은 [PLAN.md](PLAN.md), 이미 구현된 것은 [docs/IMPLEMENTED.md](docs/IMPLEMENTED.md). **이어서 작업할 때는 두 문서를 먼저 읽는다** (IMPLEMENTED.md에 구조, 알려진 한계, 작업 방식, 테스트 요령이 있다). 기능이 구현·병합되면 PLAN.md에서 지우고 IMPLEMENTED.md에 옮긴다.
- 작업은 브랜치 → 커밋 → 사용자 확인 후 로컬 `main` 병합. push는 요청받을 때만.

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
- `lib/branchdock/`은 branch-dock-flutter의 Git 기능을 통째로 옮긴 것이다(문구는 `bd` 접두어, 아이콘은 `context.icons`). 이 앱 전용 연결점은 `MergeGateScope`와 `onHeadChanged`뿐이고, 같은 방식으로 고쳐 쓰며 원본에는 되돌리지 않는다.
- 편집기 위젯(`re_editor` 포크)은 이 저장소 밖 공용 저장소 `jejezz/daylight-editor-flutter`에 있고 git 의존성으로 쓴다(daylight-commander와 공유). 편집기 동작을 고치려면 그 저장소에서 고치고 새 태그를 달아 `pubspec.yaml`의 `ref`를 올린다 — 이 저장소에 복사본을 두지 않는다.
- 검증 기록(`lib/verify/verify_store.dart`)의 파일 형식은 Branch Dock 쪽 병합 관문과 공유한다. 바꾸면 `VerifyRecord.version`을 올린다.
