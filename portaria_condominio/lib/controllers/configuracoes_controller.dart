import 'package:flutter/material.dart';

class ConfiguracoesController extends ChangeNotifier {
  // Estado do tema: Claro ou Escuro
  ThemeMode _themeMode = ThemeMode.light;

  // Estado do idioma: Inglês (en) ou Português (pt)
  Locale _locale = const Locale('en');

  // Getter para o modo de tema atual
  ThemeMode get themeMode => _themeMode;

  // Getter para o idioma atual
  Locale get locale => _locale;

  /// Alterna entre os temas (Claro e Escuro)
  /// [isDarkMode] define se o tema será escuro (true) ou claro (false)
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifica os listeners sobre a mudança
  }

  /// Altera o idioma do aplicativo
  /// [languageCode] deve ser "en" (Inglês) ou "pt" (Português)
  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners(); // Notifica os listeners sobre a mudança
  }
}
