import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @aboutTooltip.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get aboutTooltip;

  /// No description provided for @aboutVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version} (빌드 {build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutOpenSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get aboutOpenSourceLicenses;

  /// No description provided for @aboutRepository.
  ///
  /// In ko, this message translates to:
  /// **'GitHub'**
  String get aboutRepository;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @aboutMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 정보'**
  String aboutMenuItem(String appName);

  /// No description provided for @themeMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get themeMenuTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageMenuTooltip;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기 / System'**
  String get languageSystem;

  /// No description provided for @languageSystemShort.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get languageSystemShort;

  /// No description provided for @aboutTagline.
  ///
  /// In ko, this message translates to:
  /// **'Flutter 앱을 만드는 통합 작업대'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트 트리·간단 편집기·빌드/설치·PR/병합/릴리스를 한 창에 묶어, 작업 → 로컬 검증 → 병합 → 릴리스 순서를 지키게 합니다.'**
  String get aboutDescription;

  /// No description provided for @runNotFlutterProject.
  ///
  /// In ko, this message translates to:
  /// **'열린 폴더가 Flutter 프로젝트가 아닙니다'**
  String get runNotFlutterProject;

  /// No description provided for @runNoPlatforms.
  ///
  /// In ko, this message translates to:
  /// **'지원 플랫폼 없음'**
  String get runNoPlatforms;

  /// No description provided for @runTarget.
  ///
  /// In ko, this message translates to:
  /// **'대상'**
  String get runTarget;

  /// No description provided for @runRefreshDevices.
  ///
  /// In ko, this message translates to:
  /// **'기기 다시 찾기'**
  String get runRefreshDevices;

  /// No description provided for @runNoDevices.
  ///
  /// In ko, this message translates to:
  /// **'연결된 기기가 없습니다'**
  String get runNoDevices;

  /// No description provided for @runPlatformMacos.
  ///
  /// In ko, this message translates to:
  /// **'macOS 데스크톱'**
  String get runPlatformMacos;

  /// No description provided for @runPlatformWindows.
  ///
  /// In ko, this message translates to:
  /// **'Windows 데스크톱'**
  String get runPlatformWindows;

  /// No description provided for @runLinkWireless.
  ///
  /// In ko, this message translates to:
  /// **'무선'**
  String get runLinkWireless;

  /// No description provided for @runLinkLocal.
  ///
  /// In ko, this message translates to:
  /// **'이 컴퓨터'**
  String get runLinkLocal;

  /// No description provided for @runModeDebug.
  ///
  /// In ko, this message translates to:
  /// **'Debug (flutter run)'**
  String get runModeDebug;

  /// No description provided for @runStart.
  ///
  /// In ko, this message translates to:
  /// **'실행'**
  String get runStart;

  /// No description provided for @runBuildInstall.
  ///
  /// In ko, this message translates to:
  /// **'빌드 & 설치'**
  String get runBuildInstall;

  /// No description provided for @runStop.
  ///
  /// In ko, this message translates to:
  /// **'중지'**
  String get runStop;

  /// No description provided for @runHotReload.
  ///
  /// In ko, this message translates to:
  /// **'r 핫 리로드'**
  String get runHotReload;

  /// No description provided for @runHotRestart.
  ///
  /// In ko, this message translates to:
  /// **'R 핫 리스타트'**
  String get runHotRestart;

  /// No description provided for @runQuit.
  ///
  /// In ko, this message translates to:
  /// **'q 종료'**
  String get runQuit;

  /// No description provided for @runBlockerNoProject.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트를 열어 주세요.'**
  String get runBlockerNoProject;

  /// No description provided for @runBlockerNoDevice.
  ///
  /// In ko, this message translates to:
  /// **'대상을 고르세요.'**
  String get runBlockerNoDevice;

  /// No description provided for @runBlockerPlatformMissing.
  ///
  /// In ko, this message translates to:
  /// **'이 프로젝트는 선택한 플랫폼을 지원하지 않습니다.'**
  String get runBlockerPlatformMissing;

  /// No description provided for @runBlockerIosNeedsMac.
  ///
  /// In ko, this message translates to:
  /// **'iOS 설치는 macOS에서만 할 수 있습니다.'**
  String get runBlockerIosNeedsMac;

  /// No description provided for @runBlockerWireless.
  ///
  /// In ko, this message translates to:
  /// **'무선 연결에서는 설치가 실패합니다. USB로 연결하세요.'**
  String get runBlockerWireless;

  /// No description provided for @runBlockerDeveloperModeOff.
  ///
  /// In ko, this message translates to:
  /// **'iPhone의 개발자 모드가 꺼져 있습니다.'**
  String get runBlockerDeveloperModeOff;

  /// No description provided for @runBlockerAndroidUnauthorized.
  ///
  /// In ko, this message translates to:
  /// **'휴대폰에서 USB 디버깅 승인을 눌러 주세요.'**
  String get runBlockerAndroidUnauthorized;

  /// No description provided for @runBlockerNeedsTeamId.
  ///
  /// In ko, this message translates to:
  /// **'iOS 서명 Team ID가 필요합니다. (프로젝트에 DEVELOPMENT_TEAM이 있어야 합니다)'**
  String get runBlockerNeedsTeamId;

  /// No description provided for @runCommandsToRun.
  ///
  /// In ko, this message translates to:
  /// **'실행될 명령'**
  String get runCommandsToRun;

  /// No description provided for @runCommandNotFound.
  ///
  /// In ko, this message translates to:
  /// **'{command} 명령을 찾을 수 없습니다. PATH를 확인하세요.'**
  String runCommandNotFound(String command);

  /// No description provided for @runHintUseUsb.
  ///
  /// In ko, this message translates to:
  /// **'무선 연결에서는 설치가 끊깁니다. USB로 연결하세요.'**
  String get runHintUseUsb;

  /// No description provided for @runHintUnlockDevice.
  ///
  /// In ko, this message translates to:
  /// **'기기 화면의 잠금을 풀고 다시 시도하세요.'**
  String get runHintUnlockDevice;

  /// No description provided for @runHintDeveloperMode.
  ///
  /// In ko, this message translates to:
  /// **'기기에서 개발자 모드를 켜세요.'**
  String get runHintDeveloperMode;

  /// No description provided for @runHintSigning.
  ///
  /// In ko, this message translates to:
  /// **'서명 설정이 맞지 않습니다. Team ID와 프로비저닝 프로파일을 확인하세요.'**
  String get runHintSigning;

  /// No description provided for @runHintTrustComputer.
  ///
  /// In ko, this message translates to:
  /// **'기기에서 \"이 컴퓨터를 신뢰\"를 눌러 주세요.'**
  String get runHintTrustComputer;

  /// No description provided for @runHintNoAdb.
  ///
  /// In ko, this message translates to:
  /// **'adb를 찾을 수 없습니다. Android SDK platform-tools를 PATH에 추가하세요.'**
  String get runHintNoAdb;

  /// No description provided for @runHintCocoapods.
  ///
  /// In ko, this message translates to:
  /// **'CocoaPods가 필요합니다.'**
  String get runHintCocoapods;

  /// No description provided for @runHintVisualStudio.
  ///
  /// In ko, this message translates to:
  /// **'Visual Studio의 \"C++를 사용한 데스크톱 개발\" 구성 요소가 필요합니다.'**
  String get runHintVisualStudio;

  /// No description provided for @runHintRestartApp.
  ///
  /// In ko, this message translates to:
  /// **'플러그인 링크를 못 찾았습니다. 앱을 다시 연 뒤 한 번 더 시도하세요.'**
  String get runHintRestartApp;

  /// No description provided for @runHintStaleBuildCache.
  ///
  /// In ko, this message translates to:
  /// **'이전 Visual Studio 버전의 빌드 캐시가 남아 있습니다. build 폴더를 지우고 다시 시도하세요.'**
  String get runHintStaleBuildCache;

  /// No description provided for @runVerifyConfirmed.
  ///
  /// In ko, this message translates to:
  /// **'확인함'**
  String get runVerifyConfirmed;

  /// No description provided for @runVerifyBuilt.
  ///
  /// In ko, this message translates to:
  /// **'빌드만 됨 — 아직 눈으로 확인하지 않았습니다'**
  String get runVerifyBuilt;

  /// No description provided for @runVerifyProblem.
  ///
  /// In ko, this message translates to:
  /// **'문제 있음'**
  String get runVerifyProblem;

  /// No description provided for @runVerifyNone.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋은 아직 검증하지 않았습니다'**
  String get runVerifyNone;

  /// No description provided for @runVerifyTitle.
  ///
  /// In ko, this message translates to:
  /// **'검증'**
  String get runVerifyTitle;

  /// No description provided for @runDetachedHead.
  ///
  /// In ko, this message translates to:
  /// **'(분리된 HEAD)'**
  String get runDetachedHead;

  /// No description provided for @runRecordSkippedNotGit.
  ///
  /// In ko, this message translates to:
  /// **'git 저장소가 아니라서 검증 기록을 남기지 않았습니다.'**
  String get runRecordSkippedNotGit;

  /// No description provided for @runRecordSkippedDirty.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 수정이 있어 검증 기록을 남기지 않았습니다. 커밋한 뒤 다시 빌드하세요.'**
  String get runRecordSkippedDirty;

  /// No description provided for @runProblemTitle.
  ///
  /// In ko, this message translates to:
  /// **'어떤 문제가 있나요?'**
  String get runProblemTitle;

  /// No description provided for @runProblemHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 로그인 버튼이 눌리지 않습니다'**
  String get runProblemHint;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @runRecordAndCopy.
  ///
  /// In ko, this message translates to:
  /// **'기록하고 복사'**
  String get runRecordAndCopy;

  /// No description provided for @runNoteCopied.
  ///
  /// In ko, this message translates to:
  /// **'메모를 복사했습니다. Claude 세션에 붙여 넣으세요.'**
  String get runNoteCopied;

  /// No description provided for @runOutput.
  ///
  /// In ko, this message translates to:
  /// **'출력'**
  String get runOutput;

  /// No description provided for @runCopyOutput.
  ///
  /// In ko, this message translates to:
  /// **'출력 복사'**
  String get runCopyOutput;

  /// No description provided for @runNoOutput.
  ///
  /// In ko, this message translates to:
  /// **'(출력 없음)'**
  String get runNoOutput;

  /// No description provided for @commonStop.
  ///
  /// In ko, this message translates to:
  /// **'중지'**
  String get commonStop;

  /// No description provided for @gitNotRepo.
  ///
  /// In ko, this message translates to:
  /// **'열린 폴더가 git 저장소가 아닙니다'**
  String get gitNotRepo;

  /// No description provided for @gitNoGh.
  ///
  /// In ko, this message translates to:
  /// **'GitHub CLI(gh)를 찾을 수 없어 PR 기능을 쓸 수 없습니다.'**
  String get gitNoGh;

  /// No description provided for @gitUpstreamGone.
  ///
  /// In ko, this message translates to:
  /// **'원격에 없음'**
  String get gitUpstreamGone;

  /// No description provided for @gitNoUpstream.
  ///
  /// In ko, this message translates to:
  /// **'추적 브랜치 없음'**
  String get gitNoUpstream;

  /// No description provided for @gitDetachedHead.
  ///
  /// In ko, this message translates to:
  /// **'(분리된 HEAD)'**
  String get gitDetachedHead;

  /// No description provided for @gitRefresh.
  ///
  /// In ko, this message translates to:
  /// **'새로 고침'**
  String get gitRefresh;

  /// No description provided for @gitClean.
  ///
  /// In ko, this message translates to:
  /// **'변경 없음'**
  String get gitClean;

  /// No description provided for @gitChangedFiles.
  ///
  /// In ko, this message translates to:
  /// **'변경된 파일 {count}개'**
  String gitChangedFiles(int count);

  /// No description provided for @gitMoreFiles.
  ///
  /// In ko, this message translates to:
  /// **'… 외 {count}개'**
  String gitMoreFiles(int count);

  /// No description provided for @gitFileDeleted.
  ///
  /// In ko, this message translates to:
  /// **'삭제된 파일'**
  String get gitFileDeleted;

  /// No description provided for @gitFileOpenDiff.
  ///
  /// In ko, this message translates to:
  /// **'눌러서 변경점 보기'**
  String get gitFileOpenDiff;

  /// No description provided for @gitFileOpenConflict.
  ///
  /// In ko, this message translates to:
  /// **'눌러서 충돌 해결'**
  String get gitFileOpenConflict;

  /// No description provided for @gitConflicts.
  ///
  /// In ko, this message translates to:
  /// **'충돌 {count}개 — 파일을 눌러 해결하세요'**
  String gitConflicts(int count);

  /// No description provided for @gitStage.
  ///
  /// In ko, this message translates to:
  /// **'스테이지'**
  String get gitStage;

  /// No description provided for @gitUnstage.
  ///
  /// In ko, this message translates to:
  /// **'스테이지 해제'**
  String get gitUnstage;

  /// No description provided for @gitStageAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 스테이지'**
  String get gitStageAll;

  /// No description provided for @gitUnstageAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 해제'**
  String get gitUnstageAll;

  /// No description provided for @gitDoneStaged.
  ///
  /// In ko, this message translates to:
  /// **'스테이지함'**
  String get gitDoneStaged;

  /// No description provided for @gitDoneUnstaged.
  ///
  /// In ko, this message translates to:
  /// **'스테이지 해제함'**
  String get gitDoneUnstaged;

  /// No description provided for @gitDoneCommit.
  ///
  /// In ko, this message translates to:
  /// **'커밋함'**
  String get gitDoneCommit;

  /// No description provided for @gitCommitMessageHint.
  ///
  /// In ko, this message translates to:
  /// **'커밋 메시지'**
  String get gitCommitMessageHint;

  /// No description provided for @gitCommitAll.
  ///
  /// In ko, this message translates to:
  /// **'커밋'**
  String get gitCommitAll;

  /// No description provided for @gitCommitStaged.
  ///
  /// In ko, this message translates to:
  /// **'커밋 ({count})'**
  String gitCommitStaged(int count);

  /// No description provided for @gitOnDefaultBranch.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치({branch})에서는 PR을 만들 수 없습니다. 새 브랜치에서 작업하세요.'**
  String gitOnDefaultBranch(String branch);

  /// No description provided for @conflictSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 충돌 해결'**
  String conflictSheetTitle(String name);

  /// No description provided for @conflictUnreadable.
  ///
  /// In ko, this message translates to:
  /// **'파일을 읽을 수 없습니다(이진 파일이거나 삭제된 파일일 수 있습니다). 편집기에서 직접 고치세요.'**
  String get conflictUnreadable;

  /// No description provided for @conflictBroken.
  ///
  /// In ko, this message translates to:
  /// **'충돌 표시가 온전하지 않아 앱에서 읽을 수 없습니다. 편집기에서 직접 고쳐 주세요.'**
  String get conflictBroken;

  /// No description provided for @conflictNone.
  ///
  /// In ko, this message translates to:
  /// **'이 파일에는 충돌 표시가 없습니다. 이미 고쳤다면 닫고 상태를 다시 확인하세요.'**
  String get conflictNone;

  /// No description provided for @conflictBlockTitle.
  ///
  /// In ko, this message translates to:
  /// **'충돌 {index}/{total}'**
  String conflictBlockTitle(int index, int total);

  /// No description provided for @conflictSideMine.
  ///
  /// In ko, this message translates to:
  /// **'내 것'**
  String get conflictSideMine;

  /// No description provided for @conflictSideIncoming.
  ///
  /// In ko, this message translates to:
  /// **'들어오는 것'**
  String get conflictSideIncoming;

  /// No description provided for @conflictKeepBoth.
  ///
  /// In ko, this message translates to:
  /// **'둘 다 유지 (위, 아래 순서)'**
  String get conflictKeepBoth;

  /// No description provided for @conflictEmptySide.
  ///
  /// In ko, this message translates to:
  /// **'(비어 있음)'**
  String get conflictEmptySide;

  /// No description provided for @conflictPickHint.
  ///
  /// In ko, this message translates to:
  /// **'구간마다 어느 쪽을 쓸지 골라 주세요. {left}개 남았습니다.'**
  String conflictPickHint(int left);

  /// No description provided for @conflictApply.
  ///
  /// In ko, this message translates to:
  /// **'적용하고 해결됨 표시'**
  String get conflictApply;

  /// No description provided for @conflictApplyNote.
  ///
  /// In ko, this message translates to:
  /// **'고른 대로 파일을 다시 쓰고 git add 합니다. 직접 고쳐 쓰려면 편집기로 여세요.'**
  String get conflictApplyNote;

  /// No description provided for @doneConflictResolved.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 충돌 해결됨'**
  String doneConflictResolved(String name);

  /// No description provided for @gitFetch.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get gitFetch;

  /// No description provided for @gitPull.
  ///
  /// In ko, this message translates to:
  /// **'받기 (↓{behind})'**
  String gitPull(int behind);

  /// No description provided for @gitPush.
  ///
  /// In ko, this message translates to:
  /// **'올리기'**
  String get gitPush;

  /// No description provided for @gitVerified.
  ///
  /// In ko, this message translates to:
  /// **'검증됨'**
  String get gitVerified;

  /// No description provided for @gitBuiltOnly.
  ///
  /// In ko, this message translates to:
  /// **'빌드만 됨 — 눈으로 확인하지 않았습니다'**
  String get gitBuiltOnly;

  /// No description provided for @gitVerifyProblem.
  ///
  /// In ko, this message translates to:
  /// **'확인했더니 문제가 있었습니다'**
  String get gitVerifyProblem;

  /// No description provided for @gitStaleSome.
  ///
  /// In ko, this message translates to:
  /// **'검증한 뒤 커밋이 추가되었습니다'**
  String get gitStaleSome;

  /// No description provided for @gitStaleCount.
  ///
  /// In ko, this message translates to:
  /// **'검증한 뒤 커밋 {count}개가 추가되었습니다'**
  String gitStaleCount(int count);

  /// No description provided for @gitUnverified.
  ///
  /// In ko, this message translates to:
  /// **'검증하지 않은 커밋입니다'**
  String get gitUnverified;

  /// No description provided for @gitHeadDiffers.
  ///
  /// In ko, this message translates to:
  /// **'로컬 HEAD와 PR head가 다릅니다. 판정은 PR head 기준입니다.'**
  String get gitHeadDiffers;

  /// No description provided for @gitBuildInRunTab.
  ///
  /// In ko, this message translates to:
  /// **'병합하기 전에 Run 탭에서 이 커밋을 빌드해 확인하세요.'**
  String get gitBuildInRunTab;

  /// No description provided for @gitNoPr.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치의 PR이 없습니다.'**
  String get gitNoPr;

  /// No description provided for @gitPrTitle.
  ///
  /// In ko, this message translates to:
  /// **'PR 제목'**
  String get gitPrTitle;

  /// No description provided for @gitPushFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 브랜치를 올려야 PR을 만들 수 있습니다.'**
  String get gitPushFirst;

  /// No description provided for @gitCreatePr.
  ///
  /// In ko, this message translates to:
  /// **'PR 만들기'**
  String get gitCreatePr;

  /// No description provided for @gitMergeBlocked.
  ///
  /// In ko, this message translates to:
  /// **'PR 병합 (검증 필요)'**
  String get gitMergeBlocked;

  /// No description provided for @gitMergeConfirm.
  ///
  /// In ko, this message translates to:
  /// **'PR 병합…'**
  String get gitMergeConfirm;

  /// No description provided for @gitMerge.
  ///
  /// In ko, this message translates to:
  /// **'PR 병합'**
  String get gitMerge;

  /// No description provided for @gitMergeUnverified.
  ///
  /// In ko, this message translates to:
  /// **'검증 없이 병합…'**
  String get gitMergeUnverified;

  /// No description provided for @gitUnverifiedDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'확인하지 않은 커밋입니다'**
  String get gitUnverifiedDialogTitle;

  /// No description provided for @gitUnverifiedDialogBody.
  ///
  /// In ko, this message translates to:
  /// **'그래도 병합하면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나오면 고쳐서 릴리스를 다시 해야 합니다.'**
  String get gitUnverifiedDialogBody;

  /// No description provided for @gitMergeAnyway.
  ///
  /// In ko, this message translates to:
  /// **'그래도 병합'**
  String get gitMergeAnyway;

  /// No description provided for @gitPrDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안(draft) PR입니다.'**
  String get gitPrDraft;

  /// No description provided for @gitPrConflict.
  ///
  /// In ko, this message translates to:
  /// **'충돌이 있습니다.'**
  String get gitPrConflict;

  /// No description provided for @gitPrChecksFailed.
  ///
  /// In ko, this message translates to:
  /// **'실패한 검사: {names}'**
  String gitPrChecksFailed(String names);

  /// No description provided for @gitPrChecksPending.
  ///
  /// In ko, this message translates to:
  /// **'검사 {count}개가 진행 중입니다.'**
  String gitPrChecksPending(int count);

  /// No description provided for @gitPrReviewRequired.
  ///
  /// In ko, this message translates to:
  /// **'리뷰가 필요합니다.'**
  String get gitPrReviewRequired;

  /// No description provided for @gitPrMerged.
  ///
  /// In ko, this message translates to:
  /// **'병합됨'**
  String get gitPrMerged;

  /// No description provided for @gitPrOpen.
  ///
  /// In ko, this message translates to:
  /// **'열림'**
  String get gitPrOpen;

  /// No description provided for @gitPrChecks.
  ///
  /// In ko, this message translates to:
  /// **'검사 통과 {passed} · 실패 {failed} · 진행 {pending}'**
  String gitPrChecks(int passed, int failed, int pending);

  /// No description provided for @gitMergeMethod.
  ///
  /// In ko, this message translates to:
  /// **'병합 방식'**
  String get gitMergeMethod;

  /// No description provided for @gitMergeCommit.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋'**
  String get gitMergeCommit;

  /// No description provided for @gitDeleteBranchAfter.
  ///
  /// In ko, this message translates to:
  /// **'병합 후 브랜치 삭제'**
  String get gitDeleteBranchAfter;

  /// No description provided for @studioOpenProject.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트 열기'**
  String get studioOpenProject;

  /// No description provided for @studioOpenProjectFolder.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트 폴더 열기'**
  String get studioOpenProjectFolder;

  /// No description provided for @studioSettingsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'설정 (Ctrl+,)'**
  String get studioSettingsTooltip;

  /// No description provided for @studioProblemsTab.
  ///
  /// In ko, this message translates to:
  /// **'문제'**
  String get studioProblemsTab;

  /// No description provided for @studioTerminalTab.
  ///
  /// In ko, this message translates to:
  /// **'터미널'**
  String get studioTerminalTab;

  /// No description provided for @terminalNew.
  ///
  /// In ko, this message translates to:
  /// **'새 터미널'**
  String get terminalNew;

  /// No description provided for @terminalCloseTooltip.
  ///
  /// In ko, this message translates to:
  /// **'터미널 닫기'**
  String get terminalCloseTooltip;

  /// No description provided for @terminalEmpty.
  ///
  /// In ko, this message translates to:
  /// **'열린 터미널이 없습니다'**
  String get terminalEmpty;

  /// No description provided for @terminalEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'+ 를 눌러 새 터미널을 엽니다'**
  String get terminalEmptyHint;

  /// No description provided for @terminalLoadingShells.
  ///
  /// In ko, this message translates to:
  /// **'셸을 찾는 중…'**
  String get terminalLoadingShells;

  /// No description provided for @terminalNoShells.
  ///
  /// In ko, this message translates to:
  /// **'쓸 수 있는 셸을 찾지 못했습니다'**
  String get terminalNoShells;

  /// No description provided for @terminalExited.
  ///
  /// In ko, this message translates to:
  /// **'{shell} 종료됨 (코드 {code})'**
  String terminalExited(String shell, int code);

  /// No description provided for @terminalRestart.
  ///
  /// In ko, this message translates to:
  /// **'다시 시작'**
  String get terminalRestart;

  /// No description provided for @terminalStartError.
  ///
  /// In ko, this message translates to:
  /// **'셸을 시작하지 못했습니다: {error}'**
  String terminalStartError(String error);

  /// No description provided for @gitTabChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get gitTabChanges;

  /// No description provided for @studioBottomPanelHide.
  ///
  /// In ko, this message translates to:
  /// **'아래 패널 접기 (Ctrl+J)'**
  String get studioBottomPanelHide;

  /// No description provided for @studioBottomPanelShow.
  ///
  /// In ko, this message translates to:
  /// **'아래 패널 펼치기 (Ctrl+J)'**
  String get studioBottomPanelShow;

  /// No description provided for @studioShowProblems.
  ///
  /// In ko, this message translates to:
  /// **'문제 탭 열기'**
  String get studioShowProblems;

  /// No description provided for @studioVerifyConfirmed.
  ///
  /// In ko, this message translates to:
  /// **'검증됨'**
  String get studioVerifyConfirmed;

  /// No description provided for @studioVerifyBuilt.
  ///
  /// In ko, this message translates to:
  /// **'빌드만 됨'**
  String get studioVerifyBuilt;

  /// No description provided for @studioVerifyProblem.
  ///
  /// In ko, this message translates to:
  /// **'문제 있음'**
  String get studioVerifyProblem;

  /// No description provided for @studioVerifyNone.
  ///
  /// In ko, this message translates to:
  /// **'미검증'**
  String get studioVerifyNone;

  /// No description provided for @studioNotRepo.
  ///
  /// In ko, this message translates to:
  /// **'저장소 아님'**
  String get studioNotRepo;

  /// No description provided for @studioAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'분석 중…'**
  String get studioAnalyzing;

  /// No description provided for @studioDirty.
  ///
  /// In ko, this message translates to:
  /// **'수정됨 (Ctrl+S 저장)'**
  String get studioDirty;

  /// No description provided for @studioSaved.
  ///
  /// In ko, this message translates to:
  /// **'저장됨'**
  String get studioSaved;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In ko, this message translates to:
  /// **'외형'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionEditor.
  ///
  /// In ko, this message translates to:
  /// **'편집기'**
  String get settingsSectionEditor;

  /// No description provided for @settingsSectionGate.
  ///
  /// In ko, this message translates to:
  /// **'병합 관문'**
  String get settingsSectionGate;

  /// No description provided for @settingsPaletteSaturn.
  ///
  /// In ko, this message translates to:
  /// **'새턴'**
  String get settingsPaletteSaturn;

  /// No description provided for @settingsPaletteTeal.
  ///
  /// In ko, this message translates to:
  /// **'청록'**
  String get settingsPaletteTeal;

  /// No description provided for @settingsPaletteAmber.
  ///
  /// In ko, this message translates to:
  /// **'호박'**
  String get settingsPaletteAmber;

  /// No description provided for @settingsPaletteRose.
  ///
  /// In ko, this message translates to:
  /// **'장미'**
  String get settingsPaletteRose;

  /// No description provided for @settingsPaletteSlate.
  ///
  /// In ko, this message translates to:
  /// **'슬레이트'**
  String get settingsPaletteSlate;

  /// No description provided for @settingsPaletteHighContrast.
  ///
  /// In ko, this message translates to:
  /// **'고대비'**
  String get settingsPaletteHighContrast;

  /// No description provided for @settingsBrightness.
  ///
  /// In ko, this message translates to:
  /// **'밝기'**
  String get settingsBrightness;

  /// No description provided for @settingsBrightnessSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get settingsBrightnessSystem;

  /// No description provided for @settingsPalette.
  ///
  /// In ko, this message translates to:
  /// **'색 구성'**
  String get settingsPalette;

  /// No description provided for @settingsAppliedNote.
  ///
  /// In ko, this message translates to:
  /// **'바꾼 값은 바로 적용되고 다음 실행에도 유지됩니다.'**
  String get settingsAppliedNote;

  /// No description provided for @settingsGateHeading.
  ///
  /// In ko, this message translates to:
  /// **'PR 병합 전 검증'**
  String get settingsGateHeading;

  /// No description provided for @settingsGateIntro.
  ///
  /// In ko, this message translates to:
  /// **'빌드해서 눈으로 확인한 커밋만 병합하게 합니다. 확인하지 않고 병합하면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나오면 고쳐서 릴리스를 다시 해야 합니다.'**
  String get settingsGateIntro;

  /// No description provided for @settingsGateConfirmNote.
  ///
  /// In ko, this message translates to:
  /// **'\"확인함\"은 Run 탭에서 앱을 실행해 본 뒤 직접 누르는 단추입니다. 빌드만 성공한 것은 확인으로 치지 않습니다.'**
  String get settingsGateConfirmNote;

  /// No description provided for @settingsEditorUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'편집기 설정을 불러올 수 없습니다.'**
  String get settingsEditorUnavailable;

  /// No description provided for @settingsFontSize.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기'**
  String get settingsFontSize;

  /// No description provided for @settingsResetZoom.
  ///
  /// In ko, this message translates to:
  /// **'100%로'**
  String get settingsResetZoom;

  /// No description provided for @settingsZoomNote.
  ///
  /// In ko, this message translates to:
  /// **'편집기와 Markdown 보기, 변경점 보기에만 적용됩니다. 편집기에서는 Ctrl+스크롤이나 Ctrl +/-/0으로도 바꿀 수 있습니다.'**
  String get settingsZoomNote;

  /// No description provided for @gateModeBlock.
  ///
  /// In ko, this message translates to:
  /// **'차단'**
  String get gateModeBlock;

  /// No description provided for @gateModeBlockHelp.
  ///
  /// In ko, this message translates to:
  /// **'확인한 커밋만 병합합니다. 예외가 필요하면 \"검증 없이 병합\"을 따로 눌러야 합니다.'**
  String get gateModeBlockHelp;

  /// No description provided for @gateModeWarn.
  ///
  /// In ko, this message translates to:
  /// **'경고만'**
  String get gateModeWarn;

  /// No description provided for @gateModeWarnHelp.
  ///
  /// In ko, this message translates to:
  /// **'확인하지 않은 커밋을 병합하려 하면 한 번 더 묻습니다.'**
  String get gateModeWarnHelp;

  /// No description provided for @gateModeOff.
  ///
  /// In ko, this message translates to:
  /// **'끔'**
  String get gateModeOff;

  /// No description provided for @gateModeOffHelp.
  ///
  /// In ko, this message translates to:
  /// **'확인 여부와 상관없이 병합할 수 있습니다.'**
  String get gateModeOffHelp;

  /// No description provided for @gateVerified.
  ///
  /// In ko, this message translates to:
  /// **'검증됨 — 병합할 수 있습니다'**
  String get gateVerified;

  /// No description provided for @gateBuiltOnly.
  ///
  /// In ko, this message translates to:
  /// **'빌드만 하고 눈으로 확인하지 않았습니다. 실행해 본 뒤 Run 탭에서 \"확인함\"을 눌러 주세요.'**
  String get gateBuiltOnly;

  /// No description provided for @gateProblem.
  ///
  /// In ko, this message translates to:
  /// **'확인했더니 문제가 있다고 기록된 커밋입니다.'**
  String get gateProblem;

  /// No description provided for @gateProblemNote.
  ///
  /// In ko, this message translates to:
  /// **'확인했더니 문제가 있다고 기록된 커밋입니다: {note}'**
  String gateProblemNote(String note);

  /// No description provided for @gateStaleSome.
  ///
  /// In ko, this message translates to:
  /// **'검증한 뒤 커밋이 추가되었습니다. 다시 빌드해 확인하세요.'**
  String get gateStaleSome;

  /// No description provided for @gateStaleCount.
  ///
  /// In ko, this message translates to:
  /// **'검증한 뒤 커밋 {count}개가 추가되었습니다. 다시 빌드해 확인하세요.'**
  String gateStaleCount(int count);

  /// No description provided for @gateUnverified.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋은 로컬에서 확인하지 않았습니다. Run 탭에서 빌드해 눈으로 확인하세요.'**
  String get gateUnverified;

  /// No description provided for @editorOpenFromTree.
  ///
  /// In ko, this message translates to:
  /// **'왼쪽 트리에서 파일을 여세요'**
  String get editorOpenFromTree;

  /// No description provided for @editorFileGone.
  ///
  /// In ko, this message translates to:
  /// **'이 파일이 디스크에서 사라졌습니다.'**
  String get editorFileGone;

  /// No description provided for @editorFileChanged.
  ///
  /// In ko, this message translates to:
  /// **'디스크의 파일이 바뀌었습니다. 저장하면 그쪽 수정을 덮어씁니다.'**
  String get editorFileChanged;

  /// No description provided for @editorCloseTab.
  ///
  /// In ko, this message translates to:
  /// **'탭 닫기'**
  String get editorCloseTab;

  /// No description provided for @editorLeaveAsIs.
  ///
  /// In ko, this message translates to:
  /// **'그대로 두기'**
  String get editorLeaveAsIs;

  /// No description provided for @editorReloadDiscard.
  ///
  /// In ko, this message translates to:
  /// **'다시 읽기 (내 수정 버림)'**
  String get editorReloadDiscard;

  /// No description provided for @editorKeepMine.
  ///
  /// In ko, this message translates to:
  /// **'내 수정 유지'**
  String get editorKeepMine;

  /// No description provided for @editorZoomHint.
  ///
  /// In ko, this message translates to:
  /// **'Ctrl+스크롤 또는 Ctrl +/- 로 글자 크기 조절 · 클릭하면 100%'**
  String get editorZoomHint;

  /// No description provided for @editorFoldAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 접기'**
  String get editorFoldAll;

  /// No description provided for @editorUnfoldAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 펴기'**
  String get editorUnfoldAll;

  /// No description provided for @editorBackToEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집으로 돌아가기'**
  String get editorBackToEdit;

  /// No description provided for @editorDiffSame.
  ///
  /// In ko, this message translates to:
  /// **'변경점 보기 (HEAD와 같음)'**
  String get editorDiffSame;

  /// No description provided for @editorDiffChanged.
  ///
  /// In ko, this message translates to:
  /// **'변경점 보기 (HEAD와 비교)'**
  String get editorDiffChanged;

  /// No description provided for @editorEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get editorEdit;

  /// No description provided for @editorPreview.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get editorPreview;

  /// No description provided for @editorSavePromptTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 저장할까요?'**
  String editorSavePromptTitle(String name);

  /// No description provided for @editorSavePromptBody.
  ///
  /// In ko, this message translates to:
  /// **'저장하지 않은 수정이 있습니다.'**
  String get editorSavePromptBody;

  /// No description provided for @editorDontSave.
  ///
  /// In ko, this message translates to:
  /// **'저장 안 함'**
  String get editorDontSave;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @treeExplorer.
  ///
  /// In ko, this message translates to:
  /// **'탐색기'**
  String get treeExplorer;

  /// No description provided for @treeRefresh.
  ///
  /// In ko, this message translates to:
  /// **'트리 새로 고침'**
  String get treeRefresh;

  /// No description provided for @problemsNoPackage.
  ///
  /// In ko, this message translates to:
  /// **'열린 폴더에서 Dart 패키지(pubspec.yaml)를 찾지 못했습니다'**
  String get problemsNoPackage;

  /// No description provided for @problemsError.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get problemsError;

  /// No description provided for @problemsWarning.
  ///
  /// In ko, this message translates to:
  /// **'경고'**
  String get problemsWarning;

  /// No description provided for @problemsInfo.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get problemsInfo;

  /// No description provided for @problemsReanalyze.
  ///
  /// In ko, this message translates to:
  /// **'다시 분석'**
  String get problemsReanalyze;

  /// No description provided for @problemsNoPackageInfo.
  ///
  /// In ko, this message translates to:
  /// **'패키지 정보(.dart_tool)가 없어서 import 오류가 가짜로 섞입니다.'**
  String get problemsNoPackageInfo;

  /// No description provided for @problemsAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'분석하는 중…'**
  String get problemsAnalyzing;

  /// No description provided for @problemsNotAnalyzed.
  ///
  /// In ko, this message translates to:
  /// **'아직 분석하지 않았습니다'**
  String get problemsNotAnalyzed;

  /// No description provided for @problemsFilteredOut.
  ///
  /// In ko, this message translates to:
  /// **'선택한 종류의 문제가 없습니다'**
  String get problemsFilteredOut;

  /// No description provided for @problemsUnknown.
  ///
  /// In ko, this message translates to:
  /// **'분석하지 못해서 문제 여부를 알 수 없습니다'**
  String get problemsUnknown;

  /// No description provided for @problemsNone.
  ///
  /// In ko, this message translates to:
  /// **'문제가 없습니다'**
  String get problemsNone;

  /// No description provided for @diffNotComparable.
  ///
  /// In ko, this message translates to:
  /// **'이 파일은 git으로 비교할 수 없습니다.\n(git 저장소가 아니거나 .gitignore로 무시되는 파일입니다)'**
  String get diffNotComparable;

  /// No description provided for @diffAgainstHead.
  ///
  /// In ko, this message translates to:
  /// **'HEAD와 비교'**
  String get diffAgainstHead;

  /// No description provided for @diffNewFile.
  ///
  /// In ko, this message translates to:
  /// **'새 파일 (아직 커밋되지 않음)'**
  String get diffNewFile;

  /// No description provided for @diffSameAsHead.
  ///
  /// In ko, this message translates to:
  /// **'HEAD와 같습니다. 변경된 곳이 없습니다.'**
  String get diffSameAsHead;

  /// No description provided for @diffHiddenLines.
  ///
  /// In ko, this message translates to:
  /// **'같은 줄 {count}개 — 눌러서 펼치기'**
  String diffHiddenLines(int count);

  /// No description provided for @markdownImageUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'(이미지를 불러올 수 없습니다)'**
  String get markdownImageUnavailable;

  /// No description provided for @markdownImage.
  ///
  /// In ko, this message translates to:
  /// **'(이미지: {alt})'**
  String markdownImage(String alt);

  /// No description provided for @languagePlain.
  ///
  /// In ko, this message translates to:
  /// **'텍스트'**
  String get languagePlain;

  /// No description provided for @messageFolderUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'폴더를 열 수 없습니다: {path}'**
  String messageFolderUnavailable(String path);

  /// No description provided for @messageFileTooLarge.
  ///
  /// In ko, this message translates to:
  /// **'2MB보다 큰 파일은 열지 않습니다: {name}'**
  String messageFileTooLarge(String name);

  /// No description provided for @messageNotUtf8Open.
  ///
  /// In ko, this message translates to:
  /// **'글자 파일(UTF-8)이 아니라서 열 수 없습니다: {name}'**
  String messageNotUtf8Open(String name);

  /// No description provided for @messageReadFailed.
  ///
  /// In ko, this message translates to:
  /// **'파일을 읽지 못했습니다: {error}'**
  String messageReadFailed(String error);

  /// No description provided for @messageDiskChangedSaveBlocked.
  ///
  /// In ko, this message translates to:
  /// **'디스크의 파일이 바뀌었습니다. 저장하기 전에 \"다시 읽기\"나 \"내 수정 유지\"를 먼저 고르세요.'**
  String get messageDiskChangedSaveBlocked;

  /// No description provided for @messageSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장하지 못했습니다: {error}'**
  String messageSaveFailed(String error);

  /// No description provided for @messageChangedNotUtf8.
  ///
  /// In ko, this message translates to:
  /// **'{name}이(가) 디스크에서 바뀌었지만 글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.'**
  String messageChangedNotUtf8(String name);

  /// No description provided for @messageChangedReloaded.
  ///
  /// In ko, this message translates to:
  /// **'{name}이(가) 디스크에서 바뀌어 다시 읽었습니다.'**
  String messageChangedReloaded(String name);

  /// No description provided for @messageReloadedFromDisk.
  ///
  /// In ko, this message translates to:
  /// **'{name}을(를) 디스크 내용으로 다시 읽었습니다.'**
  String messageReloadedFromDisk(String name);

  /// No description provided for @messageNotUtf8Reload.
  ///
  /// In ko, this message translates to:
  /// **'글자 파일(UTF-8)이 아니라서 다시 읽지 못했습니다.'**
  String get messageNotUtf8Reload;

  /// No description provided for @messageAlreadyFormatted.
  ///
  /// In ko, this message translates to:
  /// **'이미 정렬되어 있습니다'**
  String get messageAlreadyFormatted;

  /// No description provided for @messageFormatted.
  ///
  /// In ko, this message translates to:
  /// **'정렬했습니다'**
  String get messageFormatted;

  /// No description provided for @formatNoDart.
  ///
  /// In ko, this message translates to:
  /// **'dart 명령을 찾을 수 없습니다. Flutter SDK의 bin 폴더가 PATH에 있는지 확인하세요.'**
  String get formatNoDart;

  /// No description provided for @formatTempWriteFailed.
  ///
  /// In ko, this message translates to:
  /// **'임시 파일을 쓰지 못했습니다: {error}'**
  String formatTempWriteFailed(String error);

  /// No description provided for @formatCurrentFile.
  ///
  /// In ko, this message translates to:
  /// **'(현재 파일)'**
  String get formatCurrentFile;

  /// No description provided for @formatFailed.
  ///
  /// In ko, this message translates to:
  /// **'정렬하지 못했습니다.'**
  String get formatFailed;

  /// No description provided for @formatFailedDetail.
  ///
  /// In ko, this message translates to:
  /// **'정렬하지 못했습니다: {detail}'**
  String formatFailedDetail(String detail);

  /// No description provided for @analyzeFailedRead.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과를 읽지 못했습니다.'**
  String get analyzeFailedRead;

  /// No description provided for @analyzeFailedDetail.
  ///
  /// In ko, this message translates to:
  /// **'분석하지 못했습니다: {detail}'**
  String analyzeFailedDetail(String detail);

  /// No description provided for @problemsPubGetFailed.
  ///
  /// In ko, this message translates to:
  /// **'flutter pub get이 실패했습니다. 출력은 아래 명령 기록에서 확인하세요.'**
  String get problemsPubGetFailed;

  /// No description provided for @gitDoneFetch.
  ///
  /// In ko, this message translates to:
  /// **'가져왔습니다'**
  String get gitDoneFetch;

  /// No description provided for @gitDonePull.
  ///
  /// In ko, this message translates to:
  /// **'받았습니다'**
  String get gitDonePull;

  /// No description provided for @gitDonePush.
  ///
  /// In ko, this message translates to:
  /// **'올렸습니다'**
  String get gitDonePush;

  /// No description provided for @gitDonePrCreated.
  ///
  /// In ko, this message translates to:
  /// **'PR을 만들었습니다'**
  String get gitDonePrCreated;

  /// No description provided for @gitNotMerged.
  ///
  /// In ko, this message translates to:
  /// **'병합하지 않았습니다: {reason}'**
  String gitNotMerged(String reason);

  /// No description provided for @gitDoneMergedUnverified.
  ///
  /// In ko, this message translates to:
  /// **'#{number}을 검증 없이 병합했습니다'**
  String gitDoneMergedUnverified(int number);

  /// No description provided for @gitDoneMerged.
  ///
  /// In ko, this message translates to:
  /// **'#{number}을 병합했습니다'**
  String gitDoneMerged(int number);

  /// No description provided for @gitCommandNotFound.
  ///
  /// In ko, this message translates to:
  /// **'명령을 찾을 수 없습니다. git과 GitHub CLI(gh)가 설치되어 PATH에 있는지 확인하세요.'**
  String get gitCommandNotFound;

  /// No description provided for @gitFailedExit.
  ///
  /// In ko, this message translates to:
  /// **'실패했습니다 (종료 코드 {code})'**
  String gitFailedExit(int code);

  /// No description provided for @findHint.
  ///
  /// In ko, this message translates to:
  /// **'찾기'**
  String get findHint;

  /// No description provided for @findReplaceHint.
  ///
  /// In ko, this message translates to:
  /// **'바꿀 내용'**
  String get findReplaceHint;

  /// No description provided for @findNoResults.
  ///
  /// In ko, this message translates to:
  /// **'결과 없음'**
  String get findNoResults;

  /// No description provided for @findCount.
  ///
  /// In ko, this message translates to:
  /// **'{current}/{total}'**
  String findCount(int current, int total);

  /// No description provided for @findMatchCase.
  ///
  /// In ko, this message translates to:
  /// **'대소문자 구분'**
  String get findMatchCase;

  /// No description provided for @findRegex.
  ///
  /// In ko, this message translates to:
  /// **'정규식'**
  String get findRegex;

  /// No description provided for @findPrevious.
  ///
  /// In ko, this message translates to:
  /// **'이전 (Shift+Enter)'**
  String get findPrevious;

  /// No description provided for @findNext.
  ///
  /// In ko, this message translates to:
  /// **'다음 (Enter)'**
  String get findNext;

  /// No description provided for @findClose.
  ///
  /// In ko, this message translates to:
  /// **'찾기 닫기 (Esc)'**
  String get findClose;

  /// No description provided for @findToggleReplace.
  ///
  /// In ko, this message translates to:
  /// **'바꾸기 보기/숨기기'**
  String get findToggleReplace;

  /// No description provided for @findReplaceOne.
  ///
  /// In ko, this message translates to:
  /// **'바꾸기'**
  String get findReplaceOne;

  /// No description provided for @findReplaceAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 바꾸기'**
  String get findReplaceAll;

  /// No description provided for @quickOpenHint.
  ///
  /// In ko, this message translates to:
  /// **'파일 이름으로 열기 (Ctrl+P)'**
  String get quickOpenHint;

  /// No description provided for @quickOpenNoMatch.
  ///
  /// In ko, this message translates to:
  /// **'맞는 파일이 없습니다'**
  String get quickOpenNoMatch;

  /// No description provided for @quickOpenLoading.
  ///
  /// In ko, this message translates to:
  /// **'파일 목록을 읽는 중…'**
  String get quickOpenLoading;

  /// No description provided for @searchTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트에서 찾기'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In ko, this message translates to:
  /// **'찾을 글 (Enter로 검색)'**
  String get searchHint;

  /// No description provided for @searchSearching.
  ///
  /// In ko, this message translates to:
  /// **'찾는 중…'**
  String get searchSearching;

  /// No description provided for @searchNoResults.
  ///
  /// In ko, this message translates to:
  /// **'결과가 없습니다'**
  String get searchNoResults;

  /// No description provided for @searchResultCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}곳'**
  String searchResultCount(int count);

  /// No description provided for @searchTruncated.
  ///
  /// In ko, this message translates to:
  /// **'{count}곳에서 멈췄습니다. 더 좁혀서 찾아 보세요.'**
  String searchTruncated(int count);

  /// No description provided for @searchInvalidPattern.
  ///
  /// In ko, this message translates to:
  /// **'정규식이 올바르지 않습니다'**
  String get searchInvalidPattern;

  /// No description provided for @studioQuickOpenTooltip.
  ///
  /// In ko, this message translates to:
  /// **'파일 열기 (Ctrl+P)'**
  String get studioQuickOpenTooltip;

  /// No description provided for @studioSearchTooltip.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트에서 찾기 (Ctrl+Shift+F)'**
  String get studioSearchTooltip;

  /// No description provided for @editorFormat.
  ///
  /// In ko, this message translates to:
  /// **'정렬 (Ctrl+Alt+L)'**
  String get editorFormat;

  /// No description provided for @formatJsonInvalid.
  ///
  /// In ko, this message translates to:
  /// **'JSON 문법 오류라 정렬하지 못했습니다: {detail}'**
  String formatJsonInvalid(String detail);

  /// No description provided for @settingsFormatOnSave.
  ///
  /// In ko, this message translates to:
  /// **'저장할 때 자동 정렬'**
  String get settingsFormatOnSave;

  /// No description provided for @settingsFormatOnSaveNote.
  ///
  /// In ko, this message translates to:
  /// **'Dart, JSON, ARB 파일을 저장하기 직전에 정렬합니다. 문법 오류가 있어 정렬하지 못해도 저장은 그대로 됩니다.'**
  String get settingsFormatOnSaveNote;

  /// No description provided for @settingsEditorFont.
  ///
  /// In ko, this message translates to:
  /// **'편집기 글꼴'**
  String get settingsEditorFont;

  /// No description provided for @settingsEditorFontHint.
  ///
  /// In ko, this message translates to:
  /// **'글꼴 검색'**
  String get settingsEditorFontHint;

  /// No description provided for @settingsEditorFontDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get settingsEditorFontDefault;

  /// No description provided for @settingsEditorFontNote.
  ///
  /// In ko, this message translates to:
  /// **'입력해서 걸러 찾을 수 있습니다. 이 컴퓨터에 설치된 글꼴만 고를 수 있습니다.'**
  String get settingsEditorFontNote;

  /// No description provided for @settingsLineHeight.
  ///
  /// In ko, this message translates to:
  /// **'줄 간격'**
  String get settingsLineHeight;

  /// No description provided for @settingsLineHeightReset.
  ///
  /// In ko, this message translates to:
  /// **'기본 줄 간격으로'**
  String get settingsLineHeightReset;

  /// No description provided for @settingsEditorFontMissing.
  ///
  /// In ko, this message translates to:
  /// **'이 글꼴은 이 컴퓨터에 설치되어 있지 않은 것 같습니다. Menlo 등 대체 글꼴로 보입니다.'**
  String get settingsEditorFontMissing;

  /// No description provided for @settingsPreview.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get settingsPreview;

  /// No description provided for @settingsUiFont.
  ///
  /// In ko, this message translates to:
  /// **'UI 글꼴'**
  String get settingsUiFont;

  /// No description provided for @settingsUiFontMissing.
  ///
  /// In ko, this message translates to:
  /// **'이 글꼴은 이 컴퓨터에 설치되어 있지 않은 것 같습니다. 기본 글꼴로 보입니다.'**
  String get settingsUiFontMissing;

  /// No description provided for @settingsUiFontScale.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기 배율'**
  String get settingsUiFontScale;

  /// No description provided for @settingsUiFontScaleNote.
  ///
  /// In ko, this message translates to:
  /// **'트리·탭·도구 막대 같은 칸 크기는 그대로 두고 글자만 커지거나 작아집니다.'**
  String get settingsUiFontScaleNote;

  /// No description provided for @settingsUiFontPreview.
  ///
  /// In ko, this message translates to:
  /// **'아름다운 날 Daylight Studio 123'**
  String get settingsUiFontPreview;

  /// No description provided for @settingsTerminalFontPreview.
  ///
  /// In ko, this message translates to:
  /// **'\$ echo 안녕하세요 Hello 123'**
  String get settingsTerminalFontPreview;

  /// No description provided for @settingsSectionTerminal.
  ///
  /// In ko, this message translates to:
  /// **'터미널'**
  String get settingsSectionTerminal;

  /// No description provided for @settingsTerminalShareFont.
  ///
  /// In ko, this message translates to:
  /// **'편집기 글꼴과 같이 쓰기'**
  String get settingsTerminalShareFont;

  /// No description provided for @settingsTerminalShareFontNote.
  ///
  /// In ko, this message translates to:
  /// **'끄면 터미널만의 글꼴과 크기를 따로 고를 수 있습니다. 색은 설정 없이 늘 현재 테마를 따릅니다.'**
  String get settingsTerminalShareFontNote;

  /// No description provided for @settingsTerminalFont.
  ///
  /// In ko, this message translates to:
  /// **'터미널 글꼴'**
  String get settingsTerminalFont;

  /// No description provided for @settingsTerminalFontSize.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기'**
  String get settingsTerminalFontSize;

  /// No description provided for @settingsTerminalScrollback.
  ///
  /// In ko, this message translates to:
  /// **'스크롤백 줄 수'**
  String get settingsTerminalScrollback;

  /// No description provided for @settingsTerminalScrollbackNote.
  ///
  /// In ko, this message translates to:
  /// **'이미 열려 있는 터미널 탭에는 적용되지 않고, 새로 여는 탭부터 적용됩니다.'**
  String get settingsTerminalScrollbackNote;

  /// No description provided for @releaseButton.
  ///
  /// In ko, this message translates to:
  /// **'릴리스…'**
  String get releaseButton;

  /// No description provided for @releaseTitle.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 태그'**
  String get releaseTitle;

  /// No description provided for @releaseNotReady.
  ///
  /// In ko, this message translates to:
  /// **'점검을 통과하지 못해 태그를 달지 않았습니다.'**
  String get releaseNotReady;

  /// No description provided for @releaseTagged.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 태그를 올렸습니다. GitHub Actions가 릴리스를 만듭니다.'**
  String releaseTagged(String tag);

  /// No description provided for @releaseTagPushFailed.
  ///
  /// In ko, this message translates to:
  /// **'태그를 올리지 못했습니다: {error}'**
  String releaseTagPushFailed(String error);

  /// No description provided for @releaseVersionLine.
  ///
  /// In ko, this message translates to:
  /// **'pubspec {version} → 태그 {tag}'**
  String releaseVersionLine(String version, String tag);

  /// No description provided for @releaseLastTag.
  ///
  /// In ko, this message translates to:
  /// **'마지막 태그: {tag}'**
  String releaseLastTag(String tag);

  /// No description provided for @releaseNoLastTag.
  ///
  /// In ko, this message translates to:
  /// **'아직 태그가 없습니다'**
  String get releaseNoLastTag;

  /// No description provided for @releaseNoVersion.
  ///
  /// In ko, this message translates to:
  /// **'pubspec.yaml에서 버전을 읽지 못했습니다'**
  String get releaseNoVersion;

  /// No description provided for @releaseCheckCleanTree.
  ///
  /// In ko, this message translates to:
  /// **'작업 폴더에 커밋하지 않은 수정이 없다'**
  String get releaseCheckCleanTree;

  /// No description provided for @releaseCheckOnDefaultBranch.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치에 있다 (작업 브랜치에는 태그를 달지 않습니다)'**
  String get releaseCheckOnDefaultBranch;

  /// No description provided for @releaseCheckSynced.
  ///
  /// In ko, this message translates to:
  /// **'원격과 같다'**
  String get releaseCheckSynced;

  /// No description provided for @releaseCheckVersionBumped.
  ///
  /// In ko, this message translates to:
  /// **'버전이 마지막 태그보다 높다 (버전 올림이 병합됐다)'**
  String get releaseCheckVersionBumped;

  /// No description provided for @releaseCheckTagFree.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름의 태그가 아직 없다'**
  String get releaseCheckTagFree;

  /// No description provided for @releaseCheckVerified.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋을 빌드해서 눈으로 확인했다'**
  String get releaseCheckVerified;

  /// No description provided for @releaseBumpHint.
  ///
  /// In ko, this message translates to:
  /// **'버전을 올리려면 PR로 병합할 버전 올림 커밋을 만드세요:'**
  String get releaseBumpHint;

  /// No description provided for @releaseBumpHintNoScript.
  ///
  /// In ko, this message translates to:
  /// **'pubspec.yaml의 version을 올린 커밋을 PR로 병합하세요.'**
  String get releaseBumpHintNoScript;

  /// No description provided for @releaseRecheck.
  ///
  /// In ko, this message translates to:
  /// **'다시 확인'**
  String get releaseRecheck;

  /// No description provided for @releaseCreateTag.
  ///
  /// In ko, this message translates to:
  /// **'태그 만들고 올리기'**
  String get releaseCreateTag;

  /// No description provided for @releaseTagWithoutVerification.
  ///
  /// In ko, this message translates to:
  /// **'검증 없이 태그…'**
  String get releaseTagWithoutVerification;

  /// No description provided for @releaseUnverifiedTitle.
  ///
  /// In ko, this message translates to:
  /// **'확인하지 않은 커밋입니다'**
  String get releaseUnverifiedTitle;

  /// No description provided for @releaseUnverifiedBody.
  ///
  /// In ko, this message translates to:
  /// **'그래도 태그를 올리면 GitHub에서 모든 OS 빌드가 돌고, 문제가 나와도 이미 올린 태그는 옮기지 않습니다. PATCH를 올려 다시 릴리스해야 합니다.'**
  String get releaseUnverifiedBody;

  /// No description provided for @releaseTagAnyway.
  ///
  /// In ko, this message translates to:
  /// **'그래도 태그'**
  String get releaseTagAnyway;

  /// No description provided for @settingsIconSet.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 모양'**
  String get settingsIconSet;

  /// No description provided for @settingsIconSetRounded.
  ///
  /// In ko, this message translates to:
  /// **'둥근'**
  String get settingsIconSetRounded;

  /// No description provided for @settingsIconSetOutlined.
  ///
  /// In ko, this message translates to:
  /// **'윤곽선'**
  String get settingsIconSetOutlined;

  /// No description provided for @settingsIconSetFilled.
  ///
  /// In ko, this message translates to:
  /// **'채움'**
  String get settingsIconSetFilled;

  /// No description provided for @homeBuildTitle.
  ///
  /// In ko, this message translates to:
  /// **'빌드'**
  String get homeBuildTitle;

  /// No description provided for @homeModeDebug.
  ///
  /// In ko, this message translates to:
  /// **'Debug'**
  String get homeModeDebug;

  /// No description provided for @homeModeRelease.
  ///
  /// In ko, this message translates to:
  /// **'Release'**
  String get homeModeRelease;

  /// No description provided for @homeTeamLabel.
  ///
  /// In ko, this message translates to:
  /// **'Apple Team ID'**
  String get homeTeamLabel;

  /// No description provided for @homeTeamHelp.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트를 고치지 않고 빌드 인자로만 넘깁니다. developer.apple.com/account → Membership에서 확인하세요'**
  String get homeTeamHelp;

  /// No description provided for @homeStepsTitle.
  ///
  /// In ko, this message translates to:
  /// **'실행할 명령'**
  String get homeStepsTitle;

  /// No description provided for @homeStepPrepare.
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get homeStepPrepare;

  /// No description provided for @homeStepBuild.
  ///
  /// In ko, this message translates to:
  /// **'빌드'**
  String get homeStepBuild;

  /// No description provided for @homeStepInstall.
  ///
  /// In ko, this message translates to:
  /// **'설치'**
  String get homeStepInstall;

  /// No description provided for @homeStepLaunch.
  ///
  /// In ko, this message translates to:
  /// **'실행'**
  String get homeStepLaunch;

  /// No description provided for @homeStepRun.
  ///
  /// In ko, this message translates to:
  /// **'실행 (핫 리로드)'**
  String get homeStepRun;

  /// No description provided for @homeActionInstall.
  ///
  /// In ko, this message translates to:
  /// **'빌드 & 설치'**
  String get homeActionInstall;

  /// No description provided for @homeActionBuildRun.
  ///
  /// In ko, this message translates to:
  /// **'빌드 & 실행'**
  String get homeActionBuildRun;

  /// No description provided for @homeActionInstallOnly.
  ///
  /// In ko, this message translates to:
  /// **'설치만'**
  String get homeActionInstallOnly;

  /// No description provided for @homeActionClean.
  ///
  /// In ko, this message translates to:
  /// **'정리 후 패키지 다시 받기'**
  String get homeActionClean;

  /// No description provided for @homeCleanHelp.
  ///
  /// In ko, this message translates to:
  /// **'flutter clean → flutter pub get. 이유 없이 빌드가 실패할 때 해 볼 만합니다.'**
  String get homeCleanHelp;

  /// No description provided for @optTitle.
  ///
  /// In ko, this message translates to:
  /// **'빌드 옵션'**
  String get optTitle;

  /// No description provided for @optDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본값'**
  String get optDefault;

  /// No description provided for @optFlavor.
  ///
  /// In ko, this message translates to:
  /// **'Flavor'**
  String get optFlavor;

  /// No description provided for @optFlavorHelp.
  ///
  /// In ko, this message translates to:
  /// **'--flavor. 프로젝트에 flavor가 있을 때만 입력하세요 (Windows는 Flutter 3.47 이상)'**
  String get optFlavorHelp;

  /// No description provided for @optFlavorInvalid.
  ///
  /// In ko, this message translates to:
  /// **'영문자로 시작하고 영문자·숫자·_·-만 쓸 수 있습니다'**
  String get optFlavorInvalid;

  /// No description provided for @optHelp.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get optHelp;

  /// No description provided for @optHelpLink.
  ///
  /// In ko, this message translates to:
  /// **'선택한 대상(Android·iOS·Windows …)에 맞는 Flutter 문서의 flavor 설정 방법을 브라우저로 엽니다'**
  String get optHelpLink;

  /// No description provided for @optTarget.
  ///
  /// In ko, this message translates to:
  /// **'진입 파일'**
  String get optTarget;

  /// No description provided for @optTargetHelp.
  ///
  /// In ko, this message translates to:
  /// **'-t. 비우면 lib/main.dart'**
  String get optTargetHelp;

  /// No description provided for @optDefineFile.
  ///
  /// In ko, this message translates to:
  /// **'dart-define 파일'**
  String get optDefineFile;

  /// No description provided for @optDefineFileHelp.
  ///
  /// In ko, this message translates to:
  /// **'--dart-define-from-file. 경로만 저장하고 파일 내용은 읽거나 저장하지 않습니다'**
  String get optDefineFileHelp;

  /// No description provided for @optFileMissing.
  ///
  /// In ko, this message translates to:
  /// **'파일을 찾을 수 없습니다'**
  String get optFileMissing;

  /// No description provided for @optAppId.
  ///
  /// In ko, this message translates to:
  /// **'앱 ID (선택)'**
  String get optAppId;

  /// No description provided for @optAppIdHelp.
  ///
  /// In ko, this message translates to:
  /// **'flavor가 앱 ID를 바꿀 때, 설치 뒤 실행에 쓸 ID (예: art.zoomon.app.dev)'**
  String get optAppIdHelp;

  /// No description provided for @optExtra.
  ///
  /// In ko, this message translates to:
  /// **'추가 인자'**
  String get optExtra;

  /// No description provided for @optExtraHelp.
  ///
  /// In ko, this message translates to:
  /// **'예: --obfuscate --split-debug-info=build/symbols'**
  String get optExtraHelp;

  /// No description provided for @optPick.
  ///
  /// In ko, this message translates to:
  /// **'파일 고르기'**
  String get optPick;

  /// No description provided for @optClear.
  ///
  /// In ko, this message translates to:
  /// **'옵션 지우기'**
  String get optClear;

  /// No description provided for @homeCleanDone.
  ///
  /// In ko, this message translates to:
  /// **'정리했고 패키지를 다시 받았습니다. 이제 빌드해 보세요.'**
  String get homeCleanDone;

  /// No description provided for @homeCleanFailed.
  ///
  /// In ko, this message translates to:
  /// **'정리에 실패했습니다. 기록 탭에서 출력을 확인하세요.'**
  String get homeCleanFailed;

  /// No description provided for @homeActionRun.
  ///
  /// In ko, this message translates to:
  /// **'디버그 실행'**
  String get homeActionRun;

  /// No description provided for @homeActionCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get homeActionCancel;

  /// No description provided for @homeActionStop.
  ///
  /// In ko, this message translates to:
  /// **'중지'**
  String get homeActionStop;

  /// No description provided for @homeHotReload.
  ///
  /// In ko, this message translates to:
  /// **'핫 리로드'**
  String get homeHotReload;

  /// No description provided for @homeHotRestart.
  ///
  /// In ko, this message translates to:
  /// **'핫 리스타트'**
  String get homeHotRestart;

  /// No description provided for @homeOutputTitle.
  ///
  /// In ko, this message translates to:
  /// **'출력'**
  String get homeOutputTitle;

  /// No description provided for @homeCopyCommand.
  ///
  /// In ko, this message translates to:
  /// **'명령 복사'**
  String get homeCopyCommand;

  /// No description provided for @outputCopyAll.
  ///
  /// In ko, this message translates to:
  /// **'출력 전체 복사'**
  String get outputCopyAll;

  /// No description provided for @outputCopied.
  ///
  /// In ko, this message translates to:
  /// **'출력을 복사했습니다'**
  String get outputCopied;

  /// No description provided for @outputViewer.
  ///
  /// In ko, this message translates to:
  /// **'뷰어로 보기'**
  String get outputViewer;

  /// No description provided for @viewerPause.
  ///
  /// In ko, this message translates to:
  /// **'갱신 멈추기 (텍스트 선택용)'**
  String get viewerPause;

  /// No description provided for @viewerResume.
  ///
  /// In ko, this message translates to:
  /// **'실시간 갱신 다시 켜기'**
  String get viewerResume;

  /// No description provided for @viewerLines.
  ///
  /// In ko, this message translates to:
  /// **'{count}줄'**
  String viewerLines(Object count);

  /// No description provided for @logRunning.
  ///
  /// In ko, this message translates to:
  /// **'실행 중'**
  String get logRunning;

  /// No description provided for @logExit.
  ///
  /// In ko, this message translates to:
  /// **'종료 코드 {code}'**
  String logExit(String code);

  /// No description provided for @homeActionBuildOnly.
  ///
  /// In ko, this message translates to:
  /// **'빌드만'**
  String get homeActionBuildOnly;

  /// No description provided for @homeActionRunOnly.
  ///
  /// In ko, this message translates to:
  /// **'실행만'**
  String get homeActionRunOnly;

  /// No description provided for @homeRunOnlyNeedsBuild.
  ///
  /// In ko, this message translates to:
  /// **'실행할 release 결과물이 없습니다. 먼저 빌드하세요'**
  String get homeRunOnlyNeedsBuild;

  /// No description provided for @homeActionRelaunch.
  ///
  /// In ko, this message translates to:
  /// **'빌드 없이 다시 실행'**
  String get homeActionRelaunch;

  /// No description provided for @doctorRun.
  ///
  /// In ko, this message translates to:
  /// **'다시 점검'**
  String get doctorRun;

  /// No description provided for @doctorRunning.
  ///
  /// In ko, this message translates to:
  /// **'점검 중…'**
  String get doctorRunning;

  /// No description provided for @doctorNever.
  ///
  /// In ko, this message translates to:
  /// **'아직 점검하지 않았습니다'**
  String get doctorNever;

  /// No description provided for @doctorCollected.
  ///
  /// In ko, this message translates to:
  /// **'{time}에 점검함'**
  String doctorCollected(String time);

  /// No description provided for @doctorAllGood.
  ///
  /// In ko, this message translates to:
  /// **'문제가 없습니다'**
  String get doctorAllGood;

  /// No description provided for @checkFlutterOk.
  ///
  /// In ko, this message translates to:
  /// **'Flutter {version}'**
  String checkFlutterOk(String version);

  /// No description provided for @checkFlutterRunFail.
  ///
  /// In ko, this message translates to:
  /// **'flutter를 실행했지만 실패했습니다: {error}'**
  String checkFlutterRunFail(String error);

  /// No description provided for @checkFlutterFail.
  ///
  /// In ko, this message translates to:
  /// **'flutter를 찾지 못했습니다'**
  String get checkFlutterFail;

  /// No description provided for @checkXcodeOk.
  ///
  /// In ko, this message translates to:
  /// **'Xcode {version}'**
  String checkXcodeOk(String version);

  /// No description provided for @checkXcodeFail.
  ///
  /// In ko, this message translates to:
  /// **'Xcode를 찾지 못했습니다'**
  String get checkXcodeFail;

  /// No description provided for @checkAdbOk.
  ///
  /// In ko, this message translates to:
  /// **'adb {version}'**
  String checkAdbOk(String version);

  /// No description provided for @checkAdbWarn.
  ///
  /// In ko, this message translates to:
  /// **'adb를 찾지 못했습니다 (Android 설치에 필요)'**
  String get checkAdbWarn;

  /// No description provided for @checkCertificateOk.
  ///
  /// In ko, this message translates to:
  /// **'개발 인증서 {count}개 (개인 키 있음)'**
  String checkCertificateOk(String count);

  /// No description provided for @checkCertificateFail.
  ///
  /// In ko, this message translates to:
  /// **'사용할 수 있는 Apple Development 인증서가 없음'**
  String get checkCertificateFail;

  /// No description provided for @checkCertExpiryOk.
  ///
  /// In ko, this message translates to:
  /// **'{name} · {days}일 남음'**
  String checkCertExpiryOk(String name, String days);

  /// No description provided for @checkCertExpiryWarn.
  ///
  /// In ko, this message translates to:
  /// **'{name} · {days}일 뒤 만료'**
  String checkCertExpiryWarn(String name, String days);

  /// No description provided for @checkCertExpiryFail.
  ///
  /// In ko, this message translates to:
  /// **'{name} · 만료됨'**
  String checkCertExpiryFail(String name);

  /// No description provided for @stepsCertificate.
  ///
  /// In ko, this message translates to:
  /// **'1. Xcode → Settings → Accounts에서 Apple ID로 로그인합니다\n2. Manage Certificates → + → Apple Development을 추가합니다\n3. 다시 점검을 누릅니다'**
  String get stepsCertificate;

  /// No description provided for @stepsFlutterMissing.
  ///
  /// In ko, this message translates to:
  /// **'1. flutter.dev에서 Flutter SDK를 설치합니다\n2. flutter/bin을 PATH에 추가합니다 (~/.zshrc)\n3. 앱을 다시 열고 점검을 누릅니다'**
  String get stepsFlutterMissing;

  /// No description provided for @stepsFlutterMissingWindows.
  ///
  /// In ko, this message translates to:
  /// **'1. flutter.dev에서 Flutter SDK를 설치합니다\n2. flutter\\bin 폴더를 PATH에 추가하거나, 위의 \'도구 경로 지정\'에서 flutter.bat을 직접 고릅니다\n3. 다시 점검을 누릅니다'**
  String get stepsFlutterMissingWindows;

  /// No description provided for @stepsXcodeMissing.
  ///
  /// In ko, this message translates to:
  /// **'1. App Store에서 Xcode를 설치합니다\n2. 터미널에서 sudo xcode-select -s /Applications/Xcode.app 를 실행합니다\n3. Xcode를 한 번 열어 라이선스에 동의합니다'**
  String get stepsXcodeMissing;

  /// No description provided for @stepsAdbMissing.
  ///
  /// In ko, this message translates to:
  /// **'1. Android SDK platform-tools를 설치합니다 (Android Studio SDK Manager)\n2. platform-tools 폴더를 PATH에 추가합니다\n3. 다시 점검을 누릅니다'**
  String get stepsAdbMissing;

  /// No description provided for @stepsCertExpiry.
  ///
  /// In ko, this message translates to:
  /// **'1. Xcode → Settings → Accounts → Manage Certificates에서 새 Apple Development 인증서를 만듭니다\n2. 다시 점검을 누릅니다'**
  String get stepsCertExpiry;

  /// No description provided for @toolPathsOpen.
  ///
  /// In ko, this message translates to:
  /// **'도구 경로 지정…'**
  String get toolPathsOpen;

  /// No description provided for @toolPathsTitle.
  ///
  /// In ko, this message translates to:
  /// **'도구 경로'**
  String get toolPathsTitle;

  /// No description provided for @toolPathsHelp.
  ///
  /// In ko, this message translates to:
  /// **'PATH에서 찾지 못하는 도구는 직접 지정할 수 있습니다. 한 번 지정하면 저장되고 다음 실행에도 쓰입니다. 폴더가 아니라 실행 파일을 고르세요.'**
  String get toolPathsHelp;

  /// No description provided for @toolPathNotFound.
  ///
  /// In ko, this message translates to:
  /// **'찾지 못함'**
  String get toolPathNotFound;

  /// No description provided for @toolPathChoose.
  ///
  /// In ko, this message translates to:
  /// **'찾아서 지정…'**
  String get toolPathChoose;

  /// No description provided for @toolPathAuto.
  ///
  /// In ko, this message translates to:
  /// **'자동으로'**
  String get toolPathAuto;

  /// No description provided for @toolPathCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 지정'**
  String get toolPathCustom;

  /// No description provided for @toolPathFlutter.
  ///
  /// In ko, this message translates to:
  /// **'flutter'**
  String get toolPathFlutter;

  /// No description provided for @toolPathAdb.
  ///
  /// In ko, this message translates to:
  /// **'adb (Android SDK platform-tools)'**
  String get toolPathAdb;

  /// No description provided for @checkWindowsDevModeOk.
  ///
  /// In ko, this message translates to:
  /// **'Windows 개발자 모드 켜짐 (플러그인 링크를 만들 수 있음)'**
  String get checkWindowsDevModeOk;

  /// No description provided for @checkWindowsDevModeWarn.
  ///
  /// In ko, this message translates to:
  /// **'Windows 개발자 모드가 꺼져 있습니다 (플러그인 링크를 만들지 못해 빌드가 실패할 수 있음)'**
  String get checkWindowsDevModeWarn;

  /// No description provided for @checkVisualStudioOk.
  ///
  /// In ko, this message translates to:
  /// **'Visual Studio {version} (C++ 도구 있음)'**
  String checkVisualStudioOk(String version);

  /// No description provided for @checkVisualStudioFail.
  ///
  /// In ko, this message translates to:
  /// **'Visual Studio의 \'C++를 사용한 데스크톱 개발\'이 없습니다 (Windows 앱 빌드에 필요)'**
  String get checkVisualStudioFail;

  /// No description provided for @stepsWindowsDevMode.
  ///
  /// In ko, this message translates to:
  /// **'1. Windows 설정을 열고 \'개발자용\'(개발자 설정)을 검색해 엽니다\n2. \'개발자 모드\'를 켭니다\n3. 다시 점검을 누릅니다'**
  String get stepsWindowsDevMode;

  /// No description provided for @stepsVisualStudio.
  ///
  /// In ko, this message translates to:
  /// **'1. Visual Studio 2022(Community 가능)를 설치합니다\n2. 설치 관리자에서 \'C++를 사용한 데스크톱 개발\'을 선택합니다\n3. 다시 빌드합니다'**
  String get stepsVisualStudio;

  /// No description provided for @settingsSectionEnvironment.
  ///
  /// In ko, this message translates to:
  /// **'환경 점검'**
  String get settingsSectionEnvironment;

  /// No description provided for @studioRecentProjects.
  ///
  /// In ko, this message translates to:
  /// **'최근 프로젝트'**
  String get studioRecentProjects;

  /// No description provided for @studioRecentTooltip.
  ///
  /// In ko, this message translates to:
  /// **'최근 프로젝트 보기'**
  String get studioRecentTooltip;

  /// No description provided for @studioRecentNone.
  ///
  /// In ko, this message translates to:
  /// **'최근에 연 프로젝트가 없습니다'**
  String get studioRecentNone;

  /// No description provided for @studioRecentClear.
  ///
  /// In ko, this message translates to:
  /// **'목록 지우기'**
  String get studioRecentClear;

  /// No description provided for @studioRecentForget.
  ///
  /// In ko, this message translates to:
  /// **'목록에서 빼기'**
  String get studioRecentForget;

  /// No description provided for @problemsNoPackageInfoSub.
  ///
  /// In ko, this message translates to:
  /// **'{packages}의 패키지 정보(.dart_tool)가 없어서 import 오류가 가짜로 섞입니다.'**
  String problemsNoPackageInfoSub(String packages);

  /// No description provided for @settingsIndentGuides.
  ///
  /// In ko, this message translates to:
  /// **'들여쓰기 선'**
  String get settingsIndentGuides;

  /// No description provided for @settingsIndentGuidesNote.
  ///
  /// In ko, this message translates to:
  /// **'들여쓴 줄마다 깊이별로 색이 다른 세로선을 그어 짝을 맞춰 볼 수 있게 합니다. 고정폭 글꼴에서 정확합니다.'**
  String get settingsIndentGuidesNote;

  /// No description provided for @gitTabBranches.
  ///
  /// In ko, this message translates to:
  /// **'브랜치'**
  String get gitTabBranches;

  /// No description provided for @branchesLocal.
  ///
  /// In ko, this message translates to:
  /// **'로컬 브랜치'**
  String get branchesLocal;

  /// No description provided for @branchesRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치'**
  String get branchesRemote;

  /// No description provided for @branchesSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 검색'**
  String get branchesSearchHint;

  /// No description provided for @branchesNew.
  ///
  /// In ko, this message translates to:
  /// **'새 브랜치'**
  String get branchesNew;

  /// No description provided for @branchesRefresh.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 목록 새로 고침'**
  String get branchesRefresh;

  /// No description provided for @branchesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'브랜치가 없습니다'**
  String get branchesEmpty;

  /// No description provided for @branchesNoMatch.
  ///
  /// In ko, this message translates to:
  /// **'검색과 맞는 브랜치가 없습니다'**
  String get branchesNoMatch;

  /// No description provided for @branchesNotRepo.
  ///
  /// In ko, this message translates to:
  /// **'열린 폴더가 git 저장소가 아닙니다'**
  String get branchesNotRepo;

  /// No description provided for @branchCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get branchCurrent;

  /// No description provided for @branchSwitch.
  ///
  /// In ko, this message translates to:
  /// **'전환'**
  String get branchSwitch;

  /// No description provided for @branchTrackSwitch.
  ///
  /// In ko, this message translates to:
  /// **'로컬로 가져와 전환'**
  String get branchTrackSwitch;

  /// No description provided for @branchNewFrom.
  ///
  /// In ko, this message translates to:
  /// **'여기서 새 브랜치'**
  String get branchNewFrom;

  /// No description provided for @branchRename.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get branchRename;

  /// No description provided for @branchDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get branchDelete;

  /// No description provided for @branchDeleteRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치 삭제'**
  String get branchDeleteRemote;

  /// No description provided for @branchInWorktree.
  ///
  /// In ko, this message translates to:
  /// **'다른 worktree에서 사용 중: {path}'**
  String branchInWorktree(String path);

  /// No description provided for @branchOpenWorktree.
  ///
  /// In ko, this message translates to:
  /// **'그 worktree 열기'**
  String get branchOpenWorktree;

  /// No description provided for @branchGone.
  ///
  /// In ko, this message translates to:
  /// **'원격에서 사라짐'**
  String get branchGone;

  /// No description provided for @branchNoUpstream.
  ///
  /// In ko, this message translates to:
  /// **'추적 브랜치 없음'**
  String get branchNoUpstream;

  /// No description provided for @branchCreateTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 브랜치'**
  String get branchCreateTitle;

  /// No description provided for @branchNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 이름'**
  String get branchNameLabel;

  /// No description provided for @branchBaseLabel.
  ///
  /// In ko, this message translates to:
  /// **'기준 브랜치'**
  String get branchBaseLabel;

  /// No description provided for @branchBaseHead.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치(HEAD)'**
  String get branchBaseHead;

  /// No description provided for @branchSwitchAfter.
  ///
  /// In ko, this message translates to:
  /// **'만든 뒤 바로 전환'**
  String get branchSwitchAfter;

  /// No description provided for @branchCreate.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get branchCreate;

  /// No description provided for @branchCommandPreview.
  ///
  /// In ko, this message translates to:
  /// **'실행될 명령'**
  String get branchCommandPreview;

  /// No description provided for @branchNameEmpty.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get branchNameEmpty;

  /// No description provided for @branchNameInvalidChar.
  ///
  /// In ko, this message translates to:
  /// **'공백이나 ~ ^ : ? * [ 같은 글자는 쓸 수 없습니다'**
  String get branchNameInvalidChar;

  /// No description provided for @branchNameDash.
  ///
  /// In ko, this message translates to:
  /// **'-로 시작할 수 없습니다'**
  String get branchNameDash;

  /// No description provided for @branchNameSequence.
  ///
  /// In ko, this message translates to:
  /// **'.. // 또는 .으로 시작하는 부분은 쓸 수 없습니다'**
  String get branchNameSequence;

  /// No description provided for @branchNameEdge.
  ///
  /// In ko, this message translates to:
  /// **'/로 시작하거나 /·.로 끝날 수 없습니다'**
  String get branchNameEdge;

  /// No description provided for @branchNameExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 있는 이름입니다'**
  String get branchNameExists;

  /// No description provided for @branchRenameTitle.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 이름 바꾸기'**
  String get branchRenameTitle;

  /// No description provided for @branchRenameAction.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get branchRenameAction;

  /// No description provided for @branchDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 삭제'**
  String get branchDeleteTitle;

  /// No description provided for @branchDeleteBody.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 브랜치를 삭제합니다. 다른 브랜치에 병합된 것만 지워집니다.'**
  String branchDeleteBody(String name);

  /// No description provided for @branchDeleteNotMergedTitle.
  ///
  /// In ko, this message translates to:
  /// **'병합되지 않은 브랜치'**
  String get branchDeleteNotMergedTitle;

  /// No description provided for @branchDeleteNotMergedBody.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\'에는 다른 브랜치에 없는 커밋이 있습니다. 지우면 그 커밋에 접근하기 어려워집니다.'**
  String branchDeleteNotMergedBody(String name);

  /// No description provided for @branchForceDelete.
  ///
  /// In ko, this message translates to:
  /// **'그래도 삭제 (-D)'**
  String get branchForceDelete;

  /// No description provided for @branchDeleteRemoteTitle.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치 삭제'**
  String get branchDeleteRemoteTitle;

  /// No description provided for @branchDeleteRemoteBody.
  ///
  /// In ko, this message translates to:
  /// **'원격 {remote}에서 \'{branch}\'를 삭제합니다. 같은 원격을 쓰는 다른 사람에게도 영향이 갑니다.'**
  String branchDeleteRemoteBody(String remote, String branch);

  /// No description provided for @branchDoneSwitch.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\'(으)로 전환했습니다'**
  String branchDoneSwitch(String name);

  /// No description provided for @branchDoneCreate.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 브랜치를 만들었습니다'**
  String branchDoneCreate(String name);

  /// No description provided for @branchDoneRename.
  ///
  /// In ko, this message translates to:
  /// **'\'{from}\' → \'{to}\'로 이름을 바꿨습니다'**
  String branchDoneRename(String from, String to);

  /// No description provided for @branchDoneDelete.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 브랜치를 삭제했습니다'**
  String branchDoneDelete(String name);

  /// No description provided for @branchDoneDeleteRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치 \'{name}\'을(를) 삭제했습니다'**
  String branchDoneDeleteRemote(String name);

  /// No description provided for @branchErrInOtherWorktree.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\'은(는) 다른 worktree에서 쓰고 있어 전환·삭제할 수 없습니다: {path}'**
  String branchErrInOtherWorktree(String name, String path);

  /// No description provided for @branchErrLocalChanges.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경이 있어 전환할 수 없습니다. 커밋하거나 되돌린 뒤 다시 시도하세요.'**
  String get branchErrLocalChanges;

  /// No description provided for @branchErrNotMerged.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\'은(는) 병합되지 않았습니다.'**
  String branchErrNotMerged(String name);

  /// No description provided for @branchErrExists.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 이름이 이미 있습니다.'**
  String branchErrExists(String name);

  /// No description provided for @branchErrRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격에 연결하지 못했습니다. 로그인과 네트워크를 확인하세요.'**
  String get branchErrRemote;

  /// No description provided for @branchErrNoGit.
  ///
  /// In ko, this message translates to:
  /// **'git을 찾을 수 없습니다. 설치되어 PATH에 있는지 확인하세요.'**
  String get branchErrNoGit;

  /// No description provided for @branchErrGeneric.
  ///
  /// In ko, this message translates to:
  /// **'실패했습니다 (종료 코드 {code})'**
  String branchErrGeneric(String code);

  /// No description provided for @mergeMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'현재 브랜치로 병합…'**
  String get mergeMenuItem;

  /// No description provided for @mergeTitle.
  ///
  /// In ko, this message translates to:
  /// **'\'{source}\'을(를) \'{target}\'에 병합'**
  String mergeTitle(String source, String target);

  /// No description provided for @mergeIncoming.
  ///
  /// In ko, this message translates to:
  /// **'들어올 커밋 {count}개'**
  String mergeIncoming(String count);

  /// No description provided for @mergeNothing.
  ///
  /// In ko, this message translates to:
  /// **'\'{source}\'에는 \'{target}\'에 없는 커밋이 없습니다. 이미 최신입니다.'**
  String mergeNothing(String source, String target);

  /// No description provided for @mergeLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'미리 보기를 읽지 못했습니다'**
  String get mergeLoadFailed;

  /// No description provided for @mergeModeFastForward.
  ///
  /// In ko, this message translates to:
  /// **'Fast-forward'**
  String get mergeModeFastForward;

  /// No description provided for @mergeFastForwardWhen.
  ///
  /// In ko, this message translates to:
  /// **'기록을 갈라놓지 않고 브랜치 끝만 앞으로 옮깁니다. 병합 커밋이 생기지 않습니다.'**
  String get mergeFastForwardWhen;

  /// No description provided for @mergeFastForwardDisabled.
  ///
  /// In ko, this message translates to:
  /// **'두 브랜치가 갈라져 있어 쓸 수 없습니다 (현재 브랜치에도 새 커밋이 있습니다).'**
  String get mergeFastForwardDisabled;

  /// No description provided for @mergeModeMergeCommit.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋'**
  String get mergeModeMergeCommit;

  /// No description provided for @mergeMergeCommitWhen.
  ///
  /// In ko, this message translates to:
  /// **'두 기록을 합치는 커밋을 만듭니다. 어디서 합쳤는지 기록에 남습니다.'**
  String get mergeMergeCommitWhen;

  /// No description provided for @mergeModeSquash.
  ///
  /// In ko, this message translates to:
  /// **'Squash'**
  String get mergeModeSquash;

  /// No description provided for @mergeSquashWhen.
  ///
  /// In ko, this message translates to:
  /// **'들어올 커밋을 하나로 묶어 커밋합니다. 기록은 깔끔하지만 원래 커밋은 따로 남지 않습니다.'**
  String get mergeSquashWhen;

  /// No description provided for @mergeModeRebase.
  ///
  /// In ko, this message translates to:
  /// **'Rebase'**
  String get mergeModeRebase;

  /// No description provided for @mergeRebaseWhen.
  ///
  /// In ko, this message translates to:
  /// **'현재 브랜치의 커밋을 \'{source}\' 끝에 다시 쌓습니다. 기록은 한 줄이 되지만 커밋이 새로 만들어집니다.'**
  String mergeRebaseWhen(String source);

  /// No description provided for @mergeMessageLabel.
  ///
  /// In ko, this message translates to:
  /// **'커밋 메시지'**
  String get mergeMessageLabel;

  /// No description provided for @mergeSquashNote.
  ///
  /// In ko, this message translates to:
  /// **'\'{source}\'의 커밋들이 하나로 묶여 스테이징된 뒤 커밋됩니다. 충돌이 나면 해결한 다음 직접 커밋하세요.'**
  String mergeSquashNote(String source);

  /// No description provided for @mergeRebaseReplay.
  ///
  /// In ko, this message translates to:
  /// **'다시 쌓일 내 커밋 {count}개'**
  String mergeRebaseReplay(String count);

  /// No description provided for @mergeRebaseNothing.
  ///
  /// In ko, this message translates to:
  /// **'다시 쌓을 내 커밋이 없습니다. 이미 그 브랜치 위에 있습니다.'**
  String get mergeRebaseNothing;

  /// No description provided for @mergeRebasePublishedWarning.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 원격에 올라가 있습니다. rebase하면 커밋이 새로 만들어져 다음 push에 강제 push(--force-with-lease)가 필요합니다.'**
  String get mergeRebasePublishedWarning;

  /// No description provided for @mergeConfirm.
  ///
  /// In ko, this message translates to:
  /// **'병합'**
  String get mergeConfirm;

  /// No description provided for @mergeConfirmRebase.
  ///
  /// In ko, this message translates to:
  /// **'Rebase'**
  String get mergeConfirmRebase;

  /// No description provided for @mergeDone.
  ///
  /// In ko, this message translates to:
  /// **'\'{source}\'을(를) \'{target}\'에 병합했습니다'**
  String mergeDone(String source, String target);

  /// No description provided for @mergeDoneRebase.
  ///
  /// In ko, this message translates to:
  /// **'\'{target}\'을(를) \'{source}\' 위로 rebase했습니다'**
  String mergeDoneRebase(String target, String source);

  /// No description provided for @mergeErrConflict.
  ///
  /// In ko, this message translates to:
  /// **'충돌이 났습니다. 변경 탭에서 충돌을 해결한 뒤 계속하거나, 중단해서 되돌리세요.'**
  String get mergeErrConflict;

  /// No description provided for @mergeErrLocalChanges.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경이 병합과 겹칩니다. 커밋하거나 되돌린 뒤 다시 시도하세요.'**
  String get mergeErrLocalChanges;

  /// No description provided for @mergeErrNotFastForward.
  ///
  /// In ko, this message translates to:
  /// **'fast-forward로 합칠 수 없습니다. 기록이 갈라졌으니 병합 커밋이나 squash를 고르세요.'**
  String get mergeErrNotFastForward;

  /// No description provided for @mergeBusyOperation.
  ///
  /// In ko, this message translates to:
  /// **'병합·rebase가 진행 중입니다. 먼저 계속하거나 중단하세요.'**
  String get mergeBusyOperation;

  /// No description provided for @opMerging.
  ///
  /// In ko, this message translates to:
  /// **'병합 중 — 충돌 {count}개'**
  String opMerging(String count);

  /// No description provided for @opRebasing.
  ///
  /// In ko, this message translates to:
  /// **'rebase 중 — 충돌 {count}개'**
  String opRebasing(String count);

  /// No description provided for @opCherryPicking.
  ///
  /// In ko, this message translates to:
  /// **'cherry-pick 중 — 충돌 {count}개'**
  String opCherryPicking(String count);

  /// No description provided for @opReverting.
  ///
  /// In ko, this message translates to:
  /// **'revert 중 — 충돌 {count}개'**
  String opReverting(String count);

  /// No description provided for @opContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속'**
  String get opContinue;

  /// No description provided for @opSkip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get opSkip;

  /// No description provided for @opAbort.
  ///
  /// In ko, this message translates to:
  /// **'중단'**
  String get opAbort;

  /// No description provided for @opContinueBlocked.
  ///
  /// In ko, this message translates to:
  /// **'충돌을 모두 해결하고 스테이지해야 계속할 수 있습니다.'**
  String get opContinueBlocked;

  /// No description provided for @opAbortTitle.
  ///
  /// In ko, this message translates to:
  /// **'작업 중단'**
  String get opAbortTitle;

  /// No description provided for @opAbortMergeBody.
  ///
  /// In ko, this message translates to:
  /// **'병합을 중단하고 병합 전 상태로 되돌립니다. 충돌을 해결한 내용도 사라집니다.'**
  String get opAbortMergeBody;

  /// No description provided for @opAbortRebaseBody.
  ///
  /// In ko, this message translates to:
  /// **'rebase를 중단하고 시작하기 전 상태로 되돌립니다. 이미 다시 쌓은 커밋도 사라집니다.'**
  String get opAbortRebaseBody;

  /// No description provided for @opAbortOtherBody.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 작업을 중단하고 시작 전 상태로 되돌립니다.'**
  String get opAbortOtherBody;

  /// No description provided for @opDoneContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속했습니다'**
  String get opDoneContinue;

  /// No description provided for @opDoneSkip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰었습니다'**
  String get opDoneSkip;

  /// No description provided for @opDoneAbort.
  ///
  /// In ko, this message translates to:
  /// **'중단했습니다. 시작 전 상태로 돌아왔습니다.'**
  String get opDoneAbort;

  /// No description provided for @bdAboutTooltip.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get bdAboutTooltip;

  /// No description provided for @bdAboutVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version} (빌드 {build})'**
  String bdAboutVersion(String version, String build);

  /// No description provided for @bdAboutOpenSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get bdAboutOpenSourceLicenses;

  /// No description provided for @bdAboutRepository.
  ///
  /// In ko, this message translates to:
  /// **'GitHub'**
  String get bdAboutRepository;

  /// No description provided for @bdCommonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get bdCommonClose;

  /// No description provided for @bdAboutMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 정보'**
  String bdAboutMenuItem(String appName);

  /// No description provided for @bdThemeMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get bdThemeMenuTooltip;

  /// No description provided for @bdThemeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기'**
  String get bdThemeSystem;

  /// No description provided for @bdThemeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get bdThemeLight;

  /// No description provided for @bdThemeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get bdThemeDark;

  /// No description provided for @bdLanguageMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get bdLanguageMenuTooltip;

  /// No description provided for @bdLanguageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기 / System'**
  String get bdLanguageSystem;

  /// No description provided for @bdLanguageSystemShort.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get bdLanguageSystemShort;

  /// No description provided for @bdAboutTagline.
  ///
  /// In ko, this message translates to:
  /// **'Git과 GitHub CLI를 위한 데스크톱 도우미'**
  String get bdAboutTagline;

  /// No description provided for @bdAboutDescription.
  ///
  /// In ko, this message translates to:
  /// **'편집기 옆에 세워 두고 브랜치, 태그, 병합, Pull/Push, 원격, 릴리스를 버튼으로 다룹니다. 버튼마다 실제로 실행되는 git·gh 명령을 보여 줍니다.'**
  String get bdAboutDescription;

  /// No description provided for @bdHomeEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'시작하려면 저장소를 선택하세요'**
  String get bdHomeEmptyTitle;

  /// No description provided for @bdHomeEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'저장소 열기'**
  String get bdHomeEmptyAction;

  /// No description provided for @bdAppBarRefresh.
  ///
  /// In ko, this message translates to:
  /// **'새로 고침'**
  String get bdAppBarRefresh;

  /// No description provided for @bdAppBarPin.
  ///
  /// In ko, this message translates to:
  /// **'항상 위에 표시'**
  String get bdAppBarPin;

  /// No description provided for @bdAppBarUnpin.
  ///
  /// In ko, this message translates to:
  /// **'항상 위에 표시 끄기'**
  String get bdAppBarUnpin;

  /// No description provided for @bdMenuOpenFolder.
  ///
  /// In ko, this message translates to:
  /// **'다른 폴더 열기…'**
  String get bdMenuOpenFolder;

  /// No description provided for @bdMenuEditor.
  ///
  /// In ko, this message translates to:
  /// **'파일을 열 편집기…'**
  String get bdMenuEditor;

  /// No description provided for @bdMenuEnvironment.
  ///
  /// In ko, this message translates to:
  /// **'환경 점검'**
  String get bdMenuEnvironment;

  /// No description provided for @bdMenuCloseRepo.
  ///
  /// In ko, this message translates to:
  /// **'저장소 닫기'**
  String get bdMenuCloseRepo;

  /// No description provided for @bdHostOther.
  ///
  /// In ko, this message translates to:
  /// **'기타 git 서버'**
  String get bdHostOther;

  /// No description provided for @bdCommonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get bdCommonCancel;

  /// No description provided for @bdCommonCopy.
  ///
  /// In ko, this message translates to:
  /// **'복사'**
  String get bdCommonCopy;

  /// No description provided for @bdCommonCopied.
  ///
  /// In ko, this message translates to:
  /// **'복사했습니다'**
  String get bdCommonCopied;

  /// No description provided for @bdCommonMore.
  ///
  /// In ko, this message translates to:
  /// **'더 보기'**
  String get bdCommonMore;

  /// No description provided for @bdCommonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get bdCommonSave;

  /// No description provided for @bdCommandPreviewLabel.
  ///
  /// In ko, this message translates to:
  /// **'실행될 명령'**
  String get bdCommandPreviewLabel;

  /// No description provided for @bdStartDropHint.
  ///
  /// In ko, this message translates to:
  /// **'git 저장소 폴더를 창에 끌어다 놓아도 됩니다.'**
  String get bdStartDropHint;

  /// No description provided for @bdStartRecent.
  ///
  /// In ko, this message translates to:
  /// **'최근 저장소'**
  String get bdStartRecent;

  /// No description provided for @bdStartRemoveRecent.
  ///
  /// In ko, this message translates to:
  /// **'목록에서 빼기'**
  String get bdStartRemoveRecent;

  /// No description provided for @bdStartNotARepository.
  ///
  /// In ko, this message translates to:
  /// **'이 폴더는 git 저장소가 아닙니다: {path}'**
  String bdStartNotARepository(String path);

  /// No description provided for @bdStartNotFound.
  ///
  /// In ko, this message translates to:
  /// **'폴더를 찾을 수 없습니다: {path}'**
  String bdStartNotFound(String path);

  /// No description provided for @bdEnvTitle.
  ///
  /// In ko, this message translates to:
  /// **'환경 점검'**
  String get bdEnvTitle;

  /// No description provided for @bdEnvGitRequired.
  ///
  /// In ko, this message translates to:
  /// **'Branch Dock은 설치된 git을 실행합니다. git을 먼저 설치하세요.'**
  String get bdEnvGitRequired;

  /// No description provided for @bdEnvGitOnlyNote.
  ///
  /// In ko, this message translates to:
  /// **'gh가 없거나 로그인하지 않아도 브랜치·태그·Pull·Push는 쓸 수 있습니다. GitHub에 올리기, PR, 릴리스에는 gh 로그인이 필요합니다.'**
  String get bdEnvGitOnlyNote;

  /// No description provided for @bdEnvVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version}'**
  String bdEnvVersion(String version);

  /// No description provided for @bdEnvNotInstalled.
  ///
  /// In ko, this message translates to:
  /// **'설치되지 않았거나 찾을 수 없습니다'**
  String get bdEnvNotInstalled;

  /// No description provided for @bdEnvLogin.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 로그인'**
  String get bdEnvLogin;

  /// No description provided for @bdEnvLoggedInAs.
  ///
  /// In ko, this message translates to:
  /// **'{login} 계정으로 로그인됨'**
  String bdEnvLoggedInAs(String login);

  /// No description provided for @bdEnvNotLoggedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인하지 않았습니다. 터미널에서 아래 명령을 실행하세요.'**
  String get bdEnvNotLoggedIn;

  /// No description provided for @bdEnvRecheck.
  ///
  /// In ko, this message translates to:
  /// **'다시 확인'**
  String get bdEnvRecheck;

  /// No description provided for @bdEnvGhMissing.
  ///
  /// In ko, this message translates to:
  /// **'GitHub CLI(gh)가 설치되지 않아 쓸 수 없습니다. 메뉴의 환경 점검을 확인하세요.'**
  String get bdEnvGhMissing;

  /// No description provided for @bdEnvGhLoggedOut.
  ///
  /// In ko, this message translates to:
  /// **'gh에 로그인해야 쓸 수 있습니다. 터미널에서 gh auth login을 실행하세요.'**
  String get bdEnvGhLoggedOut;

  /// No description provided for @bdHeaderOpenFolder.
  ///
  /// In ko, this message translates to:
  /// **'편집기에서 이 폴더 열기'**
  String get bdHeaderOpenFolder;

  /// No description provided for @bdVscodeMissingTitle.
  ///
  /// In ko, this message translates to:
  /// **'VS Code를 찾지 못했습니다'**
  String get bdVscodeMissingTitle;

  /// No description provided for @bdVscodeMissingMessage.
  ///
  /// In ko, this message translates to:
  /// **'VS Code를 설치하면 이 버튼으로 현재 브랜치가 체크아웃된 폴더를 바로 열 수 있습니다. 다른 편집기를 쓰려면 저장소 메뉴의 ‘파일을 열 편집기…’에 명령(cursor, zed 등)을 적으세요.'**
  String get bdVscodeMissingMessage;

  /// No description provided for @bdVscodeDownload.
  ///
  /// In ko, this message translates to:
  /// **'VS Code 받기'**
  String get bdVscodeDownload;

  /// No description provided for @bdHeaderBranchTooltip.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 목록 보기'**
  String get bdHeaderBranchTooltip;

  /// No description provided for @bdHeaderDetached.
  ///
  /// In ko, this message translates to:
  /// **'분리된 HEAD'**
  String get bdHeaderDetached;

  /// No description provided for @bdHeaderNoUpstream.
  ///
  /// In ko, this message translates to:
  /// **'원격에 없음'**
  String get bdHeaderNoUpstream;

  /// No description provided for @bdHeaderNoUpstreamTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 아직 원격에 올라가지 않았습니다. 게시(Publish)하면 올라갑니다.'**
  String get bdHeaderNoUpstreamTooltip;

  /// No description provided for @bdHeaderAheadTooltip.
  ///
  /// In ko, this message translates to:
  /// **'원격에 아직 없는 내 커밋 {count}개'**
  String bdHeaderAheadTooltip(int count);

  /// No description provided for @bdHeaderBehindTooltip.
  ///
  /// In ko, this message translates to:
  /// **'내 컴퓨터에 아직 없는 원격 커밋 {count}개'**
  String bdHeaderBehindTooltip(int count);

  /// No description provided for @bdHeaderChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경 {count}'**
  String bdHeaderChanges(int count);

  /// No description provided for @bdHeaderUpToDate.
  ///
  /// In ko, this message translates to:
  /// **'최신'**
  String get bdHeaderUpToDate;

  /// No description provided for @bdHeaderNoCommits.
  ///
  /// In ko, this message translates to:
  /// **'아직 커밋 없음'**
  String get bdHeaderNoCommits;

  /// No description provided for @bdHeaderMerging.
  ///
  /// In ko, this message translates to:
  /// **'병합 중 · 충돌 {count}'**
  String bdHeaderMerging(int count);

  /// No description provided for @bdHeaderRebasing.
  ///
  /// In ko, this message translates to:
  /// **'rebase 중 · 충돌 {count}'**
  String bdHeaderRebasing(int count);

  /// No description provided for @bdHeaderFetch.
  ///
  /// In ko, this message translates to:
  /// **'Fetch'**
  String get bdHeaderFetch;

  /// No description provided for @bdHeaderPull.
  ///
  /// In ko, this message translates to:
  /// **'Pull'**
  String get bdHeaderPull;

  /// No description provided for @bdHeaderPush.
  ///
  /// In ko, this message translates to:
  /// **'Push'**
  String get bdHeaderPush;

  /// No description provided for @bdHeaderPublish.
  ///
  /// In ko, this message translates to:
  /// **'게시'**
  String get bdHeaderPublish;

  /// No description provided for @bdPullModeTooltip.
  ///
  /// In ko, this message translates to:
  /// **'Pull 방식'**
  String get bdPullModeTooltip;

  /// No description provided for @bdPullModeTitle.
  ///
  /// In ko, this message translates to:
  /// **'Pull 방식'**
  String get bdPullModeTitle;

  /// No description provided for @bdPullModeMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합 (기본)'**
  String get bdPullModeMerge;

  /// No description provided for @bdPullModeMergeWhen.
  ///
  /// In ko, this message translates to:
  /// **'양쪽에 새 커밋이 있으면 병합 커밋으로 합칩니다. 가장 안전합니다.'**
  String get bdPullModeMergeWhen;

  /// No description provided for @bdPullModeRebase.
  ///
  /// In ko, this message translates to:
  /// **'Rebase'**
  String get bdPullModeRebase;

  /// No description provided for @bdPullModeRebaseWhen.
  ///
  /// In ko, this message translates to:
  /// **'내 커밋을 받아온 커밋 뒤로 옮겨 기록을 한 줄로 유지합니다.'**
  String get bdPullModeRebaseWhen;

  /// No description provided for @bdPullModeFastForward.
  ///
  /// In ko, this message translates to:
  /// **'Fast-forward만'**
  String get bdPullModeFastForward;

  /// No description provided for @bdPullModeFastForwardWhen.
  ///
  /// In ko, this message translates to:
  /// **'내 커밋이 없을 때만 받아옵니다. 갈라졌으면 멈추고 알려 줍니다.'**
  String get bdPullModeFastForwardWhen;

  /// No description provided for @bdOperationAbort.
  ///
  /// In ko, this message translates to:
  /// **'중단'**
  String get bdOperationAbort;

  /// No description provided for @bdOperationContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속'**
  String get bdOperationContinue;

  /// No description provided for @bdOperationContinueBlocked.
  ///
  /// In ko, this message translates to:
  /// **'충돌을 모두 해결해야 계속할 수 있습니다'**
  String get bdOperationContinueBlocked;

  /// No description provided for @bdOperationAbortTitle.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 작업을 중단할까요?'**
  String get bdOperationAbortTitle;

  /// No description provided for @bdOperationAbortMergeMessage.
  ///
  /// In ko, this message translates to:
  /// **'병합을 시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.'**
  String get bdOperationAbortMergeMessage;

  /// No description provided for @bdOperationAbortRebaseMessage.
  ///
  /// In ko, this message translates to:
  /// **'rebase를 시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.'**
  String get bdOperationAbortRebaseMessage;

  /// No description provided for @bdBannerConflicts.
  ///
  /// In ko, this message translates to:
  /// **'충돌 파일 {count}개를 해결해야 합니다'**
  String bdBannerConflicts(int count);

  /// No description provided for @bdBannerPull.
  ///
  /// In ko, this message translates to:
  /// **'원격에 새 커밋 {count}개가 있습니다'**
  String bdBannerPull(int count);

  /// No description provided for @bdBannerPublish.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 아직 원격에 없습니다'**
  String get bdBannerPublish;

  /// No description provided for @bdBannerPush.
  ///
  /// In ko, this message translates to:
  /// **'커밋 {count}개가 아직 원격에 없습니다'**
  String bdBannerPush(int count);

  /// No description provided for @bdBannerNoRemote.
  ///
  /// In ko, this message translates to:
  /// **'이 저장소는 아직 GitHub에 없습니다'**
  String get bdBannerNoRemote;

  /// No description provided for @bdBannerShow.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get bdBannerShow;

  /// No description provided for @bdBannerNotGitHub.
  ///
  /// In ko, this message translates to:
  /// **'{host} 저장소입니다. 브랜치·Pull·Push는 모두 쓸 수 있고, PR·릴리스·Actions는 GitHub 저장소에서만 쓸 수 있습니다.'**
  String bdBannerNotGitHub(String host);

  /// No description provided for @bdTabChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get bdTabChanges;

  /// No description provided for @bdTabBranches.
  ///
  /// In ko, this message translates to:
  /// **'브랜치'**
  String get bdTabBranches;

  /// No description provided for @bdTabRemotes.
  ///
  /// In ko, this message translates to:
  /// **'원격'**
  String get bdTabRemotes;

  /// No description provided for @bdChangesMessageHint.
  ///
  /// In ko, this message translates to:
  /// **'커밋 메시지'**
  String get bdChangesMessageHint;

  /// No description provided for @bdChangesPrefixTooltip.
  ///
  /// In ko, this message translates to:
  /// **'커밋 종류 접두어'**
  String get bdChangesPrefixTooltip;

  /// No description provided for @bdChangesFirstLineLong.
  ///
  /// In ko, this message translates to:
  /// **'첫 줄이 {length}자입니다. 72자 안으로 줄이면 목록에서 잘리지 않습니다.'**
  String bdChangesFirstLineLong(int length);

  /// No description provided for @bdChangesCommitStaged.
  ///
  /// In ko, this message translates to:
  /// **'커밋 (스테이징 {count})'**
  String bdChangesCommitStaged(int count);

  /// No description provided for @bdChangesCommitAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 스테이징하고 커밋'**
  String get bdChangesCommitAll;

  /// No description provided for @bdChangesConflicts.
  ///
  /// In ko, this message translates to:
  /// **'충돌'**
  String get bdChangesConflicts;

  /// No description provided for @bdChangesStaged.
  ///
  /// In ko, this message translates to:
  /// **'스테이징됨'**
  String get bdChangesStaged;

  /// No description provided for @bdChangesUnstaged.
  ///
  /// In ko, this message translates to:
  /// **'변경됨'**
  String get bdChangesUnstaged;

  /// No description provided for @bdChangesUntracked.
  ///
  /// In ko, this message translates to:
  /// **'추적 안 됨'**
  String get bdChangesUntracked;

  /// No description provided for @bdChangesStageAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 스테이징'**
  String get bdChangesStageAll;

  /// No description provided for @bdChangesUnstageAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 해제'**
  String get bdChangesUnstageAll;

  /// No description provided for @bdChangesStage.
  ///
  /// In ko, this message translates to:
  /// **'스테이징'**
  String get bdChangesStage;

  /// No description provided for @bdChangesUnstage.
  ///
  /// In ko, this message translates to:
  /// **'스테이징 해제'**
  String get bdChangesUnstage;

  /// No description provided for @bdChangesOpenInEditor.
  ///
  /// In ko, this message translates to:
  /// **'편집기로 열기'**
  String get bdChangesOpenInEditor;

  /// No description provided for @bdChangesMarkResolved.
  ///
  /// In ko, this message translates to:
  /// **'해결됨 표시'**
  String get bdChangesMarkResolved;

  /// No description provided for @bdChangesCleanTitle.
  ///
  /// In ko, this message translates to:
  /// **'커밋할 변경이 없습니다'**
  String get bdChangesCleanTitle;

  /// No description provided for @bdChangesCleanMessage.
  ///
  /// In ko, this message translates to:
  /// **'편집기에서 파일을 저장하면 여기에 바로 나타납니다.'**
  String get bdChangesCleanMessage;

  /// No description provided for @bdBranchesTitle.
  ///
  /// In ko, this message translates to:
  /// **'브랜치'**
  String get bdBranchesTitle;

  /// No description provided for @bdBranchesNew.
  ///
  /// In ko, this message translates to:
  /// **'새 브랜치'**
  String get bdBranchesNew;

  /// No description provided for @bdBranchesCreate.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get bdBranchesCreate;

  /// No description provided for @bdBranchesSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 찾기'**
  String get bdBranchesSearchHint;

  /// No description provided for @bdBranchesLocal.
  ///
  /// In ko, this message translates to:
  /// **'로컬'**
  String get bdBranchesLocal;

  /// No description provided for @bdBranchesRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격'**
  String get bdBranchesRemote;

  /// No description provided for @bdBranchesSwitch.
  ///
  /// In ko, this message translates to:
  /// **'전환'**
  String get bdBranchesSwitch;

  /// No description provided for @bdBranchesRename.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get bdBranchesRename;

  /// No description provided for @bdBranchesDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get bdBranchesDelete;

  /// No description provided for @bdBranchesDeleteRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격에서 삭제'**
  String get bdBranchesDeleteRemote;

  /// No description provided for @bdBranchesUpstreamGone.
  ///
  /// In ko, this message translates to:
  /// **'원격 삭제됨'**
  String get bdBranchesUpstreamGone;

  /// No description provided for @bdBranchesUnbornTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 커밋이 없습니다'**
  String get bdBranchesUnbornTitle;

  /// No description provided for @bdBranchesUnbornMessage.
  ///
  /// In ko, this message translates to:
  /// **'첫 커밋을 만들면 브랜치를 만들 수 있습니다.'**
  String get bdBranchesUnbornMessage;

  /// No description provided for @bdBranchesForceDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'병합되지 않은 브랜치입니다'**
  String get bdBranchesForceDeleteTitle;

  /// No description provided for @bdBranchesForceDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}에는 다른 브랜치에 병합되지 않은 커밋이 있습니다. 삭제하면 그 커밋을 찾기 어려워집니다.'**
  String bdBranchesForceDeleteMessage(String name);

  /// No description provided for @bdBranchesDeleteRemoteTitle.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치를 삭제할까요?'**
  String get bdBranchesDeleteRemoteTitle;

  /// No description provided for @bdBranchesDeleteRemoteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{target}에서 {branch} 브랜치를 삭제합니다. 다른 사람도 더 이상 이 브랜치를 받을 수 없습니다.'**
  String bdBranchesDeleteRemoteMessage(String branch, String target);

  /// No description provided for @bdBranchNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 이름'**
  String get bdBranchNameLabel;

  /// No description provided for @bdBranchNameExists.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름의 브랜치가 이미 있습니다'**
  String get bdBranchNameExists;

  /// No description provided for @bdBranchNameEmpty.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get bdBranchNameEmpty;

  /// No description provided for @bdBranchNameInvalidCharacter.
  ///
  /// In ko, this message translates to:
  /// **'공백과 ~ ^ : ? * [ \\ 는 쓸 수 없습니다'**
  String get bdBranchNameInvalidCharacter;

  /// No description provided for @bdBranchNameStartsWithDash.
  ///
  /// In ko, this message translates to:
  /// **'-로 시작할 수 없습니다'**
  String get bdBranchNameStartsWithDash;

  /// No description provided for @bdBranchNameInvalidSequence.
  ///
  /// In ko, this message translates to:
  /// **'.. 이나 //, .으로 시작하는 부분, .lock으로 끝나는 부분은 쓸 수 없습니다'**
  String get bdBranchNameInvalidSequence;

  /// No description provided for @bdBranchNameInvalidEdge.
  ///
  /// In ko, this message translates to:
  /// **'/ 로 시작하거나 / 또는 . 으로 끝날 수 없습니다'**
  String get bdBranchNameInvalidEdge;

  /// No description provided for @bdBranchBaseLabel.
  ///
  /// In ko, this message translates to:
  /// **'어디서 시작할까요'**
  String get bdBranchBaseLabel;

  /// No description provided for @bdBranchBaseCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재 브랜치 ({name})'**
  String bdBranchBaseCurrent(String name);

  /// No description provided for @bdBranchSwitchAfter.
  ///
  /// In ko, this message translates to:
  /// **'만든 뒤 바로 전환'**
  String get bdBranchSwitchAfter;

  /// No description provided for @bdBranchRenameUpstreamNote.
  ///
  /// In ko, this message translates to:
  /// **'원격의 {upstream}은 그대로 남습니다. 새 이름으로 다시 게시하세요.'**
  String bdBranchRenameUpstreamNote(String upstream);

  /// No description provided for @bdRemotesTitle.
  ///
  /// In ko, this message translates to:
  /// **'원격'**
  String get bdRemotesTitle;

  /// No description provided for @bdRemotesAdd.
  ///
  /// In ko, this message translates to:
  /// **'원격 추가'**
  String get bdRemotesAdd;

  /// No description provided for @bdRemotesRename.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get bdRemotesRename;

  /// No description provided for @bdRemotesSetUrl.
  ///
  /// In ko, this message translates to:
  /// **'URL 바꾸기'**
  String get bdRemotesSetUrl;

  /// No description provided for @bdRemotesRemove.
  ///
  /// In ko, this message translates to:
  /// **'원격 삭제'**
  String get bdRemotesRemove;

  /// No description provided for @bdRemotesRemoveTitle.
  ///
  /// In ko, this message translates to:
  /// **'원격을 삭제할까요?'**
  String get bdRemotesRemoveTitle;

  /// No description provided for @bdRemotesRemoveMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 저장소에서 {name} 연결만 지웁니다. 서버의 저장소는 그대로 남습니다.'**
  String bdRemotesRemoveMessage(String name);

  /// No description provided for @bdRemotesEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'이 저장소는 아직 GitHub에 없습니다'**
  String get bdRemotesEmptyTitle;

  /// No description provided for @bdRemotesEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에 새 저장소를 만들고 지금 브랜치를 올립니다.'**
  String get bdRemotesEmptyMessage;

  /// No description provided for @bdRemotesPublishToGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에 올리기'**
  String get bdRemotesPublishToGitHub;

  /// No description provided for @bdRemotesPublishAlsoToGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에도 올리기 (원격 추가)'**
  String get bdRemotesPublishAlsoToGitHub;

  /// No description provided for @bdRemotesPublishConfirm.
  ///
  /// In ko, this message translates to:
  /// **'만들고 올리기'**
  String get bdRemotesPublishConfirm;

  /// No description provided for @bdRemotesNotGitHubNote.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 저장소가 아니라서 PR·릴리스·Actions는 쓸 수 없습니다 (gh는 GitHub 전용).'**
  String get bdRemotesNotGitHubNote;

  /// No description provided for @bdRemotesNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'원격 이름'**
  String get bdRemotesNameLabel;

  /// No description provided for @bdRemotesNameTaken.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름의 원격이 이미 있습니다'**
  String get bdRemotesNameTaken;

  /// No description provided for @bdRemotesNameInvalid.
  ///
  /// In ko, this message translates to:
  /// **'공백과 특수 문자는 쓸 수 없습니다'**
  String get bdRemotesNameInvalid;

  /// No description provided for @bdRemotesUrlLabel.
  ///
  /// In ko, this message translates to:
  /// **'URL'**
  String get bdRemotesUrlLabel;

  /// No description provided for @bdRemotesUseHttps.
  ///
  /// In ko, this message translates to:
  /// **'HTTPS 주소로 바꾸기'**
  String get bdRemotesUseHttps;

  /// No description provided for @bdRemotesUseSsh.
  ///
  /// In ko, this message translates to:
  /// **'SSH 주소로 바꾸기'**
  String get bdRemotesUseSsh;

  /// No description provided for @bdPublishNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'저장소 이름'**
  String get bdPublishNameLabel;

  /// No description provided for @bdPublishNameHelper.
  ///
  /// In ko, this message translates to:
  /// **'조직에 만들려면 조직/이름'**
  String get bdPublishNameHelper;

  /// No description provided for @bdPublishNameInvalid.
  ///
  /// In ko, this message translates to:
  /// **'영문, 숫자, - _ . 만 쓸 수 있습니다'**
  String get bdPublishNameInvalid;

  /// No description provided for @bdPublishDescriptionLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명 (선택)'**
  String get bdPublishDescriptionLabel;

  /// No description provided for @bdPublishPrivate.
  ///
  /// In ko, this message translates to:
  /// **'비공개'**
  String get bdPublishPrivate;

  /// No description provided for @bdPublishPublic.
  ///
  /// In ko, this message translates to:
  /// **'공개'**
  String get bdPublishPublic;

  /// No description provided for @bdPublishNoCommitsNote.
  ///
  /// In ko, this message translates to:
  /// **'아직 커밋이 없어서 저장소만 만듭니다. 첫 커밋 뒤에 Push하세요.'**
  String get bdPublishNoCommitsNote;

  /// No description provided for @bdEditorTitle.
  ///
  /// In ko, this message translates to:
  /// **'파일을 열 편집기'**
  String get bdEditorTitle;

  /// No description provided for @bdEditorMessage.
  ///
  /// In ko, this message translates to:
  /// **'편집기 명령을 적으면 파일과 저장소 폴더를 그 편집기로 엽니다. 비워 두면 파일은 OS 기본 앱으로, 폴더는 VS Code로 엽니다.'**
  String get bdEditorMessage;

  /// No description provided for @bdEditorLabel.
  ///
  /// In ko, this message translates to:
  /// **'편집기 명령'**
  String get bdEditorLabel;

  /// No description provided for @bdLogTitle.
  ///
  /// In ko, this message translates to:
  /// **'명령 기록'**
  String get bdLogTitle;

  /// No description provided for @bdLogClear.
  ///
  /// In ko, this message translates to:
  /// **'지우기'**
  String get bdLogClear;

  /// No description provided for @bdLogEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 실행한 명령이 없습니다'**
  String get bdLogEmpty;

  /// No description provided for @bdLogToggleTooltip.
  ///
  /// In ko, this message translates to:
  /// **'명령 기록 펼치기/접기'**
  String get bdLogToggleTooltip;

  /// No description provided for @bdDoneFetch.
  ///
  /// In ko, this message translates to:
  /// **'원격 정보를 가져왔습니다'**
  String get bdDoneFetch;

  /// No description provided for @bdDonePull.
  ///
  /// In ko, this message translates to:
  /// **'Pull을 마쳤습니다'**
  String get bdDonePull;

  /// No description provided for @bdDonePush.
  ///
  /// In ko, this message translates to:
  /// **'Push를 마쳤습니다'**
  String get bdDonePush;

  /// No description provided for @bdDonePublish.
  ///
  /// In ko, this message translates to:
  /// **'{branch} 브랜치를 게시했습니다'**
  String bdDonePublish(String branch);

  /// No description provided for @bdDoneCommit.
  ///
  /// In ko, this message translates to:
  /// **'커밋했습니다'**
  String get bdDoneCommit;

  /// No description provided for @bdDoneSwitch.
  ///
  /// In ko, this message translates to:
  /// **'{name}(으)로 전환했습니다'**
  String bdDoneSwitch(String name);

  /// No description provided for @bdDoneCreateBranch.
  ///
  /// In ko, this message translates to:
  /// **'{name} 브랜치를 만들었습니다'**
  String bdDoneCreateBranch(String name);

  /// No description provided for @bdDoneRenameBranch.
  ///
  /// In ko, this message translates to:
  /// **'이름을 {name}(으)로 바꿨습니다'**
  String bdDoneRenameBranch(String name);

  /// No description provided for @bdDoneDeleteBranch.
  ///
  /// In ko, this message translates to:
  /// **'{name} 브랜치를 삭제했습니다'**
  String bdDoneDeleteBranch(String name);

  /// No description provided for @bdDoneAddRemote.
  ///
  /// In ko, this message translates to:
  /// **'{name} 원격을 추가했습니다'**
  String bdDoneAddRemote(String name);

  /// No description provided for @bdDoneRenameRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격 이름을 {name}(으)로 바꿨습니다'**
  String bdDoneRenameRemote(String name);

  /// No description provided for @bdDoneSetRemoteUrl.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 URL을 바꿨습니다'**
  String bdDoneSetRemoteUrl(String name);

  /// No description provided for @bdDoneRemoveRemote.
  ///
  /// In ko, this message translates to:
  /// **'{name} 원격을 삭제했습니다'**
  String bdDoneRemoveRemote(String name);

  /// No description provided for @bdDonePublishToGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에 {name} 저장소를 만들었습니다'**
  String bdDonePublishToGitHub(String name);

  /// No description provided for @bdDoneAbort.
  ///
  /// In ko, this message translates to:
  /// **'중단했습니다'**
  String get bdDoneAbort;

  /// No description provided for @bdDoneContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속 진행했습니다'**
  String get bdDoneContinue;

  /// No description provided for @bdErrorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'명령이 실패했습니다. 아래 원문을 확인하세요.'**
  String get bdErrorGeneric;

  /// No description provided for @bdErrorPushRejected.
  ///
  /// In ko, this message translates to:
  /// **'Push가 거부됐습니다. 원격에 내게 없는 커밋이 있어서입니다. 먼저 Pull 하세요.'**
  String get bdErrorPushRejected;

  /// No description provided for @bdErrorAuthFailed.
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했습니다. gh auth login으로 로그인했는지, SSH 키가 등록됐는지 확인하세요.'**
  String get bdErrorAuthFailed;

  /// No description provided for @bdErrorConflict.
  ///
  /// In ko, this message translates to:
  /// **'충돌이 났습니다. 변경 탭에서 충돌 파일을 편집기로 열어 고친 뒤 해결됨을 누르세요.'**
  String get bdErrorConflict;

  /// No description provided for @bdErrorLocalChanges.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경이 덮어써질 수 있어서 멈췄습니다. 먼저 커밋하세요.'**
  String get bdErrorLocalChanges;

  /// No description provided for @bdErrorNotFastForward.
  ///
  /// In ko, this message translates to:
  /// **'기록이 갈라져서 fast-forward로 받을 수 없습니다. Pull 방식을 병합이나 rebase로 바꾸세요.'**
  String get bdErrorNotFastForward;

  /// No description provided for @bdErrorProtectedBranch.
  ///
  /// In ko, this message translates to:
  /// **'보호된 브랜치라서 직접 Push할 수 없습니다. 새 브랜치로 올리고 PR을 만드세요.'**
  String get bdErrorProtectedBranch;

  /// No description provided for @bdErrorBranchNotMerged.
  ///
  /// In ko, this message translates to:
  /// **'병합되지 않은 커밋이 있는 브랜치입니다.'**
  String get bdErrorBranchNotMerged;

  /// No description provided for @bdErrorNoUpstream.
  ///
  /// In ko, this message translates to:
  /// **'추적 브랜치가 없습니다. 먼저 게시(Publish)하세요.'**
  String get bdErrorNoUpstream;

  /// No description provided for @bdErrorAlreadyExists.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름이 이미 있습니다.'**
  String get bdErrorAlreadyExists;

  /// No description provided for @bdErrorRepositoryNotFound.
  ///
  /// In ko, this message translates to:
  /// **'원격 저장소를 찾을 수 없습니다. URL과 접근 권한을 확인하세요.'**
  String get bdErrorRepositoryNotFound;

  /// No description provided for @bdErrorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 네트워크를 확인하세요.'**
  String get bdErrorNetwork;

  /// No description provided for @bdErrorNotInstalled.
  ///
  /// In ko, this message translates to:
  /// **'프로그램을 찾을 수 없습니다. 메뉴의 환경 점검을 확인하세요.'**
  String get bdErrorNotInstalled;

  /// No description provided for @bdErrorBranchInOtherWorktree.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 다른 worktree({path})에 체크아웃되어 있습니다. git은 한 브랜치를 한 번에 한 worktree에서만 체크아웃할 수 있습니다.'**
  String bdErrorBranchInOtherWorktree(String path);

  /// No description provided for @bdOpenWorktreeFolder.
  ///
  /// In ko, this message translates to:
  /// **'그 폴더 열기'**
  String get bdOpenWorktreeFolder;

  /// No description provided for @bdTimeJustNow.
  ///
  /// In ko, this message translates to:
  /// **'방금'**
  String get bdTimeJustNow;

  /// No description provided for @bdTimeMinutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{n}분 전'**
  String bdTimeMinutesAgo(int n);

  /// No description provided for @bdTimeHoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{n}시간 전'**
  String bdTimeHoursAgo(int n);

  /// No description provided for @bdTimeDaysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{n}일 전'**
  String bdTimeDaysAgo(int n);

  /// No description provided for @bdHelpTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이게 뭔가요?'**
  String get bdHelpTooltip;

  /// No description provided for @bdHelpSectionWord.
  ///
  /// In ko, this message translates to:
  /// **'낱말 뜻'**
  String get bdHelpSectionWord;

  /// No description provided for @bdHelpSectionInGit.
  ///
  /// In ko, this message translates to:
  /// **'git에서는'**
  String get bdHelpSectionInGit;

  /// No description provided for @bdHelpSectionWhy.
  ///
  /// In ko, this message translates to:
  /// **'왜 · 언제 쓰나'**
  String get bdHelpSectionWhy;

  /// No description provided for @bdHelpSectionLinks.
  ///
  /// In ko, this message translates to:
  /// **'더 알아보기'**
  String get bdHelpSectionLinks;

  /// No description provided for @bdHelpCaptionBefore.
  ///
  /// In ko, this message translates to:
  /// **'전'**
  String get bdHelpCaptionBefore;

  /// No description provided for @bdHelpCaptionAfter.
  ///
  /// In ko, this message translates to:
  /// **'후'**
  String get bdHelpCaptionAfter;

  /// No description provided for @bdHelpCaptionAfterFetch.
  ///
  /// In ko, this message translates to:
  /// **'Fetch 후 — 내 main은 그대로'**
  String get bdHelpCaptionAfterFetch;

  /// No description provided for @bdHelpCaptionAfterPull.
  ///
  /// In ko, this message translates to:
  /// **'Pull 후 — 내 main도 따라감'**
  String get bdHelpCaptionAfterPull;

  /// No description provided for @bdHelpCaptionAheadOne.
  ///
  /// In ko, this message translates to:
  /// **'feature가 origin/feature보다 커밋 하나 앞섬 (↑1)'**
  String get bdHelpCaptionAheadOne;

  /// No description provided for @bdHelpLinkBranchingBasics.
  ///
  /// In ko, this message translates to:
  /// **'Pro Git — 브랜치와 Merge의 기초'**
  String get bdHelpLinkBranchingBasics;

  /// No description provided for @bdHelpLinkRemoteBranches.
  ///
  /// In ko, this message translates to:
  /// **'Pro Git — 리모트 브랜치'**
  String get bdHelpLinkRemoteBranches;

  /// No description provided for @bdHelpLinkRebasing.
  ///
  /// In ko, this message translates to:
  /// **'Pro Git — Rebase 하기'**
  String get bdHelpLinkRebasing;

  /// No description provided for @bdHelpFetchVsPullTitle.
  ///
  /// In ko, this message translates to:
  /// **'Fetch와 Pull'**
  String get bdHelpFetchVsPullTitle;

  /// No description provided for @bdHelpFetchVsPullWord.
  ///
  /// In ko, this message translates to:
  /// **'fetch는 \'가서 가져오다\', pull은 \'끌어당기다\'.'**
  String get bdHelpFetchVsPullWord;

  /// No description provided for @bdHelpFetchVsPullInGit.
  ///
  /// In ko, this message translates to:
  /// **'Fetch는 원격(GitHub)에 새로 생긴 커밋을 내 컴퓨터로 가져와 origin/main 같은 \'원격 이름표\'만 옮깁니다. 내 브랜치와 파일은 건드리지 않습니다. Pull은 Fetch를 한 뒤, 가져온 커밋을 내 브랜치에 합칩니다.'**
  String get bdHelpFetchVsPullInGit;

  /// No description provided for @bdHelpFetchVsPullWhy.
  ///
  /// In ko, this message translates to:
  /// **'무엇이 바뀌었는지 먼저 보고 싶으면 Fetch — 안전하고 언제 해도 됩니다. 바로 최신으로 맞추려면 Pull. 커밋하지 않은 변경이 있으면 Pull이 멈출 수 있으니 먼저 커밋하세요.'**
  String get bdHelpFetchVsPullWhy;

  /// No description provided for @bdHelpUpstreamTitle.
  ///
  /// In ko, this message translates to:
  /// **'추적 브랜치 (upstream)와 origin'**
  String get bdHelpUpstreamTitle;

  /// No description provided for @bdHelpUpstreamWord.
  ///
  /// In ko, this message translates to:
  /// **'upstream은 \'상류\'. 물이 흘러오는 쪽입니다. origin은 \'출처, 기원\'.'**
  String get bdHelpUpstreamWord;

  /// No description provided for @bdHelpUpstreamInGit.
  ///
  /// In ko, this message translates to:
  /// **'origin은 저장소를 받아 온 원격(대개 GitHub)에 붙는 기본 이름입니다. 내 브랜치가 짝지어 둔 원격 브랜치(예: origin/feature)를 추적 브랜치, 곧 upstream이라고 합니다. ↑↓ 숫자는 이 짝과 비교한 것입니다.'**
  String get bdHelpUpstreamInGit;

  /// No description provided for @bdHelpUpstreamWhy.
  ///
  /// In ko, this message translates to:
  /// **'짝이 있어야 그냥 Push, Pull만 눌러도 어디로 보내고 어디서 받을지 압니다. 새 브랜치에는 짝이 없어서 처음 한 번은 \'게시\'(git push -u)로 짝을 지어 줍니다.'**
  String get bdHelpUpstreamWhy;

  /// No description provided for @bdHelpFastForwardTitle.
  ///
  /// In ko, this message translates to:
  /// **'Fast-forward (빨리 감기)'**
  String get bdHelpFastForwardTitle;

  /// No description provided for @bdHelpFastForwardWord.
  ///
  /// In ko, this message translates to:
  /// **'테이프나 영상을 앞으로 빨리 감는 것.'**
  String get bdHelpFastForwardWord;

  /// No description provided for @bdHelpFastForwardInGit.
  ///
  /// In ko, this message translates to:
  /// **'내 브랜치가 갈라진 적 없이 뒤처져 있기만 할 때, 새 커밋을 만들지 않고 브랜치 이름표를 최신 커밋 위치로 앞으로 옮기기만 합니다. 이미 있는 커밋을 따라 \'앞으로 감기\'만 하므로 이렇게 부릅니다.'**
  String get bdHelpFastForwardInGit;

  /// No description provided for @bdHelpFastForwardWhy.
  ///
  /// In ko, this message translates to:
  /// **'기록이 한 줄로 깔끔하고 합칠 것이 없으니 충돌도 없습니다. 양쪽에 서로 다른 새 커밋이 있으면(갈라졌으면) 빨리 감을 수 없어서, \'Fast-forward만\'은 멈추고 병합이나 rebase가 필요합니다. Push가 non-fast-forward로 거부되는 것도 같은 이유입니다.'**
  String get bdHelpFastForwardWhy;

  /// No description provided for @bdHelpMergeCommitTitle.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋 (merge commit)'**
  String get bdHelpMergeCommitTitle;

  /// No description provided for @bdHelpMergeCommitWord.
  ///
  /// In ko, this message translates to:
  /// **'merge는 \'합치다\', 두 길이 하나로 합류하는 것.'**
  String get bdHelpMergeCommitWord;

  /// No description provided for @bdHelpMergeCommitInGit.
  ///
  /// In ko, this message translates to:
  /// **'갈라진 두 기록을 그대로 두고, 둘을 부모로 가진 새 커밋(병합 커밋)을 하나 만들어 합칩니다. 누가 언제 무엇을 합쳤는지 기록에 그대로 남습니다.'**
  String get bdHelpMergeCommitInGit;

  /// No description provided for @bdHelpMergeCommitWhy.
  ///
  /// In ko, this message translates to:
  /// **'이미 올린 커밋을 바꾸지 않아 가장 안전합니다. 다른 사람과 같이 쓰는 브랜치에 알맞습니다. 대신 기록에 병합 커밋이 늘어 조금 복잡해 보입니다.'**
  String get bdHelpMergeCommitWhy;

  /// No description provided for @bdHelpRebaseTitle.
  ///
  /// In ko, this message translates to:
  /// **'Rebase'**
  String get bdHelpRebaseTitle;

  /// No description provided for @bdHelpRebaseWord.
  ///
  /// In ko, this message translates to:
  /// **'base는 \'밑받침\', rebase는 \'밑받침을 다시 놓다\'.'**
  String get bdHelpRebaseWord;

  /// No description provided for @bdHelpRebaseInGit.
  ///
  /// In ko, this message translates to:
  /// **'내 커밋들을 떼어 내서, 새로 받아온 커밋 뒤에 차례로 다시 붙입니다. 내용은 같지만 새 커밋(C\', D\')으로 다시 만들어지고, 기록은 한 줄이 됩니다.'**
  String get bdHelpRebaseInGit;

  /// No description provided for @bdHelpRebaseWhy.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋 없이 기록이 깔끔합니다. 아직 Push하지 않은 내 커밋에만 쓰세요. 이미 올린 커밋을 rebase하면 다른 사람의 기록과 어긋나서 강제 Push가 필요해집니다.'**
  String get bdHelpRebaseWhy;

  /// No description provided for @bdTabTags.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get bdTabTags;

  /// No description provided for @bdTabRelease.
  ///
  /// In ko, this message translates to:
  /// **'릴리스'**
  String get bdTabRelease;

  /// No description provided for @bdTabPr.
  ///
  /// In ko, this message translates to:
  /// **'PR'**
  String get bdTabPr;

  /// No description provided for @bdBranchesMergeInto.
  ///
  /// In ko, this message translates to:
  /// **'{head}(으)로 병합해 오기'**
  String bdBranchesMergeInto(String head);

  /// No description provided for @bdMergeTitle.
  ///
  /// In ko, this message translates to:
  /// **'{source} → {into} 병합'**
  String bdMergeTitle(String source, String into);

  /// No description provided for @bdMergeNothing.
  ///
  /// In ko, this message translates to:
  /// **'{source}에는 {into}에 없는 커밋이 없습니다'**
  String bdMergeNothing(String source, String into);

  /// No description provided for @bdMergeIncoming.
  ///
  /// In ko, this message translates to:
  /// **'들어올 커밋 {count}개'**
  String bdMergeIncoming(int count);

  /// No description provided for @bdMergeFastForward.
  ///
  /// In ko, this message translates to:
  /// **'Fast-forward'**
  String get bdMergeFastForward;

  /// No description provided for @bdMergeFastForwardWhen.
  ///
  /// In ko, this message translates to:
  /// **'새 커밋 없이 이름표만 앞으로 옮깁니다. 기록이 한 줄로 남습니다.'**
  String get bdMergeFastForwardWhen;

  /// No description provided for @bdMergeFastForwardDisabled.
  ///
  /// In ko, this message translates to:
  /// **'현재 브랜치에도 새 커밋이 있어서(갈라져서) 쓸 수 없습니다.'**
  String get bdMergeFastForwardDisabled;

  /// No description provided for @bdMergeMergeCommit.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋'**
  String get bdMergeMergeCommit;

  /// No description provided for @bdMergeMergeCommitWhen.
  ///
  /// In ko, this message translates to:
  /// **'두 기록을 그대로 두고 병합 커밋으로 합칩니다. 가장 안전합니다.'**
  String get bdMergeMergeCommitWhen;

  /// No description provided for @bdMergeSquash.
  ///
  /// In ko, this message translates to:
  /// **'Squash'**
  String get bdMergeSquash;

  /// No description provided for @bdMergeSquashWhen.
  ///
  /// In ko, this message translates to:
  /// **'브랜치의 커밋을 하나로 눌러 합칩니다. 기능 하나 = 커밋 하나.'**
  String get bdMergeSquashWhen;

  /// No description provided for @bdMergeSquashNote.
  ///
  /// In ko, this message translates to:
  /// **'squash 뒤 {source}를 계속 쓰면 같은 변경이 다시 충돌할 수 있습니다. 병합 후 브랜치를 지우는 것을 권합니다.'**
  String bdMergeSquashNote(String source);

  /// No description provided for @bdMergeMessageLabel.
  ///
  /// In ko, this message translates to:
  /// **'커밋 메시지'**
  String get bdMergeMessageLabel;

  /// No description provided for @bdMergeConfirm.
  ///
  /// In ko, this message translates to:
  /// **'병합'**
  String get bdMergeConfirm;

  /// No description provided for @bdDoneMerge.
  ///
  /// In ko, this message translates to:
  /// **'{source}을(를) {into}(으)로 병합했습니다'**
  String bdDoneMerge(String source, String into);

  /// No description provided for @bdTagsTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get bdTagsTitle;

  /// No description provided for @bdTagsNew.
  ///
  /// In ko, this message translates to:
  /// **'새 태그'**
  String get bdTagsNew;

  /// No description provided for @bdTagsCreate.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get bdTagsCreate;

  /// No description provided for @bdTagsCreateAndPush.
  ///
  /// In ko, this message translates to:
  /// **'만들고 push'**
  String get bdTagsCreateAndPush;

  /// No description provided for @bdTagsPushAll.
  ///
  /// In ko, this message translates to:
  /// **'원격에 없는 태그 {count}개 push'**
  String bdTagsPushAll(int count);

  /// No description provided for @bdTagsPushed.
  ///
  /// In ko, this message translates to:
  /// **'원격에 있음'**
  String get bdTagsPushed;

  /// No description provided for @bdTagsLocalOnly.
  ///
  /// In ko, this message translates to:
  /// **'내 컴퓨터에만 있음'**
  String get bdTagsLocalOnly;

  /// No description provided for @bdTagsLightweight.
  ///
  /// In ko, this message translates to:
  /// **'가벼운 태그'**
  String get bdTagsLightweight;

  /// No description provided for @bdTagsAnnotated.
  ///
  /// In ko, this message translates to:
  /// **'주석 태그'**
  String get bdTagsAnnotated;

  /// No description provided for @bdTagsPush.
  ///
  /// In ko, this message translates to:
  /// **'Push'**
  String get bdTagsPush;

  /// No description provided for @bdTagsDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get bdTagsDelete;

  /// No description provided for @bdTagsDeleteRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격에서 삭제'**
  String get bdTagsDeleteRemote;

  /// No description provided for @bdTagsDeleteRemoteTitle.
  ///
  /// In ko, this message translates to:
  /// **'원격 태그를 삭제할까요?'**
  String get bdTagsDeleteRemoteTitle;

  /// No description provided for @bdTagsDeleteRemoteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{target}에서 {tag} 태그를 삭제합니다. 이미 받아 간 사람이 있을 수 있으니, 같은 이름을 다시 쓰기보다 다음 번호를 쓰세요.'**
  String bdTagsDeleteRemoteMessage(String tag, String target);

  /// No description provided for @bdTagsEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 태그가 없습니다'**
  String get bdTagsEmptyTitle;

  /// No description provided for @bdTagsEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'태그는 특정 커밋에 붙이는 이름표입니다. 보통 v1.0.0처럼 릴리스 버전에 씁니다.'**
  String get bdTagsEmptyMessage;

  /// No description provided for @bdTagsPushAfter.
  ///
  /// In ko, this message translates to:
  /// **'만든 뒤 {remote}에 push'**
  String bdTagsPushAfter(String remote);

  /// No description provided for @bdTagNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'태그 이름'**
  String get bdTagNameLabel;

  /// No description provided for @bdTagNameExists.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름의 태그가 이미 있습니다'**
  String get bdTagNameExists;

  /// No description provided for @bdTagNameInvalid.
  ///
  /// In ko, this message translates to:
  /// **'공백, .., ~ ^ : ? * [ \\ 는 쓸 수 없습니다'**
  String get bdTagNameInvalid;

  /// No description provided for @bdTagNameNotSemVer.
  ///
  /// In ko, this message translates to:
  /// **'버전 형식(v1.2.3)이 아닙니다. 만들 수는 있지만 릴리스에는 버전 형식을 권합니다.'**
  String get bdTagNameNotSemVer;

  /// No description provided for @bdTagNameMissingV.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 태그는 v를 붙이는 것이 관례입니다 (v1.2.3).'**
  String get bdTagNameMissingV;

  /// No description provided for @bdTagMessageLabel.
  ///
  /// In ko, this message translates to:
  /// **'메시지'**
  String get bdTagMessageLabel;

  /// No description provided for @bdTagTargetLabel.
  ///
  /// In ko, this message translates to:
  /// **'어느 커밋에 달까요'**
  String get bdTagTargetLabel;

  /// No description provided for @bdTagTargetHead.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치 ({name})'**
  String bdTagTargetHead(String name);

  /// No description provided for @bdDoneCreateTag.
  ///
  /// In ko, this message translates to:
  /// **'{name} 태그를 만들었습니다'**
  String bdDoneCreateTag(String name);

  /// No description provided for @bdDonePushTags.
  ///
  /// In ko, this message translates to:
  /// **'태그 {count}개를 push했습니다'**
  String bdDonePushTags(int count);

  /// No description provided for @bdDoneDeleteTag.
  ///
  /// In ko, this message translates to:
  /// **'{name} 태그를 삭제했습니다'**
  String bdDoneDeleteTag(String name);

  /// No description provided for @bdDoneDeleteRemoteTag.
  ///
  /// In ko, this message translates to:
  /// **'원격에서 {name} 태그를 삭제했습니다'**
  String bdDoneDeleteRemoteTag(String name);

  /// No description provided for @bdPrTitle.
  ///
  /// In ko, this message translates to:
  /// **'Pull Request'**
  String get bdPrTitle;

  /// No description provided for @bdPrCreate.
  ///
  /// In ko, this message translates to:
  /// **'PR 만들기'**
  String get bdPrCreate;

  /// No description provided for @bdPrPublishAndCreate.
  ///
  /// In ko, this message translates to:
  /// **'게시하고 PR 만들기'**
  String get bdPrPublishAndCreate;

  /// No description provided for @bdPrTitleLabel.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get bdPrTitleLabel;

  /// No description provided for @bdPrBodyLabel.
  ///
  /// In ko, this message translates to:
  /// **'본문'**
  String get bdPrBodyLabel;

  /// No description provided for @bdPrBodyChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경 내용'**
  String get bdPrBodyChanges;

  /// No description provided for @bdPrDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안으로 만들기'**
  String get bdPrDraft;

  /// No description provided for @bdPrNotGitHubTitle.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 저장소가 아닙니다'**
  String get bdPrNotGitHubTitle;

  /// No description provided for @bdPrNotGitHubMessage.
  ///
  /// In ko, this message translates to:
  /// **'Pull Request는 GitHub 저장소에서만 쓸 수 있습니다 — gh는 GitHub 전용 도구입니다.'**
  String get bdPrNotGitHubMessage;

  /// No description provided for @bdPrGhRequiredTitle.
  ///
  /// In ko, this message translates to:
  /// **'gh가 필요합니다'**
  String get bdPrGhRequiredTitle;

  /// No description provided for @bdPrDetached.
  ///
  /// In ko, this message translates to:
  /// **'브랜치에 있지 않습니다'**
  String get bdPrDetached;

  /// No description provided for @bdPrOnDefaultTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치에 있습니다'**
  String get bdPrOnDefaultTitle;

  /// No description provided for @bdPrOnDefaultMessage.
  ///
  /// In ko, this message translates to:
  /// **'PR은 작업 브랜치에서 만듭니다. 브랜치 탭에서 새 브랜치를 만드세요.'**
  String get bdPrOnDefaultMessage;

  /// No description provided for @bdPrNoneTitle.
  ///
  /// In ko, this message translates to:
  /// **'{head}에는 아직 PR이 없습니다'**
  String bdPrNoneTitle(String head);

  /// No description provided for @bdPrNoneMessage.
  ///
  /// In ko, this message translates to:
  /// **'{base}(으)로 합칠 PR을 만들면 GitHub에서 검토와 검사를 거쳐 병합합니다.'**
  String bdPrNoneMessage(String base);

  /// No description provided for @bdPrOpenOnGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에서 보기'**
  String get bdPrOpenOnGitHub;

  /// No description provided for @bdPrStateOpen.
  ///
  /// In ko, this message translates to:
  /// **'열림'**
  String get bdPrStateOpen;

  /// No description provided for @bdPrStateDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안'**
  String get bdPrStateDraft;

  /// No description provided for @bdPrStateMerged.
  ///
  /// In ko, this message translates to:
  /// **'병합됨'**
  String get bdPrStateMerged;

  /// No description provided for @bdPrStateClosed.
  ///
  /// In ko, this message translates to:
  /// **'닫힘'**
  String get bdPrStateClosed;

  /// No description provided for @bdPrNoChecks.
  ///
  /// In ko, this message translates to:
  /// **'검사 없음'**
  String get bdPrNoChecks;

  /// No description provided for @bdPrChecksPassed.
  ///
  /// In ko, this message translates to:
  /// **'통과 {n}'**
  String bdPrChecksPassed(int n);

  /// No description provided for @bdPrChecksFailed.
  ///
  /// In ko, this message translates to:
  /// **'실패 {n}'**
  String bdPrChecksFailed(int n);

  /// No description provided for @bdPrChecksPending.
  ///
  /// In ko, this message translates to:
  /// **'진행 중 {n}'**
  String bdPrChecksPending(int n);

  /// No description provided for @bdPrApproved.
  ///
  /// In ko, this message translates to:
  /// **'승인됨'**
  String get bdPrApproved;

  /// No description provided for @bdPrReviewRequired.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 필요'**
  String get bdPrReviewRequired;

  /// No description provided for @bdPrBlockedDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안 PR은 병합할 수 없습니다. GitHub에서 \'검토 준비 완료\'로 바꾸세요.'**
  String get bdPrBlockedDraft;

  /// No description provided for @bdPrBlockedConflict.
  ///
  /// In ko, this message translates to:
  /// **'기준 브랜치와 충돌이 있습니다. 기준 브랜치를 병합해 와서 충돌을 해결하세요.'**
  String get bdPrBlockedConflict;

  /// No description provided for @bdPrBlockedChecks.
  ///
  /// In ko, this message translates to:
  /// **'실패한 검사가 있습니다: {names}'**
  String bdPrBlockedChecks(String names);

  /// No description provided for @bdPrBlockedPending.
  ///
  /// In ko, this message translates to:
  /// **'검사 {count}개가 아직 진행 중입니다.'**
  String bdPrBlockedPending(int count);

  /// No description provided for @bdPrBlockedReview.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 승인이 필요할 수 있습니다. 병합이 거부되면 GitHub에서 확인하세요.'**
  String get bdPrBlockedReview;

  /// No description provided for @bdPrMethodMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋 (merge)'**
  String get bdPrMethodMerge;

  /// No description provided for @bdPrMethodSquash.
  ///
  /// In ko, this message translates to:
  /// **'Squash 후 병합'**
  String get bdPrMethodSquash;

  /// No description provided for @bdPrMethodRebase.
  ///
  /// In ko, this message translates to:
  /// **'Rebase 후 병합'**
  String get bdPrMethodRebase;

  /// No description provided for @bdPrDeleteBranch.
  ///
  /// In ko, this message translates to:
  /// **'병합 후 브랜치 삭제'**
  String get bdPrDeleteBranch;

  /// No description provided for @bdPrMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합하기'**
  String get bdPrMerge;

  /// No description provided for @bdPrMerging.
  ///
  /// In ko, this message translates to:
  /// **'병합하는 중…'**
  String get bdPrMerging;

  /// No description provided for @bdDonePrCreated.
  ///
  /// In ko, this message translates to:
  /// **'PR을 만들었습니다'**
  String get bdDonePrCreated;

  /// No description provided for @bdDonePrMerged.
  ///
  /// In ko, this message translates to:
  /// **'PR #{number}을(를) 병합했습니다'**
  String bdDonePrMerged(int number);

  /// No description provided for @bdReleaseTitle.
  ///
  /// In ko, this message translates to:
  /// **'릴리스'**
  String get bdReleaseTitle;

  /// No description provided for @bdReleaseLatest.
  ///
  /// In ko, this message translates to:
  /// **'마지막 릴리스 {tag}'**
  String bdReleaseLatest(String tag);

  /// No description provided for @bdReleaseNoTags.
  ///
  /// In ko, this message translates to:
  /// **'아직 릴리스가 없습니다'**
  String get bdReleaseNoTags;

  /// No description provided for @bdReleaseIntro.
  ///
  /// In ko, this message translates to:
  /// **'버전 올리기 → PR → 병합 → 태그 → CI 확인을 차례로 안내합니다.'**
  String get bdReleaseIntro;

  /// No description provided for @bdReleaseNeedsGitHub.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 마법사는 GitHub 저장소에서 쓸 수 있습니다. 태그는 태그 탭에서 만들 수 있습니다.'**
  String get bdReleaseNeedsGitHub;

  /// No description provided for @bdReleaseStart.
  ///
  /// In ko, this message translates to:
  /// **'새 릴리스'**
  String get bdReleaseStart;

  /// No description provided for @bdReleaseNew.
  ///
  /// In ko, this message translates to:
  /// **'새 릴리스'**
  String get bdReleaseNew;

  /// No description provided for @bdReleaseNewVersion.
  ///
  /// In ko, this message translates to:
  /// **'새 릴리스 {tag}'**
  String bdReleaseNewVersion(String tag);

  /// No description provided for @bdReleaseCancel.
  ///
  /// In ko, this message translates to:
  /// **'그만두기'**
  String get bdReleaseCancel;

  /// No description provided for @bdReleaseCancelTitle.
  ///
  /// In ko, this message translates to:
  /// **'릴리스를 그만둘까요?'**
  String get bdReleaseCancelTitle;

  /// No description provided for @bdReleaseCancelMessage.
  ///
  /// In ko, this message translates to:
  /// **'지금까지 만든 {branch} 브랜치와 PR은 그대로 남습니다. 필요 없으면 직접 지우세요.'**
  String bdReleaseCancelMessage(String branch);

  /// No description provided for @bdReleaseCancelAfterTag.
  ///
  /// In ko, this message translates to:
  /// **'태그는 이미 push되었습니다. 마법사만 닫고, CI와 릴리스는 GitHub에서 확인하세요.'**
  String get bdReleaseCancelAfterTag;

  /// No description provided for @bdReleaseDone.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 릴리스를 마쳤습니다'**
  String bdReleaseDone(String tag);

  /// No description provided for @bdReleasePrerelease.
  ///
  /// In ko, this message translates to:
  /// **'프리릴리스'**
  String get bdReleasePrerelease;

  /// No description provided for @bdReleasePushAndPr.
  ///
  /// In ko, this message translates to:
  /// **'push하고 PR 만들기'**
  String get bdReleasePushAndPr;

  /// No description provided for @bdStepCheck.
  ///
  /// In ko, this message translates to:
  /// **'점검'**
  String get bdStepCheck;

  /// No description provided for @bdStepVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get bdStepVersion;

  /// No description provided for @bdStepPr.
  ///
  /// In ko, this message translates to:
  /// **'PR'**
  String get bdStepPr;

  /// No description provided for @bdStepMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합'**
  String get bdStepMerge;

  /// No description provided for @bdStepTag.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get bdStepTag;

  /// No description provided for @bdStepNotes.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 노트'**
  String get bdStepNotes;

  /// No description provided for @bdStepNotesCi.
  ///
  /// In ko, this message translates to:
  /// **'노트 (CI 릴리스 후)'**
  String get bdStepNotesCi;

  /// No description provided for @bdStepNotesCiSummary.
  ///
  /// In ko, this message translates to:
  /// **'CI가 릴리스를 만듭니다'**
  String get bdStepNotesCiSummary;

  /// No description provided for @bdStepCi.
  ///
  /// In ko, this message translates to:
  /// **'CI 확인'**
  String get bdStepCi;

  /// No description provided for @bdStepNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get bdStepNext;

  /// No description provided for @bdStepCheckDone.
  ///
  /// In ko, this message translates to:
  /// **'모두 통과'**
  String get bdStepCheckDone;

  /// No description provided for @bdStepMergeDone.
  ///
  /// In ko, this message translates to:
  /// **'PR #{number} 병합됨'**
  String bdStepMergeDone(int number);

  /// No description provided for @bdCheckCleanTree.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경이 없다'**
  String get bdCheckCleanTree;

  /// No description provided for @bdCheckShowChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경 보기'**
  String get bdCheckShowChanges;

  /// No description provided for @bdCheckOnDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치({branch})에 있다'**
  String bdCheckOnDefault(String branch);

  /// No description provided for @bdCheckSynced.
  ///
  /// In ko, this message translates to:
  /// **'받을 커밋도 보낼 커밋도 없다'**
  String get bdCheckSynced;

  /// No description provided for @bdCheckGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 원격과 gh 로그인'**
  String get bdCheckGitHub;

  /// No description provided for @bdCheckGitBash.
  ///
  /// In ko, this message translates to:
  /// **'Git for Windows의 bash (버전 올림 스크립트용)'**
  String get bdCheckGitBash;

  /// No description provided for @bdCheckChangesSince.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 이후 커밋 {count}개'**
  String bdCheckChangesSince(int count, String tag);

  /// No description provided for @bdCheckFirstRelease.
  ///
  /// In ko, this message translates to:
  /// **'첫 릴리스입니다'**
  String get bdCheckFirstRelease;

  /// No description provided for @bdCheckNoWorkflow.
  ///
  /// In ko, this message translates to:
  /// **'태그로 도는 워크플로가 없습니다. 앱이 GitHub 릴리스를 만듭니다.'**
  String get bdCheckNoWorkflow;

  /// No description provided for @bdCheckWorkflowCi.
  ///
  /// In ko, this message translates to:
  /// **'{file}이(가) 태그 push로 릴리스를 만듭니다. 앱은 태그까지 달고 CI를 지켜봅니다.'**
  String bdCheckWorkflowCi(String file);

  /// No description provided for @bdCheckWorkflowOther.
  ///
  /// In ko, this message translates to:
  /// **'{file}이(가) 태그 push로 돕니다.'**
  String bdCheckWorkflowOther(String file);

  /// No description provided for @bdManualBuildTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그 전 수동 빌드 (권장)'**
  String get bdManualBuildTitle;

  /// No description provided for @bdManualBuildWhy.
  ///
  /// In ko, this message translates to:
  /// **'지난 릴리스 이후 빌드에 영향을 주는 파일이 바뀌었습니다. 태그 전에 모든 플랫폼이 빌드되는지 확인하세요. 수동 실행은 릴리스를 만들지 않습니다.'**
  String get bdManualBuildWhy;

  /// No description provided for @bdManualBuildStart.
  ///
  /// In ko, this message translates to:
  /// **'빌드만 확인'**
  String get bdManualBuildStart;

  /// No description provided for @bdManualBuildShort.
  ///
  /// In ko, this message translates to:
  /// **'수동 빌드 {state}'**
  String bdManualBuildShort(String state);

  /// No description provided for @bdDoneManualBuildStarted.
  ///
  /// In ko, this message translates to:
  /// **'수동 빌드를 시작했습니다'**
  String get bdDoneManualBuildStarted;

  /// No description provided for @bdVersionCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재 {version} ({source})'**
  String bdVersionCurrent(String version, String source);

  /// No description provided for @bdVersionFromTag.
  ///
  /// In ko, this message translates to:
  /// **'마지막 태그'**
  String get bdVersionFromTag;

  /// No description provided for @bdVersionRecommended.
  ///
  /// In ko, this message translates to:
  /// **'추천'**
  String get bdVersionRecommended;

  /// No description provided for @bdVersionReason.
  ///
  /// In ko, this message translates to:
  /// **'새 기능 {feats} · 버그 수정 {fixes} · 호환 깨짐 {breaking}'**
  String bdVersionReason(int feats, int fixes, int breaking);

  /// No description provided for @bdVersionCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get bdVersionCustom;

  /// No description provided for @bdVersionFiles.
  ///
  /// In ko, this message translates to:
  /// **'바뀌는 파일'**
  String get bdVersionFiles;

  /// No description provided for @bdVersionNoFiles.
  ///
  /// In ko, this message translates to:
  /// **'버전 파일이 없어서 태그만 만듭니다.'**
  String get bdVersionNoFiles;

  /// No description provided for @bdVersionCommit.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 브랜치 만들고 커밋'**
  String get bdVersionCommit;

  /// No description provided for @bdBumpFinal.
  ///
  /// In ko, this message translates to:
  /// **'정식'**
  String get bdBumpFinal;

  /// No description provided for @bdBumpPrerelease.
  ///
  /// In ko, this message translates to:
  /// **'프리릴리스'**
  String get bdBumpPrerelease;

  /// No description provided for @bdDoneReleaseCommit.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 버전 올림을 커밋했습니다'**
  String bdDoneReleaseCommit(String tag);

  /// No description provided for @bdMergeWaiting.
  ///
  /// In ko, this message translates to:
  /// **'PR #{number} 병합을 기다리는 중 — GitHub에서 병합해도 알아챕니다'**
  String bdMergeWaiting(int number);

  /// No description provided for @bdTagCheckPrMerged.
  ///
  /// In ko, this message translates to:
  /// **'PR #{number}이(가) 병합됐다'**
  String bdTagCheckPrMerged(int number);

  /// No description provided for @bdTagCheckSynced.
  ///
  /// In ko, this message translates to:
  /// **'{branch}에 있고 받을 커밋도 보낼 커밋도 없다'**
  String bdTagCheckSynced(String branch);

  /// No description provided for @bdTagCheckVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 파일이 {tag}와 같다'**
  String bdTagCheckVersion(String tag);

  /// No description provided for @bdTagCheckVersionWrong.
  ///
  /// In ko, this message translates to:
  /// **'지금 버전은 {version}입니다. 버전 올림 PR이 아직 병합되지 않았을 수 있습니다.'**
  String bdTagCheckVersionWrong(String version);

  /// No description provided for @bdTagCheckFree.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 태그가 아직 없다'**
  String bdTagCheckFree(String tag);

  /// No description provided for @bdTagConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 태그를 push할까요?'**
  String bdTagConfirmTitle(String tag);

  /// No description provided for @bdTagConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'{branch}의 병합 커밋에 {tag}를 답니다. push하면 릴리스가 공개되고, 태그는 옮기거나 지우지 않는 것이 규칙입니다.'**
  String bdTagConfirmMessage(String tag, String branch);

  /// No description provided for @bdTagConfirmPush.
  ///
  /// In ko, this message translates to:
  /// **'태그 달고 push'**
  String get bdTagConfirmPush;

  /// No description provided for @bdDoneTagPushed.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 태그를 push했습니다'**
  String bdDoneTagPushed(String tag);

  /// No description provided for @bdNotesLabel.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 노트 (마크다운)'**
  String get bdNotesLabel;

  /// No description provided for @bdNotesFeatures.
  ///
  /// In ko, this message translates to:
  /// **'새 기능'**
  String get bdNotesFeatures;

  /// No description provided for @bdNotesFixes.
  ///
  /// In ko, this message translates to:
  /// **'버그 수정'**
  String get bdNotesFixes;

  /// No description provided for @bdNotesOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get bdNotesOther;

  /// No description provided for @bdNotesCreateRelease.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 릴리스 만들기'**
  String get bdNotesCreateRelease;

  /// No description provided for @bdNotesEdit.
  ///
  /// In ko, this message translates to:
  /// **'노트 고치기'**
  String get bdNotesEdit;

  /// No description provided for @bdDoneReleaseCreated.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 릴리스를 만들었습니다'**
  String get bdDoneReleaseCreated;

  /// No description provided for @bdDoneNotesSaved.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 노트를 저장했습니다'**
  String get bdDoneNotesSaved;

  /// No description provided for @bdCiWaitingForRun.
  ///
  /// In ko, this message translates to:
  /// **'{tag}(으)로 시작된 워크플로를 찾는 중'**
  String bdCiWaitingForRun(String tag);

  /// No description provided for @bdCiOpenInBrowser.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 보기'**
  String get bdCiOpenInBrowser;

  /// No description provided for @bdCiRerunFailed.
  ///
  /// In ko, this message translates to:
  /// **'실패한 잡 다시 실행'**
  String get bdCiRerunFailed;

  /// No description provided for @bdDoneRerun.
  ///
  /// In ko, this message translates to:
  /// **'실패한 잡을 다시 실행했습니다'**
  String get bdDoneRerun;

  /// No description provided for @bdRunQueued.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get bdRunQueued;

  /// No description provided for @bdRunRunning.
  ///
  /// In ko, this message translates to:
  /// **'진행 중'**
  String get bdRunRunning;

  /// No description provided for @bdRunSuccess.
  ///
  /// In ko, this message translates to:
  /// **'성공'**
  String get bdRunSuccess;

  /// No description provided for @bdRunFailure.
  ///
  /// In ko, this message translates to:
  /// **'실패'**
  String get bdRunFailure;

  /// No description provided for @bdRunCancelled.
  ///
  /// In ko, this message translates to:
  /// **'취소됨'**
  String get bdRunCancelled;

  /// No description provided for @bdRunSkipped.
  ///
  /// In ko, this message translates to:
  /// **'건너뜀'**
  String get bdRunSkipped;

  /// No description provided for @bdHelpCaptionAfterSquash.
  ///
  /// In ko, this message translates to:
  /// **'squash 병합 후 — main에 새 커밋 S 하나'**
  String get bdHelpCaptionAfterSquash;

  /// No description provided for @bdHelpCaptionTag.
  ///
  /// In ko, this message translates to:
  /// **'v1.0.0과 v1.1.0은 옮겨지지 않는 이름표, main은 앞으로 나아가는 이름표'**
  String get bdHelpCaptionTag;

  /// No description provided for @bdHelpLinkGitHubMergeMethods.
  ///
  /// In ko, this message translates to:
  /// **'GitHub — 병합 방법 정보'**
  String get bdHelpLinkGitHubMergeMethods;

  /// No description provided for @bdHelpLinkTagging.
  ///
  /// In ko, this message translates to:
  /// **'Pro Git — 태그'**
  String get bdHelpLinkTagging;

  /// No description provided for @bdHelpSquashTitle.
  ///
  /// In ko, this message translates to:
  /// **'Squash (눌러 합치기)'**
  String get bdHelpSquashTitle;

  /// No description provided for @bdHelpSquashWord.
  ///
  /// In ko, this message translates to:
  /// **'눌러서 납작하게 만들다, 찌그러뜨리다.'**
  String get bdHelpSquashWord;

  /// No description provided for @bdHelpSquashInGit.
  ///
  /// In ko, this message translates to:
  /// **'브랜치의 여러 커밋을 눌러 커밋 하나로 합친 뒤 대상 브랜치에 올립니다. 변경 내용은 그대로이고 커밋 개수만 하나가 됩니다.'**
  String get bdHelpSquashInGit;

  /// No description provided for @bdHelpSquashWhy.
  ///
  /// In ko, this message translates to:
  /// **'\'오타 수정\', \'다시 시도\' 같은 작업 중 커밋을 기본 브랜치 기록에 남기지 않고, 기능 하나 = 커밋 하나로 정리합니다. PR을 병합할 때 많이 씁니다. 원래 커밋들은 기본 브랜치에 남지 않으니, 병합한 브랜치를 계속 쓰지 말고 지우세요.'**
  String get bdHelpSquashWhy;

  /// No description provided for @bdHelpTagTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그 (주석 태그와 가벼운 태그)'**
  String get bdHelpTagTitle;

  /// No description provided for @bdHelpTagWord.
  ///
  /// In ko, this message translates to:
  /// **'tag는 \'꼬리표, 이름표\'.'**
  String get bdHelpTagWord;

  /// No description provided for @bdHelpTagInGit.
  ///
  /// In ko, this message translates to:
  /// **'특정 커밋에 붙이는 이름표입니다. 브랜치 이름표는 새 커밋을 따라 앞으로 가지만, 태그는 한 번 붙이면 그 커밋에 머뭅니다. 주석 태그는 만든 사람·날짜·메시지를 함께 저장하고, 가벼운 태그는 이름만 저장합니다.'**
  String get bdHelpTagInGit;

  /// No description provided for @bdHelpTagWhy.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 버전(v1.2.0)에는 주석 태그를 씁니다 — 릴리스 기록이 남고, GitHub 릴리스와 CI가 태그를 기준으로 돕니다. 이미 push한 태그는 옮기거나 지우지 말고, 잘못됐으면 다음 번호로 새로 다세요.'**
  String get bdHelpTagWhy;

  /// No description provided for @bdHeaderMergedAndGone.
  ///
  /// In ko, this message translates to:
  /// **'병합됨 · 원격 삭제됨'**
  String get bdHeaderMergedAndGone;

  /// No description provided for @bdHeaderMergedAndGoneTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 이미 기본 브랜치에 병합되었고 원격에서 삭제되었습니다. 다시 게시하면 지운 브랜치가 되살아납니다.'**
  String get bdHeaderMergedAndGoneTooltip;

  /// No description provided for @bdBannerMergedAndGone.
  ///
  /// In ko, this message translates to:
  /// **'이 브랜치는 병합되어 원격에서 삭제되었습니다. {branch}(으)로 돌아가세요'**
  String bdBannerMergedAndGone(String branch);

  /// No description provided for @bdBannerSwitchTo.
  ///
  /// In ko, this message translates to:
  /// **'{branch}(으)로 전환'**
  String bdBannerSwitchTo(String branch);

  /// No description provided for @bdBannerCreatePr.
  ///
  /// In ko, this message translates to:
  /// **'{branch}을(를) 올렸지만 아직 PR이 없습니다'**
  String bdBannerCreatePr(String branch);

  /// No description provided for @bdPrBaseLabel.
  ///
  /// In ko, this message translates to:
  /// **'기준 브랜치'**
  String get bdPrBaseLabel;

  /// No description provided for @bdPrBaseNotDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치({base})가 아닌 곳으로 합칩니다. 다른 기능 브랜치 위에 쌓는 PR일 때 씁니다.'**
  String bdPrBaseNotDefault(String base);

  /// No description provided for @bdTabCi.
  ///
  /// In ko, this message translates to:
  /// **'CI'**
  String get bdTabCi;

  /// No description provided for @bdCiTitle.
  ///
  /// In ko, this message translates to:
  /// **'CI 실행'**
  String get bdCiTitle;

  /// No description provided for @bdCiNotGitHubMessage.
  ///
  /// In ko, this message translates to:
  /// **'Actions는 GitHub 저장소에서만 쓸 수 있습니다 — gh는 GitHub 전용 도구입니다.'**
  String get bdCiNotGitHubMessage;

  /// No description provided for @bdCiEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'{branch}에는 아직 실행이 없습니다'**
  String bdCiEmptyTitle(String branch);

  /// No description provided for @bdCiEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'push나 PR, 태그로 워크플로가 돌면 여기에 나옵니다.'**
  String get bdCiEmptyMessage;

  /// No description provided for @bdCiRerun.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행'**
  String get bdCiRerun;

  /// No description provided for @bdCiCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get bdCiCancel;

  /// No description provided for @bdCiDispatch.
  ///
  /// In ko, this message translates to:
  /// **'수동 실행'**
  String get bdCiDispatch;

  /// No description provided for @bdCiDispatchNeedsPush.
  ///
  /// In ko, this message translates to:
  /// **'수동 실행은 원격에 있는 브랜치에서만 할 수 있습니다. 먼저 게시하세요.'**
  String get bdCiDispatchNeedsPush;

  /// No description provided for @bdCiDispatchTitle.
  ///
  /// In ko, this message translates to:
  /// **'{file} 수동 실행'**
  String bdCiDispatchTitle(String file);

  /// No description provided for @bdCiDispatchMessage.
  ///
  /// In ko, this message translates to:
  /// **'{branch} 브랜치로 워크플로를 실행합니다. 입력이 필요한 워크플로는 브라우저에서 실행하세요.'**
  String bdCiDispatchMessage(String branch);

  /// No description provided for @bdCiDispatchConfirm.
  ///
  /// In ko, this message translates to:
  /// **'실행'**
  String get bdCiDispatchConfirm;

  /// No description provided for @bdDoneDispatched.
  ///
  /// In ko, this message translates to:
  /// **'{file}을(를) 실행했습니다'**
  String bdDoneDispatched(String file);

  /// No description provided for @bdDoneRunCancelled.
  ///
  /// In ko, this message translates to:
  /// **'실행을 취소했습니다'**
  String get bdDoneRunCancelled;

  /// No description provided for @bdNotifyRunTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} {state}'**
  String bdNotifyRunTitle(String name, String state);

  /// No description provided for @bdNotifyReleaseRun.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 릴리스 CI {state}'**
  String bdNotifyReleaseRun(String tag, String state);

  /// No description provided for @bdNotifyManualBuild.
  ///
  /// In ko, this message translates to:
  /// **'태그 전 수동 빌드 {state}'**
  String bdNotifyManualBuild(String state);

  /// No description provided for @bdPrFilterMine.
  ///
  /// In ko, this message translates to:
  /// **'내 PR'**
  String get bdPrFilterMine;

  /// No description provided for @bdPrFilterReview.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 요청'**
  String get bdPrFilterReview;

  /// No description provided for @bdPrFilterOpen.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get bdPrFilterOpen;

  /// No description provided for @bdPrListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'열린 PR이 없습니다'**
  String get bdPrListEmpty;

  /// No description provided for @bdPrCurrentBranch.
  ///
  /// In ko, this message translates to:
  /// **'현재 브랜치'**
  String get bdPrCurrentBranch;

  /// No description provided for @bdPrCheckout.
  ///
  /// In ko, this message translates to:
  /// **'이 PR 브랜치로 체크아웃'**
  String get bdPrCheckout;

  /// No description provided for @bdPrCheckoutWhy.
  ///
  /// In ko, this message translates to:
  /// **'PR 브랜치를 내 컴퓨터로 가져와 전환합니다. 직접 실행해 보거나 고칠 때 씁니다.'**
  String get bdPrCheckoutWhy;

  /// No description provided for @bdDonePrCheckout.
  ///
  /// In ko, this message translates to:
  /// **'PR #{number}의 {branch}(으)로 전환했습니다'**
  String bdDonePrCheckout(int number, String branch);

  /// No description provided for @bdReleasesTitle.
  ///
  /// In ko, this message translates to:
  /// **'릴리스'**
  String get bdReleasesTitle;

  /// No description provided for @bdReleasesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 릴리스가 없습니다'**
  String get bdReleasesEmpty;

  /// No description provided for @bdReleasesLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 목록을 불러오지 못했습니다'**
  String get bdReleasesLoadFailed;

  /// No description provided for @bdReleaseLatestPill.
  ///
  /// In ko, this message translates to:
  /// **'최신'**
  String get bdReleaseLatestPill;

  /// No description provided for @bdReleaseDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안'**
  String get bdReleaseDraft;

  /// No description provided for @bdReleaseMakeFinal.
  ///
  /// In ko, this message translates to:
  /// **'정식 릴리스로 바꾸기'**
  String get bdReleaseMakeFinal;

  /// No description provided for @bdReleaseMakePrerelease.
  ///
  /// In ko, this message translates to:
  /// **'프리릴리스로 바꾸기'**
  String get bdReleaseMakePrerelease;

  /// No description provided for @bdReleasePublishDraft.
  ///
  /// In ko, this message translates to:
  /// **'초안 게시'**
  String get bdReleasePublishDraft;

  /// No description provided for @bdReleaseDelete.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 삭제'**
  String get bdReleaseDelete;

  /// No description provided for @bdReleaseDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 릴리스를 삭제할까요?'**
  String bdReleaseDeleteTitle(String tag);

  /// No description provided for @bdReleaseDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 릴리스와 올라간 파일이 사라집니다. 이미 받아 간 사람이 있을 수 있습니다.'**
  String get bdReleaseDeleteMessage;

  /// No description provided for @bdReleaseDeleteTagToo.
  ///
  /// In ko, this message translates to:
  /// **'GitHub의 {tag} 태그도 삭제 (로컬 태그는 남음)'**
  String bdReleaseDeleteTagToo(String tag);

  /// No description provided for @bdDoneReleaseDeleted.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 릴리스를 삭제했습니다'**
  String bdDoneReleaseDeleted(String tag);

  /// No description provided for @bdDoneReleaseMadeFinal.
  ///
  /// In ko, this message translates to:
  /// **'{tag}을(를) 정식 릴리스로 바꿨습니다'**
  String bdDoneReleaseMadeFinal(String tag);

  /// No description provided for @bdDoneReleaseMadePrerelease.
  ///
  /// In ko, this message translates to:
  /// **'{tag}을(를) 프리릴리스로 바꿨습니다'**
  String bdDoneReleaseMadePrerelease(String tag);

  /// No description provided for @bdDoneReleasePublished.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 초안을 게시했습니다'**
  String bdDoneReleasePublished(String tag);

  /// No description provided for @bdNotesEditTab.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get bdNotesEditTab;

  /// No description provided for @bdNotesPreviewTab.
  ///
  /// In ko, this message translates to:
  /// **'미리 보기'**
  String get bdNotesPreviewTab;

  /// No description provided for @bdNotesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'내용이 없습니다'**
  String get bdNotesEmpty;

  /// No description provided for @bdTagVersionMismatch.
  ///
  /// In ko, this message translates to:
  /// **'{file}의 버전은 {version}인데 태그는 {tag}입니다.'**
  String bdTagVersionMismatch(String file, String version, String tag);

  /// No description provided for @bdTagVersionMismatchWhy.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 태그는 버전을 먼저 올린 커밋에 달아야 합니다 — 릴리스 마법사가 버전 올림 PR부터 태그까지 차례로 합니다.'**
  String get bdTagVersionMismatchWhy;

  /// No description provided for @bdTagVersionMismatchCi.
  ///
  /// In ko, this message translates to:
  /// **'이 저장소는 태그를 push하면 CI가 릴리스를 만드는데, 버전이 다르면 CI가 멈춥니다.'**
  String get bdTagVersionMismatchCi;

  /// No description provided for @bdTagVersionMismatchBlocked.
  ///
  /// In ko, this message translates to:
  /// **'그래서 push는 막았습니다. 로컬에만 만들려면 push를 끄세요.'**
  String get bdTagVersionMismatchBlocked;

  /// No description provided for @bdTagOpenReleaseWizard.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 마법사 열기'**
  String get bdTagOpenReleaseWizard;

  /// No description provided for @bdTabHistory.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get bdTabHistory;

  /// No description provided for @bdMenuAutoFetch.
  ///
  /// In ko, this message translates to:
  /// **'자동 fetch (5분마다·돌아올 때)'**
  String get bdMenuAutoFetch;

  /// No description provided for @bdChangesAmendToggle.
  ///
  /// In ko, this message translates to:
  /// **'직전 커밋 고치기'**
  String get bdChangesAmendToggle;

  /// No description provided for @bdChangesAmend.
  ///
  /// In ko, this message translates to:
  /// **'직전 커밋 고치기'**
  String get bdChangesAmend;

  /// No description provided for @bdChangesAmendPushedWarning.
  ///
  /// In ko, this message translates to:
  /// **'이미 원격에 올린 커밋입니다. 고치면 기록이 갈라져 강제 push(force-with-lease)가 필요합니다.'**
  String get bdChangesAmendPushedWarning;

  /// No description provided for @bdDoneAmend.
  ///
  /// In ko, this message translates to:
  /// **'직전 커밋을 고쳤습니다'**
  String get bdDoneAmend;

  /// No description provided for @bdChangesDiscard.
  ///
  /// In ko, this message translates to:
  /// **'변경 취소'**
  String get bdChangesDiscard;

  /// No description provided for @bdChangesDiscardMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}의 커밋하지 않은 변경을 버리고 마지막으로 스테이징(또는 커밋)한 상태로 되돌립니다. 되돌릴 수 없습니다.'**
  String bdChangesDiscardMessage(String path);

  /// No description provided for @bdChangesDeleteUntracked.
  ///
  /// In ko, this message translates to:
  /// **'파일 삭제'**
  String get bdChangesDeleteUntracked;

  /// No description provided for @bdChangesDeleteUntrackedMessage.
  ///
  /// In ko, this message translates to:
  /// **'git이 추적하지 않는 {path}을(를) 지웁니다. 휴지통으로 가지 않습니다.'**
  String bdChangesDeleteUntrackedMessage(String path);

  /// No description provided for @bdConflictUseMine.
  ///
  /// In ko, this message translates to:
  /// **'내 것 사용'**
  String get bdConflictUseMine;

  /// No description provided for @bdConflictUseIncoming.
  ///
  /// In ko, this message translates to:
  /// **'들어오는 것 사용'**
  String get bdConflictUseIncoming;

  /// No description provided for @bdConflictByBlock.
  ///
  /// In ko, this message translates to:
  /// **'구간별로 해결'**
  String get bdConflictByBlock;

  /// No description provided for @bdConflictSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 충돌 해결'**
  String bdConflictSheetTitle(String name);

  /// No description provided for @bdConflictBlockTitle.
  ///
  /// In ko, this message translates to:
  /// **'충돌 {index}/{total}'**
  String bdConflictBlockTitle(int index, int total);

  /// No description provided for @bdConflictSideMine.
  ///
  /// In ko, this message translates to:
  /// **'내 것'**
  String get bdConflictSideMine;

  /// No description provided for @bdConflictSideIncoming.
  ///
  /// In ko, this message translates to:
  /// **'들어오는 것'**
  String get bdConflictSideIncoming;

  /// No description provided for @bdConflictKeepBoth.
  ///
  /// In ko, this message translates to:
  /// **'둘 다 유지 (위, 아래 순서)'**
  String get bdConflictKeepBoth;

  /// No description provided for @bdConflictEmptySide.
  ///
  /// In ko, this message translates to:
  /// **'(비어 있음)'**
  String get bdConflictEmptySide;

  /// No description provided for @bdConflictPickHint.
  ///
  /// In ko, this message translates to:
  /// **'구간마다 어느 쪽을 쓸지 골라 주세요. {left}개 남았습니다.'**
  String bdConflictPickHint(int left);

  /// No description provided for @bdConflictApply.
  ///
  /// In ko, this message translates to:
  /// **'적용하고 해결됨 표시'**
  String get bdConflictApply;

  /// No description provided for @bdConflictApplyNote.
  ///
  /// In ko, this message translates to:
  /// **'고른 대로 파일을 다시 쓰고 git add 합니다. 직접 고쳐 쓰려면 편집기로 여세요.'**
  String get bdConflictApplyNote;

  /// No description provided for @bdConflictBroken.
  ///
  /// In ko, this message translates to:
  /// **'충돌 표시가 온전하지 않아 앱에서 읽을 수 없습니다. 편집기에서 직접 고쳐 주세요.'**
  String get bdConflictBroken;

  /// No description provided for @bdConflictNone.
  ///
  /// In ko, this message translates to:
  /// **'이 파일에는 충돌 표시가 없습니다. 이미 고쳤다면 \'해결됨 표시\'만 누르면 됩니다.'**
  String get bdConflictNone;

  /// No description provided for @bdConflictUnreadable.
  ///
  /// In ko, this message translates to:
  /// **'파일을 읽을 수 없습니다 (이진 파일이거나 삭제된 파일일 수 있습니다). \'내 것 사용\' 또는 \'들어오는 것 사용\'으로 해결하세요.'**
  String get bdConflictUnreadable;

  /// No description provided for @bdDoneConflictResolved.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 충돌 해결됨'**
  String bdDoneConflictResolved(String name);

  /// No description provided for @bdChangesOperationTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 작업이 끝나지 않았습니다'**
  String get bdChangesOperationTitle;

  /// No description provided for @bdChangesOperationMessage.
  ///
  /// In ko, this message translates to:
  /// **'충돌은 모두 해결됐습니다. 위의 \'계속\'으로 마무리하거나 \'중단\'으로 시작하기 전 상태로 되돌리세요.'**
  String get bdChangesOperationMessage;

  /// No description provided for @bdConflictReopen.
  ///
  /// In ko, this message translates to:
  /// **'다시 충돌 상태로'**
  String get bdConflictReopen;

  /// No description provided for @bdConflictReopenMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}을(를) 충돌이 난 직후의 모습으로 되돌립니다. 지금까지 해결한 내용은 사라지고, 충돌 표시가 다시 들어갑니다.'**
  String bdConflictReopenMessage(String path);

  /// No description provided for @bdConflictReopenConfirm.
  ///
  /// In ko, this message translates to:
  /// **'다시 충돌'**
  String get bdConflictReopenConfirm;

  /// No description provided for @bdConflictMarkersLeftTitle.
  ///
  /// In ko, this message translates to:
  /// **'충돌 표시가 남아 있습니다'**
  String get bdConflictMarkersLeftTitle;

  /// No description provided for @bdConflictMarkersLeftMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}에 아직 `<<<<<<<` 표시가 {count}군데 남아 있습니다. 이대로 해결됨으로 표시하면 표시가 그대로 커밋됩니다. 먼저 \'구간별로 해결\'이나 편집기로 정리하세요.'**
  String bdConflictMarkersLeftMessage(String path, int count);

  /// No description provided for @bdConflictMarkersLeftConfirm.
  ///
  /// In ko, this message translates to:
  /// **'그래도 해결됨 표시'**
  String get bdConflictMarkersLeftConfirm;

  /// No description provided for @bdDoneFileAction.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 완료'**
  String bdDoneFileAction(String name);

  /// No description provided for @bdStashTitle.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장 (stash)'**
  String get bdStashTitle;

  /// No description provided for @bdStashSave.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장'**
  String get bdStashSave;

  /// No description provided for @bdStashSaveFile.
  ///
  /// In ko, this message translates to:
  /// **'이 파일만 임시 저장'**
  String get bdStashSaveFile;

  /// No description provided for @bdStashFileToStage.
  ///
  /// In ko, this message translates to:
  /// **'스테이징으로 꺼내기'**
  String get bdStashFileToStage;

  /// No description provided for @bdStashFileOverwriteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}에 이미 변경이 있습니다. 임시 저장한 내용으로 덮어씁니다.'**
  String bdStashFileOverwriteMessage(String path);

  /// No description provided for @bdStashEmpty.
  ///
  /// In ko, this message translates to:
  /// **'파일 목록을 불러오지 못했습니다.'**
  String get bdStashEmpty;

  /// No description provided for @bdStashWhy.
  ///
  /// In ko, this message translates to:
  /// **'변경 {count}개를 커밋하지 않고 따로 치워 둡니다. 추적하지 않는 파일도 함께 저장합니다. 나중에 \'다시 적용\'으로 되살립니다.'**
  String bdStashWhy(int count);

  /// No description provided for @bdStashMessageLabel.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get bdStashMessageLabel;

  /// No description provided for @bdStashPop.
  ///
  /// In ko, this message translates to:
  /// **'적용하고 지우기 (pop)'**
  String get bdStashPop;

  /// No description provided for @bdStashApply.
  ///
  /// In ko, this message translates to:
  /// **'적용만 하기 (apply)'**
  String get bdStashApply;

  /// No description provided for @bdStashDrop.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get bdStashDrop;

  /// No description provided for @bdStashDropTitle.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장을 삭제할까요?'**
  String get bdStashDropTitle;

  /// No description provided for @bdStashDropMessage.
  ///
  /// In ko, this message translates to:
  /// **'\'{text}\'에 저장한 변경이 사라집니다.'**
  String bdStashDropMessage(String text);

  /// No description provided for @bdStashAndRetry.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장하고 다시'**
  String get bdStashAndRetry;

  /// No description provided for @bdStashAutoMessage.
  ///
  /// In ko, this message translates to:
  /// **'Branch Dock: 자동 임시 저장'**
  String get bdStashAutoMessage;

  /// No description provided for @bdDoneStashSaved.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장했습니다'**
  String get bdDoneStashSaved;

  /// No description provided for @bdDoneStashApplied.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장을 적용했습니다'**
  String get bdDoneStashApplied;

  /// No description provided for @bdDoneStashDropped.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장을 삭제했습니다'**
  String get bdDoneStashDropped;

  /// No description provided for @bdDoneStashAndRetry.
  ///
  /// In ko, this message translates to:
  /// **'변경을 임시 저장하고 다시 실행했습니다. 변경 탭의 임시 저장에서 되살릴 수 있습니다.'**
  String get bdDoneStashAndRetry;

  /// No description provided for @bdPushOptionsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'Push 옵션'**
  String get bdPushOptionsTooltip;

  /// No description provided for @bdPushOptionsTitle.
  ///
  /// In ko, this message translates to:
  /// **'Push 옵션'**
  String get bdPushOptionsTitle;

  /// No description provided for @bdPushFollowTags.
  ///
  /// In ko, this message translates to:
  /// **'태그도 함께 push (--follow-tags)'**
  String get bdPushFollowTags;

  /// No description provided for @bdPushFollowTagsWhy.
  ///
  /// In ko, this message translates to:
  /// **'올리는 커밋에 달린 주석 태그를 함께 올립니다. 이 저장소에만 적용됩니다.'**
  String get bdPushFollowTagsWhy;

  /// No description provided for @bdPushForceTitle.
  ///
  /// In ko, this message translates to:
  /// **'강제 push (force-with-lease)'**
  String get bdPushForceTitle;

  /// No description provided for @bdPushForceWhy.
  ///
  /// In ko, this message translates to:
  /// **'amend나 rebase로 이미 올린 커밋을 고쳤을 때만 씁니다. 내가 모르는 원격 커밋이 있으면 git이 거부해서 다른 사람의 작업을 덮어쓰지 않습니다.'**
  String get bdPushForceWhy;

  /// No description provided for @bdPushForceBlockedDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 브랜치({branch})에서는 강제 push를 막았습니다 — 다른 사람의 기록을 덮어쓸 수 있습니다.'**
  String bdPushForceBlockedDefault(String branch);

  /// No description provided for @bdPushForce.
  ///
  /// In ko, this message translates to:
  /// **'강제 push'**
  String get bdPushForce;

  /// No description provided for @bdPushForceConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'{branch}을(를) 강제 push할까요?'**
  String bdPushForceConfirmTitle(String branch);

  /// No description provided for @bdPushForceConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'{upstream}의 기록을 내 {branch}로 바꿉니다. 내가 fetch한 뒤 누가 push했다면 git이 거부합니다.'**
  String bdPushForceConfirmMessage(String branch, String upstream);

  /// No description provided for @bdOperationSkip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get bdOperationSkip;

  /// No description provided for @bdOperationSkipTooltip.
  ///
  /// In ko, this message translates to:
  /// **'충돌 난 이 커밋을 빼고 rebase를 계속합니다'**
  String get bdOperationSkipTooltip;

  /// No description provided for @bdDoneSkip.
  ///
  /// In ko, this message translates to:
  /// **'커밋을 건너뛰었습니다'**
  String get bdDoneSkip;

  /// No description provided for @bdBranchesSetUpstream.
  ///
  /// In ko, this message translates to:
  /// **'추적 브랜치 설정'**
  String get bdBranchesSetUpstream;

  /// No description provided for @bdBranchesSetUpstreamWhy.
  ///
  /// In ko, this message translates to:
  /// **'{branch}이(가) Push·Pull할 원격 브랜치를 정합니다.'**
  String bdBranchesSetUpstreamWhy(String branch);

  /// No description provided for @bdBranchesUpstreamLabel.
  ///
  /// In ko, this message translates to:
  /// **'원격 브랜치'**
  String get bdBranchesUpstreamLabel;

  /// No description provided for @bdDoneSetUpstream.
  ///
  /// In ko, this message translates to:
  /// **'{branch}의 추적 브랜치를 {upstream}(으)로 정했습니다'**
  String bdDoneSetUpstream(String branch, String upstream);

  /// No description provided for @bdBranchesCleanup.
  ///
  /// In ko, this message translates to:
  /// **'병합된 브랜치 정리'**
  String get bdBranchesCleanup;

  /// No description provided for @bdCleanupWhy.
  ///
  /// In ko, this message translates to:
  /// **'{base}에 이미 병합됐거나 원격에서 지워진 로컬 브랜치입니다. 원격 브랜치는 건드리지 않습니다.'**
  String bdCleanupWhy(String base);

  /// No description provided for @bdCleanupMerged.
  ///
  /// In ko, this message translates to:
  /// **'병합됨'**
  String get bdCleanupMerged;

  /// No description provided for @bdCleanupGoneNotMerged.
  ///
  /// In ko, this message translates to:
  /// **'원격에서 삭제됨 · 병합 안 됨 — 지우면 커밋을 찾기 어려워집니다'**
  String get bdCleanupGoneNotMerged;

  /// No description provided for @bdCleanupConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 삭제'**
  String bdCleanupConfirm(int count);

  /// No description provided for @bdCleanupNothing.
  ///
  /// In ko, this message translates to:
  /// **'정리할 브랜치가 없습니다 ({base}에 병합된 브랜치 없음)'**
  String bdCleanupNothing(String base);

  /// No description provided for @bdDoneCleanup.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 {count}개를 정리했습니다'**
  String bdDoneCleanup(int count);

  /// No description provided for @bdTagsCommitsSince.
  ///
  /// In ko, this message translates to:
  /// **'이전 태그 이후 커밋'**
  String get bdTagsCommitsSince;

  /// No description provided for @bdTagsCommitsBetween.
  ///
  /// In ko, this message translates to:
  /// **'{from} → {to}'**
  String bdTagsCommitsBetween(String from, String to);

  /// No description provided for @bdTagsCommitsUpTo.
  ///
  /// In ko, this message translates to:
  /// **'{tag}까지'**
  String bdTagsCommitsUpTo(String tag);

  /// No description provided for @bdTagsCommitsCount.
  ///
  /// In ko, this message translates to:
  /// **'커밋 {count}개'**
  String bdTagsCommitsCount(int count);

  /// No description provided for @bdTagsCheckout.
  ///
  /// In ko, this message translates to:
  /// **'이 태그로 이동'**
  String get bdTagsCheckout;

  /// No description provided for @bdTagsCheckoutTitle.
  ///
  /// In ko, this message translates to:
  /// **'{tag}(으)로 이동할까요?'**
  String bdTagsCheckoutTitle(String tag);

  /// No description provided for @bdTagsCheckoutMessage.
  ///
  /// In ko, this message translates to:
  /// **'태그 위치의 파일을 그대로 볼 수 있습니다. 이때는 어느 브랜치에도 있지 않은 \'분리된 HEAD\' 상태라, 여기서 커밋하려면 먼저 브랜치를 만드세요.'**
  String get bdTagsCheckoutMessage;

  /// No description provided for @bdDoneCheckoutTag.
  ///
  /// In ko, this message translates to:
  /// **'{tag}(으)로 이동했습니다'**
  String bdDoneCheckoutTag(String tag);

  /// No description provided for @bdBannerDetached.
  ///
  /// In ko, this message translates to:
  /// **'어느 브랜치에도 있지 않습니다. 여기서 커밋하려면 브랜치를 만드세요'**
  String get bdBannerDetached;

  /// No description provided for @bdHistoryTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get bdHistoryTitle;

  /// No description provided for @bdHistoryUnpushed.
  ///
  /// In ko, this message translates to:
  /// **'↑ 올리지 않은 커밋 {count}'**
  String bdHistoryUnpushed(int count);

  /// No description provided for @bdHistoryNotPushed.
  ///
  /// In ko, this message translates to:
  /// **'아직 올리지 않음'**
  String get bdHistoryNotPushed;

  /// No description provided for @bdHistoryCopyHash.
  ///
  /// In ko, this message translates to:
  /// **'해시 복사'**
  String get bdHistoryCopyHash;

  /// No description provided for @bdHistoryBranchHere.
  ///
  /// In ko, this message translates to:
  /// **'여기서 브랜치 만들기'**
  String get bdHistoryBranchHere;

  /// No description provided for @bdHistoryTagHere.
  ///
  /// In ko, this message translates to:
  /// **'여기에 태그 달기'**
  String get bdHistoryTagHere;

  /// No description provided for @bdHelpLinkStashing.
  ///
  /// In ko, this message translates to:
  /// **'Pro Git — Stashing과 Cleaning'**
  String get bdHelpLinkStashing;

  /// No description provided for @bdHelpCaptionStash.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경 W를 stash 목록 맨 위에 치워 둠 — main은 그대로'**
  String get bdHelpCaptionStash;

  /// No description provided for @bdHelpStashTitle.
  ///
  /// In ko, this message translates to:
  /// **'Stash (임시 저장)'**
  String get bdHelpStashTitle;

  /// No description provided for @bdHelpStashWord.
  ///
  /// In ko, this message translates to:
  /// **'stash는 \'넣어 두다, 숨겨 두다\'. 잠깐 서랍에 치워 두는 것.'**
  String get bdHelpStashWord;

  /// No description provided for @bdHelpStashInGit.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경을 브랜치 기록에 남기지 않고 따로 저장한 뒤, 작업 트리를 깨끗하게 되돌립니다. 저장한 변경은 목록에 쌓이고(가장 최근 것이 맨 위), 나중에 어느 브랜치에서든 다시 적용할 수 있습니다.'**
  String get bdHelpStashInGit;

  /// No description provided for @bdHelpStashWhy.
  ///
  /// In ko, this message translates to:
  /// **'하던 일을 커밋하기엔 이른데 브랜치를 바꾸거나 Pull해야 할 때 씁니다. \'pop\'은 적용하고 목록에서 지우고, \'apply\'는 목록에 남겨 둡니다. 오래 두면 무엇이었는지 잊기 쉬우니 메모를 남기세요.'**
  String get bdHelpStashWhy;

  /// No description provided for @bdHelpCaptionDetached.
  ///
  /// In ko, this message translates to:
  /// **'HEAD가 브랜치가 아니라 v1.0.0 커밋을 직접 가리킴'**
  String get bdHelpCaptionDetached;

  /// No description provided for @bdHelpDetachedTitle.
  ///
  /// In ko, this message translates to:
  /// **'분리된 HEAD (detached HEAD)'**
  String get bdHelpDetachedTitle;

  /// No description provided for @bdHelpDetachedWord.
  ///
  /// In ko, this message translates to:
  /// **'detached는 \'떨어진, 분리된\'. HEAD는 \'지금 보고 있는 곳\'.'**
  String get bdHelpDetachedWord;

  /// No description provided for @bdHelpDetachedInGit.
  ///
  /// In ko, this message translates to:
  /// **'보통 HEAD는 브랜치 이름표를 가리키고, 커밋하면 그 이름표가 앞으로 갑니다. 태그나 커밋으로 직접 이동하면 HEAD가 브랜치에서 떨어져 커밋을 직접 가리킵니다.'**
  String get bdHelpDetachedInGit;

  /// No description provided for @bdHelpDetachedWhy.
  ///
  /// In ko, this message translates to:
  /// **'옛 버전을 실행해 보거나 비교할 때 안전하게 쓸 수 있습니다. 여기서 커밋하면 어느 브랜치에도 속하지 않아 다른 곳으로 옮기면 찾기 어려워지니, 커밋하려면 먼저 \'여기서 브랜치 만들기\'를 하세요.'**
  String get bdHelpDetachedWhy;

  /// No description provided for @bdHelpForceTitle.
  ///
  /// In ko, this message translates to:
  /// **'강제 push (force-with-lease)'**
  String get bdHelpForceTitle;

  /// No description provided for @bdHelpForceWord.
  ///
  /// In ko, this message translates to:
  /// **'force는 \'억지로\', lease는 \'임대 계약\' — 내가 본 상태 그대로일 때만 바꾼다는 조건.'**
  String get bdHelpForceWord;

  /// No description provided for @bdHelpForceInGit.
  ///
  /// In ko, this message translates to:
  /// **'amend나 rebase로 이미 올린 커밋을 고치면 원격 기록과 갈라져 보통 push가 거부됩니다. 강제 push는 원격 브랜치를 내 기록으로 바꿉니다. --force-with-lease는 원격이 내가 마지막으로 fetch한 상태 그대로일 때만 바꾸고, 그 사이 누가 push했으면 거부합니다.'**
  String get bdHelpForceInGit;

  /// No description provided for @bdHelpForceWhy.
  ///
  /// In ko, this message translates to:
  /// **'혼자 쓰는 작업 브랜치에서 기록을 정리했을 때만 씁니다. 여러 사람이 쓰는 브랜치, 특히 main에서는 쓰지 않습니다. 이 앱은 --force(무조건)는 제공하지 않고, 기본 브랜치에서는 막습니다.'**
  String get bdHelpForceWhy;

  /// No description provided for @bdMenuBrowse.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 저장소 열기'**
  String get bdMenuBrowse;

  /// No description provided for @bdMenuSnapRight.
  ///
  /// In ko, this message translates to:
  /// **'화면 오른쪽에 붙이기'**
  String get bdMenuSnapRight;

  /// No description provided for @bdMenuSnapLeft.
  ///
  /// In ko, this message translates to:
  /// **'화면 왼쪽에 붙이기'**
  String get bdMenuSnapLeft;

  /// No description provided for @bdStartInitRepository.
  ///
  /// In ko, this message translates to:
  /// **'이 폴더를 git 저장소로 만들기'**
  String get bdStartInitRepository;

  /// No description provided for @bdCloneTitle.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에서 복제'**
  String get bdCloneTitle;

  /// No description provided for @bdCloneSearch.
  ///
  /// In ko, this message translates to:
  /// **'내 저장소 찾기'**
  String get bdCloneSearch;

  /// No description provided for @bdCloneEmpty.
  ///
  /// In ko, this message translates to:
  /// **'저장소가 없습니다'**
  String get bdCloneEmpty;

  /// No description provided for @bdCloneNoFolder.
  ///
  /// In ko, this message translates to:
  /// **'복제할 위치를 고르세요'**
  String get bdCloneNoFolder;

  /// No description provided for @bdCloneChooseFolder.
  ///
  /// In ko, this message translates to:
  /// **'위치 고르기'**
  String get bdCloneChooseFolder;

  /// No description provided for @bdCloneExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 있는 폴더입니다: {path}'**
  String bdCloneExists(String path);

  /// No description provided for @bdCloneConfirm.
  ///
  /// In ko, this message translates to:
  /// **'복제하고 열기'**
  String get bdCloneConfirm;

  /// No description provided for @bdCloneRunning.
  ///
  /// In ko, this message translates to:
  /// **'복제하는 중…'**
  String get bdCloneRunning;

  /// No description provided for @bdLoginTitle.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 로그인'**
  String get bdLoginTitle;

  /// No description provided for @bdLoginSsh.
  ///
  /// In ko, this message translates to:
  /// **'SSH'**
  String get bdLoginSsh;

  /// No description provided for @bdLoginHttps.
  ///
  /// In ko, this message translates to:
  /// **'HTTPS'**
  String get bdLoginHttps;

  /// No description provided for @bdLoginSshRecommended.
  ///
  /// In ko, this message translates to:
  /// **'SSH 권장'**
  String get bdLoginSshRecommended;

  /// No description provided for @bdLoginSshWhy.
  ///
  /// In ko, this message translates to:
  /// **'SSH 주소의 원격이나 SSH로 접속한 환경에서는 HTTPS로 로그인하면 push 때 인증이 따로 놀 수 있습니다.'**
  String get bdLoginSshWhy;

  /// No description provided for @bdLoginStepKey.
  ///
  /// In ko, this message translates to:
  /// **'SSH 키 확인'**
  String get bdLoginStepKey;

  /// No description provided for @bdLoginStepKeyFound.
  ///
  /// In ko, this message translates to:
  /// **'이 키를 GitHub에 올립니다'**
  String get bdLoginStepKeyFound;

  /// No description provided for @bdLoginStepKeyMissing.
  ///
  /// In ko, this message translates to:
  /// **'키가 없습니다. 터미널에서 아래 명령으로 만드세요 (암호 문구 권장). 앱은 키와 암호 문구를 받지 않습니다.'**
  String get bdLoginStepKeyMissing;

  /// No description provided for @bdLoginStepLogin.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get bdLoginStepLogin;

  /// No description provided for @bdLoginStepLoginWhy.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 GitHub에 로그인하고 일회용 코드를 넣습니다.'**
  String get bdLoginStepLoginWhy;

  /// No description provided for @bdLoginLoggedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인되어 있습니다'**
  String get bdLoginLoggedIn;

  /// No description provided for @bdLoginStart.
  ///
  /// In ko, this message translates to:
  /// **'브라우저로 로그인'**
  String get bdLoginStart;

  /// No description provided for @bdLoginDeviceHowTo.
  ///
  /// In ko, this message translates to:
  /// **'브라우저가 열리지 않거나 원격 서버라면, 다른 기기의 브라우저에서 아래 주소를 열고 이 코드를 넣으세요.'**
  String get bdLoginDeviceHowTo;

  /// No description provided for @bdLoginStepUpload.
  ///
  /// In ko, this message translates to:
  /// **'공개 키 올리기'**
  String get bdLoginStepUpload;

  /// No description provided for @bdLoginStepUploadWhy.
  ///
  /// In ko, this message translates to:
  /// **'골라 둔 공개 키를 내 GitHub 계정에 등록합니다. 이미 등록돼 있으면 건너뜁니다.'**
  String get bdLoginStepUploadWhy;

  /// No description provided for @bdLoginUploadKey.
  ///
  /// In ko, this message translates to:
  /// **'공개 키 올리기'**
  String get bdLoginUploadKey;

  /// No description provided for @bdLoginNeedsKeyScope.
  ///
  /// In ko, this message translates to:
  /// **'키를 올릴 권한이 없습니다. 터미널에서 아래 명령으로 권한을 더한 뒤 다시 시도하세요.'**
  String get bdLoginNeedsKeyScope;

  /// No description provided for @bdLoginStepTest.
  ///
  /// In ko, this message translates to:
  /// **'연결 확인'**
  String get bdLoginStepTest;

  /// No description provided for @bdLoginStepTestWhy.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에 SSH로 접속해 봅니다. 처음이면 github.com 호스트 키를 known_hosts에 더합니다.'**
  String get bdLoginStepTestWhy;

  /// No description provided for @bdLoginSshFailed.
  ///
  /// In ko, this message translates to:
  /// **'연결하지 못했습니다. 키가 등록됐는지, ssh-agent에 키가 올라가 있는지 확인하세요.'**
  String get bdLoginSshFailed;

  /// No description provided for @bdLoginTest.
  ///
  /// In ko, this message translates to:
  /// **'연결 확인'**
  String get bdLoginTest;

  /// No description provided for @bdLoginChecking.
  ///
  /// In ko, this message translates to:
  /// **'확인하는 중…'**
  String get bdLoginChecking;

  /// No description provided for @bdLoginStepProtocol.
  ///
  /// In ko, this message translates to:
  /// **'git 프로토콜을 SSH로'**
  String get bdLoginStepProtocol;

  /// No description provided for @bdLoginStepProtocolWhy.
  ///
  /// In ko, this message translates to:
  /// **'gh가 앞으로 만드는 원격 주소를 SSH로 씁니다. 이미 있는 HTTPS 원격은 원격 탭의 URL 바꾸기에서 SSH로 바꿀 수 있습니다.'**
  String get bdLoginStepProtocolWhy;

  /// No description provided for @bdLoginUseSshProtocol.
  ///
  /// In ko, this message translates to:
  /// **'SSH로 설정'**
  String get bdLoginUseSshProtocol;

  /// No description provided for @bdLoginAgentTip.
  ///
  /// In ko, this message translates to:
  /// **'암호 문구를 매번 묻지 않게 하려면 macOS는 ssh-add --apple-use-keychain, 그 밖에는 ssh-agent를 쓰세요.'**
  String get bdLoginAgentTip;

  /// No description provided for @bdDoneProtocolSsh.
  ///
  /// In ko, this message translates to:
  /// **'gh의 git 프로토콜을 SSH로 바꿨습니다'**
  String get bdDoneProtocolSsh;

  /// No description provided for @bdForkTitle.
  ///
  /// In ko, this message translates to:
  /// **'{parent}의 fork입니다'**
  String bdForkTitle(String parent);

  /// No description provided for @bdForkAddWhy.
  ///
  /// In ko, this message translates to:
  /// **'원본 저장소를 upstream 원격으로 추가하면 원본의 새 커밋을 가져올 수 있습니다.'**
  String get bdForkAddWhy;

  /// No description provided for @bdForkSyncWhy.
  ///
  /// In ko, this message translates to:
  /// **'원본(upstream)의 새 커밋을 가져와 현재 브랜치로 병합합니다.'**
  String get bdForkSyncWhy;

  /// No description provided for @bdForkAddUpstream.
  ///
  /// In ko, this message translates to:
  /// **'upstream 추가'**
  String get bdForkAddUpstream;

  /// No description provided for @bdForkSync.
  ///
  /// In ko, this message translates to:
  /// **'upstream에서 가져오기'**
  String get bdForkSync;

  /// No description provided for @bdRemotesGhDefault.
  ///
  /// In ko, this message translates to:
  /// **'gh가 쓰는 저장소 (PR·릴리스·CI)'**
  String get bdRemotesGhDefault;

  /// No description provided for @bdRemotesGhDefaultNone.
  ///
  /// In ko, this message translates to:
  /// **'정해지지 않음'**
  String get bdRemotesGhDefaultNone;

  /// No description provided for @bdDoneGhDefault.
  ///
  /// In ko, this message translates to:
  /// **'gh가 {repo}을(를) 쓰도록 정했습니다'**
  String bdDoneGhDefault(String repo);

  /// No description provided for @bdReleaseNeedsRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격이 없어 릴리스할 수 없습니다. 원격 탭에서 먼저 올리세요.'**
  String get bdReleaseNeedsRemote;

  /// No description provided for @bdReleaseNeedsFiles.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 워크플로가 쓰는 파일이 없어 릴리스할 수 없습니다: {files}. 태그를 달아도 CI가 패키지를 만들지 못합니다.'**
  String bdReleaseNeedsFiles(String files);

  /// No description provided for @bdReleaseDirectOnlyNotGitHub.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 저장소가 아니라서 바로 커밋 방식(점검 → 버전 → 태그)으로 진행합니다. PR·릴리스 노트·CI는 호스팅 웹에서 하세요.'**
  String get bdReleaseDirectOnlyNotGitHub;

  /// No description provided for @bdReleaseDirectOnly.
  ///
  /// In ko, this message translates to:
  /// **'gh를 쓸 수 없어 바로 커밋 방식만 됩니다.'**
  String get bdReleaseDirectOnly;

  /// No description provided for @bdReleaseDirectMode.
  ///
  /// In ko, this message translates to:
  /// **'바로 커밋 방식'**
  String get bdReleaseDirectMode;

  /// No description provided for @bdReleaseDirectModeWhy.
  ///
  /// In ko, this message translates to:
  /// **'PR 없이 {branch}에 버전 올림을 커밋하고 커밋과 태그를 함께 push합니다. 혼자 쓰는 저장소에서만 쓰세요 — 보호된 브랜치면 push가 거부됩니다.'**
  String bdReleaseDirectModeWhy(String branch);

  /// No description provided for @bdTagCheckSyncedDirect.
  ///
  /// In ko, this message translates to:
  /// **'{branch}에 있고 원격에 내게 없는 커밋이 없다'**
  String bdTagCheckSyncedDirect(String branch);

  /// No description provided for @bdVersionUsesScript.
  ///
  /// In ko, this message translates to:
  /// **'저장소의 scripts/bump-version.sh로 버전을 올립니다 (lock 파일 포함, 규약과 같은 결과).'**
  String get bdVersionUsesScript;

  /// No description provided for @bdVersionLockFiles.
  ///
  /// In ko, this message translates to:
  /// **'함께 맞출 lock 파일: {files}'**
  String bdVersionLockFiles(String files);

  /// No description provided for @bdVersionFileChoose.
  ///
  /// In ko, this message translates to:
  /// **'버전 파일 바꾸기'**
  String get bdVersionFileChoose;

  /// No description provided for @bdVersionFileCustom.
  ///
  /// In ko, this message translates to:
  /// **'버전 파일: {path} (직접 지정)'**
  String bdVersionFileCustom(String path);

  /// No description provided for @bdVersionFileTitle.
  ///
  /// In ko, this message translates to:
  /// **'버전 파일 지정'**
  String get bdVersionFileTitle;

  /// No description provided for @bdVersionFileWhy.
  ///
  /// In ko, this message translates to:
  /// **'자동으로 찾지 못하거나 다른 파일을 쓸 때 정합니다. 정규식의 첫 번째 괄호가 버전입니다. 이 저장소에만 적용됩니다.'**
  String get bdVersionFileWhy;

  /// No description provided for @bdVersionFilePath.
  ///
  /// In ko, this message translates to:
  /// **'파일 (저장소 기준 경로)'**
  String get bdVersionFilePath;

  /// No description provided for @bdVersionFilePattern.
  ///
  /// In ko, this message translates to:
  /// **'버전 줄 정규식'**
  String get bdVersionFilePattern;

  /// No description provided for @bdVersionFileFound.
  ///
  /// In ko, this message translates to:
  /// **'찾았습니다: {version}'**
  String bdVersionFileFound(String version);

  /// No description provided for @bdVersionFileNotFound.
  ///
  /// In ko, this message translates to:
  /// **'파일이 없거나 패턴에 맞는 버전이 없습니다'**
  String get bdVersionFileNotFound;

  /// No description provided for @bdVersionFileAuto.
  ///
  /// In ko, this message translates to:
  /// **'자동 감지로 되돌리기'**
  String get bdVersionFileAuto;

  /// No description provided for @bdRollbackTitle.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 되돌리기'**
  String get bdRollbackTitle;

  /// No description provided for @bdRollbackConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'{tag} 릴리스를 되돌릴까요?'**
  String bdRollbackConfirmTitle(String tag);

  /// No description provided for @bdRollbackMessage.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 릴리스, 원격 태그, 로컬 태그를 지웁니다. 이미 받아 간 사람이 있을 수 있으니 같은 번호를 다시 쓰지 말고 다음 번호({next})로 새로 릴리스하세요.'**
  String bdRollbackMessage(String next);

  /// No description provided for @bdDoneRollback.
  ///
  /// In ko, this message translates to:
  /// **'{tag}을(를) 되돌렸습니다'**
  String bdDoneRollback(String tag);

  /// No description provided for @bdDiffBinary.
  ///
  /// In ko, this message translates to:
  /// **'바이너리 파일이라 내용을 비교할 수 없습니다'**
  String get bdDiffBinary;

  /// No description provided for @bdDiffEmpty.
  ///
  /// In ko, this message translates to:
  /// **'차이가 없습니다'**
  String get bdDiffEmpty;

  /// No description provided for @bdDiffTruncated.
  ///
  /// In ko, this message translates to:
  /// **'너무 길어 처음 {count}줄만 보여 줍니다. 전체는 편집기에서 보세요.'**
  String bdDiffTruncated(int count);

  /// No description provided for @bdHeaderCherryPicking.
  ///
  /// In ko, this message translates to:
  /// **'cherry-pick 중 · 충돌 {count}'**
  String bdHeaderCherryPicking(int count);

  /// No description provided for @bdHeaderReverting.
  ///
  /// In ko, this message translates to:
  /// **'되돌리는 중 · 충돌 {count}'**
  String bdHeaderReverting(int count);

  /// No description provided for @bdOperationAbortPickMessage.
  ///
  /// In ko, this message translates to:
  /// **'시작하기 전 상태로 되돌립니다. 충돌을 해결하던 내용은 사라집니다.'**
  String get bdOperationAbortPickMessage;

  /// No description provided for @bdHistoryBranchLabel.
  ///
  /// In ko, this message translates to:
  /// **'볼 브랜치'**
  String get bdHistoryBranchLabel;

  /// No description provided for @bdHistoryOtherBranchHint.
  ///
  /// In ko, this message translates to:
  /// **'다른 브랜치의 기록입니다. 커밋 메뉴의 \'가져오기\'로 {head}에 복사할 수 있습니다.'**
  String bdHistoryOtherBranchHint(String head);

  /// No description provided for @bdHistoryViewChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경 내용 보기'**
  String get bdHistoryViewChanges;

  /// No description provided for @bdHistoryFilesChanged.
  ///
  /// In ko, this message translates to:
  /// **'바뀐 파일 {count}개'**
  String bdHistoryFilesChanged(int count);

  /// No description provided for @bdHistoryMergeNote.
  ///
  /// In ko, this message translates to:
  /// **'병합 커밋 — 병합으로 들어온 변경'**
  String get bdHistoryMergeNote;

  /// No description provided for @bdHistoryRevert.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋 되돌리기 (revert)'**
  String get bdHistoryRevert;

  /// No description provided for @bdHistoryRevertTitle.
  ///
  /// In ko, this message translates to:
  /// **'{hash}을(를) 되돌릴까요?'**
  String bdHistoryRevertTitle(String hash);

  /// No description provided for @bdHistoryRevertMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 기록을 지우지 않으므로 이미 올린 커밋에도 안전합니다.'**
  String get bdHistoryRevertMessage;

  /// No description provided for @bdHistoryRevertUnpushed.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 아직 올리지 않은 커밋이라면 \'직전 커밋 고치기\'나 새 커밋으로 고쳐도 됩니다.'**
  String get bdHistoryRevertUnpushed;

  /// No description provided for @bdHistoryCherryPick.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get bdHistoryCherryPick;

  /// No description provided for @bdHistoryCherryPickMenu.
  ///
  /// In ko, this message translates to:
  /// **'{head}(으)로 가져오기 (cherry-pick)'**
  String bdHistoryCherryPickMenu(String head);

  /// No description provided for @bdHistoryCherryPickTitle.
  ///
  /// In ko, this message translates to:
  /// **'{hash}을(를) {head}(으)로 가져올까요?'**
  String bdHistoryCherryPickTitle(String hash, String head);

  /// No description provided for @bdHistoryCherryPickMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋과 같은 변경을 현재 브랜치에 새 커밋으로 복사합니다. 브랜치 전체를 병합하지 않고 필요한 커밋 하나만 가져올 때 씁니다.'**
  String get bdHistoryCherryPickMessage;

  /// No description provided for @bdDoneRevert.
  ///
  /// In ko, this message translates to:
  /// **'{hash}을(를) 되돌리는 커밋을 만들었습니다'**
  String bdDoneRevert(String hash);

  /// No description provided for @bdDoneCherryPick.
  ///
  /// In ko, this message translates to:
  /// **'{hash}을(를) 가져왔습니다'**
  String bdDoneCherryPick(String hash);

  /// No description provided for @bdMenuPalette.
  ///
  /// In ko, this message translates to:
  /// **'명령 팔레트'**
  String get bdMenuPalette;

  /// No description provided for @bdPaletteHint.
  ///
  /// In ko, this message translates to:
  /// **'무엇을 할까요? (예: push, 브랜치, 태그)'**
  String get bdPaletteHint;

  /// No description provided for @bdPaletteEmpty.
  ///
  /// In ko, this message translates to:
  /// **'맞는 명령이 없습니다'**
  String get bdPaletteEmpty;

  /// No description provided for @bdPaletteGroupActions.
  ///
  /// In ko, this message translates to:
  /// **'동작'**
  String get bdPaletteGroupActions;

  /// No description provided for @bdPaletteGroupTabs.
  ///
  /// In ko, this message translates to:
  /// **'탭'**
  String get bdPaletteGroupTabs;

  /// No description provided for @bdPaletteGroupBranches.
  ///
  /// In ko, this message translates to:
  /// **'브랜치'**
  String get bdPaletteGroupBranches;

  /// No description provided for @bdPaletteGroupRepos.
  ///
  /// In ko, this message translates to:
  /// **'저장소'**
  String get bdPaletteGroupRepos;

  /// No description provided for @bdPaletteGoToTab.
  ///
  /// In ko, this message translates to:
  /// **'{name} 탭으로'**
  String bdPaletteGoToTab(String name);

  /// No description provided for @bdPaletteSwitchTo.
  ///
  /// In ko, this message translates to:
  /// **'{branch}(으)로 전환'**
  String bdPaletteSwitchTo(String branch);

  /// No description provided for @bdHelpCaptionAfterRevert.
  ///
  /// In ko, this message translates to:
  /// **'C를 지우지 않고, C를 거꾸로 적용한 새 커밋 C⁻를 더함'**
  String get bdHelpCaptionAfterRevert;

  /// No description provided for @bdHelpCaptionAfterCherryPick.
  ///
  /// In ko, this message translates to:
  /// **'feature의 D와 같은 변경이 main에 새 커밋 D\'로 복사됨'**
  String get bdHelpCaptionAfterCherryPick;

  /// No description provided for @bdHelpRevertTitle.
  ///
  /// In ko, this message translates to:
  /// **'Revert (되돌리기)'**
  String get bdHelpRevertTitle;

  /// No description provided for @bdHelpRevertWord.
  ///
  /// In ko, this message translates to:
  /// **'revert는 \'원래 상태로 되돌리다\'.'**
  String get bdHelpRevertWord;

  /// No description provided for @bdHelpRevertInGit.
  ///
  /// In ko, this message translates to:
  /// **'커밋을 지우지 않고, 그 커밋의 변경을 거꾸로 적용한 새 커밋을 만듭니다. 기록에는 원래 커밋과 되돌린 커밋이 모두 남습니다.'**
  String get bdHelpRevertInGit;

  /// No description provided for @bdHelpRevertWhy.
  ///
  /// In ko, this message translates to:
  /// **'이미 올린 커밋이 문제를 일으켰을 때 씁니다. 기록을 고치지 않아 다른 사람과 어긋나지 않고 강제 push도 필요 없습니다. 아직 올리지 않은 커밋은 amend로 고치는 편이 깔끔합니다.'**
  String get bdHelpRevertWhy;

  /// No description provided for @bdHelpCaptionBeforeReset.
  ///
  /// In ko, this message translates to:
  /// **'전: main이 D를 가리킴'**
  String get bdHelpCaptionBeforeReset;

  /// No description provided for @bdHelpCaptionAfterReset.
  ///
  /// In ko, this message translates to:
  /// **'후: main이 B로 옮겨짐. C·D는 사라진 것 같지만 reflog에 남아 있음'**
  String get bdHelpCaptionAfterReset;

  /// No description provided for @bdHelpCaptionReflog.
  ///
  /// In ko, this message translates to:
  /// **'HEAD가 지나온 자리가 순서대로 적혀 있어, D로 다시 돌아갈 수 있음'**
  String get bdHelpCaptionReflog;

  /// No description provided for @bdHelpResetTitle.
  ///
  /// In ko, this message translates to:
  /// **'Reset (브랜치 옮기기)'**
  String get bdHelpResetTitle;

  /// No description provided for @bdHelpResetWord.
  ///
  /// In ko, this message translates to:
  /// **'reset은 \'처음 자리로 되돌려 놓다\'.'**
  String get bdHelpResetWord;

  /// No description provided for @bdHelpResetInGit.
  ///
  /// In ko, this message translates to:
  /// **'브랜치가 가리키는 커밋을 뒤로 옮깁니다. 커밋이 지워진 것처럼 보이지만 reflog에 남아 있어 한동안 되살릴 수 있습니다. --soft는 변경을 스테이징한 채 남기고, --keep은 작업 중인 변경을 지키며, --hard는 작업 중인 변경까지 버립니다.'**
  String get bdHelpResetInGit;

  /// No description provided for @bdHelpResetWhy.
  ///
  /// In ko, this message translates to:
  /// **'아직 올리지 않은 커밋을 취소할 때 씁니다. 이미 올린 커밋에는 쓰지 마세요. 다른 사람의 기록과 어긋나니 revert를 쓰세요. 이 앱은 안전한 --soft와 --keep만 씁니다.'**
  String get bdHelpResetWhy;

  /// No description provided for @bdHelpReflogTitle.
  ///
  /// In ko, this message translates to:
  /// **'Reflog (실수 복구 기록)'**
  String get bdHelpReflogTitle;

  /// No description provided for @bdHelpReflogWord.
  ///
  /// In ko, this message translates to:
  /// **'reflog는 \'reference log\', 가리키던 자리의 기록.'**
  String get bdHelpReflogWord;

  /// No description provided for @bdHelpReflogInGit.
  ///
  /// In ko, this message translates to:
  /// **'HEAD와 브랜치가 어디를 가리켰는지 이 컴퓨터에만 적어 둔 기록입니다. 커밋을 취소하거나 브랜치를 지워도 보통 90일 동안은 그 시점을 찾아 되돌아갈 수 있습니다.'**
  String get bdHelpReflogInGit;

  /// No description provided for @bdHelpReflogWhy.
  ///
  /// In ko, this message translates to:
  /// **'\'실수했다\' 싶으면 먼저 reflog를 보세요. 이 컴퓨터에만 있는 기록이라 다른 컴퓨터나 원격에서는 볼 수 없고, 오래된 항목은 git이 정리합니다.'**
  String get bdHelpReflogWhy;

  /// No description provided for @bdHistoryGraph.
  ///
  /// In ko, this message translates to:
  /// **'그래프'**
  String get bdHistoryGraph;

  /// No description provided for @bdHistoryAllBranches.
  ///
  /// In ko, this message translates to:
  /// **'모든 브랜치'**
  String get bdHistoryAllBranches;

  /// No description provided for @bdHelpCaptionGraphMerged.
  ///
  /// In ko, this message translates to:
  /// **'main과 feature가 갈라졌다가 M에서 합쳐진 기록 (속이 빈 점이 병합 커밋)'**
  String get bdHelpCaptionGraphMerged;

  /// No description provided for @bdHelpCommitGraphTitle.
  ///
  /// In ko, this message translates to:
  /// **'커밋 그래프 읽는 법'**
  String get bdHelpCommitGraphTitle;

  /// No description provided for @bdHelpCommitGraphWord.
  ///
  /// In ko, this message translates to:
  /// **'graph는 \'점과 선으로 그린 그림\'.'**
  String get bdHelpCommitGraphWord;

  /// No description provided for @bdHelpCommitGraphInGit.
  ///
  /// In ko, this message translates to:
  /// **'점은 커밋, 선은 부모와의 이음입니다. 위가 최신입니다. 선이 둘로 갈라지면 브랜치가 갈라진 곳, 두 선이 하나로 합쳐지면 병합입니다. 속이 빈 점은 병합 커밋, 고리가 둘러진 점은 지금 있는 자리(HEAD)입니다.'**
  String get bdHelpCommitGraphInGit;

  /// No description provided for @bdHelpCommitGraphWhy.
  ///
  /// In ko, this message translates to:
  /// **'\'내 브랜치가 main과 어디서 갈라졌는지\', \'병합이 어디서 일어났는지\'를 한눈에 봅니다. 좁은 창에서는 선을 6줄까지만 그립니다. 그보다 많으면 맨 오른쪽 줄에 겹쳐 보입니다.'**
  String get bdHelpCommitGraphWhy;

  /// No description provided for @bdRecoveryTitle.
  ///
  /// In ko, this message translates to:
  /// **'실수 복구'**
  String get bdRecoveryTitle;

  /// No description provided for @bdRecoveryIntro.
  ///
  /// In ko, this message translates to:
  /// **'실수했어도 대부분 되돌릴 수 있습니다. 상황에 맞는 것을 고르세요.'**
  String get bdRecoveryIntro;

  /// No description provided for @bdRecoveryUndoCommit.
  ///
  /// In ko, this message translates to:
  /// **'마지막 커밋 취소'**
  String get bdRecoveryUndoCommit;

  /// No description provided for @bdRecoveryUndoCommitWhy.
  ///
  /// In ko, this message translates to:
  /// **'\'{subject}\' 커밋만 취소합니다. 바꾼 내용은 스테이징된 채 남습니다.'**
  String bdRecoveryUndoCommitWhy(String subject);

  /// No description provided for @bdRecoveryUndoCommitMessage.
  ///
  /// In ko, this message translates to:
  /// **'\'{subject}\' 커밋을 취소합니다. 그 커밋에서 바꾼 내용은 지워지지 않고 스테이징된 채 남아, 고쳐서 다시 커밋할 수 있습니다.'**
  String bdRecoveryUndoCommitMessage(String subject);

  /// No description provided for @bdRecoveryUndoCommitPushed.
  ///
  /// In ko, this message translates to:
  /// **'이 커밋은 이미 원격에 올라가 있습니다. 취소해도 원격에는 남아 있어 다시 올리려면 강제 push가 필요하고, 다른 사람의 기록과 어긋납니다. 올린 커밋은 기록 탭의 \'되돌리기(revert)\'가 더 안전합니다.'**
  String get bdRecoveryUndoCommitPushed;

  /// No description provided for @bdRecoveryUndoCommitConfirm.
  ///
  /// In ko, this message translates to:
  /// **'커밋 취소'**
  String get bdRecoveryUndoCommitConfirm;

  /// No description provided for @bdRecoveryNoParent.
  ///
  /// In ko, this message translates to:
  /// **'첫 커밋은 취소할 수 없습니다.'**
  String get bdRecoveryNoParent;

  /// No description provided for @bdRecoveryStash.
  ///
  /// In ko, this message translates to:
  /// **'작업 중인 변경을 잠시 치우기'**
  String get bdRecoveryStash;

  /// No description provided for @bdRecoveryStashWhy.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장(stash)에 보관했다가 나중에 다시 꺼냅니다.'**
  String get bdRecoveryStashWhy;

  /// No description provided for @bdRecoveryHistory.
  ///
  /// In ko, this message translates to:
  /// **'이전 상태로 돌아가기'**
  String get bdRecoveryHistory;

  /// No description provided for @bdRecoveryHistoryHint.
  ///
  /// In ko, this message translates to:
  /// **'HEAD가 지나온 자리입니다. 커밋을 취소하거나 브랜치를 지운 뒤에도 보통 90일 동안 남아 있습니다.'**
  String get bdRecoveryHistoryHint;

  /// No description provided for @bdRecoveryNow.
  ///
  /// In ko, this message translates to:
  /// **'지금'**
  String get bdRecoveryNow;

  /// No description provided for @bdRecoveryEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없습니다.'**
  String get bdRecoveryEmpty;

  /// No description provided for @bdRecoveryKindCommit.
  ///
  /// In ko, this message translates to:
  /// **'커밋'**
  String get bdRecoveryKindCommit;

  /// No description provided for @bdRecoveryKindAmend.
  ///
  /// In ko, this message translates to:
  /// **'커밋 고침'**
  String get bdRecoveryKindAmend;

  /// No description provided for @bdRecoveryKindCheckout.
  ///
  /// In ko, this message translates to:
  /// **'전환'**
  String get bdRecoveryKindCheckout;

  /// No description provided for @bdRecoveryKindReset.
  ///
  /// In ko, this message translates to:
  /// **'되돌림'**
  String get bdRecoveryKindReset;

  /// No description provided for @bdRecoveryKindMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합'**
  String get bdRecoveryKindMerge;

  /// No description provided for @bdRecoveryKindPull.
  ///
  /// In ko, this message translates to:
  /// **'pull'**
  String get bdRecoveryKindPull;

  /// No description provided for @bdRecoveryKindRebase.
  ///
  /// In ko, this message translates to:
  /// **'rebase'**
  String get bdRecoveryKindRebase;

  /// No description provided for @bdRecoveryKindCherryPick.
  ///
  /// In ko, this message translates to:
  /// **'cherry-pick'**
  String get bdRecoveryKindCherryPick;

  /// No description provided for @bdRecoveryKindRevert.
  ///
  /// In ko, this message translates to:
  /// **'revert'**
  String get bdRecoveryKindRevert;

  /// No description provided for @bdRecoveryKindOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get bdRecoveryKindOther;

  /// No description provided for @bdRecoveryGoBack.
  ///
  /// In ko, this message translates to:
  /// **'여기로 되돌리기'**
  String get bdRecoveryGoBack;

  /// No description provided for @bdRecoveryGoBackMessage.
  ///
  /// In ko, this message translates to:
  /// **'{branch}를 {target} 시점으로 되돌립니다. 그 뒤의 커밋은 브랜치에서 빠지지만 reflog에 남아 있습니다. 작업 중인 변경은 그대로 두며, 겹치는 파일이 있으면 아무것도 바꾸지 않고 멈춥니다.'**
  String bdRecoveryGoBackMessage(String branch, String target);

  /// No description provided for @bdRecoveryGoBackConfirm.
  ///
  /// In ko, this message translates to:
  /// **'되돌리기'**
  String get bdRecoveryGoBackConfirm;

  /// No description provided for @bdRecoveryRescue.
  ///
  /// In ko, this message translates to:
  /// **'여기서 새 브랜치 만들기'**
  String get bdRecoveryRescue;

  /// No description provided for @bdDoneUndoCommit.
  ///
  /// In ko, this message translates to:
  /// **'마지막 커밋을 취소했습니다 (변경은 스테이징된 채 남음)'**
  String get bdDoneUndoCommit;

  /// No description provided for @bdDoneGoBack.
  ///
  /// In ko, this message translates to:
  /// **'{target} 시점으로 되돌렸습니다'**
  String bdDoneGoBack(String target);

  /// No description provided for @bdDoneRescue.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 {name}을 만들었습니다'**
  String bdDoneRescue(String name);

  /// No description provided for @bdHelpCherryPickTitle.
  ///
  /// In ko, this message translates to:
  /// **'Cherry-pick (골라 가져오기)'**
  String get bdHelpCherryPickTitle;

  /// No description provided for @bdHelpCherryPickWord.
  ///
  /// In ko, this message translates to:
  /// **'cherry-pick은 \'체리를 하나씩 골라 따다\' — 좋은 것만 골라 가져오기.'**
  String get bdHelpCherryPickWord;

  /// No description provided for @bdHelpCherryPickInGit.
  ///
  /// In ko, this message translates to:
  /// **'다른 브랜치의 커밋 하나와 같은 변경을 현재 브랜치에 새 커밋으로 복사합니다. 내용은 같지만 새 커밋(D\')이라 해시가 다릅니다.'**
  String get bdHelpCherryPickInGit;

  /// No description provided for @bdHelpCherryPickWhy.
  ///
  /// In ko, this message translates to:
  /// **'다른 브랜치의 버그 수정 하나만 급히 가져올 때 씁니다. 브랜치를 나중에 병합하면 같은 변경이 두 번 들어와 충돌할 수 있으니, 자주 쓰기보다 병합이 기본입니다.'**
  String get bdHelpCherryPickWhy;

  /// No description provided for @bdConfirmTypeToContinue.
  ///
  /// In ko, this message translates to:
  /// **'되돌릴 수 없습니다. 계속하려면 {text}을(를) 그대로 입력하세요.'**
  String bdConfirmTypeToContinue(String text);

  /// No description provided for @bdTagsDeleteRemoteReleaseDraft.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ {tag}에는 GitHub 릴리스가 있습니다. 태그를 지우면 GitHub가 그 릴리스를 초안(비공개)으로 바꿉니다 — 파일은 남지만 사람들이 볼 수 없게 됩니다. 릴리스까지 정리하려면 태그 메뉴의 \'릴리스 되돌리기\'를 쓰세요.'**
  String bdTagsDeleteRemoteReleaseDraft(String tag);

  /// No description provided for @bdTagsPushCiTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그 {count}개를 push하면 릴리스가 새로 만들어집니다'**
  String bdTagsPushCiTitle(int count);

  /// No description provided for @bdTagsPushCiMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 저장소는 태그를 push하면 {workflow}이(가) 태그마다 빌드하고 GitHub 릴리스를 만듭니다: {tags}. 일부러 지운 옛 릴리스라면 다시 생깁니다. 로컬에서만 지우려면 태그 메뉴의 \'삭제\'를 쓰세요.'**
  String bdTagsPushCiMessage(String workflow, String tags);

  /// No description provided for @bdTagsPushAnyway.
  ///
  /// In ko, this message translates to:
  /// **'그래도 push'**
  String get bdTagsPushAnyway;

  /// No description provided for @bdTagsPushMismatchTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그 {count}개의 버전이 버전 파일과 다릅니다'**
  String bdTagsPushMismatchTitle(int count);

  /// No description provided for @bdTagsPushMismatchMessage.
  ///
  /// In ko, this message translates to:
  /// **'태그가 가리키는 커밋의 {file} 버전이 태그와 다릅니다 (태그 → 파일의 버전): {tags}. 버전을 올리기 전의 커밋에 단 태그일 수 있습니다. 이대로 올리면 태그로 릴리스를 만드는 CI가 버전 검사에서 멈춥니다. 릴리스 마법사로 버전 올림부터 하세요.'**
  String bdTagsPushMismatchMessage(String file, String tags);

  /// No description provided for @bdCiVersionMismatchMessage.
  ///
  /// In ko, this message translates to:
  /// **'CI가 {tag} 태그와 버전 파일의 버전이 다르다며 멈췄습니다. 태그가 버전 올림 커밋보다 앞선 커밋에 달린 것입니다. 다시 실행해도 같은 결과이니, 버전 올림 커밋이 기본 브랜치에 들어갔는지 확인한 뒤 태그를 지우고 다시 다세요.'**
  String bdCiVersionMismatchMessage(String tag);

  /// No description provided for @bdCiRetag.
  ///
  /// In ko, this message translates to:
  /// **'태그 지우고 다시 달기'**
  String get bdCiRetag;

  /// No description provided for @bdCommonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get bdCommonDelete;

  /// No description provided for @bdPrReviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'리뷰와 코멘트'**
  String get bdPrReviewTitle;

  /// No description provided for @bdPrReviewShowAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 보기 ({count})'**
  String bdPrReviewShowAll(int count);

  /// No description provided for @bdPrReviewShowLess.
  ///
  /// In ko, this message translates to:
  /// **'접기'**
  String get bdPrReviewShowLess;

  /// No description provided for @bdPrReviewApprove.
  ///
  /// In ko, this message translates to:
  /// **'승인'**
  String get bdPrReviewApprove;

  /// No description provided for @bdPrReviewRequestChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경 요청'**
  String get bdPrReviewRequestChanges;

  /// No description provided for @bdPrReviewComment.
  ///
  /// In ko, this message translates to:
  /// **'코멘트'**
  String get bdPrReviewComment;

  /// No description provided for @bdPrReviewOwnPr.
  ///
  /// In ko, this message translates to:
  /// **'내가 만든 PR은 스스로 승인하거나 변경을 요청할 수 없습니다. 코멘트는 남길 수 있습니다.'**
  String get bdPrReviewOwnPr;

  /// No description provided for @bdPrReviewSend.
  ///
  /// In ko, this message translates to:
  /// **'보내기'**
  String get bdPrReviewSend;

  /// No description provided for @bdPrReviewBody.
  ///
  /// In ko, this message translates to:
  /// **'내용 (Markdown)'**
  String get bdPrReviewBody;

  /// No description provided for @bdPrReviewBodyOptional.
  ///
  /// In ko, this message translates to:
  /// **'내용 (선택, Markdown)'**
  String get bdPrReviewBodyOptional;

  /// No description provided for @bdDonePrReview.
  ///
  /// In ko, this message translates to:
  /// **'#{number}에 리뷰를 남겼습니다'**
  String bdDonePrReview(int number);

  /// No description provided for @bdAssetTitle.
  ///
  /// In ko, this message translates to:
  /// **'첨부 파일 {count}개'**
  String bdAssetTitle(int count);

  /// No description provided for @bdAssetEmpty.
  ///
  /// In ko, this message translates to:
  /// **'첨부 파일이 없습니다. CI가 올린 빌드 결과물이 여기에 보입니다.'**
  String get bdAssetEmpty;

  /// No description provided for @bdAssetMeta.
  ///
  /// In ko, this message translates to:
  /// **'{size} · 받은 횟수 {count}'**
  String bdAssetMeta(String size, int count);

  /// No description provided for @bdAssetUpload.
  ///
  /// In ko, this message translates to:
  /// **'파일 올리기'**
  String get bdAssetUpload;

  /// No description provided for @bdAssetDownload.
  ///
  /// In ko, this message translates to:
  /// **'받기'**
  String get bdAssetDownload;

  /// No description provided for @bdAssetReplace.
  ///
  /// In ko, this message translates to:
  /// **'덮어쓰기'**
  String get bdAssetReplace;

  /// No description provided for @bdAssetReplaceTitle.
  ///
  /// In ko, this message translates to:
  /// **'같은 이름의 파일을 덮어쓸까요?'**
  String get bdAssetReplaceTitle;

  /// No description provided for @bdAssetReplaceMessage.
  ///
  /// In ko, this message translates to:
  /// **'{names} — 이미 받아 간 사람이 있다면 내용이 서로 달라집니다. 가능하면 새 버전으로 릴리스하세요.'**
  String bdAssetReplaceMessage(String names);

  /// No description provided for @bdAssetDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name}을(를) 삭제할까요?'**
  String bdAssetDeleteTitle(String name);

  /// No description provided for @bdAssetDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 페이지에서 이 파일을 지웁니다. 되돌릴 수 없고, 이 파일로 연결된 다운로드 주소도 끊깁니다.'**
  String get bdAssetDeleteMessage;

  /// No description provided for @bdDoneAssetDownloaded.
  ///
  /// In ko, this message translates to:
  /// **'{name}을(를) 받았습니다'**
  String bdDoneAssetDownloaded(String name);

  /// No description provided for @bdDoneAssetUploaded.
  ///
  /// In ko, this message translates to:
  /// **'파일 {count}개를 올렸습니다'**
  String bdDoneAssetUploaded(int count);

  /// No description provided for @bdDoneAssetDeleted.
  ///
  /// In ko, this message translates to:
  /// **'{name}을(를) 삭제했습니다'**
  String bdDoneAssetDeleted(String name);

  /// No description provided for @bdSyncUpstreamCounts.
  ///
  /// In ko, this message translates to:
  /// **'{upstream}  ↑{ahead} ↓{behind}'**
  String bdSyncUpstreamCounts(String upstream, int ahead, int behind);

  /// No description provided for @bdSyncNoUpstream.
  ///
  /// In ko, this message translates to:
  /// **'{branch}에 연결된 원격 브랜치가 없습니다'**
  String bdSyncNoUpstream(String branch);

  /// No description provided for @bdSyncOnOtherBranch.
  ///
  /// In ko, this message translates to:
  /// **'지금은 {branch}에 있습니다'**
  String bdSyncOnOtherBranch(String branch);

  /// No description provided for @bdSyncBehind.
  ///
  /// In ko, this message translates to:
  /// **'원격에 아직 받지 않은 커밋이 {count}개 있습니다. Pull 하세요.'**
  String bdSyncBehind(int count);

  /// No description provided for @bdSyncAhead.
  ///
  /// In ko, this message translates to:
  /// **'push하지 않은 커밋이 {count}개 있습니다.'**
  String bdSyncAhead(int count);

  /// No description provided for @bdSyncAheadPr.
  ///
  /// In ko, this message translates to:
  /// **'push하지 않은 커밋이 {count}개 있습니다. 여기서 Push하면 PR 없이 {branch}에 바로 올라갑니다.'**
  String bdSyncAheadPr(int count, String branch);

  /// No description provided for @bdSyncDiverged.
  ///
  /// In ko, this message translates to:
  /// **'원격과 갈라졌습니다. 받을 커밋 {behind}개, 보낼 커밋 {ahead}개.'**
  String bdSyncDiverged(int behind, int ahead);

  /// No description provided for @bdSyncSameContent.
  ///
  /// In ko, this message translates to:
  /// **'파일 내용은 원격과 같고 커밋만 다릅니다 (로컬 커밋 {count}개). PR을 squash나 rebase로 병합하면 로컬에 옛 커밋이 남아 이렇게 됩니다.'**
  String bdSyncSameContent(int count);

  /// No description provided for @bdSyncMatchRemote.
  ///
  /// In ko, this message translates to:
  /// **'원격에 맞추기'**
  String get bdSyncMatchRemote;

  /// No description provided for @bdSyncMatchRemoteTitle.
  ///
  /// In ko, this message translates to:
  /// **'{branch}를 원격에 맞출까요?'**
  String bdSyncMatchRemoteTitle(String branch);

  /// No description provided for @bdSyncMatchRemoteMessage.
  ///
  /// In ko, this message translates to:
  /// **'로컬 커밋 {count}개를 버리고 {branch}를 {upstream}으로 옮깁니다. 파일 내용은 그대로이고 커밋하지 않은 변경도 지킵니다. 버린 커밋은 git reflog로 되찾을 수 있습니다.'**
  String bdSyncMatchRemoteMessage(int count, String branch, String upstream);

  /// No description provided for @bdDoneMatchRemote.
  ///
  /// In ko, this message translates to:
  /// **'{branch}를 원격에 맞췄습니다'**
  String bdDoneMatchRemote(String branch);

  /// No description provided for @bdSyncPushNoPrTitle.
  ///
  /// In ko, this message translates to:
  /// **'PR 없이 {branch}에 push할까요?'**
  String bdSyncPushNoPrTitle(String branch);

  /// No description provided for @bdSyncPushNoPrMessage.
  ///
  /// In ko, this message translates to:
  /// **'push하지 않은 커밋 {count}개가 PR을 거치지 않고 {branch}에 바로 올라갑니다. 보호된 브랜치면 거부됩니다. 작업 브랜치로 옮겨 PR을 올리는 편이 안전합니다.'**
  String bdSyncPushNoPrMessage(int count, String branch);

  /// No description provided for @bdWorktreesTitle.
  ///
  /// In ko, this message translates to:
  /// **'Worktree'**
  String get bdWorktreesTitle;

  /// No description provided for @bdWorktreePill.
  ///
  /// In ko, this message translates to:
  /// **'worktree'**
  String get bdWorktreePill;

  /// No description provided for @bdWorktreeHeldTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{path}에 체크아웃되어 있습니다'**
  String bdWorktreeHeldTooltip(String path);

  /// No description provided for @bdWorktreeDetachedHead.
  ///
  /// In ko, this message translates to:
  /// **'분리된 HEAD'**
  String get bdWorktreeDetachedHead;

  /// No description provided for @bdWorktreeMainPill.
  ///
  /// In ko, this message translates to:
  /// **'기본 폴더'**
  String get bdWorktreeMainPill;

  /// No description provided for @bdWorktreeOpenPill.
  ///
  /// In ko, this message translates to:
  /// **'지금 연 폴더'**
  String get bdWorktreeOpenPill;

  /// No description provided for @bdWorktreeChangesPill.
  ///
  /// In ko, this message translates to:
  /// **'변경 {count}'**
  String bdWorktreeChangesPill(int count);

  /// No description provided for @bdWorktreeMissingPill.
  ///
  /// In ko, this message translates to:
  /// **'폴더 없음'**
  String get bdWorktreeMissingPill;

  /// No description provided for @bdWorktreeLockedPill.
  ///
  /// In ko, this message translates to:
  /// **'잠김'**
  String get bdWorktreeLockedPill;

  /// No description provided for @bdWorktreeOpen.
  ///
  /// In ko, this message translates to:
  /// **'열기'**
  String get bdWorktreeOpen;

  /// No description provided for @bdWorktreeDetach.
  ///
  /// In ko, this message translates to:
  /// **'브랜치 풀기'**
  String get bdWorktreeDetach;

  /// No description provided for @bdWorktreeRemove.
  ///
  /// In ko, this message translates to:
  /// **'지우기'**
  String get bdWorktreeRemove;

  /// No description provided for @bdWorktreeClaudeWarning.
  ///
  /// In ko, this message translates to:
  /// **'Claude Code 세션이 쓰는 폴더일 수 있습니다. 세션이 끝났는지 먼저 확인하세요.'**
  String get bdWorktreeClaudeWarning;

  /// No description provided for @bdWorktreeHeldTitle.
  ///
  /// In ko, this message translates to:
  /// **'{branch}는 다른 worktree에 있습니다'**
  String bdWorktreeHeldTitle(String branch);

  /// No description provided for @bdWorktreeHeldMessage.
  ///
  /// In ko, this message translates to:
  /// **'git은 한 브랜치를 한 worktree에서만 체크아웃하게 합니다. {path}에서 이 브랜치를 쓰고 있어 여기서는 전환할 수 없습니다. 그 폴더를 열어 작업하거나, 그 폴더의 브랜치를 풀고(분리된 HEAD) 여기로 전환하세요.'**
  String bdWorktreeHeldMessage(String path);

  /// No description provided for @bdWorktreeDetachAndSwitch.
  ///
  /// In ko, this message translates to:
  /// **'풀고 여기로 전환'**
  String get bdWorktreeDetachAndSwitch;

  /// No description provided for @bdWorktreeDetachTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 브랜치를 풀까요?'**
  String bdWorktreeDetachTitle(String name);

  /// No description provided for @bdWorktreeDetachMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}를 {branch}에서 분리된 HEAD로 바꿉니다. 파일과 커밋은 그대로이고, {branch}를 다른 곳에서 체크아웃하거나 지울 수 있게 됩니다.'**
  String bdWorktreeDetachMessage(String path, String branch);

  /// No description provided for @bdWorktreeRemoveTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} worktree를 지울까요?'**
  String bdWorktreeRemoveTitle(String name);

  /// No description provided for @bdWorktreeRemoveMessage.
  ///
  /// In ko, this message translates to:
  /// **'폴더 {path}를 지웁니다. 브랜치와 커밋은 저장소에 남습니다.'**
  String bdWorktreeRemoveMessage(String path);

  /// No description provided for @bdWorktreeRemoveForceTitle.
  ///
  /// In ko, this message translates to:
  /// **'커밋하지 않은 변경까지 지울까요?'**
  String get bdWorktreeRemoveForceTitle;

  /// No description provided for @bdWorktreeRemoveForceMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}에 커밋하지 않은 변경이 {count}개 있습니다. 지우면 되찾을 수 없습니다.'**
  String bdWorktreeRemoveForceMessage(String path, int count);

  /// No description provided for @bdWorktreeLockedMessage.
  ///
  /// In ko, this message translates to:
  /// **'{path}는 잠겨 있어 지울 수 없습니다. 먼저 git worktree unlock으로 잠금을 푸세요.'**
  String bdWorktreeLockedMessage(String path);

  /// No description provided for @bdWorktreeDeleteBranchTitle.
  ///
  /// In ko, this message translates to:
  /// **'worktree도 지우고 브랜치를 삭제할까요?'**
  String get bdWorktreeDeleteBranchTitle;

  /// No description provided for @bdWorktreeDeleteBranchMessage.
  ///
  /// In ko, this message translates to:
  /// **'{branch}는 {path}에 체크아웃되어 있어 그대로는 지울 수 없습니다. 그 worktree 폴더를 먼저 지우고 브랜치를 삭제합니다.'**
  String bdWorktreeDeleteBranchMessage(String branch, String path);

  /// No description provided for @bdWorktreeDeleteBranchDirty.
  ///
  /// In ko, this message translates to:
  /// **'{branch}는 {path}에 체크아웃되어 있고, 그 폴더에 커밋하지 않은 변경이 {count}개 있습니다. 그 폴더를 열어 정리한 뒤 다시 지우세요.'**
  String bdWorktreeDeleteBranchDirty(String branch, String path, int count);

  /// No description provided for @bdWorktreePrune.
  ///
  /// In ko, this message translates to:
  /// **'사라진 폴더 기록 정리'**
  String get bdWorktreePrune;

  /// No description provided for @bdDoneWorktreeRemoved.
  ///
  /// In ko, this message translates to:
  /// **'{name} worktree를 지웠습니다'**
  String bdDoneWorktreeRemoved(String name);

  /// No description provided for @bdDoneWorktreeDetached.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 브랜치를 풀었습니다'**
  String bdDoneWorktreeDetached(String name);

  /// No description provided for @bdDoneWorktreePruned.
  ///
  /// In ko, this message translates to:
  /// **'worktree 기록을 정리했습니다'**
  String get bdDoneWorktreePruned;

  /// No description provided for @bdCleanupWorktree.
  ///
  /// In ko, this message translates to:
  /// **'worktree {name}도 함께 지웁니다'**
  String bdCleanupWorktree(String name);

  /// No description provided for @bdCleanupWorktreeBlocked.
  ///
  /// In ko, this message translates to:
  /// **'worktree {name}에 커밋하지 않은 변경이 있거나 잠겨 있어 지울 수 없습니다'**
  String bdCleanupWorktreeBlocked(String name);

  /// No description provided for @bdEnvCustomPath.
  ///
  /// In ko, this message translates to:
  /// **'직접 지정'**
  String get bdEnvCustomPath;

  /// No description provided for @bdEnvSetPath.
  ///
  /// In ko, this message translates to:
  /// **'경로 지정'**
  String get bdEnvSetPath;

  /// No description provided for @bdEnvGitTooOld.
  ///
  /// In ko, this message translates to:
  /// **'git {min} 이상이 필요합니다. 일부 명령이 실패하거나 결과를 잘못 읽을 수 있습니다.'**
  String bdEnvGitTooOld(String min);

  /// No description provided for @bdEnvGhTooOld.
  ///
  /// In ko, this message translates to:
  /// **'gh {min} 이상이 필요합니다. 더 낮으면 로그인 확인(gh auth status --json)이 안 돼 로그인했어도 \"로그인 안 됨\"으로 보입니다.'**
  String bdEnvGhTooOld(String min);

  /// No description provided for @bdEnvCopyDiagnostics.
  ///
  /// In ko, this message translates to:
  /// **'진단 정보 복사'**
  String get bdEnvCopyDiagnostics;

  /// No description provided for @bdEnvDiagnosticsCopied.
  ///
  /// In ko, this message translates to:
  /// **'진단 정보를 복사했습니다. 문제를 알릴 때 붙여 넣으세요.'**
  String get bdEnvDiagnosticsCopied;

  /// No description provided for @bdEnvSearchPath.
  ///
  /// In ko, this message translates to:
  /// **'앱이 쓰는 PATH'**
  String get bdEnvSearchPath;

  /// No description provided for @bdToolPathTitle.
  ///
  /// In ko, this message translates to:
  /// **'{tool} 경로'**
  String bdToolPathTitle(String tool);

  /// No description provided for @bdToolPathWhy.
  ///
  /// In ko, this message translates to:
  /// **'PATH에서 찾은 {tool} 대신 쓸 실행 파일을 고릅니다. 비워 두면 PATH에서 찾습니다.'**
  String bdToolPathWhy(String tool);

  /// No description provided for @bdToolPathLabel.
  ///
  /// In ko, this message translates to:
  /// **'실행 파일'**
  String get bdToolPathLabel;

  /// No description provided for @bdToolPathBrowse.
  ///
  /// In ko, this message translates to:
  /// **'파일 고르기'**
  String get bdToolPathBrowse;

  /// No description provided for @bdToolPathVerify.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get bdToolPathVerify;

  /// No description provided for @bdToolPathUsePath.
  ///
  /// In ko, this message translates to:
  /// **'PATH에서 찾기'**
  String get bdToolPathUsePath;

  /// No description provided for @bdToolPathOk.
  ///
  /// In ko, this message translates to:
  /// **'{tool} {version} 확인됨'**
  String bdToolPathOk(String tool, String version);

  /// No description provided for @bdToolPathBad.
  ///
  /// In ko, this message translates to:
  /// **'실행할 수 없거나 {tool}이(가) 아닙니다'**
  String bdToolPathBad(String tool);

  /// No description provided for @bdToolPathNeedsCheck.
  ///
  /// In ko, this message translates to:
  /// **'저장하기 전에 확인을 누르세요'**
  String get bdToolPathNeedsCheck;

  /// No description provided for @bdDoneToolPath.
  ///
  /// In ko, this message translates to:
  /// **'{tool} 경로를 저장했습니다'**
  String bdDoneToolPath(String tool);

  /// No description provided for @bdDoneToolPathReset.
  ///
  /// In ko, this message translates to:
  /// **'{tool}을(를) PATH에서 찾습니다'**
  String bdDoneToolPathReset(String tool);

  /// No description provided for @bdUpdateCheckMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 확인'**
  String get bdUpdateCheckMenuItem;

  /// No description provided for @bdUpdateChecking.
  ///
  /// In ko, this message translates to:
  /// **'업데이트를 확인하는 중…'**
  String get bdUpdateChecking;

  /// No description provided for @bdUpdateAvailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 버전이 있습니다'**
  String get bdUpdateAvailableTitle;

  /// No description provided for @bdUpdateAvailableBody.
  ///
  /// In ko, this message translates to:
  /// **'{appName} {latest} 버전이 나왔습니다. (현재 {current})'**
  String bdUpdateAvailableBody(String appName, String current, String latest);

  /// No description provided for @bdUpdateReleaseNotes.
  ///
  /// In ko, this message translates to:
  /// **'변경 내용'**
  String get bdUpdateReleaseNotes;

  /// No description provided for @bdUpdateNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 업데이트'**
  String get bdUpdateNow;

  /// No description provided for @bdUpdateLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get bdUpdateLater;

  /// No description provided for @bdUpdateSkipVersion.
  ///
  /// In ko, this message translates to:
  /// **'이 버전 건너뛰기'**
  String get bdUpdateSkipVersion;

  /// No description provided for @bdUpdateDownloading.
  ///
  /// In ko, this message translates to:
  /// **'내려받는 중…'**
  String get bdUpdateDownloading;

  /// No description provided for @bdUpdateVerifying.
  ///
  /// In ko, this message translates to:
  /// **'파일을 확인하는 중…'**
  String get bdUpdateVerifying;

  /// No description provided for @bdUpdateDownloadProgress.
  ///
  /// In ko, this message translates to:
  /// **'{received} / {total}'**
  String bdUpdateDownloadProgress(String received, String total);

  /// No description provided for @bdUpdateCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get bdUpdateCancel;

  /// No description provided for @bdUpdateFailedTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트하지 못했습니다'**
  String get bdUpdateFailedTitle;

  /// No description provided for @bdUpdateCheckFailedTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트를 확인하지 못했습니다'**
  String get bdUpdateCheckFailedTitle;

  /// No description provided for @bdUpdateErrorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 서버에 연결하지 못했습니다. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.'**
  String get bdUpdateErrorNetwork;

  /// No description provided for @bdUpdateErrorChecksum.
  ///
  /// In ko, this message translates to:
  /// **'내려받은 파일이 올바르지 않아 설치하지 않았습니다. 잠시 뒤에 다시 시도해 주세요.'**
  String get bdUpdateErrorChecksum;

  /// No description provided for @bdUpdateErrorInstall.
  ///
  /// In ko, this message translates to:
  /// **'설치를 시작하지 못했습니다.'**
  String get bdUpdateErrorInstall;

  /// No description provided for @bdUpdateErrorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 서버에서 예상하지 못한 응답을 받았습니다. 잠시 뒤에 다시 시도해 주세요.'**
  String get bdUpdateErrorGeneric;

  /// No description provided for @bdUpdateUpToDateTitle.
  ///
  /// In ko, this message translates to:
  /// **'최신 버전입니다'**
  String get bdUpdateUpToDateTitle;

  /// No description provided for @bdUpdateUpToDateBody.
  ///
  /// In ko, this message translates to:
  /// **'{version} 버전을 사용 중입니다.'**
  String bdUpdateUpToDateBody(String version);

  /// No description provided for @bdUpdateUnavailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'직접 설치해 주세요'**
  String get bdUpdateUnavailableTitle;

  /// No description provided for @bdUpdateUnavailableBody.
  ///
  /// In ko, this message translates to:
  /// **'{latest} 버전이 있지만 앱에서 자동으로 설치할 수 없습니다. 릴리스 페이지에서 받아 주세요.'**
  String bdUpdateUnavailableBody(String latest);

  /// No description provided for @bdUpdateOpenReleasePage.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 페이지 열기'**
  String get bdUpdateOpenReleasePage;

  /// No description provided for @bdUpdateMacosOpenedTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치 창이 열렸습니다'**
  String get bdUpdateMacosOpenedTitle;

  /// No description provided for @bdUpdateMacosOpenedBody.
  ///
  /// In ko, this message translates to:
  /// **'열린 창에서 {appName} 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.'**
  String bdUpdateMacosOpenedBody(String appName);

  /// No description provided for @bdUpdateWindowsInstallTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치 프로그램을 열었습니다'**
  String get bdUpdateWindowsInstallTitle;

  /// No description provided for @bdUpdateWindowsInstallBody.
  ///
  /// In ko, this message translates to:
  /// **'설치하려면 {appName} 을(를) 종료해야 합니다. 설치 프로그램의 안내를 따라 주세요.'**
  String bdUpdateWindowsInstallBody(String appName);

  /// No description provided for @bdUpdateQuitApp.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 종료'**
  String bdUpdateQuitApp(String appName);

  /// No description provided for @bdUpdateLinuxInstallTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치를 준비했습니다'**
  String get bdUpdateLinuxInstallTitle;

  /// No description provided for @bdUpdateLinuxInstallBody.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 을(를) 종료하고 설치합니다. 설치가 끝나면 자동으로 다시 시작됩니다.'**
  String bdUpdateLinuxInstallBody(String appName);

  /// No description provided for @bdUpdateQuitAndInstall.
  ///
  /// In ko, this message translates to:
  /// **'종료하고 설치'**
  String get bdUpdateQuitAndInstall;

  /// No description provided for @bdDockNoFolder.
  ///
  /// In ko, this message translates to:
  /// **'열린 프로젝트 폴더가 없습니다'**
  String get bdDockNoFolder;

  /// No description provided for @runStepsNoDevice.
  ///
  /// In ko, this message translates to:
  /// **'1. USB 케이블로 폰을 연결합니다 (충전 전용 케이블은 안 됩니다)\n2. 잠금을 풀고, iPhone은 \'이 컴퓨터를 신뢰\', Android는 \'USB 디버깅 허용\'을 누릅니다\n3. 위의 새로 고침을 누릅니다'**
  String get runStepsNoDevice;

  /// No description provided for @runTargetNone.
  ///
  /// In ko, this message translates to:
  /// **'대상을 고르지 않았습니다'**
  String get runTargetNone;

  /// No description provided for @studioDockHide.
  ///
  /// In ko, this message translates to:
  /// **'Git 패널 숨기기 (Ctrl+Alt+B)'**
  String get studioDockHide;

  /// No description provided for @studioDockShow.
  ///
  /// In ko, this message translates to:
  /// **'Git 패널 보이기 (Ctrl+Alt+B)'**
  String get studioDockShow;

  /// No description provided for @menuFile.
  ///
  /// In ko, this message translates to:
  /// **'파일'**
  String get menuFile;

  /// No description provided for @menuEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get menuEdit;

  /// No description provided for @menuView.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get menuView;

  /// No description provided for @menuHelp.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get menuHelp;

  /// No description provided for @menuOpenProject.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트 열기…'**
  String get menuOpenProject;

  /// No description provided for @menuRecentProjects.
  ///
  /// In ko, this message translates to:
  /// **'최근 프로젝트'**
  String get menuRecentProjects;

  /// No description provided for @menuNoRecent.
  ///
  /// In ko, this message translates to:
  /// **'(없음)'**
  String get menuNoRecent;

  /// No description provided for @menuSaveAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 저장'**
  String get menuSaveAll;

  /// No description provided for @menuCloseTab.
  ///
  /// In ko, this message translates to:
  /// **'탭 닫기'**
  String get menuCloseTab;

  /// No description provided for @menuQuickOpen.
  ///
  /// In ko, this message translates to:
  /// **'파일로 이동…'**
  String get menuQuickOpen;

  /// No description provided for @menuSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정…'**
  String get menuSettings;

  /// No description provided for @menuExit.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get menuExit;

  /// No description provided for @menuUndo.
  ///
  /// In ko, this message translates to:
  /// **'실행 취소'**
  String get menuUndo;

  /// No description provided for @menuRedo.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행'**
  String get menuRedo;

  /// No description provided for @menuCut.
  ///
  /// In ko, this message translates to:
  /// **'잘라내기'**
  String get menuCut;

  /// No description provided for @menuCopy.
  ///
  /// In ko, this message translates to:
  /// **'복사'**
  String get menuCopy;

  /// No description provided for @menuPaste.
  ///
  /// In ko, this message translates to:
  /// **'붙여넣기'**
  String get menuPaste;

  /// No description provided for @menuSelectAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 선택'**
  String get menuSelectAll;

  /// No description provided for @menuFind.
  ///
  /// In ko, this message translates to:
  /// **'찾기…'**
  String get menuFind;

  /// No description provided for @menuReplace.
  ///
  /// In ko, this message translates to:
  /// **'바꾸기…'**
  String get menuReplace;

  /// No description provided for @menuFindInProject.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트에서 찾기…'**
  String get menuFindInProject;

  /// No description provided for @menuFormat.
  ///
  /// In ko, this message translates to:
  /// **'코드 정렬'**
  String get menuFormat;

  /// No description provided for @menuBottomPanel.
  ///
  /// In ko, this message translates to:
  /// **'아래 패널'**
  String get menuBottomPanel;

  /// No description provided for @menuGitDock.
  ///
  /// In ko, this message translates to:
  /// **'Git 패널'**
  String get menuGitDock;

  /// No description provided for @menuZoomIn.
  ///
  /// In ko, this message translates to:
  /// **'글자 크게'**
  String get menuZoomIn;

  /// No description provided for @menuZoomOut.
  ///
  /// In ko, this message translates to:
  /// **'글자 작게'**
  String get menuZoomOut;

  /// No description provided for @menuZoomReset.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기 기본'**
  String get menuZoomReset;

  /// No description provided for @studioDropHint.
  ///
  /// In ko, this message translates to:
  /// **'여기에 놓으면 엽니다'**
  String get studioDropHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
