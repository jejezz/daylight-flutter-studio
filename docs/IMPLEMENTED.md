# 구현된 것

기준: 2026-10-27, 로컬 `main`. `flutter analyze` 새 문제 없음, 테스트 484개 통과
(`test/release_test.dart`·`test/branchdock/`의 실제 git 테스트 몇 개는 전체를 한꺼번에 돌리면 Windows 파일 잠금으로
간간이 실패한다 — 알려진 한계, 따로 돌리면 통과한다).
앞으로 할 일은 [PLAN.md](../PLAN.md)에 있다. 이 문서는 **이미 만들어진 것**과 그 구조·작업 방식을 적는다.

## 왜 만들었나

Claude Code는 worktree에서 작업하고 사용자는 main만 쓴다. 그러다 보니 worktree에서 한 번 빌드해
눈으로 확인하는 단계가 빠진 채 PR 병합·Release로 넘어가고, 문제는 GitHub 전 OS 빌드를 거친 뒤에야
발견되어 Release 버전과 빌드 시간만 늘어난다. 이 앱은 **변경 → 빌드 → 점검 → 오류 발견 → 재점검 → 릴리스**를
눈과 손으로 해 보는 것을 한 창에서 하게 하고, 검증을 병합 앞에 두어 건너뛰기 어렵게 만든다.
("점검했다"는 기록을 남기는 것은 부수적인 장치이고, 목적은 직접 보고 고치는 흐름이다.)

## 화면

```
┌ 메뉴: 파일 편집 보기 도움말 (Windows·Linux는 앱 바 아래, macOS는 시스템 메뉴 막대) ┐
┌ 프로젝트 트리 ┬ 편집기(탭) ───────────────┬ GIT ▸ ───────────────┐
│ 폴더·파일      │ 편집, 변경점 보기, 찾기    │ 상태 헤더·다음 할 일   │
│ worktree 구분  ├────────────────────────────┤ [변경|브랜치|태그|원격 │
│               │ Run|문제|터미널(접으면 막대만)│  |릴리스|PR|기록]    │
│               │ [대상▾][Debug|Release][▶]   │ 내용 · 명령 막대      │
└───────────────┴────────────────────────────┴──────────────────────┘
 상태 막대: 브랜치·검증 상태·문제 개수(누르면 문제 탭)·아래 패널 접기
```

- **Git Dock**(오른쪽, 전체 높이): 위에 가로 제목 막대(닫기 `>` + `GIT`). 닫으면 폭 32px의 세로 막대(`<`와 세로로 쌓은 글자)만 남고, 막대를 누르면 펼쳐진다.
  너비는 380~700px(기본 420)이고 구분선을 끌어 바꾼다. 앱 바의 Dock 단추와 `Ctrl+Alt+B`(Mac `Cmd+Alt+B`)로도 접고 편다. 접어도 Dock 위젯은 살아 있어 다시 열 때 저장소를 처음부터 읽지 않는다.
- **아래 패널**(편집기 아래): Run | 문제 탭. `Ctrl/Cmd+J`로 접고 편다. 접어도 탭 줄은 아래에 남고, 접힌 막대에서 탭을 누르면 그 탭으로 펼쳐진다. 높이 120~700px, 구분선을 끌어 바꾼다.
- 열림·높이·탭·Dock 너비는 저장된다(`lib/settings/panel_layout.dart`).
- 트리 위쪽에 worktree 선택기가 있다. Claude worktree(`.claude/worktrees/`)는 표시로 구분한다.
- 편집기는 일부러 단순하다: 열기·수정·저장·찾기·diff 읽기. 자동완성 등은 만들지 않는다.

## Git 패널 = Branch Dock 그대로

직접 다시 만드는 대신 branch-dock-flutter의 코드를 `lib/branchdock/`로 통째로 옮겨 쓴다
(Studio 규칙에 맞게 문구 `bd` 접두어, `context.icons`, `context.mono`). 원본 앱은 수정하지 않는다.

- 셸은 `lib/ui/branchdock_dock.dart`: 상태 헤더 → 다음 할 일 배너 → 아이콘 탭(변경·브랜치·태그·원격·릴리스·PR·기록) → 내용 → 명령 막대.
  **CI(Actions) 탭은 뜻을 두고 뺐다.** 열린 프로젝트 폴더가 바뀌면 `RepoController`를 다시 연다.
