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
  String get gitFileOpenConflict => 'Click to resolve conflict';

  @override
  String gitConflicts(int count) {
    return '$count conflicts — click a file to resolve';
  }

  @override
  String get gitStage => 'Stage';

  @override
  String get gitUnstage => 'Unstage';

  @override
  String get gitStageAll => 'Stage all';

  @override
  String get gitUnstageAll => 'Unstage all';

  @override
  String get gitDoneStaged => 'Staged';

  @override
  String get gitDoneUnstaged => 'Unstaged';

  @override
  String get gitDoneCommit => 'Committed';

  @override
  String get gitCommitMessageHint => 'Commit message';

  @override
  String get gitCommitAll => 'Commit';

  @override
  String gitCommitStaged(int count) {
    return 'Commit ($count)';
  }

  @override
  String gitOnDefaultBranch(String branch) {
    return 'Can\'t create a PR from the default branch ($branch). Work on a new branch instead.';
  }

  @override
  String conflictSheetTitle(String name) {
    return 'Resolve conflicts in $name';
  }

  @override
  String get conflictUnreadable =>
      'Can\'t read this file (it may be binary or deleted). Fix it directly in the editor.';

  @override
  String get conflictBroken =>
      'The conflict markers aren\'t intact, so this app can\'t read them. Fix the file directly in the editor.';

  @override
  String get conflictNone =>
      'This file has no conflict markers. If you\'ve already fixed it, close this and refresh the status.';

  @override
  String conflictBlockTitle(int index, int total) {
    return 'Conflict $index/$total';
  }

  @override
  String get conflictSideMine => 'Mine';

  @override
  String get conflictSideIncoming => 'Incoming';

  @override
  String get conflictKeepBoth => 'Keep both (mine, then incoming)';

  @override
  String get conflictEmptySide => '(empty)';

  @override
  String conflictPickHint(int left) {
    return 'Pick a side for each conflict. $left left.';
  }

  @override
  String get conflictApply => 'Apply and mark resolved';

  @override
  String get conflictApplyNote =>
      'Rewrites the file with your picks and runs git add. To edit by hand instead, open it in the editor.';

  @override
  String doneConflictResolved(String name) {
    return '$name: conflict resolved';
  }

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
  String get gitTabChanges => 'Changes';

  @override
  String get studioBottomPanelHide => 'Hide bottom panel (Ctrl+J)';

  @override
  String get studioBottomPanelShow => 'Show bottom panel (Ctrl+J)';

  @override
  String get studioShowProblems => 'Open Problems';

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

  @override
  String get settingsIconSet => 'Icon style';

  @override
  String get settingsIconSetRounded => 'Rounded';

  @override
  String get settingsIconSetOutlined => 'Outlined';

  @override
  String get settingsIconSetFilled => 'Filled';

  @override
  String get homeBuildTitle => 'Build';

  @override
  String get homeModeDebug => 'Debug';

  @override
  String get homeModeRelease => 'Release';

  @override
  String get homeTeamLabel => 'Apple Team ID';

  @override
  String get homeTeamHelp =>
      'Passed only as a build argument — the project is not modified. Find it at developer.apple.com/account → Membership';

  @override
  String get homeStepsTitle => 'Commands to run';

  @override
  String get homeStepPrepare => 'Prepare';

  @override
  String get homeStepBuild => 'Build';

  @override
  String get homeStepInstall => 'Install';

  @override
  String get homeStepLaunch => 'Launch';

  @override
  String get homeStepRun => 'Run (hot reload)';

  @override
  String get homeActionInstall => 'Build & install';

  @override
  String get homeActionBuildRun => 'Build & run';

  @override
  String get homeActionInstallOnly => 'Install only';

  @override
  String get homeActionClean => 'Clean & get packages';

  @override
  String get homeCleanHelp =>
      'flutter clean → flutter pub get. Worth trying when a build fails for no clear reason.';

  @override
  String get optTitle => 'Build options';

  @override
  String get optDefault => 'Defaults';

  @override
  String get optFlavor => 'Flavor';

  @override
  String get optFlavorHelp =>
      '--flavor. Only if the project defines flavors (Windows needs Flutter 3.47+)';

  @override
  String get optFlavorInvalid =>
      'Start with a letter; letters, digits, _ and - only';

  @override
  String get optHelp => 'Help';

  @override
  String get optHelpLink =>
      'Opens the Flutter docs on setting up flavors for the selected target (Android, iOS, Windows …) in a browser';

  @override
  String get optTarget => 'Entry point';

  @override
  String get optTargetHelp => '-t. Empty means lib/main.dart';

  @override
  String get optDefineFile => 'dart-define file';

  @override
  String get optDefineFileHelp =>
      '--dart-define-from-file. Only the path is stored; the file is never read or saved';

  @override
  String get optFileMissing => 'File not found';

  @override
  String get optAppId => 'App ID (optional)';

  @override
  String get optAppIdHelp =>
      'When the flavor changes the app ID, the ID to launch after installing (e.g. art.zoomon.app.dev)';

  @override
  String get optExtra => 'Extra arguments';

  @override
  String get optExtraHelp =>
      'e.g. --obfuscate --split-debug-info=build/symbols';

  @override
  String get optPick => 'Choose file';

  @override
  String get optClear => 'Clear options';

  @override
  String get homeCleanDone =>
      'Cleaned and packages restored. Try building again.';

  @override
  String get homeCleanFailed =>
      'Clean failed. Check the output in the Log tab.';

  @override
  String get homeActionRun => 'Run debug';

  @override
  String get homeActionCancel => 'Cancel';

  @override
  String get homeActionStop => 'Stop';

  @override
  String get homeHotReload => 'Hot reload';

  @override
  String get homeHotRestart => 'Hot restart';

  @override
  String get homeOutputTitle => 'Output';

  @override
  String get homeCopyCommand => 'Copy command';

  @override
  String get outputCopyAll => 'Copy all output';

  @override
  String get outputCopied => 'Output copied';

  @override
  String get outputViewer => 'Open in viewer';

  @override
  String get viewerPause => 'Pause updates (to select text)';

  @override
  String get viewerResume => 'Resume live updates';

  @override
  String viewerLines(Object count) {
    return '$count lines';
  }

  @override
  String get logRunning => 'Running';

  @override
  String logExit(String code) {
    return 'Exit code $code';
  }

  @override
  String get homeActionBuildOnly => 'Build only';

  @override
  String get homeActionRunOnly => 'Run only';

  @override
  String get homeRunOnlyNeedsBuild => 'No release build to run. Build first';

  @override
  String get homeActionRelaunch => 'Run again without building';

  @override
  String get doctorRun => 'Check again';

  @override
  String get doctorRunning => 'Checking…';

  @override
  String get doctorNever => 'Not checked yet';

  @override
  String doctorCollected(String time) {
    return 'Checked at $time';
  }

  @override
  String get doctorAllGood => 'No problems found';

  @override
  String checkFlutterOk(String version) {
    return 'Flutter $version';
  }

  @override
  String checkFlutterRunFail(String error) {
    return 'flutter ran but failed: $error';
  }

  @override
  String get checkFlutterFail => 'flutter wasn\'t found';

  @override
  String checkXcodeOk(String version) {
    return 'Xcode $version';
  }

  @override
  String get checkXcodeFail => 'Xcode wasn\'t found';

  @override
  String checkAdbOk(String version) {
    return 'adb $version';
  }

  @override
  String get checkAdbWarn => 'adb wasn\'t found (needed to install on Android)';

  @override
  String checkCertificateOk(String count) {
    return '$count development certificate(s) with a private key';
  }

  @override
  String get checkCertificateFail => 'No usable Apple Development certificate';

  @override
  String checkCertExpiryOk(String name, String days) {
    return '$name · $days days left';
  }

  @override
  String checkCertExpiryWarn(String name, String days) {
    return '$name · expires in $days days';
  }

  @override
  String checkCertExpiryFail(String name) {
    return '$name · expired';
  }

  @override
  String get stepsCertificate =>
      '1. Xcode → Settings → Accounts: sign in with your Apple ID\n2. Manage Certificates → + → add Apple Development\n3. Press Check again';

  @override
  String get stepsFlutterMissing =>
      '1. Install the Flutter SDK from flutter.dev\n2. Add flutter/bin to PATH (~/.zshrc)\n3. Reopen the app and press Check again';

  @override
  String get stepsFlutterMissingWindows =>
      '1. Install the Flutter SDK from flutter.dev\n2. Add the flutter\\bin folder to PATH, or pick flutter.bat with \"Set tool paths…\" above\n3. Press Check again';

  @override
  String get stepsXcodeMissing =>
      '1. Install Xcode from the App Store\n2. In a terminal run sudo xcode-select -s /Applications/Xcode.app\n3. Open Xcode once and accept the license';

  @override
  String get stepsAdbMissing =>
      '1. Install the Android SDK platform-tools (Android Studio SDK Manager)\n2. Add the platform-tools folder to PATH\n3. Press Check again';

  @override
  String get stepsCertExpiry =>
      '1. Xcode → Settings → Accounts → Manage Certificates: create a new Apple Development certificate\n2. Press Check again';

  @override
  String get toolPathsOpen => 'Set tool paths…';

  @override
  String get toolPathsTitle => 'Tool paths';

  @override
  String get toolPathsHelp =>
      'Point the app at tools it can\'t find on PATH. The choice is saved and used the next time too. Pick the executable file, not the folder.';

  @override
  String get toolPathNotFound => 'Not found';

  @override
  String get toolPathChoose => 'Locate…';

  @override
  String get toolPathAuto => 'Automatic';

  @override
  String get toolPathCustom => 'Custom';

  @override
  String get toolPathFlutter => 'flutter';

  @override
  String get toolPathAdb => 'adb (Android SDK platform-tools)';

  @override
  String get checkWindowsDevModeOk =>
      'Windows Developer Mode is on (plugin links can be created)';

  @override
  String get checkWindowsDevModeWarn =>
      'Windows Developer Mode is off (builds can fail because plugin links can\'t be created)';

  @override
  String checkVisualStudioOk(String version) {
    return 'Visual Studio $version (C++ tools found)';
  }

  @override
  String get checkVisualStudioFail =>
      'Visual Studio\'s \'Desktop development with C++\' is missing (needed to build the Windows app)';

  @override
  String get stepsWindowsDevMode =>
      '1. Open Windows Settings and search for \'For developers\'\n2. Turn on \'Developer Mode\'\n3. Press Check again';

  @override
  String get stepsVisualStudio =>
      '1. Install Visual Studio 2022 (Community is fine)\n2. In the installer pick \'Desktop development with C++\'\n3. Build again';

  @override
  String get settingsSectionEnvironment => 'Environment check';

  @override
  String get studioRecentProjects => 'Recent projects';

  @override
  String get studioRecentTooltip => 'Show recent projects';

  @override
  String get studioRecentNone => 'No recent projects';

  @override
  String get studioRecentClear => 'Clear list';

  @override
  String get studioRecentForget => 'Remove from list';

  @override
  String problemsNoPackageInfoSub(String packages) {
    return 'Package info (.dart_tool) is missing in $packages, so bogus import errors are mixed in.';
  }

  @override
  String get settingsIndentGuides => 'Indent guides';

  @override
  String get settingsIndentGuidesNote =>
      'Draws vertical lines in a different color per depth so you can match blocks. Accurate with monospace fonts.';

  @override
  String get gitTabBranches => 'Branches';

  @override
  String get branchesLocal => 'Local branches';

  @override
  String get branchesRemote => 'Remote branches';

  @override
  String get branchesSearchHint => 'Search branches';

  @override
  String get branchesNew => 'New branch';

  @override
  String get branchesRefresh => 'Refresh branches';

  @override
  String get branchesEmpty => 'No branches';

  @override
  String get branchesNoMatch => 'No branches match';

  @override
  String get branchesNotRepo => 'The open folder is not a git repository';

  @override
  String get branchCurrent => 'Current';

  @override
  String get branchSwitch => 'Switch';

  @override
  String get branchTrackSwitch => 'Check out as local and switch';

  @override
  String get branchNewFrom => 'New branch from here';

  @override
  String get branchRename => 'Rename';

  @override
  String get branchDelete => 'Delete';

  @override
  String get branchDeleteRemote => 'Delete remote branch';

  @override
  String branchInWorktree(String path) {
    return 'In use by another worktree: $path';
  }

  @override
  String get branchOpenWorktree => 'Open that worktree';

  @override
  String get branchGone => 'Gone from remote';

  @override
  String get branchNoUpstream => 'No upstream';

  @override
  String get branchCreateTitle => 'New branch';

  @override
  String get branchNameLabel => 'Branch name';

  @override
  String get branchBaseLabel => 'Base branch';

  @override
  String get branchBaseHead => 'Current position (HEAD)';

  @override
  String get branchSwitchAfter => 'Switch to it after creating';

  @override
  String get branchCreate => 'Create';

  @override
  String get branchCommandPreview => 'Command to run';

  @override
  String get branchNameEmpty => 'Enter a name';

  @override
  String get branchNameInvalidChar =>
      'Spaces and characters like ~ ^ : ? * [ are not allowed';

  @override
  String get branchNameDash => 'Cannot start with -';

  @override
  String get branchNameSequence =>
      '.. // and parts starting with . are not allowed';

  @override
  String get branchNameEdge => 'Cannot start with / or end with / or .';

  @override
  String get branchNameExists => 'That name already exists';

  @override
  String get branchRenameTitle => 'Rename branch';

  @override
  String get branchRenameAction => 'Rename';

  @override
  String get branchDeleteTitle => 'Delete branch';

  @override
  String branchDeleteBody(String name) {
    return 'Deletes the branch \'$name\'. Only branches already merged are removed.';
  }

  @override
  String get branchDeleteNotMergedTitle => 'Branch is not merged';

  @override
  String branchDeleteNotMergedBody(String name) {
    return '\'$name\' has commits that are not on any other branch. Deleting it makes those commits hard to reach.';
  }

  @override
  String get branchForceDelete => 'Delete anyway (-D)';

  @override
  String get branchDeleteRemoteTitle => 'Delete remote branch';

  @override
  String branchDeleteRemoteBody(String remote, String branch) {
    return 'Deletes \'$branch\' from remote $remote. This affects everyone using that remote.';
  }

  @override
  String branchDoneSwitch(String name) {
    return 'Switched to \'$name\'';
  }

  @override
  String branchDoneCreate(String name) {
    return 'Created branch \'$name\'';
  }

  @override
  String branchDoneRename(String from, String to) {
    return 'Renamed \'$from\' to \'$to\'';
  }

  @override
  String branchDoneDelete(String name) {
    return 'Deleted branch \'$name\'';
  }

  @override
  String branchDoneDeleteRemote(String name) {
    return 'Deleted remote branch \'$name\'';
  }

  @override
  String branchErrInOtherWorktree(String name, String path) {
    return '\'$name\' is in use by another worktree, so it can\'t be switched to or deleted: $path';
  }

  @override
  String get branchErrLocalChanges =>
      'You have uncommitted changes that would be overwritten. Commit or discard them and try again.';

  @override
  String branchErrNotMerged(String name) {
    return '\'$name\' is not fully merged.';
  }

  @override
  String branchErrExists(String name) {
    return '\'$name\' already exists.';
  }

  @override
  String get branchErrRemote =>
      'Couldn\'t reach the remote. Check your sign-in and network.';

  @override
  String get branchErrNoGit =>
      'git was not found. Make sure it is installed and on PATH.';

  @override
  String branchErrGeneric(String code) {
    return 'Failed (exit code $code)';
  }

  @override
  String get mergeMenuItem => 'Merge into current branch…';

  @override
  String mergeTitle(String source, String target) {
    return 'Merge \'$source\' into \'$target\'';
  }

  @override
  String mergeIncoming(String count) {
    return '$count incoming commits';
  }

  @override
  String mergeNothing(String source, String target) {
    return '\'$source\' has no commits that \'$target\' lacks. Already up to date.';
  }

  @override
  String get mergeLoadFailed => 'Could not load the preview';

  @override
  String get mergeModeFastForward => 'Fast-forward';

  @override
  String get mergeFastForwardWhen =>
      'Just moves the branch tip forward. No merge commit is created.';

  @override
  String get mergeFastForwardDisabled =>
      'Not available: the branches have diverged (the current branch has new commits too).';

  @override
  String get mergeModeMergeCommit => 'Merge commit';

  @override
  String get mergeMergeCommitWhen =>
      'Creates a commit that joins both histories, so the merge point stays visible.';

  @override
  String get mergeModeSquash => 'Squash';

  @override
  String get mergeSquashWhen =>
      'Combines the incoming commits into one. Tidy history, but the original commits are not kept.';

  @override
  String get mergeModeRebase => 'Rebase';

  @override
  String mergeRebaseWhen(String source) {
    return 'Replays the current branch\'s commits on top of \'$source\'. History stays linear, but the commits are recreated.';
  }

  @override
  String get mergeMessageLabel => 'Commit message';

  @override
  String mergeSquashNote(String source) {
    return 'The commits from \'$source\' are combined, staged and committed. If there are conflicts, resolve them and commit yourself.';
  }

  @override
  String mergeRebaseReplay(String count) {
    return '$count of your commits will be replayed';
  }

  @override
  String get mergeRebaseNothing =>
      'You have no commits to replay. You are already on top of that branch.';

  @override
  String get mergeRebasePublishedWarning =>
      'This branch is on the remote. Rebasing recreates its commits, so the next push needs a force push (--force-with-lease).';

  @override
  String get mergeConfirm => 'Merge';

  @override
  String get mergeConfirmRebase => 'Rebase';

  @override
  String mergeDone(String source, String target) {
    return 'Merged \'$source\' into \'$target\'';
  }

  @override
  String mergeDoneRebase(String target, String source) {
    return 'Rebased \'$target\' onto \'$source\'';
  }

  @override
  String get mergeErrConflict =>
      'There are conflicts. Resolve them in the Changes tab and continue, or abort to go back.';

  @override
  String get mergeErrLocalChanges =>
      'Your uncommitted changes overlap with the merge. Commit or discard them and try again.';

  @override
  String get mergeErrNotFastForward =>
      'Can\'t fast-forward: the histories have diverged. Choose a merge commit or squash.';

  @override
  String get mergeBusyOperation =>
      'A merge or rebase is in progress. Continue or abort it first.';

  @override
  String opMerging(String count) {
    return 'Merging — $count conflicts';
  }

  @override
  String opRebasing(String count) {
    return 'Rebasing — $count conflicts';
  }

  @override
  String opCherryPicking(String count) {
    return 'Cherry-picking — $count conflicts';
  }

  @override
  String opReverting(String count) {
    return 'Reverting — $count conflicts';
  }

  @override
  String get opContinue => 'Continue';

  @override
  String get opSkip => 'Skip';

  @override
  String get opAbort => 'Abort';

  @override
  String get opContinueBlocked =>
      'Resolve and stage all conflicts before continuing.';

  @override
  String get opAbortTitle => 'Abort operation';

  @override
  String get opAbortMergeBody =>
      'Aborts the merge and returns to the state before it. Conflict resolutions you made are lost.';

  @override
  String get opAbortRebaseBody =>
      'Aborts the rebase and returns to the state before it started. Commits already replayed are discarded.';

  @override
  String get opAbortOtherBody =>
      'Aborts the operation in progress and returns to the state before it.';

  @override
  String get opDoneContinue => 'Continued';

  @override
  String get opDoneSkip => 'Skipped';

  @override
  String get opDoneAbort => 'Aborted. Back to the state before it started.';
}
