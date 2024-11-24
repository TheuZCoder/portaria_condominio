import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  ThemePreset _currentPreset = ThemePreset.defaultLight;

  ThemeProvider() {
    _loadThemePreset();
  }

  ThemePreset get currentPreset => _currentPreset;
  ThemeData get currentTheme => AppTheme.getThemeByPreset(_currentPreset);

  Future<void> _loadThemePreset() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt('theme_preset') ?? 0;
    _currentPreset = ThemePreset.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemePreset(ThemePreset preset) async {
    await _prefs.setInt('theme_preset', preset.index);
    _currentPreset = preset;
    notifyListeners();
  }
}