- 기능은 Branch Dock과 같다: 스테이지·커밋, 가져오기·받기·올리기, 브랜치(전환·만들기·이름 바꾸기·삭제·worktree), 병합·squash·rebase와 충돌 해결, 태그, 원격, 기록(그래프), PR 목록·리뷰·병합, 릴리스 마법사, 실수 복구(reflog), 개념 도움말.
- **Studio 전용 연결점은 둘뿐이다**: `MergeGateScope`(PR 카드의 검증 관문과 검증 카드, `lib/ui/git_merge_gate.dart`)와 HEAD 변경 알림(`onHeadChanged` — 브랜치·커밋이 바뀌면 파일·문제·검증 상태를 새로 읽는다).
  worktree를 열 때는 `onOpenFolder`로 Studio의 프로젝트를 바꾼다.
- `GitController`(`lib/git/`)는 이제 검증 판정(관문)만 맡는다.

## Run 패널 (Flutty Dock)

한 줄 실행 도구 막대: **대상 드롭다운**(기기 목록·"기기 다시 찾기"·기기가 없을 때 연결 안내) · Debug/Release · **▶ 실행**(실행 중에는 중지·핫 리로드·핫 리스타트·종료) · release의 빌드만/실행만 · debug의 "다시 열기" · 정리 후 패키지 다시 받기 · 프로젝트 이름·플랫폼.
막지 않을 수 없는 이유와 실패 힌트는 막대 바로 아래에 붙는다. 그 아래는 폭 760px 이상이면 왼쪽(빌드 옵션 · iOS Team ID · 실행 단계, 접힘) | 오른쪽(검증 카드 · 출력), 좁으면 한 줄로 쌓는다.
빌드 옵션은 flavor·진입 파일·dart-define 파일·앱 ID·추가 인자이고 프로젝트마다 저장한다. 출력은 전체 화면 뷰어와 복사를 지원한다.
Flutty Dock의 서명·점검 탭은 설정 → 환경 점검에 있고, Git 탭은 Branch Dock 패널이 대신하며, 기기 탭은 대상 드롭다운으로 합쳤다.

## 터미널 패널

아래 패널의 세 번째 탭. Claude Code 등을 같은 창에서 이어 쓰는 것이 목적이고, 로컬 셸(PowerShell 7·Windows
PowerShell·cmd·Git Bash·WSL 배포판, macOS/Linux는 로그인 셸과 `/etc/shells`)만 다룬다 — SSH·시리얼·파일 끌어놓기·
기록(logging)은 daylight-terminal-flutter에 있지만 여기엔 없다.

- **코드 출처**: daylight-terminal-flutter(xterm2 기반)에서 로컬 셸 부분만 가져와 줄였다(원본은 수정하지 않는다).
  `lib/terminal/`(모델·셸 찾기·pty 연결·세션·세션 목록 컨트롤러), `lib/ui/terminal_pane.dart`(xterm2 `TerminalView` 한 칸),
  `lib/ui/terminal_panel.dart`(세션 탭 줄 + "+"), `lib/theme/terminal_theme.dart`(글꼴·색), `lib/settings/terminal_settings.dart`.
  렌더링·pty는 각각 `packages/xterm2`·`packages/flutter_pty`(둘 다 Windows 결함을 고친 복사본, `PATCHES.md` 참고) 그대로 쓴다.
- **세션**: 탭(세션) 여러 개를 둘 수 있다. 세션은 `TerminalSessionsController`(StudioScreen 쪽, 위젯 트리 밖)가 쥐고 있어서
  아래 패널을 접어도, 다른 바깥 탭(Run·문제)을 보고 있어도 셸은 계속 돈다. "+"는 설치된 셸 중 고르거나(하나뿐이면 바로) 연다.
- **작업 폴더**: 새 세션은 그 순간 열려 있는 프로젝트/worktree 폴더에서 시작한다. 프로젝트·worktree를 바꿔도 이미 연 세션은
  자기 폴더에 그대로 머문다(자동으로 따라가지 않는다) — 새 세션을 열어야 새 폴더에서 시작한다.
  셸이 끝나면 탭은 남고 종료 코드와 "다시 시작" 단추를 보여 준다(같은 폴더에서 다시 띈다).
