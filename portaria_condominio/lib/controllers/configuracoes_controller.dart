import 'package:flutter/material.dart';
import '../utils/preferences.dart';

class ConfiguracoesController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  Color _primaryColor = Colors.blue;
  Color _iconColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get primaryColor => _primaryColor;
  Color get iconColor => _iconColor;

  ConfiguracoesController() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final isDarkMode = await Preferences.loadTheme();
    final languageCode = await Preferences.loadLocale();
    final primaryColorHex = await Preferences.loadPrimaryColor();
    final iconColorHex = await Preferences.loadIconColor();

    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(languageCode);
    _primaryColor = Color(primaryColorHex);
    _iconColor = Color(iconColorHex);

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

  void changePrimaryColor(Color color) {
    _primaryColor = color;
    Preferences.savePrimaryColor(color.value);
    notifyListeners();
  }

  void changeIconColor(Color color) {
    _iconColor = color;
    Preferences.saveIconColor(color.value);
    notifyListeners();
  }

  void resetToDefaults() {
    toggleTheme(false);
    changeLanguage('en');
    changePrimaryColor(Colors.blue);
    changeIconColor(Colors.blue);
    notifyListeners();
  }
}
