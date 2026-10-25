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
