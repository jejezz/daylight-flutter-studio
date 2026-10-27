/// 설정 화면의 글꼴 고르기(콤보 상자)에서만 쓰는 작은 도우미. `fontFamily`를 직접 쓰는 곳을
/// `lib/theme/` 안으로 모아 `test/theme_rules_test.dart`를 지킨다.
library;

import 'package:flutter/material.dart';

/// [family]로 미리보기 글자 모양을 만든다. null이면(기본) 테마 글꼴을 그대로 쓴다.
TextStyle fontPreviewStyle(String? family) => TextStyle(fontFamily: family);

/// 설정 화면의 "미리보기" 상자 한 줄에 쓰는 크기까지 더한 모양.
TextStyle fontPreviewSampleStyle(String? family) => fontPreviewStyle(family).copyWith(fontSize: 16);

/// 글꼴 목록(DropdownMenu)의 항목 하나를 그 글꼴로 미리 보여 주는 단추 모양.
ButtonStyle fontMenuEntryStyle(String family) => MenuItemButton.styleFrom(textStyle: TextStyle(fontFamily: family));
