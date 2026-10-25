/// 앱의 모든 아이콘은 여기 의미 이름으로만 쓴다 (`context.icons.folder`).
/// 화면 코드가 `Icons.*`를 직접 쓰지 않으므로 아이콘 세트([StudioIconSet])를 바꾸면 모든 화면이 따라 바뀐다.
/// `test/theme_rules_test.dart`가 `lib/theme/` 밖의 `Icons.` 직접 사용을 막는다.
library;

import 'package:flutter/material.dart';

/// 고를 수 있는 아이콘 세트 (Material 아이콘의 모양 변형).
enum StudioIconSet {
  /// 둥근 모서리 (기본).
  rounded,

  /// 윤곽선.
  outlined,

  /// 채움 (Material 기본 모양).
  filled,
}

@immutable
class StudioIcons {
  const StudioIcons(this.set);

  final StudioIconSet set;

  IconData _pick(IconData filled, IconData outlined, IconData rounded) => switch (set) {
    StudioIconSet.filled => filled,
    StudioIconSet.outlined => outlined,
    StudioIconSet.rounded => rounded,
  };

  @override
  bool operator ==(Object other) => other is StudioIcons && other.set == set;

  @override
  int get hashCode => set.hashCode;

  IconData get warningAmber => _pick(Icons.warning_amber, Icons.warning_amber_outlined, Icons.warning_amber_rounded);
  IconData get refresh => _pick(Icons.refresh, Icons.refresh_outlined, Icons.refresh_rounded);
  IconData get search => _pick(Icons.search, Icons.search_outlined, Icons.search_rounded);
  IconData get help => _pick(Icons.help, Icons.help_outlined, Icons.help_rounded);
  IconData get folderOpen => _pick(Icons.folder_open, Icons.folder_open_outlined, Icons.folder_open_rounded);
  IconData get folder => _pick(Icons.folder, Icons.folder_outlined, Icons.folder_rounded);
  IconData get error => _pick(Icons.error, Icons.error_outlined, Icons.error_rounded);
  IconData get verified => _pick(Icons.verified, Icons.verified_outlined, Icons.verified_rounded);
  IconData get unfoldMore => _pick(Icons.unfold_more, Icons.unfold_more_outlined, Icons.unfold_more_rounded);
  IconData get unfoldLess => _pick(Icons.unfold_less, Icons.unfold_less_outlined, Icons.unfold_less_rounded);
  IconData get textFields => _pick(Icons.text_fields, Icons.text_fields_outlined, Icons.text_fields_rounded);
  IconData get restartAlt => _pick(Icons.restart_alt, Icons.restart_alt_outlined, Icons.restart_alt_rounded);
  IconData get reportProblem => _pick(Icons.report_problem, Icons.report_problem_outlined, Icons.report_problem_rounded);
  IconData get insertDriveFile => _pick(Icons.insert_drive_file, Icons.insert_drive_file_outlined, Icons.insert_drive_file_rounded);
  IconData get copy => _pick(Icons.copy, Icons.copy_outlined, Icons.copy_rounded);
  IconData get code => _pick(Icons.code, Icons.code_outlined, Icons.code_rounded);
  IconData get close => _pick(Icons.close, Icons.close_outlined, Icons.close_rounded);
  IconData get circle => _pick(Icons.circle, Icons.circle_outlined, Icons.circle_rounded);
  IconData get checkCircle => _pick(Icons.check_circle, Icons.check_circle_outlined, Icons.check_circle_rounded);
  IconData get block => _pick(Icons.block, Icons.block_outlined, Icons.block_rounded);
  IconData get accountTree => _pick(Icons.account_tree, Icons.account_tree_outlined, Icons.account_tree_rounded);
  IconData get visibility => _pick(Icons.visibility, Icons.visibility_outlined, Icons.visibility_rounded);
  IconData get upload => _pick(Icons.upload, Icons.upload_outlined, Icons.upload_rounded);
  IconData get update => _pick(Icons.update, Icons.update_outlined, Icons.update_rounded);
  IconData get sync => _pick(Icons.sync, Icons.sync_outlined, Icons.sync_rounded);
  IconData get stop => _pick(Icons.stop, Icons.stop_outlined, Icons.stop_rounded);
  IconData get smartToy => _pick(Icons.smart_toy, Icons.smart_toy_outlined, Icons.smart_toy_rounded);
  IconData get shield => _pick(Icons.shield, Icons.shield_outlined, Icons.shield_rounded);
  IconData get settings => _pick(Icons.settings, Icons.settings_outlined, Icons.settings_rounded);
  IconData get rocketLaunch => _pick(Icons.rocket_launch, Icons.rocket_launch_outlined, Icons.rocket_launch_rounded);
  IconData get radioButtonUnchecked => _pick(Icons.radio_button_unchecked, Icons.radio_button_unchecked_outlined, Icons.radio_button_unchecked_rounded);
  IconData get playArrow => _pick(Icons.play_arrow, Icons.play_arrow_outlined, Icons.play_arrow_rounded);
  IconData get palette => _pick(Icons.palette, Icons.palette_outlined, Icons.palette_rounded);
  IconData get merge => _pick(Icons.merge, Icons.merge_outlined, Icons.merge_rounded);
  IconData get callMerge => _pick(Icons.call_merge, Icons.call_merge_outlined, Icons.call_merge_rounded);
  IconData get manageSearch => _pick(Icons.manage_search, Icons.manage_search_outlined, Icons.manage_search_rounded);
  IconData get lightMode => _pick(Icons.light_mode, Icons.light_mode_outlined, Icons.light_mode_rounded);
  IconData get darkMode => _pick(Icons.dark_mode, Icons.dark_mode_outlined, Icons.dark_mode_rounded);
  IconData get brightnessAuto => _pick(Icons.brightness_auto, Icons.brightness_auto_outlined, Icons.brightness_auto_rounded);
  IconData get language => _pick(Icons.language, Icons.language_outlined, Icons.language_rounded);
  IconData get keyboardArrowRight => _pick(Icons.keyboard_arrow_right, Icons.keyboard_arrow_right_outlined, Icons.keyboard_arrow_right_rounded);
  IconData get keyboardArrowDown => _pick(Icons.keyboard_arrow_down, Icons.keyboard_arrow_down_outlined, Icons.keyboard_arrow_down_rounded);
  IconData get info => _pick(Icons.info, Icons.info_outlined, Icons.info_rounded);
  IconData get hourglassEmpty => _pick(Icons.hourglass_empty, Icons.hourglass_empty_outlined, Icons.hourglass_empty_rounded);
  IconData get formatAlignLeft => _pick(Icons.format_align_left, Icons.format_align_left_outlined, Icons.format_align_left_rounded);
  IconData get filterAlt => _pick(Icons.filter_alt, Icons.filter_alt_outlined, Icons.filter_alt_rounded);
  IconData get expandMore => _pick(Icons.expand_more, Icons.expand_more_outlined, Icons.expand_more_rounded);
  IconData get edit => _pick(Icons.edit, Icons.edit_outlined, Icons.edit_rounded);
  IconData get editNote => _pick(Icons.edit_note, Icons.edit_note_outlined, Icons.edit_note_rounded);
  IconData get download => _pick(Icons.download, Icons.download_outlined, Icons.download_rounded);
  IconData get difference => _pick(Icons.difference, Icons.difference_outlined, Icons.difference_rounded);
  IconData get chevronRight => _pick(Icons.chevron_right, Icons.chevron_right_outlined, Icons.chevron_right_rounded);
  IconData get check => _pick(Icons.check, Icons.check_outlined, Icons.check_rounded);
  IconData get cancel => _pick(Icons.cancel, Icons.cancel_outlined, Icons.cancel_rounded);
  IconData get buildCircle => _pick(Icons.build_circle, Icons.build_circle_outlined, Icons.build_circle_rounded);
  IconData get build => _pick(Icons.build, Icons.build_outlined, Icons.build_rounded);
  IconData get arrowUpward => _pick(Icons.arrow_upward, Icons.arrow_upward_outlined, Icons.arrow_upward_rounded);
  IconData get arrowDownward => _pick(Icons.arrow_downward, Icons.arrow_downward_outlined, Icons.arrow_downward_rounded);
}
