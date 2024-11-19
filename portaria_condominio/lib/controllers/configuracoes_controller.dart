import 'package:flutter/material.dart';
import '../utils/preferences.dart';

class ConfiguracoesController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  ConfiguracoesController() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final isDarkMode = await Preferences.loadTheme();
    final languageCode = await Preferences.loadLocale();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    Preferences.saveTheme(isDarkMode);
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    Preferences.saveLocale(languageCode);
    notifyListeners();
  }
}
