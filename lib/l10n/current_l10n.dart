import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// 위젯 트리 밖(컨트롤러·서비스)에서 사용자에게 보일 문구를 만들 때 쓰는 현재 언어.
///
/// 화면은 [L10nBridge]로 바뀐 언어를 알려 준다. 알려 주기 전(테스트 등)에는 한국어다.
/// 문구가 필요한 순간에 읽으므로 이미 만들어진 문구는 언어를 바꿔도 그대로 남는다.
abstract final class CurrentL10n {
  static AppLocalizations value = lookupAppLocalizations(const Locale('ko'));
}

/// `MaterialApp.builder`에서 [child]를 감싸 현재 언어를 [CurrentL10n]에 맞춘다.
class L10nBridge extends StatelessWidget {
  const L10nBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    CurrentL10n.value = AppLocalizations.of(context);
    return child;
  }
}
