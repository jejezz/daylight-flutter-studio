/// 병합 관문: PR 병합 전에 그 커밋을 로컬에서 확인했는지 보는 규칙과 설정.
///
/// 이 앱의 목적은 "빌드해서 눈으로 확인한 뒤에 병합한다"를 건너뛰기 어렵게 하는 것이다.
/// 확인 없이 병합하면 GitHub에서 전체 OS 빌드가 돌고, 문제가 나오면 수정해 다시 릴리스를 해야 한다.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../l10n/current_l10n.dart';
import '../verify/verify_state.dart';

enum GateMode {
  /// 확인된(`검증됨`) 커밋만 병합할 수 있다. 예외는 "검증 없이 병합"을 따로 눌러야 한다.
  block,

  /// 확인되지 않은 커밋은 병합 전에 한 번 더 묻는다.
  warn,

  /// 관문을 쓰지 않는다.
  off;

  String label(AppLocalizations l10n) => switch (this) {
    block => l10n.gateModeBlock,
    warn => l10n.gateModeWarn,
    off => l10n.gateModeOff,
  };

  String description(AppLocalizations l10n) => switch (this) {
    block => l10n.gateModeBlockHelp,
    warn => l10n.gateModeWarnHelp,
    off => l10n.gateModeOffHelp,
  };
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
  const GateDecision(this.action, String this._message);

  const GateDecision.allow() : this._(GateAction.allow);

  const GateDecision._(this.action) : _message = null;

  final GateAction action;

  final String? _message;

  /// 왜 그런 판단인지 한 줄 설명 (화면에 그대로 보여 준다).
  String get message => _message ?? CurrentL10n.value.gateVerified;

  bool get allowed => action == GateAction.allow;
}

/// 검증 판정을 사람이 읽는 한 줄로.
String describeVerdict(VerifyVerdict? verdict) {
  final l10n = CurrentL10n.value;
  switch (verdict?.state) {
    case VerifyState.verified:
      return l10n.gateVerified;
    case VerifyState.builtOnly:
      return l10n.gateBuiltOnly;
    case VerifyState.problem:
      final note = verdict?.record?.note ?? '';
      return note.isEmpty ? l10n.gateProblem : l10n.gateProblemNote(note);
    case VerifyState.stale:
      final n = verdict?.commitsSince;
      return n == null ? l10n.gateStaleSome : l10n.gateStaleCount(n);
    case VerifyState.unverified:
    case null:
      return l10n.gateUnverified;
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