- **글꼴·색**: 색은 늘 현재 테마(`ColorScheme`·`SyntaxTokens`)에서 읽고 따로 고르는 색 구성표는 없다. 글꼴은 설정 →
  터미널에서 "편집기 글꼴과 같이 쓰기"(기본 켜짐, 편집기의 글꼴·배율을 그대로 따른다)를 끄면 터미널만의 글꼴·크기를 고를 수 있다.
  스크롤백 줄 수도 거기서 바꾸지만 새로 여는 탭부터 적용된다(xterm2는 만들 때만 정할 수 있다).
- **키보드**: `Ctrl/⌘+,`(설정)·`Ctrl/⌘+J`(아래 패널 접기)·`Ctrl/⌘+Alt+B`(Git Dock)·`Ctrl/⌘+Shift+F`(프로젝트에서 찾기)는
  터미널에 포커스가 있어도 앱 단축키로 간다. `Ctrl/⌘+W`·`+O`·`+P`는 셸의 줄 편집(단어 지우기·이전 명령 등)에서 쓰므로 가로채지
  않는다 — 터미널에 포커스가 있는 동안은 탭 닫기·프로젝트 열기·빠른 열기를 키보드로 할 수 없다(단추·메뉴를 쓴다).

## 검증 기록과 병합 관문

- 저장: `<git-common-dir>/dock-verify/<커밋 sha>.json`, 필드 `version, sha, branch, mode, target, status(built|confirmed|problem), at, note`. 형식은 Branch Dock 쪽 관문과 공유하고, 바꾸면 `VerifyRecord.version`을 올린다.
- Run에서 빌드·설치가 성공하면 `built`, 사용자가 "확인함"을 누르면 `confirmed`, "문제 있음"은 메모와 함께 `problem`(복사해서 Claude 세션에 붙일 수 있다). 작업 폴더가 더럽혀져 있으면 기록하지 않는다.
- PR 카드는 PR head 커밋의 상태를 보여 준다: 검증됨 / 빌드만 됨 / 문제 있음 / 검증 후 수정됨 / 미검증.
- **병합 관문**(`lib/settings/gate_settings.dart`의 `decideGate`): 기본은 차단 — `검증됨`이 아니면 병합 단추가 비활성이고, 예외는 "검증 없이 병합…" → 확인창 → "그래도 병합"뿐이다. 경고만 모드는 확인창만 거치고, 끔은 바로 병합한다(설정 → 병합 관문). 병합 직전에 기록을 다시 읽어 판정한다.
- 릴리스에 "점검 완료" 검사를 따로 넣지 않기로 했다(눈으로 보고 릴리스하는 것이 목적). 릴리스는 Branch Dock의 마법사를 그대로 쓴다.

## 편집기 (`re_editor`)

