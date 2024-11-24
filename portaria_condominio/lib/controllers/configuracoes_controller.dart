import 'package:flutter/material.dart';
import '../utils/preferences.dart';

class ConfiguracoesController extends ChangeNotifier {
  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  ConfiguracoesController() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final languageCode = await Preferences.loadLocale();
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    Preferences.saveLocale(languageCode);
    notifyListeners();
  }

  void resetToDefaults() {
    changeLanguage('pt');
    notifyListeners();
  }
}
