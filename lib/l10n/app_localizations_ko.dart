// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get aboutTooltip => '정보';

  @override
  String aboutVersion(String version, String build) {
    return '버전 $version (빌드 $build)';
  }

  @override
  String get aboutOpenSourceLicenses => '오픈소스 라이선스';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => '닫기';

  @override
  String aboutMenuItem(String appName) {
    return '$appName 정보';
  }

  @override
  String get themeMenuTooltip => '테마';

  @override
  String get themeSystem => '시스템 설정 따르기';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get languageMenuTooltip => '언어';

  @override
  String get languageSystem => '시스템 설정 따르기 / System';

  @override
  String get languageSystemShort => '시스템';

  @override
  String get aboutTagline => 'Flutter 앱을 만드는 통합 작업대';

  @override
  String get aboutDescription =>
      '프로젝트 트리·간단 편집기·빌드/설치·PR/병합/릴리스를 한 창에 묶어, 작업 → 로컬 검증 → 병합 → 릴리스 순서를 지키게 합니다.';

  @override
  String get runNotFlutterProject => '열린 폴더가 Flutter 프로젝트가 아닙니다';

  @override
  String get runNoPlatforms => '지원 플랫폼 없음';

  @override
  String get runTarget => '대상';

  @override
  String get runRefreshDevices => '기기 다시 찾기';

  @override
  String get runNoDevices => '연결된 기기가 없습니다';

  @override
  String get runPlatformMacos => 'macOS 데스크톱';

  @override
  String get runPlatformWindows => 'Windows 데스크톱';

  @override
  String get runLinkWireless => '무선';

  @override
  String get runLinkLocal => '이 컴퓨터';

  @override
  String get runModeDebug => 'Debug (flutter run)';

  @override
  String get runStart => '실행';

  @override
  String get runBuildInstall => '빌드 & 설치';

  @override
  String get runStop => '중지';

  @override
  String get runHotReload => 'r 핫 리로드';

  @override
  String get runHotRestart => 'R 핫 리스타트';

  @override
  String get runQuit => 'q 종료';

  @override
  String get runBlockerNoProject => '프로젝트를 열어 주세요.';

  @override
  String get runBlockerNoDevice => '대상을 고르세요.';

  @override
  String get runBlockerPlatformMissing => '이 프로젝트는 선택한 플랫폼을 지원하지 않습니다.';

  @override
  String get runBlockerIosNeedsMac => 'iOS 설치는 macOS에서만 할 수 있습니다.';

  @override
  String get runBlockerWireless => '무선 연결에서는 설치가 실패합니다. USB로 연결하세요.';

  @override
  String get runBlockerDeveloperModeOff => 'iPhone의 개발자 모드가 꺼져 있습니다.';

  @override
  String get runBlockerAndroidUnauthorized => '휴대폰에서 USB 디버깅 승인을 눌러 주세요.';

  @override
  String get runBlockerNeedsTeamId =>
      'iOS 서명 Team ID가 필요합니다. (프로젝트에 DEVELOPMENT_TEAM이 있어야 합니다)';

  @override
  String get runCommandsToRun => '실행될 명령';

  @override
  String runCommandNotFound(String command) {
    return '$command 명령을 찾을 수 없습니다. PATH를 확인하세요.';
  }

  @override
  String get runHintUseUsb => '무선 연결에서는 설치가 끊깁니다. USB로 연결하세요.';

  @override
  String get runHintUnlockDevice => '기기 화면의 잠금을 풀고 다시 시도하세요.';

  @override
  String get runHintDeveloperMode => '기기에서 개발자 모드를 켜세요.';

  @override
  String get runHintSigning => '서명 설정이 맞지 않습니다. Team ID와 프로비저닝 프로파일을 확인하세요.';

  @override
  String get runHintTrustComputer => '기기에서 \"이 컴퓨터를 신뢰\"를 눌러 주세요.';

  @override
  String get runHintNoAdb =>
      'adb를 찾을 수 없습니다. Android SDK platform-tools를 PATH에 추가하세요.';

  @override
  String get runHintCocoapods => 'CocoaPods가 필요합니다.';

  @override
  String get runHintVisualStudio =>
      'Visual Studio의 \"C++를 사용한 데스크톱 개발\" 구성 요소가 필요합니다.';

  @override
  String get runHintRestartApp => '플러그인 링크를 못 찾았습니다. 앱을 다시 연 뒤 한 번 더 시도하세요.';

  @override
  String get runHintStaleBuildCache =>
      '이전 Visual Studio 버전의 빌드 캐시가 남아 있습니다. build 폴더를 지우고 다시 시도하세요.';

  @override
  String get runVerifyConfirmed => '확인함';

  @override
  String get runVerifyBuilt => '빌드만 됨 — 아직 눈으로 확인하지 않았습니다';

  @override
  String get runVerifyProblem => '문제 있음';

  @override
  String get runVerifyNone => '이 커밋은 아직 검증하지 않았습니다';

  @override
  String get runVerifyTitle => '검증';

  @override
  String get runDetachedHead => '(분리된 HEAD)';

  @override
  String get runRecordSkippedNotGit => 'git 저장소가 아니라서 검증 기록을 남기지 않았습니다.';

  @override
  String get runRecordSkippedDirty =>
      '커밋하지 않은 수정이 있어 검증 기록을 남기지 않았습니다. 커밋한 뒤 다시 빌드하세요.';

  @override
  String get runProblemTitle => '어떤 문제가 있나요?';

  @override
  String get runProblemHint => '예: 로그인 버튼이 눌리지 않습니다';

  @override
  String get commonCancel => '취소';

  @override
  String get runRecordAndCopy => '기록하고 복사';

  @override
  String get runNoteCopied => '메모를 복사했습니다. Claude 세션에 붙여 넣으세요.';

  @override
  String get runOutput => '출력';

  @override
  String get runCopyOutput => '출력 복사';

  @override
  String get runNoOutput => '(출력 없음)';

  @override
  String get commonStop => '중지';

  @override
  String get gitNotRepo => '열린 폴더가 git 저장소가 아닙니다';

  @override
  String get gitNoGh => 'GitHub CLI(gh)를 찾을 수 없어 PR 기능을 쓸 수 없습니다.';

  @override
  String get gitUpstreamGone => '원격에 없음';

  @override
  String get gitNoUpstream => '추적 브랜치 없음';

  @override
  String get gitDetachedHead => '(분리된 HEAD)';

  @override
  String get gitRefresh => '새로 고침';

  @override
  String get gitClean => '변경 없음';

  @override
  String gitChangedFiles(int count) {
    return '변경된 파일 $count개';
  }

  @override
  String gitMoreFiles(int count) {
    return '… 외 $count개';
  }

  @override
  String get gitFileDeleted => '삭제된 파일';

  @override
  String get gitFileOpenDiff => '눌러서 변경점 보기';

  @override
  String get gitFileOpenConflict => '눌러서 충돌 해결';

  @override
  String gitConflicts(int count) {
    return '충돌 $count개 — 파일을 눌러 해결하세요';
  }

  @override
  String get gitStage => '스테이지';

  @override
  String get gitUnstage => '스테이지 해제';

  @override
  String get gitStageAll => '모두 스테이지';

  @override
  String get gitUnstageAll => '모두 해제';

  @override
  String get gitDoneStaged => '스테이지함';

  @override
  String get gitDoneUnstaged => '스테이지 해제함';

  @override
  String get gitDoneCommit => '커밋함';

  @override
  String get gitCommitMessageHint => '커밋 메시지';

  @override
  String get gitCommitAll => '커밋';

  @override
  String gitCommitStaged(int count) {
    return '커밋 ($count)';
  }

  @override
  String gitOnDefaultBranch(String branch) {
    return '기본 브랜치($branch)에서는 PR을 만들 수 없습니다. 새 브랜치에서 작업하세요.';
  }

  @override
  String conflictSheetTitle(String name) {
    return '$name 충돌 해결';
  }

  @override
  String get conflictUnreadable =>
      '파일을 읽을 수 없습니다(이진 파일이거나 삭제된 파일일 수 있습니다). 편집기에서 직접 고치세요.';

  @override
  String get conflictBroken => '충돌 표시가 온전하지 않아 앱에서 읽을 수 없습니다. 편집기에서 직접 고쳐 주세요.';

  @override
  String get conflictNone => '이 파일에는 충돌 표시가 없습니다. 이미 고쳤다면 닫고 상태를 다시 확인하세요.';

  @override
  String conflictBlockTitle(int index, int total) {
    return '충돌 $index/$total';
  }

  @override
  String get conflictSideMine => '내 것';

  @override
  String get conflictSideIncoming => '들어오는 것';

  @override
  String get conflictKeepBoth => '둘 다 유지 (위, 아래 순서)';

  @override
  String get conflictEmptySide => '(비어 있음)';

  @override
  String conflictPickHint(int left) {
    return '구간마다 어느 쪽을 쓸지 골라 주세요. $left개 남았습니다.';
  }

  @override
  String get conflictApply => '적용하고 해결됨 표시';

  @override
  String get conflictApplyNote =>
      '고른 대로 파일을 다시 쓰고 git add 합니다. 직접 고쳐 쓰려면 편집기로 여세요.';

  @override
  String doneConflictResolved(String name) {
    return '$name: 충돌 해결됨';
  }

  @override
  String get gitFetch => '가져오기';

  @override
  String gitPull(int behind) {
    return '받기 (↓$behind)';
  }

  @override
  String get gitPush => '올리기';

  @override
  String get gitVerified => '검증됨';

  @override
  String get gitBuiltOnly => '빌드만 됨 — 눈으로 확인하지 않았습니다';

  @override
  String get gitVerifyProblem => '확인했더니 문제가 있었습니다';

  @override
  String get gitStaleSome => '검증한 뒤 커밋이 추가되었습니다';

  @override
  String gitStaleCount(int count) {
    return '검증한 뒤 커밋 $count개가 추가되었습니다';
  }

  @override
  String get gitUnverified => '검증하지 않은 커밋입니다';

  @override
  String get gitHeadDiffers => '로컬 HEAD와 PR head가 다릅니다. 판정은 PR head 기준입니다.';

  @override
  String get gitBuildInRunTab => '병합하기 전에 Run 탭에서 이 커밋을 빌드해 확인하세요.';

  @override
  String get gitNoPr => '이 브랜치의 PR이 없습니다.';

  @override
  String get gitPrTitle => 'PR 제목';

  @override
  String get gitPushFirst => '먼저 브랜치를 올려야 PR을 만들 수 있습니다.';

  @override
  String get gitCreatePr => 'PR 만들기';

  @override
  String get gitMergeBlocked => 'PR 병합 (검증 필요)';

  @override
  String get gitMergeConfirm => 'PR 병합…';

  @override
  String get gitMerge => 'PR 병합';

  @override
  String get gitMergeUnverified => '검증 없이 병합…';

  @override
  String get gitUnverifiedDialogTitle => '확인하지 않은 커밋입니다';

  @override
  String get gitUnverifiedDialogBody =>
      '그래도 병합하면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나오면 고쳐서 릴리스를 다시 해야 합니다.';

  @override
  String get gitMergeAnyway => '그래도 병합';

  @override
  String get gitPrDraft => '초안(draft) PR입니다.';

  @override
  String get gitPrConflict => '충돌이 있습니다.';

  @override
  String gitPrChecksFailed(String names) {
    return '실패한 검사: $names';
  }

  @override
  String gitPrChecksPending(int count) {
    return '검사 $count개가 진행 중입니다.';
  }

  @override
  String get gitPrReviewRequired => '리뷰가 필요합니다.';

  @override
  String get gitPrMerged => '병합됨';

  @override
  String get gitPrOpen => '열림';

  @override
  String gitPrChecks(int passed, int failed, int pending) {
    return '검사 통과 $passed · 실패 $failed · 진행 $pending';
  }

  @override
  String get gitMergeMethod => '병합 방식';

  @override
  String get gitMergeCommit => '병합 커밋';

  @override
  String get gitDeleteBranchAfter => '병합 후 브랜치 삭제';

  @override
  String get studioOpenProject => '프로젝트 열기';

  @override
  String get studioOpenProjectFolder => '프로젝트 폴더 열기';

  @override
  String get studioSettingsTooltip => '설정 (Ctrl+,)';

  @override
  String get studioProblemsTab => '문제';

  @override
  String get studioTerminalTab => '터미널';

  @override
  String get terminalNew => '새 터미널';

  @override
  String get terminalCloseTooltip => '터미널 닫기';

  @override
  String get terminalEmpty => '열린 터미널이 없습니다';

  @override
  String get terminalEmptyHint => '+ 를 눌러 새 터미널을 엽니다';

  @override
  String get terminalLoadingShells => '셸을 찾는 중…';

  @override
  String get terminalNoShells => '쓸 수 있는 셸을 찾지 못했습니다';

  @override
  String terminalExited(String shell, int code) {
    return '$shell 종료됨 (코드 $code)';
  }

  @override
  String get terminalRestart => '다시 시작';

  @override
  String terminalStartError(String error) {
    return '셸을 시작하지 못했습니다: $error';
  }

  @override
  String get gitTabChanges => '변경';

  @override
  String get studioBottomPanelHide => '아래 패널 접기 (Ctrl+J)';

  @override
  String get studioBottomPanelShow => '아래 패널 펼치기 (Ctrl+J)';

  @override
  String get studioShowProblems => '문제 탭 열기';

  @override
  String get studioVerifyConfirmed => '검증됨';

  @override
  String get studioVerifyBuilt => '빌드만 됨';

  @override
  String get studioVerifyProblem => '문제 있음';

  @override
  String get studioVerifyNone => '미검증';

  @override
  String get studioNotRepo => '저장소 아님';

  @override
  String get studioAnalyzing => '분석 중…';

  @override
  String get studioDirty => '수정됨 (Ctrl+S 저장)';

  @override
  String get studioSaved => '저장됨';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionAppearance => '외형';

  @override
  String get settingsSectionEditor => '편집기';

  @override
  String get settingsSectionGate => '병합 관문';

  @override
  String get settingsPaletteSaturn => '새턴';

  @override
  String get settingsPaletteTeal => '청록';

  @override
  String get settingsPaletteAmber => '호박';

  @override
  String get settingsPaletteRose => '장미';

  @override
  String get settingsPaletteSlate => '슬레이트';

  @override
  String get settingsPaletteHighContrast => '고대비';

  @override
  String get settingsBrightness => '밝기';

  @override
  String get settingsBrightnessSystem => '시스템';

  @override
  String get settingsPalette => '색 구성';

  @override
  String get settingsAppliedNote => '바꾼 값은 바로 적용되고 다음 실행에도 유지됩니다.';

  @override
  String get settingsGateHeading => 'PR 병합 전 검증';

  @override
  String get settingsGateIntro =>
      '빌드해서 눈으로 확인한 커밋만 병합하게 합니다. 확인하지 않고 병합하면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나오면 고쳐서 릴리스를 다시 해야 합니다.';

  @override
  String get settingsGateConfirmNote =>
      '\"확인함\"은 Run 탭에서 앱을 실행해 본 뒤 직접 누르는 단추입니다. 빌드만 성공한 것은 확인으로 치지 않습니다.';

  @override
  String get settingsEditorUnavailable => '편집기 설정을 불러올 수 없습니다.';

  @override
  String get settingsFontSize => '글자 크기';

  @override
  String get settingsResetZoom => '100%로';

  @override
  String get settingsZoomNote =>
      '편집기와 Markdown 보기, 변경점 보기에만 적용됩니다. 편집기에서는 Ctrl+스크롤이나 Ctrl +/-/0으로도 바꿀 수 있습니다.';

  @override
  String get gateModeBlock => '차단';

  @override
  String get gateModeBlockHelp =>
      '확인한 커밋만 병합합니다. 예외가 필요하면 \"검증 없이 병합\"을 따로 눌러야 합니다.';

  @override
  String get gateModeWarn => '경고만';

  @override
  String get gateModeWarnHelp => '확인하지 않은 커밋을 병합하려 하면 한 번 더 묻습니다.';

  @override
  String get gateModeOff => '끔';

  @override
  String get gateModeOffHelp => '확인 여부와 상관없이 병합할 수 있습니다.';

  @override
  String get gateVerified => '검증됨 — 병합할 수 있습니다';

  @override
  String get gateBuiltOnly =>
      '빌드만 하고 눈으로 확인하지 않았습니다. 실행해 본 뒤 Run 탭에서 \"확인함\"을 눌러 주세요.';

  @override
  String get gateProblem => '확인했더니 문제가 있다고 기록된 커밋입니다.';

  @override
  String gateProblemNote(String note) {
    return '확인했더니 문제가 있다고 기록된 커밋입니다: $note';
  }

  @override
  String get gateStaleSome => '검증한 뒤 커밋이 추가되었습니다. 다시 빌드해 확인하세요.';

  @override
  String gateStaleCount(int count) {
    return '검증한 뒤 커밋 $count개가 추가되었습니다. 다시 빌드해 확인하세요.';
  }

  @override
  String get gateUnverified => '이 커밋은 로컬에서 확인하지 않았습니다. Run 탭에서 빌드해 눈으로 확인하세요.';

  @override
  String get editorOpenFromTree => '왼쪽 트리에서 파일을 여세요';

  @override
  String get editorFileGone => '이 파일이 디스크에서 사라졌습니다.';

  @override
  String get editorFileChanged => '디스크의 파일이 바뀌었습니다. 저장하면 그쪽 수정을 덮어씁니다.';

  @override
  String get editorCloseTab => '탭 닫기';

  @override
  String get editorLeaveAsIs => '그대로 두기';

  @override
  String get editorReloadDiscard => '다시 읽기 (내 수정 버림)';

  @override
  String get editorKeepMine => '내 수정 유지';

  @override
  String get editorZoomHint => 'Ctrl+스크롤 또는 Ctrl +/- 로 글자 크기 조절 · 클릭하면 100%';

  @override
  String get editorFoldAll => '모두 접기';

  @override
  String get editorUnfoldAll => '모두 펴기';

  @override
  String get editorBackToEdit => '편집으로 돌아가기';

  @override
  String get editorDiffSame => '변경점 보기 (HEAD와 같음)';

  @override
  String get editorDiffChanged => '변경점 보기 (HEAD와 비교)';

  @override
  String get editorEdit => '편집';

  @override
  String get editorPreview => '보기';

  @override
  String editorSavePromptTitle(String name) {
    return '$name 저장할까요?';
  }

  @override
  String get editorSavePromptBody => '저장하지 않은 수정이 있습니다.';

  @override
  String get editorDontSave => '저장 안 함';

  @override
  String get commonSave => '저장';

  @override
  String get treeExplorer => '탐색기';

  @override
  String get treeRefresh => '트리 새로 고침';

  @override
  String get problemsNoPackage => '열린 폴더에서 Dart 패키지(pubspec.yaml)를 찾지 못했습니다';

  @override
  String get problemsError => '오류';

  @override
  String get problemsWarning => '경고';

  @override
  String get problemsInfo => '정보';

  @override
  String get problemsReanalyze => '다시 분석';

  @override
  String get problemsNoPackageInfo =>
      '패키지 정보(.dart_tool)가 없어서 import 오류가 가짜로 섞입니다.';

  @override
  String get problemsAnalyzing => '분석하는 중…';

  @override
  String get problemsNotAnalyzed => '아직 분석하지 않았습니다';

  @override
  String get problemsFilteredOut => '선택한 종류의 문제가 없습니다';

  @override
  String get problemsUnknown => '분석하지 못해서 문제 여부를 알 수 없습니다';

  @override
  String get problemsNone => '문제가 없습니다';

  @override
  String get diffNotComparable =>
      '이 파일은 git으로 비교할 수 없습니다.\n(git 저장소가 아니거나 .gitignore로 무시되는 파일입니다)';

  @override
  String get diffAgainstHead => 'HEAD와 비교';

  @override
  String get diffNewFile => '새 파일 (아직 커밋되지 않음)';

  @override
  String get diffSameAsHead => 'HEAD와 같습니다. 변경된 곳이 없습니다.';

  @override
  String diffHiddenLines(int count) {
    return '같은 줄 $count개 — 눌러서 펼치기';
  }

  @override
  String get markdownImageUnavailable => '(이미지를 불러올 수 없습니다)';

  @override
  String markdownImage(String alt) {
    return '(이미지: $alt)';
  }

  @override
  String get languagePlain => '텍스트';

  @override
  String messageFolderUnavailable(String path) {
    return '폴더를 열 수 없습니다: $path';
  }

  @override
  String messageFileTooLarge(String name) {
    return '2MB보다 큰 파일은 열지 않습니다: $name';
  }

  @override
  String messageNotUtf8Open(String name) {
    return '글자 파일(UTF-8)이 아니라서 열 수 없습니다: $name';
  }

  @override
  String messageReadFailed(String error) {
    return '파일을 읽지 못했습니다: $error';
  }

  @override
  String get messageDiskChangedSaveBlocked =>
      '디스크의 파일이 바뀌었습니다. 저장하기 전에 \"다시 읽기\"나 \"내 수정 유지\"를 먼저 고르세요.';

  @override
  String messageSaveFailed(String error) {
    return '저장하지 못했습니다: $error';
  }

  @override
  String messageChangedNotUtf8(String name) {
    return '$name이(가) 디스크에서 바뀌었지만 글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.';
  }

  @override
  String messageChangedReloaded(String name) {
    return '$name이(가) 디스크에서 바뀌어 다시 읽었습니다.';
  }

  @override
  String messageReloadedFromDisk(String name) {
    return '$name을(를) 디스크 내용으로 다시 읽었습니다.';
  }

  @override
  String get messageNotUtf8Reload => '글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.';

  @override
  String get messageAlreadyFormatted => '이미 정렬되어 있습니다';

  @override
  String get messageFormatted => '정렬했습니다';

  @override
  String get formatNoDart =>
      'dart 명령을 찾을 수 없습니다. Flutter SDK의 bin 폴더가 PATH에 있는지 확인하세요.';

  @override
  String formatTempWriteFailed(String error) {
    return '임시 파일을 쓰지 못했습니다: $error';
  }

  @override
  String get formatCurrentFile => '(현재 파일)';

  @override
  String get formatFailed => '정렬하지 못했습니다.';

  @override
  String formatFailedDetail(String detail) {
    return '정렬하지 못했습니다: $detail';
  }

  @override
  String get analyzeFailedRead => '분석 결과를 읽지 못했습니다.';

  @override
  String analyzeFailedDetail(String detail) {
    return '분석하지 못했습니다: $detail';
  }

  @override
  String get problemsPubGetFailed =>
      'flutter pub get이 실패했습니다. 출력은 아래 명령 기록에서 확인하세요.';

  @override
  String get gitDoneFetch => '가져왔습니다';

  @override
  String get gitDonePull => '받았습니다';

  @override
  String get gitDonePush => '올렸습니다';

  @override
  String get gitDonePrCreated => 'PR을 만들었습니다';

  @override
  String gitNotMerged(String reason) {
    return '병합하지 않았습니다: $reason';
  }

  @override
  String gitDoneMergedUnverified(int number) {
    return '#$number을 검증 없이 병합했습니다';
  }

  @override
  String gitDoneMerged(int number) {
    return '#$number을 병합했습니다';
  }

  @override
  String get gitCommandNotFound =>
      '명령을 찾을 수 없습니다. git과 GitHub CLI(gh)가 설치되어 PATH에 있는지 확인하세요.';

  @override
  String gitFailedExit(int code) {
    return '실패했습니다 (종료 코드 $code)';
  }

  @override
  String get findHint => '찾기';

  @override
  String get findReplaceHint => '바꿀 내용';

  @override
  String get findNoResults => '결과 없음';

  @override
  String findCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get findMatchCase => '대소문자 구분';

  @override
  String get findRegex => '정규식';

  @override
  String get findPrevious => '이전 (Shift+Enter)';

  @override
  String get findNext => '다음 (Enter)';

  @override
  String get findClose => '찾기 닫기 (Esc)';

  @override
  String get findToggleReplace => '바꾸기 보기/숨기기';

  @override
  String get findReplaceOne => '바꾸기';

  @override
  String get findReplaceAll => '모두 바꾸기';

  @override
  String get quickOpenHint => '파일 이름으로 열기 (Ctrl+P)';

  @override
  String get quickOpenNoMatch => '맞는 파일이 없습니다';

  @override
  String get quickOpenLoading => '파일 목록을 읽는 중…';

  @override
  String get searchTitle => '프로젝트에서 찾기';

  @override
  String get searchHint => '찾을 글 (Enter로 검색)';

  @override
  String get searchSearching => '찾는 중…';

  @override
  String get searchNoResults => '결과가 없습니다';

  @override
  String searchResultCount(int count) {
    return '$count곳';
  }

  @override
  String searchTruncated(int count) {
    return '$count곳에서 멈췄습니다. 더 좁혀서 찾아 보세요.';
  }

  @override
  String get searchInvalidPattern => '정규식이 올바르지 않습니다';

  @override
  String searchReplaceSelected(int count) {
    return '선택한 $count곳 바꾸기';
  }

  @override
  String searchConfirmBody(int files, int lines) {
    return '$files개 파일의 $lines곳을 바꿉니다. 바꾼 뒤에는 이 창의 \"되돌리기\"로 되돌릴 수 있습니다.';
  }

  @override
  String searchReplaceDone(int files, int lines) {
    return '$files개 파일에서 $lines곳을 바꿨습니다.';
  }

  @override
  String get searchNothingReplaced =>
      '바뀐 곳이 없습니다. 검색한 뒤에 파일이 바뀌었을 수 있으니 다시 찾아 보세요.';

  @override
  String searchSkippedBusy(int count) {
    return '수정 중인 탭이 열려 있는 $count개 파일은 건너뛰었습니다. 저장하거나 닫고 다시 찾아 보세요.';
  }

  @override
  String searchReplaceFailed(int count) {
    return '$count개 파일은 읽거나 쓰지 못했습니다.';
  }

  @override
  String get searchUndo => '되돌리기';

  @override
  String searchUndoDone(int count) {
    return '$count개 파일을 되돌렸습니다.';
  }

  @override
  String searchUndoSkipped(int count) {
    return '바꾼 뒤에 또 수정된 $count개 파일은 그대로 두었습니다.';
  }

  @override
  String get studioQuickOpenTooltip => '파일 열기 (Ctrl+P)';

  @override
  String get studioSearchTooltip => '프로젝트에서 찾기 (Ctrl+Shift+F)';

  @override
  String get editorFormat => '정렬 (Ctrl+Alt+L)';

  @override
  String formatJsonInvalid(String detail) {
    return 'JSON 문법 오류라 정렬하지 못했습니다: $detail';
  }

  @override
  String get settingsFormatOnSave => '저장할 때 자동 정렬';

  @override
  String get settingsFormatOnSaveNote =>
      'Dart, JSON, ARB 파일을 저장하기 직전에 정렬합니다. 문법 오류가 있어 정렬하지 못해도 저장은 그대로 됩니다.';

  @override
  String get settingsEditorFont => '편집기 글꼴';

  @override
  String get settingsEditorFontHint => '글꼴 검색';

  @override
  String get settingsEditorFontDefault => '기본';

  @override
  String get settingsEditorFontNote =>
      '입력해서 걸러 찾을 수 있습니다. 이 컴퓨터에 설치된 글꼴만 고를 수 있습니다.';

  @override
  String get settingsLineHeight => '줄 간격';

  @override
  String get settingsLineHeightReset => '기본 줄 간격으로';

  @override
  String get settingsEditorFontMissing =>
      '이 글꼴은 이 컴퓨터에 설치되어 있지 않은 것 같습니다. Menlo 등 대체 글꼴로 보입니다.';

  @override
  String get settingsPreview => '미리보기';

  @override
  String get settingsUiFont => 'UI 글꼴';

  @override
  String get settingsUiFontMissing =>
      '이 글꼴은 이 컴퓨터에 설치되어 있지 않은 것 같습니다. 기본 글꼴로 보입니다.';

  @override
  String get settingsUiFontScale => '글자 크기 배율';

  @override
  String get settingsUiFontScaleNote =>
      '트리·탭·도구 막대 같은 칸 크기는 그대로 두고 글자만 커지거나 작아집니다.';

  @override
  String get settingsSectionTerminal => '터미널';

  @override
  String get settingsTerminalShareFont => '편집기 글꼴과 같이 쓰기';

  @override
  String get settingsTerminalShareFontNote =>
      '끄면 터미널만의 글꼴과 크기를 따로 고를 수 있습니다. 색은 설정 없이 늘 현재 테마를 따릅니다.';

  @override
  String get settingsTerminalFont => '터미널 글꼴';

  @override
  String get settingsTerminalFontSize => '글자 크기';

  @override
  String get settingsTerminalScrollback => '스크롤백 줄 수';

  @override
  String get settingsTerminalScrollbackNote =>
      '이미 열려 있는 터미널 탭에는 적용되지 않고, 새로 여는 탭부터 적용됩니다.';

  @override
  String get releaseButton => '릴리스…';

  @override
  String get releaseTitle => '릴리스 태그';

  @override
  String get releaseNotReady => '점검을 통과하지 못해 태그를 달지 않았습니다.';

  @override
  String releaseTagged(String tag) {
    return '$tag 태그를 올렸습니다. GitHub Actions가 릴리스를 만듭니다.';
  }

  @override
  String releaseTagPushFailed(String error) {
    return '태그를 올리지 못했습니다: $error';
  }

  @override
  String releaseVersionLine(String version, String tag) {
    return 'pubspec $version → 태그 $tag';
  }

  @override
  String releaseLastTag(String tag) {
    return '마지막 태그: $tag';
  }

  @override
  String get releaseNoLastTag => '아직 태그가 없습니다';

  @override
  String get releaseNoVersion => 'pubspec.yaml에서 버전을 읽지 못했습니다';

  @override
  String get releaseCheckCleanTree => '작업 폴더에 커밋하지 않은 수정이 없다';

  @override
  String get releaseCheckOnDefaultBranch => '기본 브랜치에 있다 (작업 브랜치에는 태그를 달지 않습니다)';

  @override
  String get releaseCheckSynced => '원격과 같다';

  @override
  String get releaseCheckVersionBumped => '버전이 마지막 태그보다 높다 (버전 올림이 병합됐다)';

  @override
  String get releaseCheckTagFree => '같은 이름의 태그가 아직 없다';

  @override
  String get releaseCheckVerified => '이 커밋을 빌드해서 눈으로 확인했다';

  @override
  String get releaseBumpHint => '버전을 올리려면 PR로 병합할 버전 올림 커밋을 만드세요:';

  @override
  String get releaseBumpHintNoScript =>
      'pubspec.yaml의 version을 올린 커밋을 PR로 병합하세요.';

  @override
  String get releaseRecheck => '다시 확인';

  @override
  String get releaseCreateTag => '태그 만들고 올리기';

  @override
  String get releaseTagWithoutVerification => '검증 없이 태그…';

  @override
  String get releaseUnverifiedTitle => '확인하지 않은 커밋입니다';

  @override
  String get releaseUnverifiedBody =>
      '그래도 태그를 올리면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나와도 이미 올린 태그는 옮기지 않습니다. PATCH를 올려 다시 릴리스해야 합니다.';

  @override
  String get releaseTagAnyway => '그래도 태그';

  @override
  String get settingsIconSet => '아이콘 모양';

  @override
  String get settingsIconSetRounded => '둥근';

  @override
  String get settingsIconSetOutlined => '윤곽선';

  @override
  String get settingsIconSetFilled => '채움';

  @override
  String get homeBuildTitle => '빌드';

  @override
  String get homeModeDebug => 'Debug';

  @override
  String get homeModeRelease => 'Release';

  @override
  String get homeTeamLabel => 'Apple Team ID';

  @override
  String get homeTeamHelp =>
      '프로젝트를 고치지 않고 빌드 인자로만 넘깁니다. developer.apple.com/account → Membership에서 확인하세요';

  @override
  String get homeStepsTitle => '실행할 명령';

  @override
  String get homeStepPrepare => '준비';

  @override
  String get homeStepBuild => '빌드';

  @override
  String get homeStepInstall => '설치';

  @override
  String get homeStepLaunch => '실행';

  @override
  String get homeStepRun => '실행 (핫 리로드)';

  @override
  String get homeActionInstall => '빌드 & 설치';

  @override
  String get homeActionBuildRun => '빌드 & 실행';

  @override
  String get homeActionInstallOnly => '설치만';

  @override
  String get homeActionClean => '정리 후 패키지 다시 받기';

  @override
  String get homeCleanHelp =>
      'flutter clean → flutter pub get. 이유 없이 빌드가 실패할 때 해 볼 만합니다.';

  @override
  String get optTitle => '빌드 옵션';

  @override
  String get optDefault => '기본값';

  @override
  String get optFlavor => 'Flavor';

  @override
  String get optFlavorHelp =>
      '--flavor. 프로젝트에 flavor가 있을 때만 입력하세요 (Windows는 Flutter 3.47 이상)';

  @override
  String get optFlavorInvalid => '영문자로 시작하고 영문자·숫자·_·-만 쓸 수 있습니다';

  @override
  String get optHelp => '도움말';

  @override
  String get optHelpLink =>
      '선택한 대상(Android·iOS·Windows …)에 맞는 Flutter 문서의 flavor 설정 방법을 브라우저로 엽니다';

  @override
  String get optTarget => '진입 파일';

  @override
  String get optTargetHelp => '-t. 비우면 lib/main.dart';

  @override
  String get optDefineFile => 'dart-define 파일';

  @override
  String get optDefineFileHelp =>
      '--dart-define-from-file. 경로만 저장하고 파일 내용은 읽거나 저장하지 않습니다';

  @override
  String get optFileMissing => '파일을 찾을 수 없습니다';

  @override
  String get optAppId => '앱 ID (선택)';

  @override
  String get optAppIdHelp =>
      'flavor가 앱 ID를 바꿀 때, 설치 뒤 실행에 쓸 ID (예: art.zoomon.app.dev)';

  @override
  String get optExtra => '추가 인자';

  @override
  String get optExtraHelp => '예: --obfuscate --split-debug-info=build/symbols';

  @override
  String get optPick => '파일 고르기';

  @override
  String get optClear => '옵션 지우기';

  @override
  String get homeCleanDone => '정리했고 패키지를 다시 받았습니다. 이제 빌드해 보세요.';

  @override
  String get homeCleanFailed => '정리에 실패했습니다. 기록 탭에서 출력을 확인하세요.';

  @override
  String get homeActionRun => '디버그 실행';

  @override
  String get homeActionCancel => '취소';

  @override
  String get homeActionStop => '중지';

  @override
  String get homeHotReload => '핫 리로드';

  @override
  String get homeHotRestart => '핫 리스타트';

  @override
  String get homeOutputTitle => '출력';

  @override
  String get homeCopyCommand => '명령 복사';

  @override
  String get outputCopyAll => '출력 전체 복사';

  @override
  String get outputCopied => '출력을 복사했습니다';

  @override
  String get outputViewer => '뷰어로 보기';

  @override
  String get viewerPause => '갱신 멈추기 (텍스트 선택용)';

  @override
  String get viewerResume => '실시간 갱신 다시 켜기';

  @override
  String viewerLines(Object count) {
    return '$count줄';
  }

  @override
  String get logRunning => '실행 중';

  @override
  String logExit(String code) {
    return '종료 코드 $code';
  }

  @override
  String get homeActionBuildOnly => '빌드만';

  @override
  String get homeActionRunOnly => '실행만';

  @override
  String get homeRunOnlyNeedsBuild => '실행할 release 결과물이 없습니다. 먼저 빌드하세요';

  @override
  String get homeActionRelaunch => '빌드 없이 다시 실행';

  @override
  String get doctorRun => '다시 점검';

  @override
  String get doctorRunning => '점검 중…';

  @override
  String get doctorNever => '아직 점검하지 않았습니다';

  @override
  String doctorCollected(String time) {
    return '$time에 점검함';
  }

  @override
  String get doctorAllGood => '문제가 없습니다';

  @override
  String checkFlutterOk(String version) {
    return 'Flutter $version';
  }

  @override
  String checkFlutterRunFail(String error) {
    return 'flutter를 실행했지만 실패했습니다: $error';
  }

  @override
  String get checkFlutterFail => 'flutter를 찾지 못했습니다';

  @override
  String checkXcodeOk(String version) {
    return 'Xcode $version';
  }

  @override
  String get checkXcodeFail => 'Xcode를 찾지 못했습니다';

  @override
  String checkAdbOk(String version) {
    return 'adb $version';
  }

  @override
  String get checkAdbWarn => 'adb를 찾지 못했습니다 (Android 설치에 필요)';

  @override
  String checkCertificateOk(String count) {
    return '개발 인증서 $count개 (개인 키 있음)';
  }

  @override
  String get checkCertificateFail => '사용할 수 있는 Apple Development 인증서가 없음';

  @override
  String checkCertExpiryOk(String name, String days) {
    return '$name · $days일 남음';
  }

  @override
  String checkCertExpiryWarn(String name, String days) {
    return '$name · $days일 뒤 만료';
  }

  @override
  String checkCertExpiryFail(String name) {
    return '$name · 만료됨';
  }

  @override
  String get stepsCertificate =>
      '1. Xcode → Settings → Accounts에서 Apple ID로 로그인합니다\n2. Manage Certificates → + → Apple Development을 추가합니다\n3. 다시 점검을 누릅니다';

  @override
  String get stepsFlutterMissing =>
      '1. flutter.dev에서 Flutter SDK를 설치합니다\n2. flutter/bin을 PATH에 추가합니다 (~/.zshrc)\n3. 앱을 다시 열고 점검을 누릅니다';

  @override
  String get stepsFlutterMissingWindows =>
      '1. flutter.dev에서 Flutter SDK를 설치합니다\n2. flutter\\bin 폴더를 PATH에 추가하거나, 위의 \'도구 경로 지정\'에서 flutter.bat을 직접 고릅니다\n3. 다시 점검을 누릅니다';

  @override
  String get stepsXcodeMissing =>
      '1. App Store에서 Xcode를 설치합니다\n2. 터미널에서 sudo xcode-select -s /Applications/Xcode.app 를 실행합니다\n3. Xcode를 한 번 열어 라이선스에 동의합니다';

  @override
  String get stepsAdbMissing =>
      '1. Android SDK platform-tools를 설치합니다 (Android Studio SDK Manager)\n2. platform-tools 폴더를 PATH에 추가합니다\n3. 다시 점검을 누릅니다';

  @override
  String get stepsCertExpiry =>
      '1. Xcode → Settings → Accounts → Manage Certificates에서 새 Apple Development 인증서를 만듭니다\n2. 다시 점검을 누릅니다';

  @override
  String get toolPathsOpen => '도구 경로 지정…';

  @override
  String get toolPathsTitle => '도구 경로';

  @override
  String get toolPathsHelp =>
      'PATH에서 찾지 못하는 도구는 직접 지정할 수 있습니다. 한 번 지정하면 저장되고 다음 실행에도 쓰입니다. 폴더가 아니라 실행 파일을 고르세요.';

  @override
  String get toolPathNotFound => '찾지 못함';

  @override
  String get toolPathChoose => '찾아서 지정…';

  @override
  String get toolPathAuto => '자동으로';

  @override
  String get toolPathCustom => '직접 지정';

  @override
  String get toolPathFlutter => 'flutter';

  @override
  String get toolPathAdb => 'adb (Android SDK platform-tools)';

  @override
  String get checkWindowsDevModeOk => 'Windows 개발자 모드 켜짐 (플러그인 링크를 만들 수 있음)';

  @override
  String get checkWindowsDevModeWarn =>
      'Windows 개발자 모드가 꺼져 있습니다 (플러그인 링크를 만들지 못해 빌드가 실패할 수 있음)';

  @override
  String checkVisualStudioOk(String version) {
    return 'Visual Studio $version (C++ 도구 있음)';
  }

  @override
  String get checkVisualStudioFail =>
      'Visual Studio의 \'C++를 사용한 데스크톱 개발\'이 없습니다 (Windows 앱 빌드에 필요)';

  @override
  String get stepsWindowsDevMode =>
      '1. Windows 설정을 열고 \'개발자용\'(개발자 설정)을 검색해 엽니다\n2. \'개발자 모드\'를 켭니다\n3. 다시 점검을 누릅니다';

  @override
  String get stepsVisualStudio =>
      '1. Visual Studio 2022(Community 가능)를 설치합니다\n2. 설치 관리자에서 \'C++를 사용한 데스크톱 개발\'을 선택합니다\n3. 다시 빌드합니다';

  @override
  String get settingsSectionEnvironment => '환경 점검';

  @override
  String get studioRecentProjects => '최근 프로젝트';

  @override
  String get studioRecentTooltip => '최근 프로젝트 보기';

  @override
  String get studioRecentNone => '최근에 연 프로젝트가 없습니다';

  @override
  String get studioRecentClear => '목록 지우기';

  @override
  String get studioRecentForget => '목록에서 빼기';

  @override
  String problemsNoPackageInfoSub(String packages) {
    return '$packages의 패키지 정보(.dart_tool)가 없어서 import 오류가 가짜로 섞입니다.';
  }

  @override
  String get settingsIndentGuides => '들여쓰기 선';

  @override
  String get settingsIndentGuidesNote =>
      '들여쓴 줄마다 깊이별로 색이 다른 세로선을 그어 짝을 맞춰 볼 수 있게 합니다. 고정폭 글꼴에서 정확합니다.';

  @override
  String get gitTabBranches => '브랜치';

  @override
  String get branchesLocal => '로컬 브랜치';

  @override
  String get branchesRemote => '원격 브랜치';

  @override
  String get branchesSearchHint => '브랜치 검색';

  @override
  String get branchesNew => '새 브랜치';

  @override
  String get branchesRefresh => '브랜치 목록 새로 고침';

  @override
  String get branchesEmpty => '브랜치가 없습니다';

  @override
  String get branchesNoMatch => '검색과 맞는 브랜치가 없습니다';

  @override
  String get branchesNotRepo => '열린 폴더가 git 저장소가 아닙니다';

  @override
  String get branchCurrent => '현재';

  @override
  String get branchSwitch => '전환';

  @override
  String get branchTrackSwitch => '로컬로 가져와 전환';

  @override
  String get branchNewFrom => '여기서 새 브랜치';

  @override
  String get branchRename => '이름 바꾸기';

  @override
  String get branchDelete => '삭제';

  @override
  String get branchDeleteRemote => '원격 브랜치 삭제';

  @override
  String branchInWorktree(String path) {
    return '다른 worktree에서 사용 중: $path';
  }

  @override
  String get branchOpenWorktree => '그 worktree 열기';

  @override
  String get branchGone => '원격에서 사라짐';

  @override
  String get branchNoUpstream => '추적 브랜치 없음';

  @override
  String get branchCreateTitle => '새 브랜치';

  @override
  String get branchNameLabel => '브랜치 이름';

  @override
  String get branchBaseLabel => '기준 브랜치';

  @override
  String get branchBaseHead => '현재 위치(HEAD)';

  @override
  String get branchSwitchAfter => '만든 뒤 바로 전환';

  @override
  String get branchCreate => '만들기';

  @override
  String get branchCommandPreview => '실행될 명령';

  @override
  String get branchNameEmpty => '이름을 입력하세요';

  @override
  String get branchNameInvalidChar => '공백이나 ~ ^ : ? * [ 같은 글자는 쓸 수 없습니다';

  @override
  String get branchNameDash => '-로 시작할 수 없습니다';

  @override
  String get branchNameSequence => '.. // 또는 .으로 시작하는 부분은 쓸 수 없습니다';

  @override
  String get branchNameEdge => '/로 시작하거나 /·.로 끝날 수 없습니다';

  @override
  String get branchNameExists => '이미 있는 이름입니다';

  @override
  String get branchRenameTitle => '브랜치 이름 바꾸기';

  @override
  String get branchRenameAction => '이름 바꾸기';

  @override
  String get branchDeleteTitle => '브랜치 삭제';

  @override
  String branchDeleteBody(String name) {
    return '\'$name\' 브랜치를 삭제합니다. 다른 브랜치에 병합된 것만 지워집니다.';
  }

  @override
  String get branchDeleteNotMergedTitle => '병합되지 않은 브랜치';

  @override
  String branchDeleteNotMergedBody(String name) {
    return '\'$name\'에는 다른 브랜치에 없는 커밋이 있습니다. 지우면 그 커밋에 접근하기 어려워집니다.';
  }

  @override
  String get branchForceDelete => '그래도 삭제 (-D)';

  @override
  String get branchDeleteRemoteTitle => '원격 브랜치 삭제';

  @override
  String branchDeleteRemoteBody(String remote, String branch) {
    return '원격 $remote에서 \'$branch\'를 삭제합니다. 같은 원격을 쓰는 다른 사람에게도 영향이 갑니다.';
  }

  @override
  String branchDoneSwitch(String name) {
    return '\'$name\'(으)로 전환했습니다';
  }

  @override
  String branchDoneCreate(String name) {
    return '\'$name\' 브랜치를 만들었습니다';
  }

  @override
  String branchDoneRename(String from, String to) {
    return '\'$from\' → \'$to\'로 이름을 바꿨습니다';
  }

  @override
  String branchDoneDelete(String name) {
    return '\'$name\' 브랜치를 삭제했습니다';
  }

  @override
  String branchDoneDeleteRemote(String name) {
    return '원격 브랜치 \'$name\'을(를) 삭제했습니다';
  }

  @override
  String branchErrInOtherWorktree(String name, String path) {
    return '\'$name\'은(는) 다른 worktree에서 쓰고 있어 전환·삭제할 수 없습니다: $path';
  }

  @override
  String get branchErrLocalChanges =>
      '커밋하지 않은 변경이 있어 전환할 수 없습니다. 커밋하거나 되돌린 뒤 다시 시도하세요.';

  @override
  String branchErrNotMerged(String name) {
    return '\'$name\'은(는) 병합되지 않았습니다.';
  }

  @override
  String branchErrExists(String name) {
    return '\'$name\' 이름이 이미 있습니다.';
  }

  @override
  String get branchErrRemote => '원격에 연결하지 못했습니다. 로그인과 네트워크를 확인하세요.';

  @override
  String get branchErrNoGit => 'git을 찾을 수 없습니다. 설치되어 PATH에 있는지 확인하세요.';

  @override
  String branchErrGeneric(String code) {
    return '실패했습니다 (종료 코드 $code)';
  }

  @override
  String get mergeMenuItem => '현재 브랜치로 병합…';

  @override
  String mergeTitle(String source, String target) {
    return '\'$source\'을(를) \'$target\'에 병합';
  }

  @override
  String mergeIncoming(String count) {
    return '들어올 커밋 $count개';
  }

  @override
  String mergeNothing(String source, String target) {
    return '\'$source\'에는 \'$target\'에 없는 커밋이 없습니다. 이미 최신입니다.';
  }

  @override
  String get mergeLoadFailed => '미리 보기를 읽지 못했습니다';

  @override
  String get mergeModeFastForward => 'Fast-forward';

  @override
  String get mergeFastForwardWhen =>
      '기록을 갈라놓지 않고 브랜치 끝만 앞으로 옮깁니다. 병합 커밋이 생기지 않습니다.';

  @override
  String get mergeFastForwardDisabled =>
      '두 브랜치가 갈라져 있어 쓸 수 없습니다 (현재 브랜치에도 새 커밋이 있습니다).';

  @override
  String get mergeModeMergeCommit => '병합 커밋';

  @override
  String get mergeMergeCommitWhen => '두 기록을 합치는 커밋을 만듭니다. 어디서 합쳤는지 기록에 남습니다.';

  @override
  String get mergeModeSquash => 'Squash';

  @override
  String get mergeSquashWhen =>
      '들어올 커밋을 하나로 묶어 커밋합니다. 기록은 깔끔하지만 원래 커밋은 따로 남지 않습니다.';

  @override
  String get mergeModeRebase => 'Rebase';

  @override
  String mergeRebaseWhen(String source) {
    return '현재 브랜치의 커밋을 \'$source\' 끝에 다시 쌓습니다. 기록은 한 줄이 되지만 커밋이 새로 만들어집니다.';
  }

  @override
  String get mergeMessageLabel => '커밋 메시지';

  @override
  String mergeSquashNote(String source) {
    return '\'$source\'의 커밋들이 하나로 묶여 스테이징된 뒤 커밋됩니다. 충돌이 나면 해결한 다음 직접 커밋하세요.';
  }

  @override
  String mergeRebaseReplay(String count) {
    return '다시 쌓일 내 커밋 $count개';
  }

  @override
  String get mergeRebaseNothing => '다시 쌓을 내 커밋이 없습니다. 이미 그 브랜치 위에 있습니다.';

  @override
  String get mergeRebasePublishedWarning =>
      '이 브랜치는 원격에 올라가 있습니다. rebase하면 커밋이 새로 만들어져 다음 push에 강제 push(--force-with-lease)가 필요합니다.';

  @override
  String get mergeConfirm => '병합';

  @override
  String get mergeConfirmRebase => 'Rebase';

  @override
  String mergeDone(String source, String target) {
    return '\'$source\'을(를) \'$target\'에 병합했습니다';
  }

  @override
  String mergeDoneRebase(String target, String source) {
    return '\'$target\'을(를) \'$source\' 위로 rebase했습니다';
  }

  @override
  String get mergeErrConflict =>
      '충돌이 났습니다. 변경 탭에서 충돌을 해결한 뒤 계속하거나, 중단해서 되돌리세요.';

  @override
  String get mergeErrLocalChanges =>
      '커밋하지 않은 변경이 병합과 겹칩니다. 커밋하거나 되돌린 뒤 다시 시도하세요.';

  @override
  String get mergeErrNotFastForward =>
      'fast-forward로 합칠 수 없습니다. 기록이 갈라졌으니 병합 커밋이나 squash를 고르세요.';

  @override
  String get mergeBusyOperation => '병합·rebase가 진행 중입니다. 먼저 계속하거나 중단하세요.';

  @override
  String opMerging(String count) {
    return '병합 중 — 충돌 $count개';
  }

  @override
  String opRebasing(String count) {
    return 'rebase 중 — 충돌 $count개';
  }

  @override
  String opCherryPicking(String count) {
    return 'cherry-pick 중 — 충돌 $count개';
  }

  @override
  String opReverting(String count) {
    return 'revert 중 — 충돌 $count개';
  }

  @override
  String get opContinue => '계속';

  @override
  String get opSkip => '건너뛰기';

  @override
  String get opAbort => '중단';

  @override
  String get opContinueBlocked => '충돌을 모두 해결하고 스테이지해야 계속할 수 있습니다.';

  @override
  String get opAbortTitle => '작업 중단';

  @override
  String get opAbortMergeBody => '병합을 중단하고 병합 전 상태로 되돌립니다. 충돌을 해결한 내용도 사라집니다.';

  @override
  String get opAbortRebaseBody =>
      'rebase를 중단하고 시작하기 전 상태로 되돌립니다. 이미 다시 쌓은 커밋도 사라집니다.';

  @override
  String get opAbortOtherBody => '진행 중인 작업을 중단하고 시작 전 상태로 되돌립니다.';

  @override
  String get opDoneContinue => '계속했습니다';

  @override
  String get opDoneSkip => '건너뛰었습니다';

  @override
  String get opDoneAbort => '중단했습니다. 시작 전 상태로 돌아왔습니다.';

  @override
  String get bdAboutTooltip => '정보';

  @override
  String bdAboutVersion(String version, String build) {
    return '버전 $version (빌드 $build)';
  }

  @override
  String get bdAboutOpenSourceLicenses => '오픈소스 라이선스';

  @override
  String get bdAboutRepository => 'GitHub';

  @override
  String get bdCommonClose => '닫기';

  @override
  String bdAboutMenuItem(String appName) {
    return '$appName 정보';
  }

  @override
  String get bdThemeMenuTooltip => '테마';

  @override
  String get bdThemeSystem => '시스템 설정 따르기';

  @override
  String get bdThemeLight => '라이트';

  @override
  String get bdThemeDark => '다크';

  @override
  String get bdLanguageMenuTooltip => '언어';

  @override
  String get bdLanguageSystem => '시스템 설정 따르기 / System';

  @override
  String get bdLanguageSystemShort => '시스템';

  @override
  String get bdAboutTagline => 'Git과 GitHub CLI를 위한 데스크톱 도우미';

  @override
  String get bdAboutDescription =>
      '편집기 옆에 세워 두고 브랜치, 태그, 병합, Pull/Push, 원격, 릴리스를 버튼으로 다룹니다. 버튼마다 실제로 실행되는 git·gh 명령을 보여 줍니다.';

  @override
  String get bdHomeEmptyTitle => '시작하려면 저장소를 선택하세요';

  @override
  String get bdHomeEmptyAction => '저장소 열기';

  @override
  String get bdAppBarRefresh => '새로 고침';

  @override
  String get bdAppBarPin => '항상 위에 표시';

  @override
  String get bdAppBarUnpin => '항상 위에 표시 끄기';

  @override
  String get bdMenuOpenFolder => '다른 폴더 열기…';

  @override
  String get bdMenuEditor => '파일을 열 편집기…';

  @override
  String get bdMenuEnvironment => '환경 점검';

  @override
  String get bdMenuCloseRepo => '저장소 닫기';

  @override
  String get bdHostOther => '기타 git 서버';

  @override
  String get bdCommonCancel => '취소';

  @override
  String get bdCommonCopy => '복사';

  @override
  String get bdCommonCopied => '복사했습니다';

  @override
  String get bdCommonMore => '더 보기';

  @override
  String get bdCommonSave => '저장';

  @override
  String get bdCommandPreviewLabel => '실행될 명령';

  @override
  String get bdStartDropHint => 'git 저장소 폴더를 창에 끌어다 놓아도 됩니다.';

  @override
  String get bdStartRecent => '최근 저장소';

  @override
  String get bdStartRemoveRecent => '목록에서 빼기';

  @override
  String bdStartNotARepository(String path) {
    return '이 폴더는 git 저장소가 아닙니다: $path';
  }

  @override
  String bdStartNotFound(String path) {
    return '폴더를 찾을 수 없습니다: $path';
  }

  @override
  String get bdEnvTitle => '환경 점검';

  @override
  String get bdEnvGitRequired => 'Branch Dock은 설치된 git을 실행합니다. git을 먼저 설치하세요.';

  @override
  String get bdEnvGitOnlyNote =>
      'gh가 없거나 로그인하지 않아도 브랜치·태그·Pull·Push는 쓸 수 있습니다. GitHub에 올리기, PR, 릴리스에는 gh 로그인이 필요합니다.';

  @override
  String bdEnvVersion(String version) {
    return '버전 $version';
  }

  @override
  String get bdEnvNotInstalled => '설치되지 않았거나 찾을 수 없습니다';

  @override
  String get bdEnvLogin => 'GitHub 로그인';

  @override
  String bdEnvLoggedInAs(String login) {
    return '$login 계정으로 로그인됨';
  }

  @override
  String get bdEnvNotLoggedIn => '로그인하지 않았습니다. 터미널에서 아래 명령을 실행하세요.';

  @override
  String get bdEnvRecheck => '다시 확인';

  @override
  String get bdEnvGhMissing =>
      'GitHub CLI(gh)가 설치되지 않아 쓸 수 없습니다. 메뉴의 환경 점검을 확인하세요.';

  @override
  String get bdEnvGhLoggedOut =>
      'gh에 로그인해야 쓸 수 있습니다. 터미널에서 gh auth login을 실행하세요.';

  @override
  String get bdHeaderOpenFolder => '편집기에서 이 폴더 열기';

  @override
  String get bdVscodeMissingTitle => 'VS Code를 찾지 못했습니다';

  @override
  String get bdVscodeMissingMessage =>
      'VS Code를 설치하면 이 버튼으로 현재 브랜치가 체크아웃된 폴더를 바로 열 수 있습니다. 다른 편집기를 쓰려면 저장소 메뉴의 ‘파일을 열 편집기…’에 명령(cursor, zed 등)을 적으세요.';

  @override
  String get bdVscodeDownload => 'VS Code 받기';

  @override
  String get bdHeaderBranchTooltip => '브랜치 목록 보기';

  @override
  String get bdHeaderDetached => '분리된 HEAD';

  @override
  String get bdHeaderNoUpstream => '원격에 없음';

  @override
  String get bdHeaderNoUpstreamTooltip =>
      '이 브랜치는 아직 원격에 올라가지 않았습니다. 게시(Publish)하면 올라갑니다.';

  @override
  String bdHeaderAheadTooltip(int count) {
    return '원격에 아직 없는 내 커밋 $count개';
  }

  @override
  String bdHeaderBehindTooltip(int count) {
    return '내 컴퓨터에 아직 없는 원격 커밋 $count개';
  }

  @override
  String bdHeaderChanges(int count) {
    return '변경 $count';
  }

  @override
  String get bdHeaderUpToDate => '최신';

  @override
  String get bdHeaderNoCommits => '아직 커밋 없음';

  @override
  String bdHeaderMerging(int count) {
    return '병합 중 · 충돌 $count';
  }

  @override
  String bdHeaderRebasing(int count) {
    return 'rebase 중 · 충돌 $count';
  }

  @override
  String get bdHeaderFetch => 'Fetch';

  @override
  String get bdHeaderPull => 'Pull';

  @override
  String get bdHeaderPush => 'Push';

  @override
  String get bdHeaderPublish => '게시';

  @override
  String get bdPullModeTooltip => 'Pull 방식';

  @override
  String get bdPullModeTitle => 'Pull 방식';

  @override
  String get bdPullModeMerge => '병합 (기본)';

  @override
  String get bdPullModeMergeWhen => '양쪽에 새 커밋이 있으면 병합 커밋으로 합칩니다. 가장 안전합니다.';

  @override
  String get bdPullModeRebase => 'Rebase';

  @override
  String get bdPullModeRebaseWhen => '내 커밋을 받아온 커밋 뒤로 옮겨 기록을 한 줄로 유지합니다.';

  @override
  String get bdPullModeFastForward => 'Fast-forward만';

  @override
  String get bdPullModeFastForwardWhen =>
      '내 커밋이 없을 때만 받아옵니다. 갈라졌으면 멈추고 알려 줍니다.';

  @override
  String get bdOperationAbort => '중단';

  @override
  String get bdOperationContinue => '계속';

  @override
  String get bdOperationContinueBlocked => '충돌을 모두 해결해야 계속할 수 있습니다';

  @override
  String get bdOperationAbortTitle => '진행 중인 작업을 중단할까요?';

  @override
  String get bdOperationAbortMergeMessage =>
      '병합을 시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.';

  @override
  String get bdOperationAbortRebaseMessage =>
      'rebase를 시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.';

  @override
  String bdBannerConflicts(int count) {
    return '충돌 파일 $count개를 해결해야 합니다';
  }

  @override
  String bdBannerPull(int count) {
    return '원격에 새 커밋 $count개가 있습니다';
  }

  @override
  String get bdBannerPublish => '이 브랜치는 아직 원격에 없습니다';

  @override
  String bdBannerPush(int count) {
    return '커밋 $count개가 아직 원격에 없습니다';
  }

  @override
  String get bdBannerNoRemote => '이 저장소는 아직 GitHub에 없습니다';

  @override
  String get bdBannerShow => '보기';

  @override
  String bdBannerNotGitHub(String host) {
    return '$host 저장소입니다. 브랜치·Pull·Push는 모두 쓸 수 있고, PR·릴리스·Actions는 GitHub 저장소에서만 쓸 수 있습니다.';
  }

  @override
  String get bdTabChanges => '변경';

  @override
  String get bdTabBranches => '브랜치';

  @override
  String get bdTabRemotes => '원격';

  @override
  String get bdChangesMessageHint => '커밋 메시지';

  @override
  String get bdChangesPrefixTooltip => '커밋 종류 접두어';

  @override
  String bdChangesFirstLineLong(int length) {
    return '첫 줄이 $length자입니다. 72자 안으로 줄이면 목록에서 잘리지 않습니다.';
  }

  @override
  String bdChangesCommitStaged(int count) {
    return '커밋 (스테이징 $count)';
  }

  @override
  String get bdChangesCommitAll => '모두 스테이징하고 커밋';

  @override
  String get bdChangesConflicts => '충돌';

  @override
  String get bdChangesStaged => '스테이징됨';

  @override
  String get bdChangesUnstaged => '변경됨';

  @override
  String get bdChangesUntracked => '추적 안 됨';

  @override
  String get bdChangesStageAll => '모두 스테이징';

  @override
  String get bdChangesUnstageAll => '모두 해제';

  @override
  String get bdChangesStage => '스테이징';

  @override
  String get bdChangesUnstage => '스테이징 해제';

  @override
  String get bdChangesOpenInEditor => '편집기로 열기';

  @override
  String get bdChangesMarkResolved => '해결됨 표시';

  @override
  String get bdChangesCleanTitle => '커밋할 변경이 없습니다';

  @override
  String get bdChangesCleanMessage => '편집기에서 파일을 저장하면 여기에 바로 나타납니다.';

  @override
  String get bdBranchesTitle => '브랜치';

  @override
  String get bdBranchesNew => '새 브랜치';

  @override
  String get bdBranchesCreate => '만들기';

  @override
  String get bdBranchesSearchHint => '브랜치 찾기';

  @override
  String get bdBranchesLocal => '로컬';

  @override
  String get bdBranchesRemote => '원격';

  @override
  String get bdBranchesSwitch => '전환';

  @override
  String get bdBranchesRename => '이름 바꾸기';

  @override
  String get bdBranchesDelete => '삭제';

  @override
  String get bdBranchesDeleteRemote => '원격에서 삭제';

  @override
  String get bdBranchesUpstreamGone => '원격 삭제됨';

  @override
  String get bdBranchesUnbornTitle => '아직 커밋이 없습니다';

  @override
  String get bdBranchesUnbornMessage => '첫 커밋을 만들면 브랜치를 만들 수 있습니다.';

  @override
  String get bdBranchesForceDeleteTitle => '병합되지 않은 브랜치입니다';

  @override
  String bdBranchesForceDeleteMessage(String name) {
    return '$name에는 다른 브랜치에 병합되지 않은 커밋이 있습니다. 삭제하면 그 커밋을 찾기 어려워집니다.';
  }

  @override
  String get bdBranchesDeleteRemoteTitle => '원격 브랜치를 삭제할까요?';

  @override
  String bdBranchesDeleteRemoteMessage(String branch, String target) {
    return '$target에서 $branch 브랜치를 삭제합니다. 다른 사람도 더 이상 이 브랜치를 받을 수 없습니다.';
  }

  @override
  String get bdBranchNameLabel => '브랜치 이름';

  @override
  String get bdBranchNameExists => '같은 이름의 브랜치가 이미 있습니다';

  @override
  String get bdBranchNameEmpty => '이름을 입력하세요';

  @override
  String get bdBranchNameInvalidCharacter => '공백과 ~ ^ : ? * [ \\ 는 쓸 수 없습니다';

  @override
  String get bdBranchNameStartsWithDash => '-로 시작할 수 없습니다';

  @override
  String get bdBranchNameInvalidSequence =>
      '.. 이나 //, .으로 시작하는 부분, .lock으로 끝나는 부분은 쓸 수 없습니다';

  @override
  String get bdBranchNameInvalidEdge => '/ 로 시작하거나 / 또는 . 으로 끝날 수 없습니다';

  @override
  String get bdBranchBaseLabel => '어디서 시작할까요';

  @override
  String bdBranchBaseCurrent(String name) {
    return '현재 브랜치 ($name)';
  }

  @override
  String get bdBranchSwitchAfter => '만든 뒤 바로 전환';

  @override
  String bdBranchRenameUpstreamNote(String upstream) {
    return '원격의 $upstream은 그대로 남습니다. 새 이름으로 다시 게시하세요.';
  }

  @override
  String get bdRemotesTitle => '원격';

  @override
  String get bdRemotesAdd => '원격 추가';

  @override
  String get bdRemotesRename => '이름 바꾸기';

  @override
  String get bdRemotesSetUrl => 'URL 바꾸기';

  @override
  String get bdRemotesRemove => '원격 삭제';

  @override
  String get bdRemotesRemoveTitle => '원격을 삭제할까요?';

  @override
  String bdRemotesRemoveMessage(String name) {
    return '이 저장소에서 $name 연결만 지웁니다. 서버의 저장소는 그대로 남습니다.';
  }

  @override
  String get bdRemotesEmptyTitle => '이 저장소는 아직 GitHub에 없습니다';

  @override
  String get bdRemotesEmptyMessage => 'GitHub에 새 저장소를 만들고 지금 브랜치를 올립니다.';

  @override
  String get bdRemotesPublishToGitHub => 'GitHub에 올리기';

  @override
  String get bdRemotesPublishAlsoToGitHub => 'GitHub에도 올리기 (원격 추가)';

  @override
  String get bdRemotesPublishConfirm => '만들고 올리기';

  @override
  String get bdRemotesNotGitHubNote =>
      'GitHub 저장소가 아니라서 PR·릴리스·Actions는 쓸 수 없습니다 (gh는 GitHub 전용).';

  @override
  String get bdRemotesNameLabel => '원격 이름';

  @override
  String get bdRemotesNameTaken => '같은 이름의 원격이 이미 있습니다';

  @override
  String get bdRemotesNameInvalid => '공백과 특수 문자는 쓸 수 없습니다';

  @override
  String get bdRemotesUrlLabel => 'URL';

  @override
  String get bdRemotesUseHttps => 'HTTPS 주소로 바꾸기';

  @override
  String get bdRemotesUseSsh => 'SSH 주소로 바꾸기';

  @override
  String get bdPublishNameLabel => '저장소 이름';

  @override
  String get bdPublishNameHelper => '조직에 만들려면 조직/이름';

  @override
  String get bdPublishNameInvalid => '영문, 숫자, - _ . 만 쓸 수 있습니다';

  @override
  String get bdPublishDescriptionLabel => '설명 (선택)';

  @override
  String get bdPublishPrivate => '비공개';

  @override
  String get bdPublishPublic => '공개';

  @override
  String get bdPublishNoCommitsNote => '아직 커밋이 없어서 저장소만 만듭니다. 첫 커밋 뒤에 Push하세요.';

  @override
  String get bdEditorTitle => '파일을 열 편집기';

  @override
  String get bdEditorMessage =>
      '편집기 명령을 적으면 파일과 저장소 폴더를 그 편집기로 엽니다. 비워 두면 파일은 OS 기본 앱으로, 폴더는 VS Code로 엽니다.';

  @override
  String get bdEditorLabel => '편집기 명령';

  @override
  String get bdLogTitle => '명령 기록';

  @override
  String get bdLogClear => '지우기';

  @override
  String get bdLogEmpty => '아직 실행한 명령이 없습니다';

  @override
  String get bdLogToggleTooltip => '명령 기록 펼치기/접기';

  @override
  String get bdDoneFetch => '원격 정보를 가져왔습니다';

  @override
  String get bdDonePull => 'Pull을 마쳤습니다';

  @override
  String get bdDonePush => 'Push를 마쳤습니다';

  @override
  String bdDonePublish(String branch) {
    return '$branch 브랜치를 게시했습니다';
  }

  @override
  String get bdDoneCommit => '커밋했습니다';

  @override
  String bdDoneSwitch(String name) {
    return '$name(으)로 전환했습니다';
  }

  @override
  String bdDoneCreateBranch(String name) {
    return '$name 브랜치를 만들었습니다';
  }

  @override
  String bdDoneRenameBranch(String name) {
    return '이름을 $name(으)로 바꿨습니다';
  }

  @override
  String bdDoneDeleteBranch(String name) {
    return '$name 브랜치를 삭제했습니다';
  }

  @override
  String bdDoneAddRemote(String name) {
    return '$name 원격을 추가했습니다';
  }

  @override
  String bdDoneRenameRemote(String name) {
    return '원격 이름을 $name(으)로 바꿨습니다';
  }

  @override
  String bdDoneSetRemoteUrl(String name) {
    return '$name의 URL을 바꿨습니다';
  }

  @override
  String bdDoneRemoveRemote(String name) {
    return '$name 원격을 삭제했습니다';
  }

  @override
  String bdDonePublishToGitHub(String name) {
    return 'GitHub에 $name 저장소를 만들었습니다';
  }

  @override
  String get bdDoneAbort => '중단했습니다';

  @override
  String get bdDoneContinue => '계속 진행했습니다';

  @override
  String get bdErrorGeneric => '명령이 실패했습니다. 아래 원문을 확인하세요.';

  @override
  String get bdErrorPushRejected =>
      'Push가 거부됐습니다. 원격에 내게 없는 커밋이 있어서입니다. 먼저 Pull 하세요.';

  @override
  String get bdErrorAuthFailed =>
      '인증에 실패했습니다. gh auth login으로 로그인했는지, SSH 키가 등록됐는지 확인하세요.';

  @override
  String get bdErrorConflict =>
      '충돌이 났습니다. 변경 탭에서 충돌 파일을 편집기로 열어 고친 뒤 해결됨을 누르세요.';

  @override
  String get bdErrorLocalChanges => '커밋하지 않은 변경이 덮어써질 수 있어서 멈췄습니다. 먼저 커밋하세요.';

  @override
  String get bdErrorNotFastForward =>
      '기록이 갈라져서 fast-forward로 받을 수 없습니다. Pull 방식을 병합이나 rebase로 바꾸세요.';

  @override
  String get bdErrorProtectedBranch =>
      '보호된 브랜치라서 직접 Push할 수 없습니다. 새 브랜치로 올리고 PR을 만드세요.';

  @override
  String get bdErrorBranchNotMerged => '병합되지 않은 커밋이 있는 브랜치입니다.';

  @override
  String get bdErrorNoUpstream => '추적 브랜치가 없습니다. 먼저 게시(Publish)하세요.';

  @override
  String get bdErrorAlreadyExists => '같은 이름이 이미 있습니다.';

  @override
  String get bdErrorRepositoryNotFound =>
      '원격 저장소를 찾을 수 없습니다. URL과 접근 권한을 확인하세요.';

  @override
  String get bdErrorNetwork => '서버에 연결할 수 없습니다. 네트워크를 확인하세요.';

  @override
  String get bdErrorNotInstalled => '프로그램을 찾을 수 없습니다. 메뉴의 환경 점검을 확인하세요.';

  @override
  String bdErrorBranchInOtherWorktree(String path) {
    return '이 브랜치는 다른 worktree($path)에 체크아웃되어 있습니다. git은 한 브랜치를 한 번에 한 worktree에서만 체크아웃할 수 있습니다.';
  }

  @override
  String get bdOpenWorktreeFolder => '그 폴더 열기';

  @override
  String get bdTimeJustNow => '방금';

  @override
  String bdTimeMinutesAgo(int n) {
    return '$n분 전';
  }

  @override
  String bdTimeHoursAgo(int n) {
    return '$n시간 전';
  }

  @override
  String bdTimeDaysAgo(int n) {
    return '$n일 전';
  }

  @override
  String get bdHelpTooltip => '이게 뭔가요?';

  @override
  String get bdHelpSectionWord => '낱말 뜻';

  @override
  String get bdHelpSectionInGit => 'git에서는';

  @override
  String get bdHelpSectionWhy => '왜 · 언제 쓰나';

  @override
  String get bdHelpSectionLinks => '더 알아보기';

  @override
  String get bdHelpCaptionBefore => '전';

  @override
  String get bdHelpCaptionAfter => '후';

  @override
  String get bdHelpCaptionAfterFetch => 'Fetch 후 — 내 main은 그대로';

  @override
  String get bdHelpCaptionAfterPull => 'Pull 후 — 내 main도 따라감';

  @override
  String get bdHelpCaptionAheadOne => 'feature가 origin/feature보다 커밋 하나 앞섬 (↑1)';

  @override
  String get bdHelpLinkBranchingBasics => 'Pro Git — 브랜치와 Merge의 기초';

  @override
  String get bdHelpLinkRemoteBranches => 'Pro Git — 리모트 브랜치';

  @override
  String get bdHelpLinkRebasing => 'Pro Git — Rebase 하기';

  @override
  String get bdHelpFetchVsPullTitle => 'Fetch와 Pull';

  @override
  String get bdHelpFetchVsPullWord => 'fetch는 \'가서 가져오다\', pull은 \'끌어당기다\'.';

  @override
  String get bdHelpFetchVsPullInGit =>
      'Fetch는 원격(GitHub)에 새로 생긴 커밋을 내 컴퓨터로 가져와 origin/main 같은 \'원격 이름표\'만 옮깁니다. 내 브랜치와 파일은 건드리지 않습니다. Pull은 Fetch를 한 뒤, 가져온 커밋을 내 브랜치에 합칩니다.';

  @override
  String get bdHelpFetchVsPullWhy =>
      '무엇이 바뀌었는지 먼저 보고 싶으면 Fetch — 안전하고 언제 해도 됩니다. 바로 최신으로 맞추려면 Pull. 커밋하지 않은 변경이 있으면 Pull이 멈출 수 있으니 먼저 커밋하세요.';

  @override
  String get bdHelpUpstreamTitle => '추적 브랜치 (upstream)와 origin';

  @override
  String get bdHelpUpstreamWord =>
      'upstream은 \'상류\'. 물이 흘러오는 쪽입니다. origin은 \'출처, 기원\'.';

  @override
  String get bdHelpUpstreamInGit =>
      'origin은 저장소를 받아 온 원격(대개 GitHub)에 붙는 기본 이름입니다. 내 브랜치가 짝지어 둔 원격 브랜치(예: origin/feature)를 추적 브랜치, 곧 upstream이라고 합니다. ↑↓ 숫자는 이 짝과 비교한 것입니다.';

  @override
  String get bdHelpUpstreamWhy =>
      '짝이 있어야 그냥 Push, Pull만 눌러도 어디로 보내고 어디서 받을지 압니다. 새 브랜치에는 짝이 없어서 처음 한 번은 \'게시\'(git push -u)로 짝을 지어 줍니다.';

  @override
  String get bdHelpFastForwardTitle => 'Fast-forward (빨리 감기)';

  @override
  String get bdHelpFastForwardWord => '테이프나 영상을 앞으로 빨리 감는 것.';

  @override
  String get bdHelpFastForwardInGit =>
      '내 브랜치가 갈라진 적 없이 뒤처져 있기만 할 때, 새 커밋을 만들지 않고 브랜치 이름표를 최신 커밋 위치로 앞으로 옮기기만 합니다. 이미 있는 커밋을 따라 \'앞으로 감기\'만 하므로 이렇게 부릅니다.';

  @override
  String get bdHelpFastForwardWhy =>
      '기록이 한 줄로 깔끔하고 합칠 것이 없으니 충돌도 없습니다. 양쪽에 서로 다른 새 커밋이 있으면(갈라졌으면) 빨리 감을 수 없어서, \'Fast-forward만\'은 멈추고 병합이나 rebase가 필요합니다. Push가 non-fast-forward로 거부되는 것도 같은 이유입니다.';

  @override
  String get bdHelpMergeCommitTitle => '병합 커밋 (merge commit)';

  @override
  String get bdHelpMergeCommitWord => 'merge는 \'합치다\', 두 길이 하나로 합류하는 것.';

  @override
  String get bdHelpMergeCommitInGit =>
      '갈라진 두 기록을 그대로 두고, 둘을 부모로 가진 새 커밋(병합 커밋)을 하나 만들어 합칩니다. 누가 언제 무엇을 합쳤는지 기록에 그대로 남습니다.';

  @override
  String get bdHelpMergeCommitWhy =>
      '이미 올린 커밋을 바꾸지 않아 가장 안전합니다. 다른 사람과 같이 쓰는 브랜치에 알맞습니다. 대신 기록에 병합 커밋이 늘어 조금 복잡해 보입니다.';

  @override
  String get bdHelpRebaseTitle => 'Rebase';

  @override
  String get bdHelpRebaseWord => 'base는 \'밑받침\', rebase는 \'밑받침을 다시 놓다\'.';

  @override
  String get bdHelpRebaseInGit =>
      '내 커밋들을 떼어 내서, 새로 받아온 커밋 뒤에 차례로 다시 붙입니다. 내용은 같지만 새 커밋(C\', D\')으로 다시 만들어지고, 기록은 한 줄이 됩니다.';

  @override
  String get bdHelpRebaseWhy =>
      '병합 커밋 없이 기록이 깔끔합니다. 아직 Push하지 않은 내 커밋에만 쓰세요. 이미 올린 커밋을 rebase하면 다른 사람의 기록과 어긋나서 강제 Push가 필요해집니다.';

  @override
  String get bdTabTags => '태그';

  @override
  String get bdTabRelease => '릴리스';

  @override
  String get bdTabPr => 'PR';

  @override
  String bdBranchesMergeInto(String head) {
    return '$head(으)로 병합해 오기';
  }

  @override
  String bdMergeTitle(String source, String into) {
    return '$source → $into 병합';
  }

  @override
  String bdMergeNothing(String source, String into) {
    return '$source에는 $into에 없는 커밋이 없습니다';
  }

  @override
  String bdMergeIncoming(int count) {
    return '들어올 커밋 $count개';
  }

  @override
  String get bdMergeFastForward => 'Fast-forward';

  @override
  String get bdMergeFastForwardWhen => '새 커밋 없이 이름표만 앞으로 옮깁니다. 기록이 한 줄로 남습니다.';

  @override
  String get bdMergeFastForwardDisabled => '현재 브랜치에도 새 커밋이 있어서(갈라져서) 쓸 수 없습니다.';

  @override
  String get bdMergeMergeCommit => '병합 커밋';

  @override
  String get bdMergeMergeCommitWhen => '두 기록을 그대로 두고 병합 커밋으로 합칩니다. 가장 안전합니다.';

  @override
  String get bdMergeSquash => 'Squash';

  @override
  String get bdMergeSquashWhen => '브랜치의 커밋을 하나로 눌러 합칩니다. 기능 하나 = 커밋 하나.';

  @override
  String bdMergeSquashNote(String source) {
    return 'squash 뒤 $source를 계속 쓰면 같은 변경이 다시 충돌할 수 있습니다. 병합 후 브랜치를 지우는 것을 권합니다.';
  }

  @override
  String get bdMergeMessageLabel => '커밋 메시지';

  @override
  String get bdMergeConfirm => '병합';

  @override
  String bdDoneMerge(String source, String into) {
    return '$source을(를) $into(으)로 병합했습니다';
  }

  @override
  String get bdTagsTitle => '태그';

  @override
  String get bdTagsNew => '새 태그';

  @override
  String get bdTagsCreate => '만들기';

  @override
  String get bdTagsCreateAndPush => '만들고 push';

  @override
  String bdTagsPushAll(int count) {
    return '원격에 없는 태그 $count개 push';
  }

  @override
  String get bdTagsPushed => '원격에 있음';

  @override
  String get bdTagsLocalOnly => '내 컴퓨터에만 있음';

  @override
  String get bdTagsLightweight => '가벼운 태그';

  @override
  String get bdTagsAnnotated => '주석 태그';

  @override
  String get bdTagsPush => 'Push';

  @override
  String get bdTagsDelete => '삭제';

  @override
  String get bdTagsDeleteRemote => '원격에서 삭제';

  @override
  String get bdTagsDeleteRemoteTitle => '원격 태그를 삭제할까요?';

  @override
  String bdTagsDeleteRemoteMessage(String tag, String target) {
    return '$target에서 $tag 태그를 삭제합니다. 이미 받아 간 사람이 있을 수 있으니, 같은 이름을 다시 쓰기보다 다음 번호를 쓰세요.';
  }

  @override
  String get bdTagsEmptyTitle => '아직 태그가 없습니다';

  @override
  String get bdTagsEmptyMessage =>
      '태그는 특정 커밋에 붙이는 이름표입니다. 보통 v1.0.0처럼 릴리스 버전에 씁니다.';

  @override
  String bdTagsPushAfter(String remote) {
    return '만든 뒤 $remote에 push';
  }

  @override
  String get bdTagNameLabel => '태그 이름';

  @override
  String get bdTagNameExists => '같은 이름의 태그가 이미 있습니다';

  @override
  String get bdTagNameInvalid => '공백, .., ~ ^ : ? * [ \\ 는 쓸 수 없습니다';

  @override
  String get bdTagNameNotSemVer =>
      '버전 형식(v1.2.3)이 아닙니다. 만들 수는 있지만 릴리스에는 버전 형식을 권합니다.';

  @override
  String get bdTagNameMissingV => '릴리스 태그는 v를 붙이는 것이 관례입니다 (v1.2.3).';

  @override
  String get bdTagMessageLabel => '메시지';

  @override
  String get bdTagTargetLabel => '어느 커밋에 달까요';

  @override
  String bdTagTargetHead(String name) {
    return '현재 위치 ($name)';
  }

  @override
  String bdDoneCreateTag(String name) {
    return '$name 태그를 만들었습니다';
  }

  @override
  String bdDonePushTags(int count) {
    return '태그 $count개를 push했습니다';
  }

  @override
  String bdDoneDeleteTag(String name) {
    return '$name 태그를 삭제했습니다';
  }

  @override
  String bdDoneDeleteRemoteTag(String name) {
    return '원격에서 $name 태그를 삭제했습니다';
  }

  @override
  String get bdPrTitle => 'Pull Request';

  @override
  String get bdPrCreate => 'PR 만들기';

  @override
  String get bdPrPublishAndCreate => '게시하고 PR 만들기';

  @override
  String get bdPrTitleLabel => '제목';

  @override
  String get bdPrBodyLabel => '본문';

  @override
  String get bdPrBodyChanges => '변경 내용';

  @override
  String get bdPrDraft => '초안으로 만들기';

  @override
  String get bdPrNotGitHubTitle => 'GitHub 저장소가 아닙니다';

  @override
  String get bdPrNotGitHubMessage =>
      'Pull Request는 GitHub 저장소에서만 쓸 수 있습니다 — gh는 GitHub 전용 도구입니다.';

  @override
  String get bdPrGhRequiredTitle => 'gh가 필요합니다';

  @override
  String get bdPrDetached => '브랜치에 있지 않습니다';

  @override
  String get bdPrOnDefaultTitle => '기본 브랜치에 있습니다';

  @override
  String get bdPrOnDefaultMessage => 'PR은 작업 브랜치에서 만듭니다. 브랜치 탭에서 새 브랜치를 만드세요.';

  @override
  String bdPrNoneTitle(String head) {
    return '$head에는 아직 PR이 없습니다';
  }

  @override
  String bdPrNoneMessage(String base) {
    return '$base(으)로 합칠 PR을 만들면 GitHub에서 검토와 검사를 거쳐 병합합니다.';
  }

  @override
  String get bdPrOpenOnGitHub => 'GitHub에서 보기';

  @override
  String get bdPrStateOpen => '열림';

  @override
  String get bdPrStateDraft => '초안';

  @override
  String get bdPrStateMerged => '병합됨';

  @override
  String get bdPrStateClosed => '닫힘';

  @override
  String get bdPrNoChecks => '검사 없음';

  @override
  String bdPrChecksPassed(int n) {
    return '통과 $n';
  }

  @override
  String bdPrChecksFailed(int n) {
    return '실패 $n';
  }

  @override
  String bdPrChecksPending(int n) {
    return '진행 중 $n';
  }

  @override
  String get bdPrApproved => '승인됨';

  @override
  String get bdPrReviewRequired => '리뷰 필요';

  @override
  String get bdPrBlockedDraft =>
      '초안 PR은 병합할 수 없습니다. GitHub에서 \'검토 준비 완료\'로 바꾸세요.';

  @override
  String get bdPrBlockedConflict =>
      '기준 브랜치와 충돌이 있습니다. 기준 브랜치를 병합해 와서 충돌을 해결하세요.';

  @override
  String bdPrBlockedChecks(String names) {
    return '실패한 검사가 있습니다: $names';
  }

  @override
  String bdPrBlockedPending(int count) {
    return '검사 $count개가 아직 진행 중입니다.';
  }

  @override
  String get bdPrBlockedReview => '리뷰 승인이 필요할 수 있습니다. 병합이 거부되면 GitHub에서 확인하세요.';

  @override
  String get bdPrMethodMerge => '병합 커밋 (merge)';

  @override
  String get bdPrMethodSquash => 'Squash 후 병합';

  @override
  String get bdPrMethodRebase => 'Rebase 후 병합';

  @override
  String get bdPrDeleteBranch => '병합 후 브랜치 삭제';

  @override
  String get bdPrMerge => '병합하기';

  @override
  String get bdPrMerging => '병합하는 중…';

  @override
  String get bdDonePrCreated => 'PR을 만들었습니다';

  @override
  String bdDonePrMerged(int number) {
    return 'PR #$number을(를) 병합했습니다';
  }

  @override
  String get bdReleaseTitle => '릴리스';

  @override
  String bdReleaseLatest(String tag) {
    return '마지막 릴리스 $tag';
  }

  @override
  String get bdReleaseNoTags => '아직 릴리스가 없습니다';

  @override
  String get bdReleaseIntro => '버전 올리기 → PR → 병합 → 태그 → CI 확인을 차례로 안내합니다.';

  @override
  String get bdReleaseNeedsGitHub =>
      '릴리스 마법사는 GitHub 저장소에서 쓸 수 있습니다. 태그는 태그 탭에서 만들 수 있습니다.';

  @override
  String get bdReleaseStart => '새 릴리스';

  @override
  String get bdReleaseNew => '새 릴리스';

  @override
  String bdReleaseNewVersion(String tag) {
    return '새 릴리스 $tag';
  }

  @override
  String get bdReleaseCancel => '그만두기';

  @override
  String get bdReleaseCancelTitle => '릴리스를 그만둘까요?';

  @override
  String bdReleaseCancelMessage(String branch) {
    return '지금까지 만든 $branch 브랜치와 PR은 그대로 남습니다. 필요 없으면 직접 지우세요.';
  }

  @override
  String get bdReleaseCancelAfterTag =>
      '태그는 이미 push되었습니다. 마법사만 닫고, CI와 릴리스는 GitHub에서 확인하세요.';

  @override
  String bdReleaseDone(String tag) {
    return '$tag 릴리스를 마쳤습니다';
  }

  @override
  String get bdReleasePrerelease => '프리릴리스';

  @override
  String get bdReleasePushAndPr => 'push하고 PR 만들기';

  @override
  String get bdStepCheck => '점검';

  @override
  String get bdStepVersion => '버전';

  @override
  String get bdStepPr => 'PR';

  @override
  String get bdStepMerge => '병합';

  @override
  String get bdStepTag => '태그';

  @override
  String get bdStepNotes => '릴리스 노트';

  @override
  String get bdStepNotesCi => '노트 (CI 릴리스 후)';

  @override
  String get bdStepNotesCiSummary => 'CI가 릴리스를 만듭니다';

  @override
  String get bdStepCi => 'CI 확인';

  @override
  String get bdStepNext => '다음';

  @override
  String get bdStepCheckDone => '모두 통과';

  @override
  String bdStepMergeDone(int number) {
    return 'PR #$number 병합됨';
  }

  @override
  String get bdCheckCleanTree => '커밋하지 않은 변경이 없다';

  @override
  String get bdCheckShowChanges => '변경 보기';

  @override
  String bdCheckOnDefault(String branch) {
    return '기본 브랜치($branch)에 있다';
  }

  @override
  String get bdCheckSynced => '받을 커밋도 보낼 커밋도 없다';

  @override
  String get bdCheckGitHub => 'GitHub 원격과 gh 로그인';

  @override
  String get bdCheckGitBash => 'Git for Windows의 bash (버전 올림 스크립트용)';

  @override
  String bdCheckChangesSince(int count, String tag) {
    return '$tag 이후 커밋 $count개';
  }

  @override
  String get bdCheckFirstRelease => '첫 릴리스입니다';

  @override
  String get bdCheckNoWorkflow => '태그로 도는 워크플로가 없습니다. 앱이 GitHub 릴리스를 만듭니다.';

  @override
  String bdCheckWorkflowCi(String file) {
    return '$file이(가) 태그 push로 릴리스를 만듭니다. 앱은 태그까지 달고 CI를 지켜봅니다.';
  }

  @override
  String bdCheckWorkflowOther(String file) {
    return '$file이(가) 태그 push로 돕니다.';
  }

  @override
  String get bdManualBuildTitle => '태그 전 수동 빌드 (권장)';

  @override
  String get bdManualBuildWhy =>
      '지난 릴리스 이후 빌드에 영향을 주는 파일이 바뀌었습니다. 태그 전에 모든 플랫폼이 빌드되는지 확인하세요. 수동 실행은 릴리스를 만들지 않습니다.';

  @override
  String get bdManualBuildStart => '빌드만 확인';

  @override
  String bdManualBuildShort(String state) {
    return '수동 빌드 $state';
  }

  @override
  String get bdDoneManualBuildStarted => '수동 빌드를 시작했습니다';

  @override
  String bdVersionCurrent(String version, String source) {
    return '현재 $version ($source)';
  }

  @override
  String get bdVersionFromTag => '마지막 태그';

  @override
  String get bdVersionRecommended => '추천';

  @override
  String bdVersionReason(int feats, int fixes, int breaking) {
    return '새 기능 $feats · 버그 수정 $fixes · 호환 깨짐 $breaking';
  }

  @override
  String get bdVersionCustom => '직접 입력';

  @override
  String get bdVersionFiles => '바뀌는 파일';

  @override
  String get bdVersionNoFiles => '버전 파일이 없어서 태그만 만듭니다.';

  @override
  String get bdVersionCommit => '릴리스 브랜치 만들고 커밋';

  @override
  String get bdBumpFinal => '정식';

  @override
  String get bdBumpPrerelease => '프리릴리스';

  @override
  String bdDoneReleaseCommit(String tag) {
    return '$tag 버전 올림을 커밋했습니다';
  }

  @override
  String bdMergeWaiting(int number) {
    return 'PR #$number 병합을 기다리는 중 — GitHub에서 병합해도 알아챕니다';
  }

  @override
  String bdTagCheckPrMerged(int number) {
    return 'PR #$number이(가) 병합됐다';
  }

  @override
  String bdTagCheckSynced(String branch) {
    return '$branch에 있고 받을 커밋도 보낼 커밋도 없다';
  }

  @override
  String bdTagCheckVersion(String tag) {
    return '버전 파일이 $tag와 같다';
  }

  @override
  String bdTagCheckVersionWrong(String version) {
    return '지금 버전은 $version입니다. 버전 올림 PR이 아직 병합되지 않았을 수 있습니다.';
  }

  @override
  String bdTagCheckFree(String tag) {
    return '$tag 태그가 아직 없다';
  }

  @override
  String bdTagConfirmTitle(String tag) {
    return '$tag 태그를 push할까요?';
  }

  @override
  String bdTagConfirmMessage(String tag, String branch) {
    return '$branch의 병합 커밋에 $tag를 답니다. push하면 릴리스가 공개되고, 태그는 옮기거나 지우지 않는 것이 규칙입니다.';
  }

  @override
  String get bdTagConfirmPush => '태그 달고 push';

  @override
  String bdDoneTagPushed(String tag) {
    return '$tag 태그를 push했습니다';
  }

  @override
  String get bdNotesLabel => '릴리스 노트 (마크다운)';

  @override
  String get bdNotesFeatures => '새 기능';

  @override
  String get bdNotesFixes => '버그 수정';

  @override
  String get bdNotesOther => '기타';

  @override
  String get bdNotesCreateRelease => 'GitHub 릴리스 만들기';

  @override
  String get bdNotesEdit => '노트 고치기';

  @override
  String get bdDoneReleaseCreated => 'GitHub 릴리스를 만들었습니다';

  @override
  String get bdDoneNotesSaved => '릴리스 노트를 저장했습니다';

  @override
  String bdCiWaitingForRun(String tag) {
    return '$tag(으)로 시작된 워크플로를 찾는 중';
  }

  @override
  String get bdCiOpenInBrowser => '브라우저에서 보기';

  @override
  String get bdCiRerunFailed => '실패한 잡 다시 실행';

  @override
  String get bdDoneRerun => '실패한 잡을 다시 실행했습니다';

  @override
  String get bdRunQueued => '대기 중';

  @override
  String get bdRunRunning => '진행 중';

  @override
  String get bdRunSuccess => '성공';

  @override
  String get bdRunFailure => '실패';

  @override
  String get bdRunCancelled => '취소됨';

  @override
  String get bdRunSkipped => '건너뜀';

  @override
  String get bdHelpCaptionAfterSquash => 'squash 병합 후 — main에 새 커밋 S 하나';

  @override
  String get bdHelpCaptionTag =>
      'v1.0.0과 v1.1.0은 옮겨지지 않는 이름표, main은 앞으로 나아가는 이름표';

  @override
  String get bdHelpLinkGitHubMergeMethods => 'GitHub — 병합 방법 정보';

  @override
  String get bdHelpLinkTagging => 'Pro Git — 태그';

  @override
  String get bdHelpSquashTitle => 'Squash (눌러 합치기)';

  @override
  String get bdHelpSquashWord => '눌러서 납작하게 만들다, 찌그러뜨리다.';

  @override
  String get bdHelpSquashInGit =>
      '브랜치의 여러 커밋을 눌러 커밋 하나로 합친 뒤 대상 브랜치에 올립니다. 변경 내용은 그대로이고 커밋 개수만 하나가 됩니다.';

  @override
  String get bdHelpSquashWhy =>
      '\'오타 수정\', \'다시 시도\' 같은 작업 중 커밋을 기본 브랜치 기록에 남기지 않고, 기능 하나 = 커밋 하나로 정리합니다. PR을 병합할 때 많이 씁니다. 원래 커밋들은 기본 브랜치에 남지 않으니, 병합한 브랜치를 계속 쓰지 말고 지우세요.';

  @override
  String get bdHelpTagTitle => '태그 (주석 태그와 가벼운 태그)';

  @override
  String get bdHelpTagWord => 'tag는 \'꼬리표, 이름표\'.';

  @override
  String get bdHelpTagInGit =>
      '특정 커밋에 붙이는 이름표입니다. 브랜치 이름표는 새 커밋을 따라 앞으로 가지만, 태그는 한 번 붙이면 그 커밋에 머뭅니다. 주석 태그는 만든 사람·날짜·메시지를 함께 저장하고, 가벼운 태그는 이름만 저장합니다.';

  @override
  String get bdHelpTagWhy =>
      '릴리스 버전(v1.2.0)에는 주석 태그를 씁니다 — 릴리스 기록이 남고, GitHub 릴리스와 CI가 태그를 기준으로 돕니다. 이미 push한 태그는 옮기거나 지우지 말고, 잘못됐으면 다음 번호로 새로 다세요.';

  @override
  String get bdHeaderMergedAndGone => '병합됨 · 원격 삭제됨';

  @override
  String get bdHeaderMergedAndGoneTooltip =>
      '이 브랜치는 이미 기본 브랜치에 병합되었고 원격에서 삭제되었습니다. 다시 게시하면 지운 브랜치가 되살아납니다.';

  @override
  String bdBannerMergedAndGone(String branch) {
    return '이 브랜치는 병합되어 원격에서 삭제되었습니다. $branch(으)로 돌아가세요';
  }

  @override
  String bdBannerSwitchTo(String branch) {
    return '$branch(으)로 전환';
  }

  @override
  String bdBannerCreatePr(String branch) {
    return '$branch을(를) 올렸지만 아직 PR이 없습니다';
  }

  @override
  String get bdPrBaseLabel => '기준 브랜치';

  @override
  String bdPrBaseNotDefault(String base) {
    return '기본 브랜치($base)가 아닌 곳으로 합칩니다. 다른 기능 브랜치 위에 쌓는 PR일 때 씁니다.';
  }

  @override
  String get bdTabCi => 'CI';

  @override
  String get bdCiTitle => 'CI 실행';

  @override
  String get bdCiNotGitHubMessage =>
      'Actions는 GitHub 저장소에서만 쓸 수 있습니다 — gh는 GitHub 전용 도구입니다.';

  @override
  String bdCiEmptyTitle(String branch) {
    return '$branch에는 아직 실행이 없습니다';
  }

  @override
  String get bdCiEmptyMessage => 'push나 PR, 태그로 워크플로가 돌면 여기에 나옵니다.';

  @override
  String get bdCiRerun => '다시 실행';

  @override
  String get bdCiCancel => '취소';

  @override
  String get bdCiDispatch => '수동 실행';

  @override
  String get bdCiDispatchNeedsPush =>
      '수동 실행은 원격에 있는 브랜치에서만 할 수 있습니다. 먼저 게시하세요.';

  @override
  String bdCiDispatchTitle(String file) {
    return '$file 수동 실행';
  }

  @override
  String bdCiDispatchMessage(String branch) {
    return '$branch 브랜치로 워크플로를 실행합니다. 입력이 필요한 워크플로는 브라우저에서 실행하세요.';
  }

  @override
  String get bdCiDispatchConfirm => '실행';

  @override
  String bdDoneDispatched(String file) {
    return '$file을(를) 실행했습니다';
  }

  @override
  String get bdDoneRunCancelled => '실행을 취소했습니다';

  @override
  String bdNotifyRunTitle(String name, String state) {
    return '$name $state';
  }

  @override
  String bdNotifyReleaseRun(String tag, String state) {
    return '$tag 릴리스 CI $state';
  }

  @override
  String bdNotifyManualBuild(String state) {
    return '태그 전 수동 빌드 $state';
  }

  @override
  String get bdPrFilterMine => '내 PR';

  @override
  String get bdPrFilterReview => '리뷰 요청';

  @override
  String get bdPrFilterOpen => '전체';

  @override
  String get bdPrListEmpty => '열린 PR이 없습니다';

  @override
  String get bdPrCurrentBranch => '현재 브랜치';

  @override
  String get bdPrCheckout => '이 PR 브랜치로 체크아웃';

  @override
  String get bdPrCheckoutWhy =>
      'PR 브랜치를 내 컴퓨터로 가져와 전환합니다. 직접 실행해 보거나 고칠 때 씁니다.';

  @override
  String bdDonePrCheckout(int number, String branch) {
    return 'PR #$number의 $branch(으)로 전환했습니다';
  }

  @override
  String get bdReleasesTitle => '릴리스';

  @override
  String get bdReleasesEmpty => 'GitHub 릴리스가 없습니다';

  @override
  String get bdReleasesLoadFailed => '릴리스 목록을 불러오지 못했습니다';

  @override
  String get bdReleaseLatestPill => '최신';

  @override
  String get bdReleaseDraft => '초안';

  @override
  String get bdReleaseMakeFinal => '정식 릴리스로 바꾸기';

  @override
  String get bdReleaseMakePrerelease => '프리릴리스로 바꾸기';

  @override
  String get bdReleasePublishDraft => '초안 게시';

  @override
  String get bdReleaseDelete => '릴리스 삭제';

  @override
  String bdReleaseDeleteTitle(String tag) {
    return '$tag 릴리스를 삭제할까요?';
  }

  @override
  String get bdReleaseDeleteMessage =>
      'GitHub 릴리스와 올라간 파일이 사라집니다. 이미 받아 간 사람이 있을 수 있습니다.';

  @override
  String bdReleaseDeleteTagToo(String tag) {
    return 'GitHub의 $tag 태그도 삭제 (로컬 태그는 남음)';
  }

  @override
  String bdDoneReleaseDeleted(String tag) {
    return '$tag 릴리스를 삭제했습니다';
  }

  @override
  String bdDoneReleaseMadeFinal(String tag) {
    return '$tag을(를) 정식 릴리스로 바꿨습니다';
  }

  @override
  String bdDoneReleaseMadePrerelease(String tag) {
    return '$tag을(를) 프리릴리스로 바꿨습니다';
  }

  @override
  String bdDoneReleasePublished(String tag) {
    return '$tag 초안을 게시했습니다';
  }

  @override
  String get bdNotesEditTab => '편집';

  @override
  String get bdNotesPreviewTab => '미리 보기';

  @override
  String get bdNotesEmpty => '내용이 없습니다';

  @override
  String bdTagVersionMismatch(String file, String version, String tag) {
    return '$file의 버전은 $version인데 태그는 $tag입니다.';
  }

  @override
  String get bdTagVersionMismatchWhy =>
      '릴리스 태그는 버전을 먼저 올린 커밋에 달아야 합니다 — 릴리스 마법사가 버전 올림 PR부터 태그까지 차례로 합니다.';

  @override
  String get bdTagVersionMismatchCi =>
      '이 저장소는 태그를 push하면 CI가 릴리스를 만드는데, 버전이 다르면 CI가 멈춥니다.';

  @override
  String get bdTagVersionMismatchBlocked =>
      '그래서 push는 막았습니다. 로컬에만 만들려면 push를 끄세요.';

  @override
  String get bdTagOpenReleaseWizard => '릴리스 마법사 열기';

  @override
  String get bdTabHistory => '기록';

  @override
  String get bdMenuAutoFetch => '자동 fetch (5분마다·돌아올 때)';

  @override
  String get bdChangesAmendToggle => '직전 커밋 고치기';

  @override
  String get bdChangesAmend => '직전 커밋 고치기';

  @override
  String get bdChangesAmendPushedWarning =>
      '이미 원격에 올린 커밋입니다. 고치면 기록이 갈라져 강제 push(force-with-lease)가 필요합니다.';

  @override
  String get bdDoneAmend => '직전 커밋을 고쳤습니다';

  @override
  String get bdChangesDiscard => '변경 취소';

  @override
  String bdChangesDiscardMessage(String path) {
    return '$path의 커밋하지 않은 변경을 버리고 마지막으로 스테이징(또는 커밋)한 상태로 되돌립니다. 되돌릴 수 없습니다.';
  }

  @override
  String get bdChangesDeleteUntracked => '파일 삭제';

  @override
  String bdChangesDeleteUntrackedMessage(String path) {
    return 'git이 추적하지 않는 $path을(를) 지웁니다. 휴지통으로 가지 않습니다.';
  }

  @override
  String get bdConflictUseMine => '내 것 사용';

  @override
  String get bdConflictUseIncoming => '들어오는 것 사용';

  @override
  String get bdConflictByBlock => '구간별로 해결';

  @override
  String bdConflictSheetTitle(String name) {
    return '$name 충돌 해결';
  }

  @override
  String bdConflictBlockTitle(int index, int total) {
    return '충돌 $index/$total';
  }

  @override
  String get bdConflictSideMine => '내 것';

  @override
  String get bdConflictSideIncoming => '들어오는 것';

  @override
  String get bdConflictKeepBoth => '둘 다 유지 (위, 아래 순서)';

  @override
  String get bdConflictEmptySide => '(비어 있음)';

  @override
  String bdConflictPickHint(int left) {
    return '구간마다 어느 쪽을 쓸지 골라 주세요. $left개 남았습니다.';
  }

  @override
  String get bdConflictApply => '적용하고 해결됨 표시';

  @override
  String get bdConflictApplyNote =>
      '고른 대로 파일을 다시 쓰고 git add 합니다. 직접 고쳐 쓰려면 편집기로 여세요.';

  @override
  String get bdConflictBroken =>
      '충돌 표시가 온전하지 않아 앱에서 읽을 수 없습니다. 편집기에서 직접 고쳐 주세요.';

  @override
  String get bdConflictNone =>
      '이 파일에는 충돌 표시가 없습니다. 이미 고쳤다면 \'해결됨 표시\'만 누르면 됩니다.';

  @override
  String get bdConflictUnreadable =>
      '파일을 읽을 수 없습니다 (이진 파일이거나 삭제된 파일일 수 있습니다). \'내 것 사용\' 또는 \'들어오는 것 사용\'으로 해결하세요.';

  @override
  String bdDoneConflictResolved(String name) {
    return '$name: 충돌 해결됨';
  }

  @override
  String get bdChangesOperationTitle => '아직 작업이 끝나지 않았습니다';

  @override
  String get bdChangesOperationMessage =>
      '충돌은 모두 해결됐습니다. 위의 \'계속\'으로 마무리하거나 \'중단\'으로 시작하기 전 상태로 되돌리세요.';

  @override
  String get bdConflictReopen => '다시 충돌 상태로';

  @override
  String bdConflictReopenMessage(String path) {
    return '$path을(를) 충돌이 난 직후의 모습으로 되돌립니다. 지금까지 해결한 내용은 사라지고, 충돌 표시가 다시 들어갑니다.';
  }

  @override
  String get bdConflictReopenConfirm => '다시 충돌';

  @override
  String get bdConflictMarkersLeftTitle => '충돌 표시가 남아 있습니다';

  @override
  String bdConflictMarkersLeftMessage(String path, int count) {
    return '$path에 아직 `<<<<<<<` 표시가 $count군데 남아 있습니다. 이대로 해결됨으로 표시하면 표시가 그대로 커밋됩니다. 먼저 \'구간별로 해결\'이나 편집기로 정리하세요.';
  }

  @override
  String get bdConflictMarkersLeftConfirm => '그래도 해결됨 표시';

  @override
  String bdDoneFileAction(String name) {
    return '$name: 완료';
  }

  @override
  String get bdStashTitle => '임시 저장 (stash)';

  @override
  String get bdStashSave => '임시 저장';

  @override
  String get bdStashSaveFile => '이 파일만 임시 저장';

  @override
  String get bdStashFileToStage => '스테이징으로 꺼내기';

  @override
  String bdStashFileOverwriteMessage(String path) {
    return '$path에 이미 변경이 있습니다. 임시 저장한 내용으로 덮어씁니다.';
  }

  @override
  String get bdStashEmpty => '파일 목록을 불러오지 못했습니다.';

  @override
  String bdStashWhy(int count) {
    return '변경 $count개를 커밋하지 않고 따로 치워 둡니다. 추적하지 않는 파일도 함께 저장합니다. 나중에 \'다시 적용\'으로 되살립니다.';
  }

  @override
  String get bdStashMessageLabel => '메모 (선택)';

  @override
  String get bdStashPop => '적용하고 지우기 (pop)';

  @override
  String get bdStashApply => '적용만 하기 (apply)';

  @override
  String get bdStashDrop => '삭제';

  @override
  String get bdStashDropTitle => '임시 저장을 삭제할까요?';

  @override
  String bdStashDropMessage(String text) {
    return '\'$text\'에 저장한 변경이 사라집니다.';
  }

  @override
  String get bdStashAndRetry => '임시 저장하고 다시';

  @override
  String get bdStashAutoMessage => 'Branch Dock: 자동 임시 저장';

  @override
  String get bdDoneStashSaved => '임시 저장했습니다';

  @override
  String get bdDoneStashApplied => '임시 저장을 적용했습니다';

  @override
  String get bdDoneStashDropped => '임시 저장을 삭제했습니다';

  @override
  String get bdDoneStashAndRetry =>
      '변경을 임시 저장하고 다시 실행했습니다. 변경 탭의 임시 저장에서 되살릴 수 있습니다.';

  @override
  String get bdPushOptionsTooltip => 'Push 옵션';

  @override
  String get bdPushOptionsTitle => 'Push 옵션';

  @override
  String get bdPushFollowTags => '태그도 함께 push (--follow-tags)';

  @override
  String get bdPushFollowTagsWhy => '올리는 커밋에 달린 주석 태그를 함께 올립니다. 이 저장소에만 적용됩니다.';

  @override
  String get bdPushForceTitle => '강제 push (force-with-lease)';

  @override
  String get bdPushForceWhy =>
      'amend나 rebase로 이미 올린 커밋을 고쳤을 때만 씁니다. 내가 모르는 원격 커밋이 있으면 git이 거부해서 다른 사람의 작업을 덮어쓰지 않습니다.';

  @override
  String bdPushForceBlockedDefault(String branch) {
    return '기본 브랜치($branch)에서는 강제 push를 막았습니다 — 다른 사람의 기록을 덮어쓸 수 있습니다.';
  }

  @override
  String get bdPushForce => '강제 push';

  @override
  String bdPushForceConfirmTitle(String branch) {
    return '$branch을(를) 강제 push할까요?';
  }

  @override
  String bdPushForceConfirmMessage(String branch, String upstream) {
    return '$upstream의 기록을 내 $branch로 바꿉니다. 내가 fetch한 뒤 누가 push했다면 git이 거부합니다.';
  }

  @override
  String get bdOperationSkip => '건너뛰기';

  @override
  String get bdOperationSkipTooltip => '충돌 난 이 커밋을 빼고 rebase를 계속합니다';

  @override
  String get bdDoneSkip => '커밋을 건너뛰었습니다';

  @override
  String get bdBranchesSetUpstream => '추적 브랜치 설정';

  @override
  String bdBranchesSetUpstreamWhy(String branch) {
    return '$branch이(가) Push·Pull할 원격 브랜치를 정합니다.';
  }

  @override
  String get bdBranchesUpstreamLabel => '원격 브랜치';

  @override
  String bdDoneSetUpstream(String branch, String upstream) {
    return '$branch의 추적 브랜치를 $upstream(으)로 정했습니다';
  }

  @override
  String get bdBranchesCleanup => '병합된 브랜치 정리';

  @override
  String bdCleanupWhy(String base) {
    return '$base에 이미 병합됐거나 원격에서 지워진 로컬 브랜치입니다. 원격 브랜치는 건드리지 않습니다.';
  }

  @override
  String get bdCleanupMerged => '병합됨';

  @override
  String get bdCleanupGoneNotMerged => '원격에서 삭제됨 · 병합 안 됨 — 지우면 커밋을 찾기 어려워집니다';

  @override
  String bdCleanupConfirm(int count) {
    return '$count개 삭제';
  }

  @override
  String bdCleanupNothing(String base) {
    return '정리할 브랜치가 없습니다 ($base에 병합된 브랜치 없음)';
  }

  @override
  String bdDoneCleanup(int count) {
    return '브랜치 $count개를 정리했습니다';
  }

  @override
  String get bdTagsCommitsSince => '이전 태그 이후 커밋';

  @override
  String bdTagsCommitsBetween(String from, String to) {
    return '$from → $to';
  }

  @override
  String bdTagsCommitsUpTo(String tag) {
    return '$tag까지';
  }

  @override
  String bdTagsCommitsCount(int count) {
    return '커밋 $count개';
  }

  @override
  String get bdTagsCheckout => '이 태그로 이동';

  @override
  String bdTagsCheckoutTitle(String tag) {
    return '$tag(으)로 이동할까요?';
  }

  @override
  String get bdTagsCheckoutMessage =>
      '태그 위치의 파일을 그대로 볼 수 있습니다. 이때는 어느 브랜치에도 있지 않은 \'분리된 HEAD\' 상태라, 여기서 커밋하려면 먼저 브랜치를 만드세요.';

  @override
  String bdDoneCheckoutTag(String tag) {
    return '$tag(으)로 이동했습니다';
  }

  @override
  String get bdBannerDetached => '어느 브랜치에도 있지 않습니다. 여기서 커밋하려면 브랜치를 만드세요';

  @override
  String get bdHistoryTitle => '기록';

  @override
  String bdHistoryUnpushed(int count) {
    return '↑ 올리지 않은 커밋 $count';
  }

  @override
  String get bdHistoryNotPushed => '아직 올리지 않음';

  @override
  String get bdHistoryCopyHash => '해시 복사';

  @override
  String get bdHistoryBranchHere => '여기서 브랜치 만들기';

  @override
  String get bdHistoryTagHere => '여기에 태그 달기';

  @override
  String get bdHelpLinkStashing => 'Pro Git — Stashing과 Cleaning';

  @override
  String get bdHelpCaptionStash =>
      '커밋하지 않은 변경 W를 stash 목록 맨 위에 치워 둠 — main은 그대로';

  @override
  String get bdHelpStashTitle => 'Stash (임시 저장)';

  @override
  String get bdHelpStashWord => 'stash는 \'넣어 두다, 숨겨 두다\'. 잠깐 서랍에 치워 두는 것.';

  @override
  String get bdHelpStashInGit =>
      '커밋하지 않은 변경을 브랜치 기록에 남기지 않고 따로 저장한 뒤, 작업 트리를 깨끗하게 되돌립니다. 저장한 변경은 목록에 쌓이고(가장 최근 것이 맨 위), 나중에 어느 브랜치에서든 다시 적용할 수 있습니다.';

  @override
  String get bdHelpStashWhy =>
      '하던 일을 커밋하기엔 이른데 브랜치를 바꾸거나 Pull해야 할 때 씁니다. \'pop\'은 적용하고 목록에서 지우고, \'apply\'는 목록에 남겨 둡니다. 오래 두면 무엇이었는지 잊기 쉬우니 메모를 남기세요.';

  @override
  String get bdHelpCaptionDetached => 'HEAD가 브랜치가 아니라 v1.0.0 커밋을 직접 가리킴';

  @override
  String get bdHelpDetachedTitle => '분리된 HEAD (detached HEAD)';

  @override
  String get bdHelpDetachedWord =>
      'detached는 \'떨어진, 분리된\'. HEAD는 \'지금 보고 있는 곳\'.';

  @override
  String get bdHelpDetachedInGit =>
      '보통 HEAD는 브랜치 이름표를 가리키고, 커밋하면 그 이름표가 앞으로 갑니다. 태그나 커밋으로 직접 이동하면 HEAD가 브랜치에서 떨어져 커밋을 직접 가리킵니다.';

  @override
  String get bdHelpDetachedWhy =>
      '옛 버전을 실행해 보거나 비교할 때 안전하게 쓸 수 있습니다. 여기서 커밋하면 어느 브랜치에도 속하지 않아 다른 곳으로 옮기면 찾기 어려워지니, 커밋하려면 먼저 \'여기서 브랜치 만들기\'를 하세요.';

  @override
  String get bdHelpForceTitle => '강제 push (force-with-lease)';

  @override
  String get bdHelpForceWord =>
      'force는 \'억지로\', lease는 \'임대 계약\' — 내가 본 상태 그대로일 때만 바꾼다는 조건.';

  @override
  String get bdHelpForceInGit =>
      'amend나 rebase로 이미 올린 커밋을 고치면 원격 기록과 갈라져 보통 push가 거부됩니다. 강제 push는 원격 브랜치를 내 기록으로 바꿉니다. --force-with-lease는 원격이 내가 마지막으로 fetch한 상태 그대로일 때만 바꾸고, 그 사이 누가 push했으면 거부합니다.';

  @override
  String get bdHelpForceWhy =>
      '혼자 쓰는 작업 브랜치에서 기록을 정리했을 때만 씁니다. 여러 사람이 쓰는 브랜치, 특히 main에서는 쓰지 않습니다. 이 앱은 --force(무조건)는 제공하지 않고, 기본 브랜치에서는 막습니다.';

  @override
  String get bdMenuBrowse => '브라우저에서 저장소 열기';

  @override
  String get bdMenuSnapRight => '화면 오른쪽에 붙이기';

  @override
  String get bdMenuSnapLeft => '화면 왼쪽에 붙이기';

  @override
  String get bdStartInitRepository => '이 폴더를 git 저장소로 만들기';

  @override
  String get bdCloneTitle => 'GitHub에서 복제';

  @override
  String get bdCloneSearch => '내 저장소 찾기';

  @override
  String get bdCloneEmpty => '저장소가 없습니다';

  @override
  String get bdCloneNoFolder => '복제할 위치를 고르세요';

  @override
  String get bdCloneChooseFolder => '위치 고르기';

  @override
  String bdCloneExists(String path) {
    return '이미 있는 폴더입니다: $path';
  }

  @override
  String get bdCloneConfirm => '복제하고 열기';

  @override
  String get bdCloneRunning => '복제하는 중…';

  @override
  String get bdLoginTitle => 'GitHub 로그인';

  @override
  String get bdLoginSsh => 'SSH';

  @override
  String get bdLoginHttps => 'HTTPS';

  @override
  String get bdLoginSshRecommended => 'SSH 권장';

  @override
  String get bdLoginSshWhy =>
      'SSH 주소의 원격이나 SSH로 접속한 환경에서는 HTTPS로 로그인하면 push 때 인증이 따로 놀 수 있습니다.';

  @override
  String get bdLoginStepKey => 'SSH 키 확인';

  @override
  String get bdLoginStepKeyFound => '이 키를 GitHub에 올립니다';

  @override
  String get bdLoginStepKeyMissing =>
      '키가 없습니다. 터미널에서 아래 명령으로 만드세요 (암호 문구 권장). 앱은 키와 암호 문구를 받지 않습니다.';

  @override
  String get bdLoginStepLogin => '로그인';

  @override
  String get bdLoginStepLoginWhy => '브라우저에서 GitHub에 로그인하고 일회용 코드를 넣습니다.';

  @override
  String get bdLoginLoggedIn => '로그인되어 있습니다';

  @override
  String get bdLoginStart => '브라우저로 로그인';

  @override
  String get bdLoginDeviceHowTo =>
      '브라우저가 열리지 않거나 원격 서버라면, 다른 기기의 브라우저에서 아래 주소를 열고 이 코드를 넣으세요.';

  @override
  String get bdLoginStepUpload => '공개 키 올리기';

  @override
  String get bdLoginStepUploadWhy =>
      '골라 둔 공개 키를 내 GitHub 계정에 등록합니다. 이미 등록돼 있으면 건너뜁니다.';

  @override
  String get bdLoginUploadKey => '공개 키 올리기';

  @override
  String get bdLoginNeedsKeyScope =>
      '키를 올릴 권한이 없습니다. 터미널에서 아래 명령으로 권한을 더한 뒤 다시 시도하세요.';

  @override
  String get bdLoginStepTest => '연결 확인';

  @override
  String get bdLoginStepTestWhy =>
      'GitHub에 SSH로 접속해 봅니다. 처음이면 github.com 호스트 키를 known_hosts에 더합니다.';

  @override
  String get bdLoginSshFailed =>
      '연결하지 못했습니다. 키가 등록됐는지, ssh-agent에 키가 올라가 있는지 확인하세요.';

  @override
  String get bdLoginTest => '연결 확인';

  @override
  String get bdLoginChecking => '확인하는 중…';

  @override
  String get bdLoginStepProtocol => 'git 프로토콜을 SSH로';

  @override
  String get bdLoginStepProtocolWhy =>
      'gh가 앞으로 만드는 원격 주소를 SSH로 씁니다. 이미 있는 HTTPS 원격은 원격 탭의 URL 바꾸기에서 SSH로 바꿀 수 있습니다.';

  @override
  String get bdLoginUseSshProtocol => 'SSH로 설정';

  @override
  String get bdLoginAgentTip =>
      '암호 문구를 매번 묻지 않게 하려면 macOS는 ssh-add --apple-use-keychain, 그 밖에는 ssh-agent를 쓰세요.';

  @override
  String get bdDoneProtocolSsh => 'gh의 git 프로토콜을 SSH로 바꿨습니다';

  @override
  String bdForkTitle(String parent) {
    return '$parent의 fork입니다';
  }

  @override
  String get bdForkAddWhy => '원본 저장소를 upstream 원격으로 추가하면 원본의 새 커밋을 가져올 수 있습니다.';

  @override
  String get bdForkSyncWhy => '원본(upstream)의 새 커밋을 가져와 현재 브랜치로 병합합니다.';

  @override
  String get bdForkAddUpstream => 'upstream 추가';

  @override
  String get bdForkSync => 'upstream에서 가져오기';

  @override
  String get bdRemotesGhDefault => 'gh가 쓰는 저장소 (PR·릴리스·CI)';

  @override
  String get bdRemotesGhDefaultNone => '정해지지 않음';

  @override
  String bdDoneGhDefault(String repo) {
    return 'gh가 $repo을(를) 쓰도록 정했습니다';
  }

  @override
  String get bdReleaseNeedsRemote => '원격이 없어 릴리스할 수 없습니다. 원격 탭에서 먼저 올리세요.';

  @override
  String bdReleaseNeedsFiles(String files) {
    return '릴리스 워크플로가 쓰는 파일이 없어 릴리스할 수 없습니다: $files. 태그를 달아도 CI가 패키지를 만들지 못합니다.';
  }

  @override
  String get bdReleaseDirectOnlyNotGitHub =>
      'GitHub 저장소가 아니라서 바로 커밋 방식(점검 → 버전 → 태그)으로 진행합니다. PR·릴리스 노트·CI는 호스팅 웹에서 하세요.';

  @override
  String get bdReleaseDirectOnly => 'gh를 쓸 수 없어 바로 커밋 방식만 됩니다.';

  @override
  String get bdReleaseDirectMode => '바로 커밋 방식';

  @override
  String bdReleaseDirectModeWhy(String branch) {
    return 'PR 없이 $branch에 버전 올림을 커밋하고 커밋과 태그를 함께 push합니다. 혼자 쓰는 저장소에서만 쓰세요 — 보호된 브랜치면 push가 거부됩니다.';
  }

  @override
  String bdTagCheckSyncedDirect(String branch) {
    return '$branch에 있고 원격에 내게 없는 커밋이 없다';
  }

  @override
  String get bdVersionUsesScript =>
      '저장소의 scripts/bump-version.sh로 버전을 올립니다 (lock 파일 포함, 규약과 같은 결과).';

  @override
  String bdVersionLockFiles(String files) {
    return '함께 맞출 lock 파일: $files';
  }

  @override
  String get bdVersionFileChoose => '버전 파일 바꾸기';

  @override
  String bdVersionFileCustom(String path) {
    return '버전 파일: $path (직접 지정)';
  }

  @override
  String get bdVersionFileTitle => '버전 파일 지정';

  @override
  String get bdVersionFileWhy =>
      '자동으로 찾지 못하거나 다른 파일을 쓸 때 정합니다. 정규식의 첫 번째 괄호가 버전입니다. 이 저장소에만 적용됩니다.';

  @override
  String get bdVersionFilePath => '파일 (저장소 기준 경로)';

  @override
  String get bdVersionFilePattern => '버전 줄 정규식';

  @override
  String bdVersionFileFound(String version) {
    return '찾았습니다: $version';
  }

  @override
  String get bdVersionFileNotFound => '파일이 없거나 패턴에 맞는 버전이 없습니다';

  @override
  String get bdVersionFileAuto => '자동 감지로 되돌리기';

  @override
  String get bdRollbackTitle => '릴리스 되돌리기';

  @override
  String bdRollbackConfirmTitle(String tag) {
    return '$tag 릴리스를 되돌릴까요?';
  }

  @override
  String bdRollbackMessage(String next) {
    return 'GitHub 릴리스, 원격 태그, 로컬 태그를 지웁니다. 이미 받아 간 사람이 있을 수 있으니 같은 번호를 다시 쓰지 말고 다음 번호($next)로 새로 릴리스하세요.';
  }

  @override
  String bdDoneRollback(String tag) {
    return '$tag을(를) 되돌렸습니다';
  }

  @override
  String get bdDiffBinary => '바이너리 파일이라 내용을 비교할 수 없습니다';

  @override
  String get bdDiffEmpty => '차이가 없습니다';

  @override
  String bdDiffTruncated(int count) {
    return '너무 길어 처음 $count줄만 보여 줍니다. 전체는 편집기에서 보세요.';
  }

  @override
  String bdHeaderCherryPicking(int count) {
    return 'cherry-pick 중 · 충돌 $count';
  }

  @override
  String bdHeaderReverting(int count) {
    return '되돌리는 중 · 충돌 $count';
  }

  @override
  String get bdOperationAbortPickMessage =>
      '시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.';

  @override
  String get bdHistoryBranchLabel => '볼 브랜치';

  @override
  String bdHistoryOtherBranchHint(String head) {
    return '다른 브랜치의 기록입니다. 커밋 메뉴의 \'가져오기\'로 $head에 복사할 수 있습니다.';
  }

  @override
  String get bdHistoryViewChanges => '변경 내용 보기';

  @override
  String bdHistoryFilesChanged(int count) {
    return '바뀐 파일 $count개';
  }

  @override
  String get bdHistoryMergeNote => '병합 커밋 — 병합으로 들어온 변경';

  @override
  String get bdHistoryRevert => '이 커밋 되돌리기 (revert)';

  @override
  String bdHistoryRevertTitle(String hash) {
    return '$hash을(를) 되돌릴까요?';
  }

  @override
  String get bdHistoryRevertMessage =>
      '이 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 기록을 지우지 않으므로 이미 올린 커밋에도 안전합니다.';

  @override
  String get bdHistoryRevertUnpushed =>
      '이 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 아직 올리지 않은 커밋이라면 \'직전 커밋 고치기\'나 새 커밋으로 고쳐도 됩니다.';

  @override
  String get bdHistoryCherryPick => '가져오기';

  @override
  String bdHistoryCherryPickMenu(String head) {
    return '$head(으)로 가져오기 (cherry-pick)';
  }

  @override
  String bdHistoryCherryPickTitle(String hash, String head) {
    return '$hash을(를) $head(으)로 가져올까요?';
  }

  @override
  String get bdHistoryCherryPickMessage =>
      '이 커밋과 같은 변경을 현재 브랜치에 새 커밋으로 복사합니다. 브랜치 전체를 병합하지 않고 필요한 커밋 하나만 가져올 때 씁니다.';

  @override
  String bdDoneRevert(String hash) {
    return '$hash을(를) 되돌리는 커밋을 만들었습니다';
  }

  @override
  String bdDoneCherryPick(String hash) {
    return '$hash을(를) 가져왔습니다';
  }

  @override
  String get bdMenuPalette => '명령 팔레트';

  @override
  String get bdPaletteHint => '무엇을 할까요? (예: push, 브랜치, 태그)';

  @override
  String get bdPaletteEmpty => '맞는 명령이 없습니다';

  @override
  String get bdPaletteGroupActions => '동작';

  @override
  String get bdPaletteGroupTabs => '탭';

  @override
  String get bdPaletteGroupBranches => '브랜치';

  @override
  String get bdPaletteGroupRepos => '저장소';

  @override
  String bdPaletteGoToTab(String name) {
    return '$name 탭으로';
  }

  @override
  String bdPaletteSwitchTo(String branch) {
    return '$branch(으)로 전환';
  }

  @override
  String get bdHelpCaptionAfterRevert => 'C를 지우지 않고, C를 거꾸로 적용한 새 커밋 C⁻를 더함';

  @override
  String get bdHelpCaptionAfterCherryPick =>
      'feature의 D와 같은 변경이 main에 새 커밋 D\'로 복사됨';

  @override
  String get bdHelpRevertTitle => 'Revert (되돌리기)';

  @override
  String get bdHelpRevertWord => 'revert는 \'원래 상태로 되돌리다\'.';

  @override
  String get bdHelpRevertInGit =>
      '커밋을 지우지 않고, 그 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 기록에는 원래 커밋과 되돌린 커밋이 모두 남습니다.';

  @override
  String get bdHelpRevertWhy =>
      '이미 올린 커밋이 문제를 일으켰을 때 씁니다. 기록을 고치지 않아 다른 사람과 어긋나지 않고 강제 push도 필요 없습니다. 아직 올리지 않은 커밋은 amend로 고치는 편이 깔끔합니다.';

  @override
  String get bdHelpCaptionBeforeReset => '전: main이 D를 가리킴';

  @override
  String get bdHelpCaptionAfterReset =>
      '후: main이 B로 옮겨짐. C·D는 사라진 것 같지만 reflog에 남아 있음';

  @override
  String get bdHelpCaptionReflog => 'HEAD가 지나온 자리가 순서대로 적혀 있어, D로 다시 돌아갈 수 있음';

  @override
  String get bdHelpResetTitle => 'Reset (브랜치 옮기기)';

  @override
  String get bdHelpResetWord => 'reset은 \'처음 자리로 되돌려 놓다\'.';

  @override
  String get bdHelpResetInGit =>
      '브랜치가 가리키는 커밋을 뒤로 옮깁니다. 커밋이 지워진 것처럼 보이지만 reflog에 남아 있어 한동안 되살릴 수 있습니다. --soft는 변경을 스테이징한 채 남기고, --keep은 작업 중인 변경을 지키며, --hard는 작업 중인 변경까지 버립니다.';

  @override
  String get bdHelpResetWhy =>
      '아직 올리지 않은 커밋을 취소할 때 씁니다. 이미 올린 커밋에는 쓰지 마세요. 다른 사람의 기록과 어긋나니 revert를 쓰세요. 이 앱은 안전한 --soft와 --keep만 씁니다.';

  @override
  String get bdHelpReflogTitle => 'Reflog (실수 복구 기록)';

  @override
  String get bdHelpReflogWord => 'reflog는 \'reference log\', 가리키던 자리의 기록.';

  @override
  String get bdHelpReflogInGit =>
      'HEAD와 브랜치가 어디를 가리켰는지 이 컴퓨터에만 적어 둔 기록입니다. 커밋을 취소하거나 브랜치를 지워도 보통 90일 동안은 그 시점을 찾아 되돌아갈 수 있습니다.';

  @override
  String get bdHelpReflogWhy =>
      '\'실수했다\' 싶으면 먼저 reflog를 보세요. 이 컴퓨터에만 있는 기록이라 다른 컴퓨터나 원격에서는 볼 수 없고, 오래된 항목은 git이 정리합니다.';

  @override
  String get bdHistoryGraph => '그래프';

  @override
  String get bdHistoryAllBranches => '모든 브랜치';

  @override
  String get bdHelpCaptionGraphMerged =>
      'main과 feature가 갈라졌다가 M에서 합쳐진 기록 (속이 빈 점이 병합 커밋)';

  @override
  String get bdHelpCommitGraphTitle => '커밋 그래프 읽는 법';

  @override
  String get bdHelpCommitGraphWord => 'graph는 \'점과 선으로 그린 그림\'.';

  @override
  String get bdHelpCommitGraphInGit =>
      '점은 커밋, 선은 부모와의 이음입니다. 위가 최신입니다. 선이 둘로 갈라지면 브랜치가 갈라진 곳, 두 선이 하나로 합쳐지면 병합입니다. 속이 빈 점은 병합 커밋, 고리가 둘러진 점은 지금 있는 자리(HEAD)입니다.';

  @override
  String get bdHelpCommitGraphWhy =>
      '\'내 브랜치가 main과 어디서 갈라졌는지\', \'병합이 어디서 일어났는지\'를 한눈에 봅니다. 좁은 창에서는 선을 6줄까지만 그립니다. 그보다 많으면 맨 오른쪽 줄에 겹쳐 보입니다.';

  @override
  String get bdRecoveryTitle => '실수 복구';

  @override
  String get bdRecoveryIntro => '실수했어도 대부분 되돌릴 수 있습니다. 상황에 맞는 것을 고르세요.';

  @override
  String get bdRecoveryUndoCommit => '마지막 커밋 취소';

  @override
  String bdRecoveryUndoCommitWhy(String subject) {
    return '\'$subject\' 커밋만 취소합니다. 바꾼 내용은 스테이징된 채 남습니다.';
  }

  @override
  String bdRecoveryUndoCommitMessage(String subject) {
    return '\'$subject\' 커밋을 취소합니다. 그 커밋에서 바꾼 내용은 지워지지 않고 스테이징된 채 남아, 고쳐서 다시 커밋할 수 있습니다.';
  }

  @override
  String get bdRecoveryUndoCommitPushed =>
      '이 커밋은 이미 원격에 올라가 있습니다. 취소해도 원격에는 남아 있어 다시 올리려면 강제 push가 필요하고, 다른 사람의 기록과 어긋납니다. 올린 커밋은 기록 탭의 \'되돌리기(revert)\'가 더 안전합니다.';

  @override
  String get bdRecoveryUndoCommitConfirm => '커밋 취소';

  @override
  String get bdRecoveryNoParent => '첫 커밋은 취소할 수 없습니다.';

  @override
  String get bdRecoveryStash => '작업 중인 변경을 잠시 치우기';

  @override
  String get bdRecoveryStashWhy => '임시 저장(stash)에 보관했다가 나중에 다시 꺼냅니다.';

  @override
  String get bdRecoveryHistory => '이전 상태로 돌아가기';

  @override
  String get bdRecoveryHistoryHint =>
      'HEAD가 지나온 자리입니다. 커밋을 취소하거나 브랜치를 지운 뒤에도 보통 90일 동안 남아 있습니다.';

  @override
  String get bdRecoveryNow => '지금';

  @override
  String get bdRecoveryEmpty => '아직 기록이 없습니다.';

  @override
  String get bdRecoveryKindCommit => '커밋';

  @override
  String get bdRecoveryKindAmend => '커밋 고침';

  @override
  String get bdRecoveryKindCheckout => '전환';

  @override
  String get bdRecoveryKindReset => '되돌림';

  @override
  String get bdRecoveryKindMerge => '병합';

  @override
  String get bdRecoveryKindPull => 'pull';

  @override
  String get bdRecoveryKindRebase => 'rebase';

  @override
  String get bdRecoveryKindCherryPick => 'cherry-pick';

  @override
  String get bdRecoveryKindRevert => 'revert';

  @override
  String get bdRecoveryKindOther => '기타';

  @override
  String get bdRecoveryGoBack => '여기로 되돌리기';

  @override
  String bdRecoveryGoBackMessage(String branch, String target) {
    return '$branch를 $target 시점으로 되돌립니다. 그 뒤의 커밋은 브랜치에서 빠지지만 reflog에 남아 있습니다. 작업 중인 변경은 그대로 두며, 겹치는 파일이 있으면 아무것도 바꾸지 않고 멈춥니다.';
  }

  @override
  String get bdRecoveryGoBackConfirm => '되돌리기';

  @override
  String get bdRecoveryRescue => '여기서 새 브랜치 만들기';

  @override
  String get bdDoneUndoCommit => '마지막 커밋을 취소했습니다 (변경은 스테이징된 채 남음)';

  @override
  String bdDoneGoBack(String target) {
    return '$target 시점으로 되돌렸습니다';
  }

  @override
  String bdDoneRescue(String name) {
    return '브랜치 $name을 만들었습니다';
  }

  @override
  String get bdHelpCherryPickTitle => 'Cherry-pick (골라 가져오기)';

  @override
  String get bdHelpCherryPickWord =>
      'cherry-pick은 \'체리를 하나씩 골라 따다\' — 좋은 것만 골라 가져오기.';

  @override
  String get bdHelpCherryPickInGit =>
      '다른 브랜치의 커밋 하나와 같은 변경을 현재 브랜치에 새 커밋으로 복사합니다. 내용은 같지만 새 커밋(D\')이라 해시가 다릅니다.';

  @override
  String get bdHelpCherryPickWhy =>
      '다른 브랜치의 버그 수정 하나만 급히 가져올 때 씁니다. 브랜치를 나중에 병합하면 같은 변경이 두 번 들어와 충돌할 수 있으니, 자주 쓰기보다 병합이 기본입니다.';

  @override
  String bdConfirmTypeToContinue(String text) {
    return '되돌릴 수 없습니다. 계속하려면 $text을(를) 그대로 입력하세요.';
  }

  @override
  String bdTagsDeleteRemoteReleaseDraft(String tag) {
    return '⚠️ $tag에는 GitHub 릴리스가 있습니다. 태그를 지우면 GitHub가 그 릴리스를 초안(비공개)으로 바꿉니다 — 파일은 남지만 사람들이 볼 수 없게 됩니다. 릴리스까지 정리하려면 태그 메뉴의 \'릴리스 되돌리기\'를 쓰세요.';
  }

  @override
  String bdTagsPushCiTitle(int count) {
    return '태그 $count개를 push하면 릴리스가 새로 만들어집니다';
  }

  @override
  String bdTagsPushCiMessage(String workflow, String tags) {
    return '이 저장소는 태그를 push하면 $workflow이(가) 태그마다 빌드하고 GitHub 릴리스를 만듭니다: $tags. 일부러 지운 옛 릴리스라면 다시 생깁니다. 로컬에서만 지우려면 태그 메뉴의 \'삭제\'를 쓰세요.';
  }

  @override
  String get bdTagsPushAnyway => '그래도 push';

  @override
  String bdTagsPushMismatchTitle(int count) {
    return '태그 $count개의 버전이 버전 파일과 다릅니다';
  }

  @override
  String bdTagsPushMismatchMessage(String file, String tags) {
    return '태그가 가리키는 커밋의 $file 버전이 태그와 다릅니다 (태그 → 파일의 버전): $tags. 버전을 올리기 전의 커밋에 단 태그일 수 있습니다. 이대로 올리면 태그로 릴리스를 만드는 CI가 버전 검사에서 멈춥니다. 릴리스 마법사로 버전 올림부터 하세요.';
  }

  @override
  String bdCiVersionMismatchMessage(String tag) {
    return 'CI가 $tag 태그와 버전 파일의 버전이 다르다며 멈췄습니다. 태그가 버전 올림 커밋보다 앞선 커밋에 달린 것입니다. 다시 실행해도 같은 결과이니, 버전 올림 커밋이 기본 브랜치에 들어갔는지 확인한 뒤 태그를 지우고 다시 다세요.';
  }

  @override
  String get bdCiRetag => '태그 지우고 다시 달기';

  @override
  String get bdCommonDelete => '삭제';

  @override
  String get bdPrReviewTitle => '리뷰와 코멘트';

  @override
  String bdPrReviewShowAll(int count) {
    return '모두 보기 ($count)';
  }

  @override
  String get bdPrReviewShowLess => '접기';

  @override
  String get bdPrReviewApprove => '승인';

  @override
  String get bdPrReviewRequestChanges => '변경 요청';

  @override
  String get bdPrReviewComment => '코멘트';

  @override
  String get bdPrReviewOwnPr =>
      '내가 만든 PR은 스스로 승인하거나 변경을 요청할 수 없습니다. 코멘트는 남길 수 있습니다.';

  @override
  String get bdPrReviewSend => '보내기';

  @override
  String get bdPrReviewBody => '내용 (Markdown)';

  @override
  String get bdPrReviewBodyOptional => '내용 (선택, Markdown)';

  @override
  String bdDonePrReview(int number) {
    return '#$number에 리뷰를 남겼습니다';
  }

  @override
  String bdAssetTitle(int count) {
    return '첨부 파일 $count개';
  }

  @override
  String get bdAssetEmpty => '첨부 파일이 없습니다. CI가 올린 빌드 결과물이 여기에 보입니다.';

  @override
  String bdAssetMeta(String size, int count) {
    return '$size · 받은 횟수 $count';
  }

  @override
  String get bdAssetUpload => '파일 올리기';

  @override
  String get bdAssetDownload => '받기';

  @override
  String get bdAssetReplace => '덮어쓰기';

  @override
  String get bdAssetReplaceTitle => '같은 이름의 파일을 덮어쓸까요?';

  @override
  String bdAssetReplaceMessage(String names) {
    return '$names — 이미 받아 간 사람이 있다면 내용이 서로 달라집니다. 가능하면 새 버전으로 릴리스하세요.';
  }

  @override
  String bdAssetDeleteTitle(String name) {
    return '$name을(를) 삭제할까요?';
  }

  @override
  String get bdAssetDeleteMessage =>
      '릴리스 페이지에서 이 파일을 지웁니다. 되돌릴 수 없고, 이 파일로 연결된 다운로드 주소도 끊깁니다.';

  @override
  String bdDoneAssetDownloaded(String name) {
    return '$name을(를) 받았습니다';
  }

  @override
  String bdDoneAssetUploaded(int count) {
    return '파일 $count개를 올렸습니다';
  }

  @override
  String bdDoneAssetDeleted(String name) {
    return '$name을(를) 삭제했습니다';
  }

  @override
  String bdSyncUpstreamCounts(String upstream, int ahead, int behind) {
    return '$upstream  ↑$ahead ↓$behind';
  }

  @override
  String bdSyncNoUpstream(String branch) {
    return '$branch에 연결된 원격 브랜치가 없습니다';
  }

  @override
  String bdSyncOnOtherBranch(String branch) {
    return '지금은 $branch에 있습니다';
  }

  @override
  String bdSyncBehind(int count) {
    return '원격에 아직 받지 않은 커밋이 $count개 있습니다. Pull 하세요.';
  }

  @override
  String bdSyncAhead(int count) {
    return 'push하지 않은 커밋이 $count개 있습니다.';
  }

  @override
  String bdSyncAheadPr(int count, String branch) {
    return 'push하지 않은 커밋이 $count개 있습니다. 여기서 Push하면 PR 없이 $branch에 바로 올라갑니다.';
  }

  @override
  String bdSyncDiverged(int behind, int ahead) {
    return '원격과 갈라졌습니다. 받을 커밋 $behind개, 보낼 커밋 $ahead개.';
  }

  @override
  String bdSyncSameContent(int count) {
    return '파일 내용은 원격과 같고 커밋만 다릅니다 (로컬 커밋 $count개). PR을 squash나 rebase로 병합하면 로컬에 옛 커밋이 남아 이렇게 됩니다.';
  }

  @override
  String get bdSyncMatchRemote => '원격에 맞추기';

  @override
  String bdSyncMatchRemoteTitle(String branch) {
    return '$branch를 원격에 맞출까요?';
  }

  @override
  String bdSyncMatchRemoteMessage(int count, String branch, String upstream) {
    return '로컬 커밋 $count개를 버리고 $branch를 $upstream으로 옮깁니다. 파일 내용은 그대로이고 커밋하지 않은 변경도 지킵니다. 버린 커밋은 git reflog로 되찾을 수 있습니다.';
  }

  @override
  String bdDoneMatchRemote(String branch) {
    return '$branch를 원격에 맞췄습니다';
  }

  @override
  String bdSyncPushNoPrTitle(String branch) {
    return 'PR 없이 $branch에 push할까요?';
  }

  @override
  String bdSyncPushNoPrMessage(int count, String branch) {
    return 'push하지 않은 커밋 $count개가 PR을 거치지 않고 $branch에 바로 올라갑니다. 보호된 브랜치면 거부됩니다. 작업 브랜치로 옮겨 PR을 올리는 편이 안전합니다.';
  }

  @override
  String get bdWorktreesTitle => 'Worktree';

  @override
  String get bdWorktreePill => 'worktree';

  @override
  String bdWorktreeHeldTooltip(String path) {
    return '$path에 체크아웃되어 있습니다';
  }

  @override
  String get bdWorktreeDetachedHead => '분리된 HEAD';

  @override
  String get bdWorktreeMainPill => '기본 폴더';

  @override
  String get bdWorktreeOpenPill => '지금 연 폴더';

  @override
  String bdWorktreeChangesPill(int count) {
    return '변경 $count';
  }

  @override
  String get bdWorktreeMissingPill => '폴더 없음';

  @override
  String get bdWorktreeLockedPill => '잠김';

  @override
  String get bdWorktreeOpen => '열기';

  @override
  String get bdWorktreeDetach => '브랜치 풀기';

  @override
  String get bdWorktreeRemove => '지우기';

  @override
  String get bdWorktreeClaudeWarning =>
      'Claude Code 세션이 쓰는 폴더일 수 있습니다. 세션이 끝났는지 먼저 확인하세요.';

  @override
  String bdWorktreeHeldTitle(String branch) {
    return '$branch는 다른 worktree에 있습니다';
  }

  @override
  String bdWorktreeHeldMessage(String path) {
    return 'git은 한 브랜치를 한 worktree에서만 체크아웃하게 합니다. $path에서 이 브랜치를 쓰고 있어 여기서는 전환할 수 없습니다. 그 폴더를 열어 작업하거나, 그 폴더의 브랜치를 풀고(분리된 HEAD) 여기로 전환하세요.';
  }

  @override
  String get bdWorktreeDetachAndSwitch => '풀고 여기로 전환';

  @override
  String bdWorktreeDetachTitle(String name) {
    return '$name의 브랜치를 풀까요?';
  }

  @override
  String bdWorktreeDetachMessage(String path, String branch) {
    return '$path를 $branch에서 분리된 HEAD로 바꿉니다. 파일과 커밋은 그대로이고, $branch를 다른 곳에서 체크아웃하거나 지울 수 있게 됩니다.';
  }

  @override
  String bdWorktreeRemoveTitle(String name) {
    return '$name worktree를 지울까요?';
  }

  @override
  String bdWorktreeRemoveMessage(String path) {
    return '폴더 $path를 지웁니다. 브랜치와 커밋은 저장소에 남습니다.';
  }

  @override
  String get bdWorktreeRemoveForceTitle => '커밋하지 않은 변경까지 지울까요?';

  @override
  String bdWorktreeRemoveForceMessage(String path, int count) {
    return '$path에 커밋하지 않은 변경이 $count개 있습니다. 지우면 되찾을 수 없습니다.';
  }

  @override
  String bdWorktreeLockedMessage(String path) {
    return '$path는 잠겨 있어 지울 수 없습니다. 먼저 git worktree unlock으로 잠금을 푸세요.';
  }

  @override
  String get bdWorktreeDeleteBranchTitle => 'worktree도 지우고 브랜치를 삭제할까요?';

  @override
  String bdWorktreeDeleteBranchMessage(String branch, String path) {
    return '$branch는 $path에 체크아웃되어 있어 그대로는 지울 수 없습니다. 그 worktree 폴더를 먼저 지우고 브랜치를 삭제합니다.';
  }

  @override
  String bdWorktreeDeleteBranchDirty(String branch, String path, int count) {
    return '$branch는 $path에 체크아웃되어 있고, 그 폴더에 커밋하지 않은 변경이 $count개 있습니다. 그 폴더를 열어 정리한 뒤 다시 지우세요.';
  }

  @override
  String get bdWorktreePrune => '사라진 폴더 기록 정리';

  @override
  String bdDoneWorktreeRemoved(String name) {
    return '$name worktree를 지웠습니다';
  }

  @override
  String bdDoneWorktreeDetached(String name) {
    return '$name의 브랜치를 풀었습니다';
  }

  @override
  String get bdDoneWorktreePruned => 'worktree 기록을 정리했습니다';

  @override
  String bdCleanupWorktree(String name) {
    return 'worktree $name도 함께 지웁니다';
  }

  @override
  String bdCleanupWorktreeBlocked(String name) {
    return 'worktree $name에 커밋하지 않은 변경이 있거나 잠겨 있어 지울 수 없습니다';
  }

  @override
  String get bdEnvCustomPath => '직접 지정';

  @override
  String get bdEnvSetPath => '경로 지정';

  @override
  String bdEnvGitTooOld(String min) {
    return 'git $min 이상이 필요합니다. 일부 명령이 실패하거나 결과를 잘못 읽을 수 있습니다.';
  }

  @override
  String bdEnvGhTooOld(String min) {
    return 'gh $min 이상이 필요합니다. 더 낮으면 로그인 확인(gh auth status --json)이 안 돼 로그인했어도 \"로그인 안 됨\"으로 보입니다.';
  }

  @override
  String get bdEnvCopyDiagnostics => '진단 정보 복사';

  @override
  String get bdEnvDiagnosticsCopied => '진단 정보를 복사했습니다. 문제를 알릴 때 붙여 넣으세요.';

  @override
  String get bdEnvSearchPath => '앱이 쓰는 PATH';

  @override
  String bdToolPathTitle(String tool) {
    return '$tool 경로';
  }

  @override
  String bdToolPathWhy(String tool) {
    return 'PATH에서 찾은 $tool 대신 쓸 실행 파일을 고릅니다. 비워 두면 PATH에서 찾습니다.';
  }

  @override
  String get bdToolPathLabel => '실행 파일';

  @override
  String get bdToolPathBrowse => '파일 고르기';

  @override
  String get bdToolPathVerify => '확인';

  @override
  String get bdToolPathUsePath => 'PATH에서 찾기';

  @override
  String bdToolPathOk(String tool, String version) {
    return '$tool $version 확인됨';
  }

  @override
  String bdToolPathBad(String tool) {
    return '실행할 수 없거나 $tool이(가) 아닙니다';
  }

  @override
  String get bdToolPathNeedsCheck => '저장하기 전에 확인을 누르세요';

  @override
  String bdDoneToolPath(String tool) {
    return '$tool 경로를 저장했습니다';
  }

  @override
  String bdDoneToolPathReset(String tool) {
    return '$tool을(를) PATH에서 찾습니다';
  }

  @override
  String get bdUpdateCheckMenuItem => '업데이트 확인';

  @override
  String get bdUpdateChecking => '업데이트를 확인하는 중…';

  @override
  String get bdUpdateAvailableTitle => '새 버전이 있습니다';

  @override
  String bdUpdateAvailableBody(String appName, String current, String latest) {
    return '$appName $latest 버전이 나왔습니다. (현재 $current)';
  }

  @override
  String get bdUpdateReleaseNotes => '변경 내용';

  @override
  String get bdUpdateNow => '지금 업데이트';

  @override
  String get bdUpdateLater => '나중에';

  @override
  String get bdUpdateSkipVersion => '이 버전 건너뛰기';

  @override
  String get bdUpdateDownloading => '내려받는 중…';

  @override
  String get bdUpdateVerifying => '파일을 확인하는 중…';

  @override
  String bdUpdateDownloadProgress(String received, String total) {
    return '$received / $total';
  }

  @override
  String get bdUpdateCancel => '취소';

  @override
  String get bdUpdateFailedTitle => '업데이트하지 못했습니다';

  @override
  String get bdUpdateCheckFailedTitle => '업데이트를 확인하지 못했습니다';

  @override
  String get bdUpdateErrorNetwork =>
      '업데이트 서버에 연결하지 못했습니다. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get bdUpdateErrorChecksum =>
      '내려받은 파일이 올바르지 않아 설치하지 않았습니다. 잠시 뒤에 다시 시도해 주세요.';

  @override
  String get bdUpdateErrorInstall => '설치를 시작하지 못했습니다.';

  @override
  String get bdUpdateErrorGeneric =>
      '업데이트 서버에서 예상하지 못한 응답을 받았습니다. 잠시 뒤에 다시 시도해 주세요.';

  @override
  String get bdUpdateUpToDateTitle => '최신 버전입니다';

  @override
  String bdUpdateUpToDateBody(String version) {
    return '$version 버전을 사용 중입니다.';
  }

  @override
  String get bdUpdateUnavailableTitle => '직접 설치해 주세요';

  @override
  String bdUpdateUnavailableBody(String latest) {
    return '$latest 버전이 있지만 앱에서 자동으로 설치할 수 없습니다. 릴리스 페이지에서 받아 주세요.';
  }

  @override
  String get bdUpdateOpenReleasePage => '릴리스 페이지 열기';

  @override
  String get bdUpdateMacosOpenedTitle => '설치 창이 열렸습니다';

  @override
  String bdUpdateMacosOpenedBody(String appName) {
    return '열린 창에서 $appName 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.';
  }

  @override
  String get bdUpdateWindowsInstallTitle => '설치 프로그램을 열었습니다';

  @override
  String bdUpdateWindowsInstallBody(String appName) {
    return '설치하려면 $appName 을(를) 종료해야 합니다. 설치 프로그램의 안내를 따라 주세요.';
  }

  @override
  String bdUpdateQuitApp(String appName) {
    return '$appName 종료';
  }

  @override
  String get bdUpdateLinuxInstallTitle => '설치를 준비했습니다';

  @override
  String bdUpdateLinuxInstallBody(String appName) {
    return '$appName 을(를) 종료하고 설치합니다. 설치가 끝나면 자동으로 다시 시작됩니다.';
  }

  @override
  String get bdUpdateQuitAndInstall => '종료하고 설치';

  @override
  String get bdDockNoFolder => '열린 프로젝트 폴더가 없습니다';

  @override
  String get runStepsNoDevice =>
      '1. USB 케이블로 폰을 연결합니다 (충전 전용 케이블은 안 됩니다)\n2. 잠금을 풀고, iPhone은 \'이 컴퓨터를 신뢰\', Android는 \'USB 디버깅 허용\'을 누릅니다\n3. 위의 새로 고침을 누릅니다';

  @override
  String get runTargetNone => '대상을 고르지 않았습니다';

  @override
  String get studioDockHide => 'Git 패널 숨기기 (Ctrl+Alt+B)';

  @override
  String get studioDockShow => 'Git 패널 보이기 (Ctrl+Alt+B)';

  @override
  String get menuFile => '파일';

  @override
  String get menuEdit => '편집';

  @override
  String get menuView => '보기';

  @override
  String get menuHelp => '도움말';

  @override
  String get menuOpenProject => '프로젝트 열기…';

  @override
  String get menuRecentProjects => '최근 프로젝트';

  @override
  String get menuNoRecent => '(없음)';

  @override
  String get menuSaveAll => '모두 저장';

  @override
  String get menuCloseTab => '탭 닫기';

  @override
  String get menuQuickOpen => '파일로 이동…';

  @override
  String get menuSettings => '설정…';

  @override
  String get menuExit => '종료';

  @override
  String get menuUndo => '실행 취소';

  @override
  String get menuRedo => '다시 실행';

  @override
  String get menuCut => '잘라내기';

  @override
  String get menuCopy => '복사';

  @override
  String get menuPaste => '붙여넣기';

  @override
  String get menuSelectAll => '전체 선택';

  @override
  String get menuFind => '찾기…';

  @override
  String get menuReplace => '바꾸기…';

  @override
  String get menuFindInProject => '프로젝트에서 찾기…';

  @override
  String get menuFormat => '코드 정렬';

  @override
  String get menuBottomPanel => '아래 패널';

  @override
  String get menuGitDock => 'Git 패널';

  @override
  String get menuZoomIn => '글자 크게';

  @override
  String get menuZoomOut => '글자 작게';

  @override
  String get menuZoomReset => '글자 크기 기본';

  @override
  String get studioDropHint => '여기에 놓으면 엽니다';
}