- 구문 강조(색은 `SyntaxTokens`, Dart는 `lib/studio/dart_highlight.dart`로 함수·타입·이름 붙인 인자 등을 더 칠함), 들여쓰기 선(깊이별 색, 설정에서 끔), 줄 번호, 접기.
- **탭**: 끌어서 순서를 바꾼다(저장·복원). 열어 둔 탭은 프로젝트마다 기억한다. 닫을 때 고친 내용이 있으면 저장할지 묻는다.
- **파일·폴더 끌어다 놓기**: 창에 파일을 놓으면 편집기 탭으로, 폴더를 놓으면 프로젝트로 연다(`desktop_drop`). 끄는 동안 안내 테두리가 보인다.
- **Dart 접기**: `()`, `[]`, `{}`가 여러 줄인 곳. 주석·문자열의 괄호는 무시. "모두 접기"는 안쪽 구간만.
- **정렬**: Dart(`dart format`)·JSON·ARB(들여쓰기 2칸, 키 순서 유지). `Ctrl+Alt+L` / `Shift+Alt+F`. 설정의 "저장할 때 자동 정렬"(기본 꺼짐)을 켜면 저장 직전에 정렬하고, 문법 오류로 정렬하지 못해도 저장은 한다.
- **글자 크기**: Ctrl(Mac은 Cmd)+스크롤, Ctrl +/-/0. 편집기·줄 번호·Markdown 보기에만 적용(60~300%), 저장된다.
- **Markdown**: 편집/보기 전환. 보기는 테마를 따르고 상대 경로 이미지를 읽으며 웹 링크만 연다.
- 줄 끝(CRLF/LF)은 파일 그대로 보존한다.
- **디스크 변경 감지**: 열린 탭의 수정 시각·크기를 1초마다, 창이 다시 활성화될 때도 확인한다. 수정 안 한 탭은 조용히 다시 읽고, 수정 중인 탭은 배너로 "다시 읽기 / 내 수정 유지"를 고르게 하며 그 전에는 저장을 막는다. 파일이 사라지면 "탭 닫기 / 그대로 두기".
- **변경 표시와 변경점 보기**: 줄 번호 옆에 HEAD 대비 새 줄·바뀐 줄·지워진 자리를 편집 중에 바로 그린다. 도구 막대의 변경점 단추로 통합 diff(+/- 개수, 바뀐 곳 둘레 3줄, 나머지는 눌러서 펼침)로 전환한다. git 저장소가 아니거나 .gitignore로 무시되는 파일은 비교하지 않는다.
- **Dart 문제**: `dart analyze --format=json`을 패키지에서 돌려 "문제" 탭에 파일별로 보여 준다(오류·경고·정보 필터, 눌러서 그 줄로 이동). 편집기 줄 번호 왼쪽에 점, 상태 막대와 탭 이름에 개수. 폴더를 열 때·Dart 파일 저장 때·창이 30초 넘게 지난 뒤 다시 활성화될 때 분석하고 재요청은 한 번으로 합친다. `.dart_tool`이 없는 새 worktree는 `flutter pub get` 단추를 안내한다(서브 패키지 포함). 분석이 실패하면 "문제 없음"이라고 하지 않는다.
- **찾기·바꾸기**(`Ctrl/Cmd+F` 찾기, `Ctrl/Cmd+R` 바꾸기 — 편집기에 포커스가 있을 때만; 터미널에서는 `Ctrl+R`이 셸 기록 검색이라 앱 전체 단축키로 두지 않았다. 편집기 위 줄: 대소문자·정규식·이전/다음·모두 바꾸기), **빠른 열기**(`Ctrl/Cmd+P`), **프로젝트에서 찾기**(`Ctrl/Cmd+Shift+F`; `build`·`.git` 등은 건너뜀, 바꾸기는 아래).
- **프로젝트에서 바꾸기**(`lib/ui/project_search.dart`, 로직은 `lib/studio/project_replace.dart`): 검색창 왼쪽 ▸ 단추로 바꾸기 줄을 연다.
  결과는 파일별로 묶여 보이고(파일 체크 상자는 그 파일의 줄 전체), **줄 단위**로 골라 바꾼다(고른 줄 안의 맞는 곳은 모두 바뀐다).
  바꾼 뒤의 모습이 결과 줄 아래에 초록으로 미리 보이고, "선택한 N곳 바꾸기"는 확인창을 거친다. 정규식 모드에서는 `$1`~`$9`(묶음)·`$$`(`$`)를 쓴다.
  쓰기 직전에 파일을 다시 읽어 그 줄이 지금도 맞는지 보고(검색한 뒤 바뀌었으면 건너뛴다), 줄 끝(CRLF·LF)은 그대로 둔다.
  **수정 중이거나 디스크와 달라진 탭이 열려 있는 파일은 건너뛰고**(검색 결과는 디스크 기준이라 편집 중인 글과 다르다) 몇 개를 건너뛰었는지 알려 준다.
  끝나면 열린 탭(수정 없는 탭은 조용히 다시 읽는다)·트리·변경 표시·문제를 다시 읽는다.
  **되돌리기**: 바꾼 파일의 이전 글을 이 창이 들고 있다가 "되돌리기"로 되돌린다(창을 닫으면 잃는다 — 그 뒤에는 git으로).
  바꾼 뒤에 또 수정된 파일은 그 수정을 덮어쓰지 않으려고 그대로 둔다.
- 편집기 글꼴: 설정 → 편집기에서 이름(설치된 고정폭 글꼴 콤보 상자, 아래 "테마" 참고)과 줄 간격(1.2~2.0), 미리보기. 설치된 글꼴은 OS 글꼴 파일(`lib/theme/font_scan.dart`)에서 읽고 Flutter가 그릴 수 있는 것(`font_probe.dart`)만 보인다.

## 메뉴 막대

