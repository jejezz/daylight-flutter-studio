/// 병합 관문: PR 병합 전에 그 커밋을 로컬에서 확인했는지 보는 규칙과 설정.
///
/// 이 앱의 목적은 "빌드해서 눈으로 확인한 뒤에 병합한다"를 건너뛰기 어렵게 하는 것이다.
/// 확인 없이 병합하면 GitHub에서 전체 OS 빌드가 돌고, 문제가 나오면 수정해 다시 릴리스를 해야 한다.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../verify/verify_state.dart';

enum GateMode {
  /// 확인된(`검증됨`) 커밋만 병합할 수 있다. 예외는 "검증 없이 병합"을 따로 눌러야 한다.
  block('차단', '확인한 커밋만 병합합니다. 예외가 필요하면 "검증 없이 병합"을 따로 눌러야 합니다.'),

  /// 확인되지 않은 커밋은 병합 전에 한 번 더 묻는다.
  warn('경고만', '확인하지 않은 커밋을 병합하려 하면 한 번 더 묻습니다.'),

  /// 관문을 쓰지 않는다.
  off('끔', '확인 여부와 상관없이 병합할 수 있습니다.');

  const GateMode(this.label, this.description);

  final String label;
  final String description;
}

enum GateAction {
  /// 그대로 병합할 수 있다.
  allow,

  /// 사용자에게 확인을 받은 뒤에 병합할 수 있다.
  confirm,

  /// 병합할 수 없다 ("검증 없이 병합"이라는 명시적 예외만 가능).
  block,
}

class GateDecision {
  const GateDecision(this.action, this.message);

  const GateDecision.allow() : this(GateAction.allow, '검증됨 — 병합할 수 있습니다');

  final GateAction action;

  /// 왜 그런 판단인지 한 줄 설명 (화면에 그대로 보여 준다).
  final String message;

  bool get allowed => action == GateAction.allow;
}

/// 검증 판정을 사람이 읽는 한 줄로.
String describeVerdict(VerifyVerdict? verdict) {
  switch (verdict?.state) {
    case VerifyState.verified:
      return '검증됨 — 병합할 수 있습니다';
    case VerifyState.builtOnly:
      return '빌드만 하고 눈으로 확인하지 않았습니다. 실행해 본 뒤 Run 탭에서 "확인함"을 눌러 주세요.';
    case VerifyState.problem:
      final note = verdict?.record?.note ?? '';
      return note.isEmpty ? '확인했더니 문제가 있다고 기록된 커밋입니다.' : '확인했더니 문제가 있다고 기록된 커밋입니다: $note';
    case VerifyState.stale:
      final n = verdict?.commitsSince;
      return n == null ? '검증한 뒤 커밋이 추가되었습니다. 다시 빌드해 확인하세요.' : '검증한 뒤 커밋 $n개가 추가되었습니다. 다시 빌드해 확인하세요.';
    case VerifyState.unverified:
    case null:
      return '이 커밋은 로컬에서 확인하지 않았습니다. Run 탭에서 빌드해 눈으로 확인하세요.';
  }
}

/// [mode]와 검증 판정으로 병합을 허용할지 정한다.
GateDecision decideGate(GateMode mode, VerifyVerdict? verdict) {
  if (mode == GateMode.off) return const GateDecision.allow();
  if (verdict?.passes ?? false) return const GateDecision.allow();
  final why = describeVerdict(verdict);
  return GateDecision(mode == GateMode.block ? GateAction.block : GateAction.confirm, why);
}

class GateSettings extends ChangeNotifier {
  GateSettings([this._mode = GateMode.block]);

  static const _key = 'merge_gate_mode';

  GateMode _mode;

  GateMode get mode => _mode;

  GateDecision decide(VerifyVerdict? verdict) => decideGate(_mode, verdict);

  Future<void> restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      final mode = GateMode.values.asNameMap()[saved];
      if (mode != null && mode != _mode) {
        _mode = mode;
        notifyListeners();
      }
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다 — 기본값(차단)을 쓴다.
    }
  }

  Future<void> setMode(GateMode value) async {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(_key, value.name);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}
