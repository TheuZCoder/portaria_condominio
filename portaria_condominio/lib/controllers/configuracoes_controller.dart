import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesController extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;
  late Locale _locale;

  ConfiguracoesController(this._prefs) {
    _loadLocale();
  }

  Locale get locale => _locale;

  void _loadLocale() {
    final savedLocale = _prefs.getString(_localeKey);
    _locale = savedLocale != null
        ? Locale(savedLocale)
        : const Locale('pt'); // Português como padrão
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      await _prefs.setString(_localeKey, languageCode);
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    await _prefs.remove(_localeKey);
    _loadLocale();
    notifyListeners();
  }
}
