import 'dart:convert';

import '../l10n/current_l10n.dart';
import 'dart_formatter.dart' show FormatResult;

/// JSON·ARB 글을 들여쓰기 2칸으로 정렬한다. 키 순서는 그대로 두고, 끝의 줄바꿈 유무도 원본을 따른다.
FormatResult formatJson(String text) {
  try {
    final value = jsonDecode(text);
    final formatted = const JsonEncoder.withIndent('  ').convert(value);
    return FormatResult.ok(text.endsWith('\n') ? '$formatted\n' : formatted);
  } on FormatException catch (e) {
    return FormatResult.failed(CurrentL10n.value.formatJsonInvalid(e.message));
  }
}
