# PLAN

앞으로 구현할 것만 적는다. 이미 만들어진 것·구조·작업 방식·테스트 요령은 [docs/IMPLEMENTED.md](docs/IMPLEMENTED.md).
기능이 구현·병합되면 이 문서에서 지우고 IMPLEMENTED.md로 옮긴다.

지금까지의 구현으로 이 앱의 목적(변경 → 빌드 → 점검 → 오류 발견 → 재점검 → 릴리스를 한 창에서 눈과 손으로 해 보기)은 달성했다.
아래 기능을 끝까지 구현한 뒤에는 **직접 써 가면서 불편한 점을 고친다.**

## 권장 순서

IDE 테마(남은 항목) → 편집기 보강 → 규약 마무리.

## 1. IDE 테마

Android Studio처럼 테마를 바꾸면 아이콘과 글꼴이 함께 바뀌고, 편집기 글꼴만 따로 정할 수 있어야 한다.
밝기+색 구성을 테마로 묶기(고대비 포함)와 UI 글꼴 설정은 끝났다(구조·설정 화면은 [docs/IMPLEMENTED.md](docs/IMPLEMENTED.md) 참고).
남은 것:

- **확인할 것**: Flutty Dock으로 빌드해 실제로 — 합자 켜기·끄기(Fira Code·JetBrains Mono·Cascadia Code), 로그 글꼴 같이 쓰기, 고대비·UI 글꼴 배율(85~125%)에서 트리·탭·도구 막대가 깨지지 않는지,
  Branch Dock 화면(`lib/branchdock/`)도 같은 테마(특히 고대비)를 따르는지, 편집기 탭·빠른 열기·검색 결과의 파일 아이콘이 트리와 맞는지 눈으로 확인한다.

## 2. 편집기 보강

- **문제 표시**: 빠른 수정과 분석 서버(LSP) 연결은 필요해질 때.
- 정렬: JSON·ARB·Dart 말고 다른 언어는 믿을 만한 포맷터가 생겼을 때만 더한다(YAML·Markdown은 주석·서식을 해칠 수 있어 뺐다). 자동완성은 만들지 않는다 — 편집기는 일부러 단순하게 둔다.
- **확인할 것**: Flutty Dock으로 빌드해 물결 밑줄 위치(한글이 섞인 줄·가로 스크롤)와 변경점 보기의 글자 차이 칠하기·비교 기준 고르기를 눈으로 본다.
- 메뉴: macOS 메뉴를 실제 Mac에서 확인.

## 3. 규약 마무리와 공개 준비

- README 스크린샷: `home.png`(라이트|다크 분할)·`detail.png`(다크)는 현재 화면(Branch Dock Git 패널, Run 패널)으로 다시 찍었다. 남은 것: 변경점 보기(diff)·메뉴 막대가 보이는 화면과 `demo.gif`(클릭이 필요해 직접 `tool/readme/capture.sh record`).
- **확인할 것**: 업데이트 확인을 실제 Windows·macOS 빌드에서 — 메뉴("업데이트 확인")와 정보 창 단추가 뜨는지, 서버 응답을 실제로 받는지.

## 이 앱 밖

- 각 앱의 GitHub 워크플로를 나눈다: PR에서는 한 OS만, 전 OS 빌드는 태그 푸시 때만.
- 서명·점검 상세가 더 필요하면 Flutty Dock의 서명·점검 화면을 설정 → 환경 점검에 확장한다(필요해질 때).

## 먼 미래: Run 패널을 프로젝트 종류별로 꽂기 (아이디어, 필요해지면)

지금 이 앱에서 Flutter 전용이 아닌 부분(트리·편집기·Branch Dock·메뉴·테마·검증 기록/병합 관문)은 이미 일반적이고,
Flutter 전용인 부분은 Run 패널(기기·대상·빌드 옵션)과 환경 점검(`lib/doctor`)뿐이다. `pubspec.yaml`/`package.json`/
`Cargo.toml` 같은 매니페스트로 프로젝트 종류를 감지해 맞는 Run 패널·환경 점검을 꽂으면, 이 앱을 Flutter 전용에서
몇 가지 개발 도구를 아는 IDE로 넓힐 수 있다. 검증 기록(`lib/verify/verify_store.dart`)이 "빌드 성공 → built" 신호를
받는 연결점만 지키면 병합 관문은 그대로 작동한다.

후보(기존 `lib/devices`·`lib/doctor`의 adb·Xcode 코드를 얼마나 재사용하는지로 난이도가 갈린다):

1. **Tauri(Rust)** — `Cargo.toml`+`tauri.conf.json`. Flutter 데스크톱과 구조가 거의 같다(기기 목록 없음, 단일 실행 파일).
2. **네이티브 Android(Gradle)** — `build.gradle(.kts)`. `lib/devices`의 adb 코드를 거의 그대로 쓴다.
3. **네이티브 iOS/macOS(Xcode)** — `.xcodeproj`/`Package.swift`. `lib/doctor`의 Xcode 시뮬레이터·서명 점검과 겹친다.
4. Electron(Node) — `package.json`. 5. Go — `go.mod`(기기 목록 없는 가장 단순한 경우). 6. .NET MAUI — `.csproj`.

서드파티가 자기 플러그인을 넣게 하는 것(Android Studio·VSCode 식)은 Dart/Flutter에 그런 동적 로딩 API가 없어서
범위가 다르다 — 하려면 LSP처럼 별도 프로세스 + JSON-RPC 프로토콜을 새로 설계해야 하는 훨씬 큰 일이라 지금은 보류.