파일(프로젝트 열기·최근 프로젝트·저장·모두 저장·탭 닫기·파일로 이동·설정·종료) · 편집(실행 취소·다시 실행·잘라내기·복사·붙여넣기·전체 선택·찾기·바꾸기·프로젝트에서 찾기·코드 정렬) · 보기(아래 패널·Git 패널·글자 크게/작게/기본) · 도움말(정보). 항목 오른쪽에 단축키를 보여 준다.
`lib/ui/studio_menus.dart`가 메뉴를 한 번 정의하고, Windows·Linux는 Material `MenuBar`, macOS는 `PlatformMenuBar`(`AppMenuBar`가 그리고 화면이 `StudioMenuHost`로 메뉴를 넘긴다)로 그린다.
Material 쪽은 단축키를 글자로만 보여 준다(이미 화면에 바인딩이 있어 등록하면 두 번 실행된다). macOS 편집 메뉴는 단축키를 시스템에 등록하지 않는다(대화상자 입력 칸의 복사·붙여넣기가 막힌다).

## 테마

"테마"는 밝기(라이트·다크·시스템) + 색 구성(`StudioPalette`) + 아이콘 모양 + UI 글꼴을 하나로 묶은 것이다.
`ThemeController`가 고른 값을 들고 있고(저장도 한다), `AppTheme.build`(`lib/theme/app_theme.dart`)가 실제 `ThemeData`로 만든다.
모든 색·글꼴·크기는 `lib/theme/`에만 있다(`test/theme_rules_test.dart`가 강제하고 화면 코드의 `Colors.`·`Color(`·`fontSize`·`fontFamily`·`Icons.` 직접 사용을 막는다). 화면은 `context.icons.<의미 이름>`, `context.tokens`, `Theme.of(context)`만 쓴다.

- **색 구성** 6가지: 새턴·청록·호박·장미·슬레이트는 규약 ColorScheme의 주색만 바꾸고(`StudioPalette.apply`), **고대비**는
  배경·글자·테두리 전부를 순흑/순백 최대 대비로 바꾼 완전히 다른 ColorScheme이다(`_HighContrastTheme`). 구문 강조 색도
  고대비 전용(`SyntaxTokens.highContrast`)이다. 밝기(라이트/다크/시스템)는 색 구성과 상관없이 그대로 고른다.
- **UI 글꼴**: 이름(설치된 글꼴 중 고르거나 직접 적음, 비우면 기본 SeoulNamsan)과 크기 배율(85~125%, `AppTheme.minUiFontScale`~`maxUiFontScale`). 트리·탭·메뉴·단추 등 화면 전체 글자 크기에 배율이 곱해지지만 칸 크기(행 높이·탭
  높이·도구 막대 높이)는 그대로 둔다 — 배율 범위를 넓지 않게 둔 것도 그래서다. 편집기 글꼴·배율은 따로 설정한다
  (`EditorSettings`·`EditorZoom`) — 아직 "편집기와 같이 쓰기"는 없다(터미널 글꼴에는 있다).
- 설치된 글꼴 목록은 `lib/theme/font_scan.dart`가 OS 글꼴 폴더를 훑어 읽는다 — 편집기·터미널 글꼴은 고정폭만
  (`monospaceOnly: true`), UI 글꼴은 고정폭이 아닌 것도 보여 준다.
- **글꼴 고르기**(`_FontPicker`, `lib/ui/settings_dialog.dart`): 편집기·터미널·UI 글꼴이 모두 같은 콤보 상자를 쓴다 —
  설치된 글꼴이 수백 개(특히 UI 글꼴)여도 단추를 죽 늘어놓지 않는다. 입력하면 가까운 항목을 찾아가고(`enableSearch`),
  목록의 각 항목 자체가 그 글꼴로 그려지므로(`fontMenuEntryStyle`) 따로 미리보기 글을 두지 않는다 — 훑어보는 것
  자체가 미리보기다. 칸은 좁혀 한 번에 더 보이게 하고(`MenuItemButton` 칸 줄임), 목록이 길면(9개 이상) 펼친 목록
  높이를 제한해 화면을 거의 다 덮지 않게 한다(짧은 목록은 제한하지 않는다 — 빈 자리가 생기면 항목을 짚는 자리가
  어긋났었다). 너비는 설정 창 칸에 맞게 못 박는다(`expandedInsets`로 늘이면 창 밖까지 넘친 적이 있다). 저장된
  글꼴이 지금 이 컴퓨터에 없어도(지웠거나 다른 PC에서 쓰던 이름) 목록에 남겨 두고 경고를 보여 준다.
