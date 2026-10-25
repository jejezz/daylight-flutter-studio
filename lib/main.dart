import 'package:flutter/material.dart';

import 'theme/editor_zoom.dart';
import 'theme/theme_controller.dart';
import 'ui/studio_screen.dart';

void main() {
  runApp(const StudioApp());
}

class StudioApp extends StatefulWidget {
  const StudioApp({super.key});

  @override
  State<StudioApp> createState() => _StudioAppState();
}

class _StudioAppState extends State<StudioApp> {
  final _theme = ThemeController();
  final _zoom = EditorZoom();

  @override
  void initState() {
    super.initState();
    _theme.restore();
    _zoom.restore();
  }

  @override
  void dispose() {
    _theme.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, _) => MaterialApp(
        title: 'Daylight Flutter Studio',
        debugShowCheckedModeBanner: false,
        theme: _theme.light,
        darkTheme: _theme.dark,
        themeMode: _theme.mode,
        builder: (context, child) => EditorZoomScope(zoom: _zoom, child: child!),
        home: StudioScreen(theme: _theme),
      ),
    );
  }
}
