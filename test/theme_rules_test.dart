import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 모든 컨트롤이 테마를 따르도록, 색·글꼴 값은 `lib/theme/`에만 둔다.
/// 화면 코드는 `Theme.of(context)`와 `context.tokens`에서 읽어야 한다.
void main() {
  test('lib/theme 밖에서 색·글꼴·아이콘 값을 직접 쓰지 않는다', () {
    final forbidden = {
      'Colors.': RegExp(r'\bColors\.'),
      'Color(': RegExp(r'\bColor\('),
      'fontSize:': RegExp(r'\bfontSize\s*:'),
      'fontFamily': RegExp(r'\bfontFamily'),
      'Icons.': RegExp(r'\bIcons\.'),
    };
    final violations = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.startsWith('lib/theme/')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        for (final e in forbidden.entries) {
          if (e.value.hasMatch(line)) violations.add('$path:${i + 1} ${e.key}');
        }
      }
    }
    expect(violations, isEmpty, reason: '색·글꼴은 lib/theme/app_theme.dart의 테마·토큰으로, 아이콘은 context.icons(lib/theme/studio_icons.dart)로 옮기세요.');
  });
}