- **선택 표시**: 배경을 채우는 대신 왼쪽에 굵은 선을 긋는다(설정 왼쪽 구역 목록 `_SectionTile`) — 탭 줄의 밑줄과 같은
  생각이다. 배경을 채우면 고대비에서 글자색(`colorScheme.primary`)과 배경색(`secondaryContainer`, 기본값이 `primary`와
  같다)이 겹쳐 글자가 안 보이는 문제가 있었다. `ListTileThemeData.selectedColor`도 `onSecondaryContainer`로 맞춰서
  (Chip·SegmentedButton과 같은 색 규칙) 이 앱의 다른 `ListTile(selected: true)` 화면도 함께 고쳤다.

## 설정 (톱니, `Ctrl+,`)

외형(밝기, 색 구성 — 고대비 포함, 아이콘 모양 둥근·윤곽선·채움, UI 글꼴 이름·배율) · 편집기(글자 크기, 글꼴, 줄 간격, 들여쓰기 선, 저장 시 정렬) · 터미널(편집기 글꼴 같이 쓰기, 글꼴, 스크롤백) · 병합 관문(차단/경고만/끔) · 환경 점검.
**환경 점검**(이 컴퓨터 전체): flutter·adb·Xcode(Mac)·Windows 개발자 모드·Visual Studio, Mac 서명 인증서·만료일, 도구(flutter·adb) 위치 직접 지정(저장). 프로젝트·기기별 문제는 Run이 막는 항목·실패 힌트로 알려 준다.

## 규약·배포

conventions-v1 적용: 정보 창·오픈소스 라이선스·macOS 앱 메뉴, 한국어/영어(앱 바 `테마|언어|정보`), Saturn 팔레트·SeoulNamsan 글꼴, 고양이 아이콘, 릴리스 워크플로(`release.yml`, macOS·Windows)와 Windows 설치기, `scripts/bump-version.sh`.
macOS 앱 샌드박스는 **꺼져 있다**(폴더 선택·git·flutter 실행에 필요). Debug 빌드는 `.dev` 식별자.
프로젝트 열기: 앱 바 "프로젝트 열기" 옆 화살표와 파일 메뉴에서 최근 프로젝트(최대 8개, 사라진 폴더는 알리고 뺌)를 다시 열 수 있고, 첫 화면에도 같은 목록이 나온다. worktree 전환은 목록에 더하지 않는다.

## 코드 구조와 출처

- `lib/branchdock/`: branch-dock-flutter에서 옮긴 Git 기능 전체(자기 `core`·`git`·`github`·`repo`·`release`·`ui`). `lib/ui/branchdock_dock.dart`가 셸.
- `lib/core`, `lib/devices`, `lib/flutter`, `lib/install`, `lib/doctor`: flutty-dock-flutter에서 복사해 이쪽에서 고쳐 쓴 것. `lib/run/run_controller.dart`가 Run 상태.
- `lib/terminal/`: daylight-terminal-flutter에서 로컬 셸 부분만 가져와 줄인 것. `lib/ui/terminal_pane.dart`·`terminal_panel.dart`가 화면.
  `packages/xterm2`·`packages/flutter_pty`는 그 앱의 패치된 복사본을 그대로 옮겨 온 것(각 폴더의 `PATCHES.md`).
- `lib/studio/`(프로젝트·탭·편집기 상태), `lib/ui/`(화면), `lib/problems/`, `lib/diff/`, `lib/verify/`(검증 기록), `lib/settings/`, `lib/theme/`.
- 원본 앱(flutty-dock-flutter, branch-dock-flutter, daylight-terminal-flutter)은 수정하지 않는다. 필요한 코드는 복사해 온다.

## 작업 방식 (사용자 선호)

