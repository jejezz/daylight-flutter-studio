import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _theme.restore();
  }

  @override
  void dispose() {
    _theme.dispose();
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
        home: StudioScreen(theme: _theme),
      ),
    );
  }
}
