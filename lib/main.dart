import 'dart:io';

import 'package:flutter/material.dart';
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

final bool _isDesktop =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerExtraLicenses();

  if (_isDesktop) {
    await windowManager.ensureInitialized();
    // ui-ux.md §5: 최소 크기는 960×600 이하 (1366×768 노트북).
    const options = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(960, 600),
      center: true,
      title: AppIdentity.displayName,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(StudioApp(settings: await AppSettings.load()));
}

class StudioApp extends StatefulWidget {
  const StudioApp({super.key, required this.settings});

  final AppSettings settings;

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
