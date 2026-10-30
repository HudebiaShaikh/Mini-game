import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/settings_storage.dart';
import 'theme/app_theme.dart';

/// The root widget. It remembers whether the app is in light or dark mode.
class MiniGamesApp extends StatefulWidget {
  const MiniGamesApp({super.key});

  @override
  State<MiniGamesApp> createState() => _MiniGamesAppState();
}

class _MiniGamesAppState extends State<MiniGamesApp> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await SettingsStorage.loadDarkMode();
    setState(() => _isDark = isDark);
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
    SettingsStorage.saveDarkMode(_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(isDark: _isDark, onToggleTheme: _toggleTheme),
    );
  }
}
