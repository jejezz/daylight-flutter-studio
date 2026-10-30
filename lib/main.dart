import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'about/about_dialog.dart';
import 'about/app_menu_bar.dart';
import 'about/extra_licenses.dart';
import 'app_identity.dart';
import 'l10n/app_localizations.dart';
import 'l10n/current_l10n.dart';
import 'settings/app_settings.dart';
import 'settings/editor_settings.dart';
import 'theme/editor_zoom.dart';
import 'theme/theme_controller.dart';
import 'ui/studio_menus.dart';
import 'ui/studio_screen.dart';
import 'update/update_scope.dart';
import 'update/update_service.dart';
import 'window/window_placement.dart';

final bool _isDesktop =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerExtraLicenses();

  Future<void> Function()? showWindow;
  if (_isDesktop) {
    await windowManager.ensureInitialized();
    showWindow = await _prepareWindow();
  }

  final settings = await AppSettings.load();
  // 데스크톱이 아니거나 UPDATE_SERVER 가 비어 있으면 null — 업데이트 확인 없음.
  final updates = await UpdateService.create();
  // UpdateScope 는 MaterialApp 위에 둔다 — 정보 창이 이것을 읽어 "업데이트 확인" 단추를 붙인다.
  runApp(UpdateScope(service: updates, child: StudioApp(settings: settings, updates: updates)));

  if (showWindow != null) {
    final show = showWindow;
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(show()));
  }
}

/// 다음 프레임이 그려질 때까지 기다린다.
Future<void> _nextFrame() {
  final completer = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
  WidgetsBinding.instance.scheduleFrame();
  return completer.future;
}

/// ui-ux.md §5: 최소 크기는 960×600 이하 (1366×768 노트북).
/// 배치가 끝나고 첫 프레임이 그려진 뒤에 show() 를 불러야 깜빡이지 않는다 (window-placement.md §5).
Future<Future<void> Function()> _prepareWindow() async {
  const windowSize = Size(1280, 800);
  WindowPlacement? placement;
  if (WindowPlacement.enabled) {
    placement = WindowPlacement(await SharedPreferences.getInstance(), defaultSize: windowSize);
  }
  final options = WindowOptions(
    size: windowSize,
    minimumSize: const Size(960, 600),
    center: placement == null,
    title: AppIdentity.displayName,
  );
  final placed = Completer<void>();
  await windowManager.waitUntilReadyToShow(options, () async {
    await placement?.placeInitially();
    placed.complete();
  });
  return () async {
    await placed.future;
    await _nextFrame();
    await windowManager.show();
    await windowManager.focus();
    placement?.attach();
  };
}

class StudioApp extends StatefulWidget {
  const StudioApp({super.key, required this.settings, this.updates});

  final AppSettings settings;
  final UpdateService? updates;

  @override
  State<StudioApp> createState() => _StudioAppState();
}

class _StudioAppState extends State<StudioApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _theme = ThemeController(widget.settings);
  final _zoom = EditorZoom();
  final _editor = EditorSettings();
  final _menus = ValueNotifier<List<PlatformMenu>>(const []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _theme.addListener(_syncWindowBrightness);
    _theme.restore();
    _zoom.restore();
    _editor.restore();
    _syncWindowBrightness();
    widget.updates?.startAutomaticCheck(_navigatorKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _theme.removeListener(_syncWindowBrightness);
    _theme.dispose();
    _zoom.dispose();
    _editor.dispose();
    _menus.dispose();
    super.dispose();
  }

  // 앱에서 다크를 골라도 OS가 라이트면 제목 표시줄은 밝게 남는다 (theming.md §4).
  @override
  void didChangePlatformBrightness() => _syncWindowBrightness();

  void _syncWindowBrightness() {
    if (!_isDesktop || Platform.isLinux) return;
    final brightness = switch (_theme.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    windowManager.setBrightness(brightness);
  }

  void _showAbout() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context);
    showAppAboutDialog(
      context,
      tagline: l10n.aboutTagline,
      description: l10n.aboutDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: widget.settings,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          title: AppIdentity.displayName,
          debugShowCheckedModeBanner: false,
          theme: _theme.light,
          darkTheme: _theme.dark,
          themeMode: _theme.mode,
          locale: widget.settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: AppSettings.resolveLocale,
          builder: (context, child) => StudioMenuHost(
            menus: _menus,
            child: AppMenuBar(
              onAbout: _showAbout,
              extraMenus: _menus,
              child: L10nBridge(
                child: EditorSettingsScope(
                  settings: _editor,
                  child: EditorZoomScope(zoom: _zoom, child: child!),
                ),
              ),
            ),
          ),
          home: StudioScreen(theme: _theme, onAbout: _showAbout),
        ),
      ),
    );
  }
}
