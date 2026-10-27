import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 편집기 동작 설정. 글자 크기는 [EditorZoom]이 따로 맡는다.
class EditorSettings extends ChangeNotifier {
  EditorSettings([this._formatOnSave = false]);

  static const _formatOnSaveKey = 'format_on_save';
  static const _indentGuidesKey = 'indent_guides';
  static const _fontNameKey = 'editor_font_family';
  static const _lineHeightKey = 'editor_line_height';
  static const _ligaturesKey = 'editor_ligatures';
  static const _logFollowsEditorKey = 'log_follows_editor_font';

  /// 줄 간격(글자 크기의 배수) 범위. 기본값은 테마의 편집기 글꼴이 정한다.
  static const minLineHeight = 1.2;
  static const maxLineHeight = 2.0;

  /// 설정 화면에서 한 번에 고를 수 있는 고정폭 글꼴 이름.
  static const presetFonts = ['Menlo', 'SF Mono', 'Consolas', 'Cascadia Mono', 'JetBrains Mono', 'Fira Code'];

  bool _formatOnSave;
  bool _indentGuides = true;

  /// 들여쓰기 쌍을 깊이별 색의 세로선으로 표시한다.
  bool get indentGuides => _indentGuides;

  Future<void> setIndentGuides(bool value) async {
    if (value == _indentGuides) return;
    _indentGuides = value;
    notifyListeners();
    await _store((p) => p.setBool(_indentGuidesKey, value));
  }
  String? _fontName;
  double? _lineHeight;
  bool _ligatures = true;
  bool _logFollowsEditor = false;

  /// 합자(ligature)를 쓴다: `->`, `!=`, `>=` 같은 글자 묶음을 글꼴이 한 글자처럼 그린다. 합자가 있는 글꼴(Fira Code,
  /// JetBrains Mono, Cascadia Code 등)에서만 보이고, 끄면 글자를 낱낱이 그린다. 기본은 켬.
  bool get ligatures => _ligatures;

  /// 로그·명령 출력·Markdown 코드·경로·해시의 글꼴을 편집기 글꼴(과 합자 설정)과 같이 쓴다. 기본은 끔(테마의 로그 글꼴).
  bool get logFollowsEditor => _logFollowsEditor;

  Future<void> setLigatures(bool value) async {
    if (value == _ligatures) return;
    _ligatures = value;
    notifyListeners();
    await _store((p) => p.setBool(_ligaturesKey, value));
  }

  Future<void> setLogFollowsEditor(bool value) async {
    if (value == _logFollowsEditor) return;
    _logFollowsEditor = value;
    notifyListeners();
    await _store((p) => p.setBool(_logFollowsEditorKey, value));
  }

  /// 편집기 글꼴 이름. null이면 테마 기본.
  String? get fontName => _fontName;

  /// 줄 간격. null이면 테마 기본.
  double? get lineHeight => _lineHeight;

  Future<void> setFontName(String? value) async {
    final next = (value == null || value.trim().isEmpty) ? null : value.trim();
    if (next == _fontName) return;
    _fontName = next;
    notifyListeners();
    await _store((p) => next == null ? p.remove(_fontNameKey) : p.setString(_fontNameKey, next));
  }

  Future<void> setLineHeight(double? value) async {
    final next = value == null ? null : (value.clamp(minLineHeight, maxLineHeight) * 100).round() / 100;
    if (next == _lineHeight) return;
    _lineHeight = next;
    notifyListeners();
    await _store((p) => next == null ? p.remove(_lineHeightKey) : p.setDouble(_lineHeightKey, next));
  }

  Future<void> _store(Future<bool> Function(SharedPreferences) write) async {
    try {
      await write(await SharedPreferences.getInstance());
    } on Object {
      // 저장하지 못해도 이번 실행에는 적용된다.
    }
  }

  /// 저장하기 직전에 Dart·JSON·ARB 글을 정렬한다.
  bool get formatOnSave => _formatOnSave;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _formatOnSave = prefs.getBool(_formatOnSaveKey) ?? _formatOnSave;
      _indentGuides = prefs.getBool(_indentGuidesKey) ?? _indentGuides;
      _fontName = prefs.getString(_fontNameKey) ?? _fontName;
      _lineHeight = prefs.getDouble(_lineHeightKey) ?? _lineHeight;
      _ligatures = prefs.getBool(_ligaturesKey) ?? _ligatures;
      _logFollowsEditor = prefs.getBool(_logFollowsEditorKey) ?? _logFollowsEditor;
      notifyListeners();
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