- Claude는 브랜치에서 작업 → 커밋 → 사용자가 확인하면 **로컬 `main`에 병합**한다. **push는 따로 요청할 때만** 한다. 새 작업마다 브랜치 이름을 제안하고, 병합은 매번 사용자에게 묻는다.
- `flutter pub get`이 만드는 플러그인 생성 파일은 커밋하지 않는다(`.gitignore`에 있음).
- Windows/macOS 앱은 사용자가 Flutty Dock으로 직접 빌드해 확인한다. worktree에서 `flutter run`으로 앱을 띄우지 않는다.
- 테스트 요령:
  - 실제 파일·프로세스 입출력이 필요한 위젯 테스트는 `tester.runAsync`로 감싸고, 끝날 때까지 **고정 시간이 아니라 조건**이 될 때까지 기다린다(전체 실행에서 느려져 가끔 실패한다). 화면을 내리기 전에 시작한 프로세스가 끝나야 타이머가 남지 않는다.
  - 편집기를 쓰는 테스트는 `debugDefaultTargetPlatformOverride = TargetPlatform.windows`를 쓰되 **테스트 본문이 끝나기 전에** 되돌리고, 끝에서 트리를 내린다(타이머 정리). re_editor의 접기 계산(isolate)은 테스트에서 결과가 오지 않아 같은 분석기를 직접 넣는다.
  - 실제 git이 필요한 테스트는 임시 저장소를 만들고, Windows에서는 줄 끝(CRLF)과 임시 폴더 삭제 잠금을 고려한다(`test/branchdock/support.dart`의 `safeDelete`).
  - Branch Dock 이식 테스트는 `test/branchdock/`에 있다.
  - 터미널 테스트(`test/terminal/`)는 네이티브 flutter_pty 없이 `PtyFactory`를 가짜(`helpers/fake_pty.dart`)로 바꿔 끼운다.

## 다른 PC에서 시작하기

- 원격: `https://github.com/jejezz/daylight-flutter-studio.git` (공개). 필요한 것: Flutter 3.47(Dart 3.13), git, `dart`·`flutter`가 PATH에 있을 것, GitHub CLI `gh`(PR 기능, `gh auth login`).
- 시작: `flutter pub get` → `flutter analyze` → `flutter test` → Flutty Dock으로 빌드(또는 `flutter run -d windows`).
- 코드 출처 앱은 이미 필요한 코드를 복사했으므로 다른 PC에 없어도 된다.

## 알려진 한계

- 변경 파일을 눌러도 Studio 편집기의 변경점 보기가 열리지 않고 Branch Dock의 diff 화면이 열린다.
- 문제 표시는 줄 단위 점뿐(글자 단위 물결 밑줄·빠른 수정·LSP 없음). 변경점 보기는 줄 단위(줄 안 글자 차이는 표시 안 함)이고 HEAD와만 비교한다.
- 프로젝트 검색의 파일 목록은 열 때마다 새로 읽는다(최대 2만 개).
- 프로젝트 바꾸기는 줄 단위뿐이다(여러 줄에 걸친 패턴은 못 바꾼다). 되돌리기 기록은 검색창을 닫으면 사라진다. 수정 중인 탭이 열린 파일을 건너뛰는 것을 직접 눈으로(Flutty Dock 빌드) 확인하지는 않았다(컨트롤러 단위·위젯 테스트만).
- macOS 메뉴는 코드와 변환 테스트만 있고 실제 Mac에서는 확인하지 않았다. (편집 메뉴의 찾기·바꾸기는 탭이 들고 있는 찾기 제어를 직접 불러서 포커스와 상관없이 동작한다.)
- 파일 끌어다 놓기는 컨트롤러 동작만 테스트했다(실제 OS에서 끄는 동작은 직접 확인 필요).
- 앱 이름에 "Flutter"가 들어 있어 공개 배포 전에 다시 정해야 한다(Flutter 상표).
- 터미널 패널은 Windows/macOS에서 실제 셸로 직접 켜 보고 확인하지 않았다(네이티브 flutter_pty 빌드가 필요해 Flutty Dock으로 빌드해야 한다). 탐색기·파일 끌어놓기, 로그 기록, ANSI 제거 같은 daylight-terminal-flutter의 기능은 가져오지 않았다.
- 고대비·UI 글꼴 배율은 설정 화면을 직접 켜서 확인했다(선택된 구역 글자가 묻히던 문제를 찾아 고쳤다). 다만 트리·
  Branch Dock 화면까지 고대비·85~125% 배율로 눈으로 다 훑어보지는 않았다.
- 아이콘 세트는 아직 모양(둥근·윤곽선·채움) 3종뿐이다. 파일 종류별 색 아이콘 같은 "완전히 다른 세트"는 없다 — 지금
  트리는 모든 파일에 같은 아이콘을 쓴다. 편집기 글꼴의 합자(ligature) 켜고 끄기도 없다.
- 앱을 끌 때(⌘Q 등) 위젯 dispose가 보장되지 않아, 열린 터미널의 셸 프로세스가 남을 수 있다 — 종료 전에 정리하는 장치는 아직 없다.
