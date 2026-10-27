/// 설정 화면의 글꼴 고르기(콤보 상자)에서만 쓰는 작은 도우미. `fontFamily`를 직접 쓰는 곳을
/// `lib/theme/` 안으로 모아 `test/theme_rules_test.dart`를 지킨다.
library;

import 'package:flutter/material.dart';

/// [family]로 미리보기 글자 모양을 만든다. null이면(기본) 테마 글꼴을 그대로 쓴다.
TextStyle fontPreviewStyle(String? family) => TextStyle(fontFamily: family);

/// 글꼴 목록(DropdownMenu) 항목 칸을 좁힌 공통 모양. [family]가 있으면 그 글꼴로 미리 보여 준다.
/// 칸이 좁아야 목록이 길어도(수백 개) 한 번에 더 많이 보이고 펼친 목록이 화면을 덜 덮는다.
ButtonStyle fontMenuEntryStyle([String? family]) => MenuItemButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
  visualDensity: VisualDensity.compact,
  minimumSize: const Size(0, 32),
  textStyle: family == null ? null : TextStyle(fontFamily: family),
);
