# PLAN

앞으로 구현할 것만 적는다. 이미 만들어진 것·구조·작업 방식·테스트 요령은 [docs/IMPLEMENTED.md](docs/IMPLEMENTED.md).
기능이 구현·병합되면 이 문서에서 지우고 IMPLEMENTED.md로 옮긴다.

지금까지의 구현으로 이 앱의 목적(변경 → 빌드 → 점검 → 오류 발견 → 재점검 → 릴리스를 한 창에서 눈과 손으로 해 보기)은 달성했다.
아래 기능을 끝까지 구현한 뒤에는 **직접 써 가면서 불편한 점을 고친다.**

## 권장 순서

IDE 테마 → 프로젝트 검색 바꾸기 → 편집기 보강 → 규약 마무리. 정리 작업은 각 단계 사이에 끼워 넣는다.

## 1. IDE 테마

Android Studio처럼 테마를 바꾸면 아이콘과 글꼴이 함께 바뀌고, 편집기 글꼴만 따로 정할 수 있어야 한다.
밝기+색 구성을 테마로 묶기(고대비 포함)와 UI 글꼴 설정은 끝났다(구조·설정 화면은 [docs/IMPLEMENTED.md](docs/IMPLEMENTED.md) 참고).
남은 것:

- **아이콘 세트**: 모양(둥근·윤곽선·채움)을 넘어 완전히 다른 세트 — 특히 파일 종류별 색 아이콘(지금 트리는 모든 파일에 같은
  아이콘을 쓴다, `lib/ui/file_tree.dart`)을 추가하고 테마와 묶을지 정한다.
- **편집기 글꼴 보강**: 합자(ligature) 여부, 로그·명령 출력(Markdown 코드 포함) 글꼴을 편집기와 같이 쓸지 고르기.
- **확인할 것**: Flutty Dock으로 빌드해 실제로 — 고대비·UI 글꼴 배율(85~125%)에서 트리·탭·도구 막대가 깨지지 않는지,
  Branch Dock 화면(`lib/branchdock/`)도 같은 테마(특히 고대비)를 따르는지 눈으로 확인한다.

## 2. 프로젝트 검색의 바꾸기

- 프로젝트에서 찾기(`Ctrl/Cmd+Shift+F`)에 바꾸기를 더한다: 결과를 미리 보고 파일·줄 단위로 골라 바꾸고, 열린 탭과 디스크 변경 감지(수정 중인 탭)와 충돌하지 않게 한다. 실행 취소 방법을 정한다.

## 3. 편집기 보강

- **변경 파일 → Studio 변경점 보기**: Branch Dock의 변경 파일 목록에서 파일을 누르면 Studio 편집기의 변경점 보기로 열리는 연결 지점(`ChangesTab`)을 둔다. 지금은 Branch Dock의 diff 화면이 열린다.
- **문제 표시**: 줄 단위 점에서 글자 단위 물결 밑줄로, 빠른 수정과 분석 서버(LSP) 연결은 필요해질 때.
- **변경점 보기**: 줄 안의 글자 차이 표시, HEAD 이외와의 비교(브랜치·커밋).
- 정렬: JSON 등 다른 언어. (자동완성은 만들지 않는다 — 편집기는 일부러 단순하게 둔다.)
- 메뉴: 편집 메뉴의 찾기·바꾸기가 메뉴를 거쳐도 항상 편집기로 가는지 확인·보강(포커스), macOS 메뉴를 실제 Mac에서 확인.

## 4. 규약 마무리와 공개 준비

- 업데이트 확인(`lib/update`): 서버가 정해지면 conventions-v1대로 넣는다.
- README 스크린샷·GIF(`tool/readme/capture.sh`)를 현재 화면(Branch Dock Git 패널, Run 도구 막대, 메뉴 막대)으로 다시 찍는다.
- **앱 이름의 "Flutter"**: 공개 배포 전에 이름을 다시 정한다(Flutter 상표). 이름을 바꾸면 패키지명·식별자·릴리스 워크플로·문서를 함께 고친다.

## 정리 (틈틈이)

- **옛 Studio 쪽 Git·릴리스 코드**: 화면에서 더 쓰지 않는 파일이 남아 있다 — `lib/ui/release_dialog.dart`, `lib/release/`(release_check·release_controller·semver), `lib/ui/conflict_sheet.dart`, `lib/git/`의 `conflicts`·`commits`·`refs`·`operation`·`error_hints` 중 `GitController`가 쓰지 않는 것, 그리고 그 테스트(`test/release_test.dart`, `test/conflicts_test.dart` 등). 쓰는 곳을 확인한 뒤 지우고, 안 쓰는 언어 문구(옛 Git 패널·브랜치 탭용)도 `lib/l10n`에서 정리한다.
- `GitController`가 맡는 검증 판정(관문)만 남기고 이름·위치를 정리할지 정한다.
- Branch Dock 이식본(`lib/branchdock/`)이 원본에서 갈라진 곳(이 앱 전용 연결점, `command_runner`의 실행 파일 경로 검사 등)을 주석으로 표시해 둔다.

## 이 앱 밖

- 각 앱의 GitHub 워크플로를 나눈다: PR에서는 한 OS만, 전 OS 빌드는 태그 푸시 때만.
- 서명·점검 상세가 더 필요하면 Flutty Dock의 서명·점검 화면을 설정 → 환경 점검에 확장한다(필요해질 때).
