import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _themeKey = 'theme';
  static const _localeKey = 'locale';
  static const _emailKey = 'email';
  static const _rememberEmailKey = 'rememberEmail';

  /// **Salvar Tema**
  static Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// **Carregar Tema**
  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }

  /// **Salvar Idioma**
  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  /// **Carregar Idioma**
  static Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en'; // Default to English
  }

  /// **Salvar Email**
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// **Carregar Email**
  static Future<String?> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// **Salvar Preferência de Lembrar Email**
  static Future<void> saveRememberEmail(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberEmailKey, remember);
  }

  /// **Carregar Preferência de Lembrar Email**
  static Future<bool> loadRememberEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberEmailKey) ?? false;
  }

  /// **Limpar Preferências (Opcional)**
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
