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
  String get settingsEditorFontHint => '글꼴 이름 (비우면 기본)';

  @override
  String get settingsEditorFontDefault => '기본';

  @override
  String get settingsEditorFontNote =>
      '이 컴퓨터에 설치된 글꼴만 단추로 보입니다. 다른 글꼴은 이름을 그대로 적으세요.';

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
}
