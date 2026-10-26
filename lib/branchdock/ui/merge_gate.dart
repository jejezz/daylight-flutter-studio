import 'package:flutter/widgets.dart';

import '../../settings/gate_settings.dart';

/// PR 병합 관문 (Studio 전용 확장). 검증 기록으로 "지금 병합해도 되는지"를 판정한다.
///
/// Branch Dock에는 없는 기능이라 [MergeGateScope]가 없으면 PR 카드는 원래대로 동작한다.
abstract class MergeGateSource extends ChangeNotifier {
  /// 관문이 켜져 있는지. 꺼져 있으면 판정 줄도 보이지 않는다.
  bool get active;

  /// 마지막으로 읽은 기록으로 한 판정.
  GateDecision get decision;

  /// 검증 상태 카드 (확인함·빌드만·문제 있음…).
  Widget buildVerifyCard(BuildContext context);

  /// 병합 직전에 기록을 다시 읽어 판정한다 (화면의 판정이 낡았을 수 있다).
  Future<GateDecision> judge();

  /// 차단·확인 사유를 보여 주고 사용자가 "그래도 병합"을 고르면 true.
  Future<bool> confirmOverride(BuildContext context, String reason);
}

class MergeGateScope extends InheritedNotifier<MergeGateSource> {
  const MergeGateScope({super.key, required MergeGateSource gate, required super.child}) : super(notifier: gate);

  static MergeGateSource? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MergeGateScope>()?.notifier;
}
