/// 글꼴이 이 컴퓨터에 실제로 있는지 알아낸다. Flutter에는 설치된 글꼴 목록을 묻는 방법이 없어서,
/// 같은 글자를 그 글꼴과 "없는 글꼴"로 각각 재어 보고 폭이 다르면 있는 것으로 본다
/// (없는 이름은 OS 기본 글꼴로 대체되므로 고정폭 글꼴과는 폭이 다르다).
library;

import 'package:flutter/painting.dart';

abstract final class FontProbe {
  /// 테스트에서는 글꼴이 모두 같은 글꼴로 그려지므로 바꿔 끼울 수 있게 둔다.
  static bool Function(String family) isInstalled = _measured;

  static final _cache = <String, bool>{};

  static const _sample = 'iIlWmM0Oo1|@#gjy';
  static const _missing = '__daylight_no_such_font__';

  static bool _measured(String family) => _cache.putIfAbsent(family, () {
    // 대체 글꼴 없이 재야 "그 글꼴이 있나"만 드러난다.
    Size measure(String name) {
      final painter = TextPainter(
        text: TextSpan(text: _sample, style: TextStyle(fontFamily: name, fontSize: 40)),
        textDirection: TextDirection.ltr,
      )..layout();
      final size = painter.size;
      painter.dispose();
      return size;
    }

    final a = measure(family);
    final b = measure(_missing);
    return (a.width - b.width).abs() > 0.5 || (a.height - b.height).abs() > 0.5;
  });
}
