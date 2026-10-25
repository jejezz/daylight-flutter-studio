// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTooltip => 'About';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get aboutOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => 'Close';

  @override
  String aboutMenuItem(String appName) {
    return 'About $appName';
  }

  @override
  String get themeMenuTooltip => 'Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageSystem => 'System / 시스템 설정 따르기';

  @override
  String get languageSystemShort => 'System';

  @override
  String get aboutTagline =>
      'An all-in-one workbench for building Flutter apps';

  @override
  String get aboutDescription =>
      'Combines a project tree, a light editor, build/install, and PR/merge/release in one window, keeping the order: work → local verification → merge → release.';

  @override
  String get runNotFlutterProject => 'The open folder is not a Flutter project';

  @override
  String get runNoPlatforms => 'No supported platforms';

  @override
  String get runTarget => 'Target';

  @override
  String get runRefreshDevices => 'Rescan devices';

  @override
  String get runNoDevices => 'No devices connected';

  @override
  String get runPlatformMacos => 'macOS desktop';

  @override
  String get runPlatformWindows => 'Windows desktop';

  @override
  String get runLinkWireless => 'Wireless';

  @override
  String get runLinkLocal => 'This computer';

  @override
  String get runModeDebug => 'Debug (flutter run)';

  @override
  String get runStart => 'Run';

  @override
  String get runBuildInstall => 'Build & install';

  @override
  String get runStop => 'Stop';

  @override
  String get runHotReload => 'r hot reload';

  @override
  String get runHotRestart => 'R hot restart';

  @override
  String get runQuit => 'q quit';

  @override
  String get runBlockerNoProject => 'Open a project.';

  @override
  String get runBlockerNoDevice => 'Choose a target.';

  @override
  String get runBlockerPlatformMissing =>
      'This project does not support the selected platform.';

  @override
  String get runBlockerIosNeedsMac =>
      'iOS installs are only possible on macOS.';

  @override
  String get runBlockerWireless =>
      'Installs fail over a wireless connection. Connect with USB.';

  @override
  String get runBlockerDeveloperModeOff =>
      'Developer Mode is off on the iPhone.';

  @override
  String get runBlockerAndroidUnauthorized =>
      'Approve USB debugging on the phone.';

  @override
  String get runBlockerNeedsTeamId =>
      'An iOS signing Team ID is required. (The project needs DEVELOPMENT_TEAM)';

  @override
  String get runCommandsToRun => 'Commands to run';

  @override
  String runCommandNotFound(String command) {
    return 'Command $command not found. Check your PATH.';
  }

  @override
  String get runHintUseUsb =>
      'Installs drop over a wireless connection. Connect with USB.';

  @override
  String get runHintUnlockDevice => 'Unlock the device screen and try again.';

  @override
  String get runHintDeveloperMode => 'Turn on Developer Mode on the device.';

  @override
  String get runHintSigning =>
      'Signing is misconfigured. Check the Team ID and provisioning profile.';

  @override
  String get runHintTrustComputer =>
      'Tap \"Trust This Computer\" on the device.';

  @override
  String get runHintNoAdb =>
      'adb not found. Add the Android SDK platform-tools to your PATH.';

  @override
  String get runHintCocoapods => 'CocoaPods is required.';

  @override
  String get runHintVisualStudio =>
      'The Visual Studio \"Desktop development with C++\" workload is required.';

  @override
  String get runHintRestartApp =>
      'Plugin links were not found. Reopen the app and try once more.';

  @override
  String get runHintStaleBuildCache =>
      'A build cache from an older Visual Studio is left over. Delete the build folder and try again.';

  @override
  String get runVerifyConfirmed => 'Confirmed';

  @override
  String get runVerifyBuilt => 'Built only — not yet checked by eye';

  @override
  String get runVerifyProblem => 'Problem found';

  @override
  String get runVerifyNone => 'This commit has not been verified yet';

  @override
  String get runVerifyTitle => 'Verification';

  @override
  String get runDetachedHead => '(detached HEAD)';

  @override
  String get runRecordSkippedNotGit =>
      'Not a git repository, so no verification was recorded.';

  @override
  String get runRecordSkippedDirty =>
      'Uncommitted changes exist, so no verification was recorded. Commit and build again.';

  @override
  String get runProblemTitle => 'What went wrong?';

  @override
  String get runProblemHint => 'e.g. The login button does nothing';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get runRecordAndCopy => 'Record and copy';

  @override
  String get runNoteCopied => 'Note copied. Paste it into your Claude session.';

  @override
  String get runOutput => 'Output';

  @override
  String get runCopyOutput => 'Copy output';

  @override
  String get runNoOutput => '(no output)';

  @override
  String get commonStop => 'Stop';

  @override
  String get gitNotRepo => 'The open folder is not a git repository';

  @override
  String get gitNoGh =>
      'GitHub CLI (gh) not found, so PR features are unavailable.';

  @override
  String get gitUpstreamGone => 'Gone from remote';

  @override
  String get gitNoUpstream => 'No upstream branch';

  @override
  String get gitDetachedHead => '(detached HEAD)';

  @override
  String get gitRefresh => 'Refresh';

  @override
  String get gitClean => 'No changes';

  @override
  String gitChangedFiles(int count) {
    return '$count changed files';
  }

  @override
  String gitMoreFiles(int count) {
    return '… and $count more';
  }

  @override
  String get gitFileDeleted => 'Deleted file';

  @override
  String get gitFileOpenDiff => 'Click to view changes';

  @override
  String get gitFetch => 'Fetch';

  @override
  String gitPull(int behind) {
    return 'Pull (↓$behind)';
  }

  @override
  String get gitPush => 'Push';

  @override
  String get gitVerified => 'Verified';

  @override
  String get gitBuiltOnly => 'Built only — not checked by eye';

  @override
  String get gitVerifyProblem => 'A problem was found when checked';

  @override
  String get gitStaleSome => 'Commits were added after verification';

  @override
  String gitStaleCount(int count) {
    return '$count commits were added after verification';
  }

  @override
  String get gitUnverified => 'This commit has not been verified';

  @override
  String get gitHeadDiffers =>
      'Local HEAD and PR head differ. The verdict is based on the PR head.';

  @override
  String get gitBuildInRunTab =>
      'Before merging, build and check this commit in the Run tab.';

  @override
  String get gitNoPr => 'This branch has no PR.';

  @override
  String get gitPrTitle => 'PR title';

  @override
  String get gitPushFirst => 'Push the branch first to create a PR.';

  @override
  String get gitCreatePr => 'Create PR';

  @override
  String get gitMergeBlocked => 'Merge PR (verification required)';

  @override
  String get gitMergeConfirm => 'Merge PR…';

  @override
  String get gitMerge => 'Merge PR';

  @override
  String get gitMergeUnverified => 'Merge without verification…';

  @override
  String get gitUnverifiedDialogTitle => 'This commit has not been checked';

  @override
  String get gitUnverifiedDialogBody =>
      'If you merge anyway, GitHub builds every OS, and any problem means fixing it and releasing again.';

  @override
  String get gitMergeAnyway => 'Merge anyway';

  @override
  String get gitPrDraft => 'This is a draft PR.';

  @override
  String get gitPrConflict => 'There are conflicts.';

  @override
  String gitPrChecksFailed(String names) {
    return 'Failed checks: $names';
  }

  @override
  String gitPrChecksPending(int count) {
    return '$count checks are in progress.';
  }

  @override
  String get gitPrReviewRequired => 'A review is required.';

  @override
  String get gitPrMerged => 'Merged';

  @override
  String get gitPrOpen => 'Open';

  @override
  String gitPrChecks(int passed, int failed, int pending) {
    return 'Checks passed $passed · failed $failed · pending $pending';
  }

  @override
  String get gitMergeMethod => 'Merge method';

  @override
  String get gitMergeCommit => 'Merge commit';

  @override
  String get gitDeleteBranchAfter => 'Delete branch after merge';

  @override
  String get studioOpenProject => 'Open project';

  @override
  String get studioOpenProjectFolder => 'Open project folder';

  @override
  String get studioSettingsTooltip => 'Settings (Ctrl+,)';

  @override
  String get studioProblemsTab => 'Problems';

  @override
  String get studioVerifyConfirmed => 'Verified';

  @override
  String get studioVerifyBuilt => 'Built only';

  @override
  String get studioVerifyProblem => 'Problem found';

  @override
  String get studioVerifyNone => 'Unverified';

  @override
  String get studioNotRepo => 'Not a repository';

  @override
  String get studioAnalyzing => 'Analyzing…';

  @override
  String get studioDirty => 'Modified (Ctrl+S to save)';

  @override
  String get studioSaved => 'Saved';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionEditor => 'Editor';

  @override
  String get settingsSectionGate => 'Merge gate';

  @override
  String get settingsPaletteSaturn => 'Saturn';

  @override
  String get settingsPaletteTeal => 'Teal';

  @override
  String get settingsPaletteAmber => 'Amber';

  @override
  String get settingsPaletteRose => 'Rose';

  @override
  String get settingsPaletteSlate => 'Slate';

  @override
  String get settingsBrightness => 'Brightness';

  @override
  String get settingsBrightnessSystem => 'System';

  @override
  String get settingsPalette => 'Color scheme';

  @override
  String get settingsAppliedNote =>
      'Changes apply immediately and are kept for the next launch.';

  @override
  String get settingsGateHeading => 'Verification before PR merge';

  @override
  String get settingsGateIntro =>
      'Only commits you built and checked by eye can be merged. If you merge without checking, GitHub builds every OS, and any problem means fixing it and releasing again.';

  @override
  String get settingsGateConfirmNote =>
      '\"Confirmed\" is a button you press yourself after running the app from the Run tab. A successful build alone doesn\'t count.';

  @override
  String get settingsEditorUnavailable => 'Editor settings are unavailable.';

  @override
  String get settingsFontSize => 'Font size';

  @override
  String get settingsResetZoom => 'Reset to 100%';

  @override
  String get settingsZoomNote =>
      'Applies to the editor, Markdown view and diff view only. In the editor you can also use Ctrl+scroll or Ctrl +/-/0.';

  @override
  String get gateModeBlock => 'Block';

  @override
  String get gateModeBlockHelp =>
      'Only checked commits merge. For an exception, press \"Merge without verification\" separately.';

  @override
  String get gateModeWarn => 'Warn only';

  @override
  String get gateModeWarnHelp =>
      'Asks once more before merging an unchecked commit.';

  @override
  String get gateModeOff => 'Off';

  @override
  String get gateModeOffHelp =>
      'Merging is allowed whether or not the commit was checked.';

  @override
  String get gateVerified => 'Verified — ready to merge';

  @override
  String get gateBuiltOnly =>
      'Built but not checked by eye. After trying it, press \"Confirmed\" in the Run tab.';

  @override
  String get gateProblem => 'This commit was recorded as having a problem.';

  @override
  String gateProblemNote(String note) {
    return 'This commit was recorded as having a problem: $note';
  }

  @override
  String get gateStaleSome =>
      'Commits were added after verification. Build and check again.';

  @override
  String gateStaleCount(int count) {
    return '$count commits were added after verification. Build and check again.';
  }

  @override
  String get gateUnverified =>
      'This commit has not been checked locally. Build it in the Run tab and check by eye.';

  @override
  String get editorOpenFromTree => 'Open a file from the tree on the left';

  @override
  String get editorFileGone => 'This file has disappeared from disk.';

  @override
  String get editorFileChanged =>
      'The file on disk has changed. Saving will overwrite those edits.';

  @override
  String get editorCloseTab => 'Close tab';

  @override
  String get editorLeaveAsIs => 'Leave as is';

  @override
  String get editorReloadDiscard => 'Reload (discard my edits)';

  @override
  String get editorKeepMine => 'Keep my edits';

  @override
  String get editorZoomHint =>
      'Ctrl+scroll or Ctrl +/- to resize text · click for 100%';

  @override
  String get editorFoldAll => 'Fold all';

  @override
  String get editorUnfoldAll => 'Unfold all';

  @override
  String get editorBackToEdit => 'Back to editing';

  @override
  String get editorDiffSame => 'View changes (same as HEAD)';

  @override
  String get editorDiffChanged => 'View changes (vs HEAD)';

  @override
  String get editorEdit => 'Edit';

  @override
  String get editorPreview => 'View';

  @override
  String editorSavePromptTitle(String name) {
    return 'Save $name?';
  }

  @override
  String get editorSavePromptBody => 'There are unsaved changes.';

  @override
  String get editorDontSave => 'Don\'t save';

  @override
  String get commonSave => 'Save';

  @override
  String get treeExplorer => 'Explorer';

  @override
  String get treeRefresh => 'Refresh tree';

  @override
  String get problemsNoPackage =>
      'No Dart package (pubspec.yaml) found in the open folder';

  @override
  String get problemsError => 'Errors';

  @override
  String get problemsWarning => 'Warnings';

  @override
  String get problemsInfo => 'Info';

  @override
  String get problemsReanalyze => 'Analyze again';

  @override
  String get problemsNoPackageInfo =>
      'Package info (.dart_tool) is missing, so bogus import errors are mixed in.';

  @override
  String get problemsAnalyzing => 'Analyzing…';

  @override
  String get problemsNotAnalyzed => 'Not analyzed yet';

  @override
  String get problemsFilteredOut => 'No problems of the selected kinds';

  @override
  String get problemsUnknown => 'Analysis failed, so problems are unknown';

  @override
  String get problemsNone => 'No problems';

  @override
  String get diffNotComparable =>
      'This file can\'t be compared with git.\n(Not a git repository, or ignored by .gitignore)';

  @override
  String get diffAgainstHead => 'Compared with HEAD';

  @override
  String get diffNewFile => 'New file (not committed yet)';

  @override
  String get diffSameAsHead => 'Same as HEAD. Nothing changed.';

  @override
  String diffHiddenLines(int count) {
    return '$count unchanged lines — click to expand';
  }

  @override
  String get markdownImageUnavailable => '(image unavailable)';

  @override
  String markdownImage(String alt) {
    return '(image: $alt)';
  }

  @override
  String get languagePlain => 'Text';

  @override
  String messageFolderUnavailable(String path) {
    return 'Can\'t open folder: $path';
  }

  @override
  String messageFileTooLarge(String name) {
    return 'Files over 2MB are not opened: $name';
  }

  @override
  String messageNotUtf8Open(String name) {
    return 'Not a text (UTF-8) file, can\'t open: $name';
  }

  @override
  String messageReadFailed(String error) {
    return 'Couldn\'t read the file: $error';
  }

  @override
  String get messageDiskChangedSaveBlocked =>
      'The file on disk has changed. Before saving, choose \"Reload\" or \"Keep my edits\".';

  @override
  String messageSaveFailed(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String messageChangedNotUtf8(String name) {
    return '$name changed on disk but is not a text (UTF-8) file, so it was not reloaded.';
  }

  @override
  String messageChangedReloaded(String name) {
    return '$name changed on disk and was reloaded.';
  }

  @override
  String messageReloadedFromDisk(String name) {
    return 'Reloaded $name from disk.';
  }

  @override
  String get messageNotUtf8Reload =>
      'Not a text (UTF-8) file, so it was not reloaded.';

  @override
  String get messageAlreadyFormatted => 'Already formatted';

  @override
  String get messageFormatted => 'Formatted';

  @override
  String get formatNoDart =>
      'dart command not found. Make sure the Flutter SDK bin folder is on your PATH.';

  @override
  String formatTempWriteFailed(String error) {
    return 'Couldn\'t write a temp file: $error';
  }

  @override
  String get formatCurrentFile => '(current file)';

  @override
  String get formatFailed => 'Couldn\'t format.';

  @override
  String formatFailedDetail(String detail) {
    return 'Couldn\'t format: $detail';
  }

  @override
  String get analyzeFailedRead => 'Couldn\'t read the analysis result.';

  @override
  String analyzeFailedDetail(String detail) {
    return 'Couldn\'t analyze: $detail';
  }

  @override
  String get problemsPubGetFailed =>
      'flutter pub get failed. See the output in the command log below.';

  @override
  String get gitDoneFetch => 'Fetched';

  @override
  String get gitDonePull => 'Pulled';

  @override
  String get gitDonePush => 'Pushed';

  @override
  String get gitDonePrCreated => 'PR created';

  @override
  String gitNotMerged(String reason) {
    return 'Not merged: $reason';
  }

  @override
  String gitDoneMergedUnverified(int number) {
    return 'Merged #$number without verification';
  }

  @override
  String gitDoneMerged(int number) {
    return 'Merged #$number';
  }

  @override
  String get gitCommandNotFound =>
      'Command not found. Make sure git and the GitHub CLI (gh) are installed and on your PATH.';

  @override
  String gitFailedExit(int code) {
    return 'Failed (exit code $code)';
  }

  @override
  String get findHint => 'Find';

  @override
  String get findReplaceHint => 'Replace with';

  @override
  String get findNoResults => 'No results';

  @override
  String findCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get findMatchCase => 'Match case';

  @override
  String get findRegex => 'Regular expression';

  @override
  String get findPrevious => 'Previous (Shift+Enter)';

  @override
  String get findNext => 'Next (Enter)';

  @override
  String get findClose => 'Close find (Esc)';

  @override
  String get findToggleReplace => 'Show/hide replace';

  @override
  String get findReplaceOne => 'Replace';

  @override
  String get findReplaceAll => 'Replace all';

  @override
  String get quickOpenHint => 'Open by file name (Ctrl+P)';

  @override
  String get quickOpenNoMatch => 'No matching files';

  @override
  String get quickOpenLoading => 'Reading the file list…';

  @override
  String get searchTitle => 'Find in project';

  @override
  String get searchHint => 'Text to find (Enter to search)';

  @override
  String get searchSearching => 'Searching…';

  @override
  String get searchNoResults => 'No results';

  @override
  String searchResultCount(int count) {
    return '$count matches';
  }

  @override
  String searchTruncated(int count) {
    return 'Stopped at $count matches. Narrow your search.';
  }

  @override
  String get searchInvalidPattern => 'The regular expression is invalid';

  @override
  String get studioQuickOpenTooltip => 'Open file (Ctrl+P)';

  @override
  String get studioSearchTooltip => 'Find in project (Ctrl+Shift+F)';

  @override
  String get editorFormat => 'Format (Ctrl+Alt+L)';

  @override
  String formatJsonInvalid(String detail) {
    return 'Invalid JSON, couldn\'t format: $detail';
  }

  @override
  String get settingsFormatOnSave => 'Format on save';

  @override
  String get settingsFormatOnSaveNote =>
      'Formats Dart, JSON and ARB files just before saving. If a syntax error prevents formatting, the file is still saved.';

  @override
  String get settingsEditorFont => 'Editor font';

  @override
  String get settingsEditorFontHint => 'Font name (empty for default)';

  @override
  String get settingsEditorFontDefault => 'Default';

  @override
  String get settingsEditorFontNote =>
      'Only fonts installed on this computer appear as buttons. Type the name of any other font.';

  @override
  String get settingsLineHeight => 'Line spacing';

  @override
  String get settingsLineHeightReset => 'Reset line spacing';

  @override
  String get settingsEditorFontMissing =>
      'This font doesn\'t seem to be installed on this computer. A fallback such as Menlo is shown instead.';

  @override
  String get settingsPreview => 'Preview';

  @override
  String get releaseButton => 'Release…';

  @override
  String get releaseTitle => 'Release tag';

  @override
  String get releaseNotReady => 'Checks did not pass, so no tag was created.';

  @override
  String releaseTagged(String tag) {
    return 'Pushed tag $tag. GitHub Actions will build the release.';
  }

  @override
  String releaseTagPushFailed(String error) {
    return 'Couldn\'t push the tag: $error';
  }

  @override
  String releaseVersionLine(String version, String tag) {
    return 'pubspec $version → tag $tag';
  }

  @override
  String releaseLastTag(String tag) {
    return 'Last tag: $tag';
  }

  @override
  String get releaseNoLastTag => 'No tags yet';

  @override
  String get releaseNoVersion => 'Couldn\'t read a version from pubspec.yaml';

  @override
  String get releaseCheckCleanTree =>
      'No uncommitted changes in the working folder';

  @override
  String get releaseCheckOnDefaultBranch =>
      'On the default branch (no tags on work branches)';

  @override
  String get releaseCheckSynced => 'In sync with the remote';

  @override
  String get releaseCheckVersionBumped =>
      'Version is higher than the last tag (the bump is merged)';

  @override
  String get releaseCheckTagFree => 'No tag with that name yet';

  @override
  String get releaseCheckVerified => 'This commit was built and checked by eye';

  @override
  String get releaseBumpHint =>
      'To bump the version, make a bump commit and merge it by PR:';

  @override
  String get releaseBumpHintNoScript =>
      'Merge a commit that raises version in pubspec.yaml via PR.';

  @override
  String get releaseRecheck => 'Check again';

  @override
  String get releaseCreateTag => 'Create and push tag';

  @override
  String get releaseTagWithoutVerification => 'Tag without verification…';

  @override
  String get releaseUnverifiedTitle => 'This commit has not been checked';

  @override
  String get releaseUnverifiedBody =>
      'If you push the tag anyway, GitHub builds every OS, and a pushed tag is never moved — a problem means releasing a new PATCH.';

  @override
  String get releaseTagAnyway => 'Tag anyway';
}
