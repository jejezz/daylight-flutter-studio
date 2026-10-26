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
  IconData get radioButtonChecked => _pick(Icons.radio_button_checked, Icons.radio_button_checked_outlined, Icons.radio_button_checked_rounded);
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
  IconData get expandLess => _pick(Icons.expand_less, Icons.expand_less_outlined, Icons.expand_less_rounded);
  IconData get moreVert => _pick(Icons.more_vert, Icons.more_vert_outlined, Icons.more_vert_rounded);
  IconData get add => _pick(Icons.add, Icons.add_outlined, Icons.add_rounded);
  IconData get delete => _pick(Icons.delete, Icons.delete_outlined, Icons.delete_rounded);
  IconData get cloud => _pick(Icons.cloud, Icons.cloud_outlined, Icons.cloud_rounded);
  IconData get arrowForward => _pick(Icons.arrow_forward, Icons.arrow_forward_outlined, Icons.arrow_forward_rounded);
  IconData get callSplit => _pick(Icons.call_split, Icons.call_split_outlined, Icons.call_split_rounded);
  IconData get celebration => _pick(Icons.celebration, Icons.celebration_outlined, Icons.celebration_rounded);
  IconData get changeCircle => _pick(Icons.change_circle, Icons.change_circle_outlined, Icons.change_circle_rounded);
  IconData get chatBubbleOutline => _pick(Icons.chat_bubble_outline, Icons.chat_bubble_outline_outlined, Icons.chat_bubble_outline_rounded);
  IconData get checkCircleOutline => _pick(Icons.check_circle_outline, Icons.check_circle_outline_outlined, Icons.check_circle_outline_rounded);
  IconData get cloudDone => _pick(Icons.cloud_done, Icons.cloud_done_outlined, Icons.cloud_done_rounded);
  IconData get cloudOff => _pick(Icons.cloud_off, Icons.cloud_off_outlined, Icons.cloud_off_rounded);
  IconData get cloudUpload => _pick(Icons.cloud_upload, Icons.cloud_upload_outlined, Icons.cloud_upload_rounded);
  IconData get contentCopy => _pick(Icons.content_copy, Icons.content_copy_outlined, Icons.content_copy_rounded);
  IconData get deleteOutline => _pick(Icons.delete_outline, Icons.delete_outline_outlined, Icons.delete_outline_rounded);
  IconData get errorOutline => _pick(Icons.error_outline, Icons.error_outline_outlined, Icons.error_outline_rounded);
  IconData get folderCopy => _pick(Icons.folder_copy, Icons.folder_copy_outlined, Icons.folder_copy_rounded);
  IconData get forkRight => _pick(Icons.fork_right, Icons.fork_right_outlined, Icons.fork_right_rounded);
  IconData get helpOutline => _pick(Icons.help_outline, Icons.help_outline_outlined, Icons.help_outline_rounded);
  IconData get inventory2 => _pick(Icons.inventory_2, Icons.inventory_2_outlined, Icons.inventory_2_rounded);
  IconData get keyboardArrowUp => _pick(Icons.keyboard_arrow_up, Icons.keyboard_arrow_up_outlined, Icons.keyboard_arrow_up_rounded);
  IconData get lightbulbOutline => _pick(Icons.lightbulb_outline, Icons.lightbulb_outline, Icons.lightbulb_outline);
  IconData get linkOff => _pick(Icons.link_off, Icons.link_off_outlined, Icons.link_off_rounded);
  IconData get lockOutline => _pick(Icons.lock_outline, Icons.lock_outline, Icons.lock_outline);
  IconData get menuBook => _pick(Icons.menu_book, Icons.menu_book_outlined, Icons.menu_book_rounded);
  IconData get moreHoriz => _pick(Icons.more_horiz, Icons.more_horiz_outlined, Icons.more_horiz_rounded);
  IconData get north => _pick(Icons.north, Icons.north_outlined, Icons.north_rounded);
  IconData get openInNew => _pick(Icons.open_in_new, Icons.open_in_new_outlined, Icons.open_in_new_rounded);
  IconData get public => _pick(Icons.public, Icons.public_outlined, Icons.public_rounded);
  IconData get radioButtonOff => _pick(Icons.radio_button_off, Icons.radio_button_off_outlined, Icons.radio_button_off_rounded);
  IconData get rateReview => _pick(Icons.rate_review, Icons.rate_review_outlined, Icons.rate_review_rounded);
  IconData get redo => _pick(Icons.redo, Icons.redo_outlined, Icons.redo_rounded);
  IconData get remove => _pick(Icons.remove, Icons.remove_outlined, Icons.remove_rounded);
  IconData get removeCircleOutline => _pick(Icons.remove_circle_outline, Icons.remove_circle_outline_outlined, Icons.remove_circle_outline_rounded);
  IconData get replay => _pick(Icons.replay, Icons.replay_outlined, Icons.replay_rounded);
  IconData get restore => _pick(Icons.restore, Icons.restore_outlined, Icons.restore_rounded);
  IconData get schedule => _pick(Icons.schedule, Icons.schedule_outlined, Icons.schedule_rounded);
  IconData get sell => _pick(Icons.sell, Icons.sell_outlined, Icons.sell_rounded);
  IconData get south => _pick(Icons.south, Icons.south_outlined, Icons.south_rounded);
  IconData get terminal => _pick(Icons.terminal, Icons.terminal_outlined, Icons.terminal_rounded);
  IconData get tune => _pick(Icons.tune, Icons.tune_outlined, Icons.tune_rounded);
  IconData get undo => _pick(Icons.undo, Icons.undo_outlined, Icons.undo_rounded);
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

  IconData get checkBox => _pick(Icons.check_box, Icons.check_box_outlined, Icons.check_box_rounded);
  IconData get checkBoxOutlineBlank => _pick(Icons.check_box_outline_blank, Icons.check_box_outline_blank_outlined, Icons.check_box_outline_blank_rounded);
  IconData get cleaningServices => _pick(Icons.cleaning_services, Icons.cleaning_services_outlined, Icons.cleaning_services_rounded);
  IconData get openInFull => _pick(Icons.open_in_full, Icons.open_in_full_outlined, Icons.open_in_full_rounded);
  IconData get pause => _pick(Icons.pause, Icons.pause_outlined, Icons.pause_rounded);
  IconData get bolt => _pick(Icons.bolt, Icons.bolt_outlined, Icons.bolt_rounded);
  IconData get arrowDropDown => _pick(Icons.arrow_drop_down, Icons.arrow_drop_down_outlined, Icons.arrow_drop_down_rounded);
  IconData get history => _pick(Icons.history, Icons.history_outlined, Icons.history_rounded);
}
