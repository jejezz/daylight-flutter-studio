import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 편집기 동작 설정. 글자 크기는 [EditorZoom]이 따로 맡는다.
class EditorSettings extends ChangeNotifier {
  EditorSettings([this._formatOnSave = false]);

  static const _formatOnSaveKey = 'format_on_save';

  bool _formatOnSave;

  /// 저장하기 직전에 Dart·JSON·ARB 글을 정렬한다.
  bool get formatOnSave => _formatOnSave;

  Future<void> restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getBool(_formatOnSaveKey);
      if (saved != null && saved != _formatOnSave) {
        _formatOnSave = saved;
        notifyListeners();
      }
    } on Object {
      // 기억해 둔 값은 편의일 뿐이다.
    }
  }

  Future<void> setFormatOnSave(bool value) async {
    if (value == _formatOnSave) return;
    _formatOnSave = value;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setBool(_formatOnSaveKey, value);
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }
}

class EditorSettingsScope extends InheritedNotifier<EditorSettings> {
  const EditorSettingsScope({super.key, required EditorSettings settings, required super.child}) : super(notifier: settings);

  /// 범위 밖(테스트 등)이면 null.
  static EditorSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EditorSettingsScope>()?.notifier;
}
