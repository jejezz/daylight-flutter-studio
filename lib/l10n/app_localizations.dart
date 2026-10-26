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
  /// **'글꼴 이름 (비우면 기본)'**
  String get settingsEditorFontHint;

  /// No description provided for @settingsEditorFontDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get settingsEditorFontDefault;

  /// No description provided for @settingsEditorFontNote.
  ///
  /// In ko, this message translates to:
  /// **'이 컴퓨터에 설치된 글꼴만 단추로 보입니다. 다른 글꼴은 이름을 그대로 적으세요.'**
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
