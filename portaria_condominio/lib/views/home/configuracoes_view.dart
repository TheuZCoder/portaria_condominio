import 'package:flutter/material.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';
import 'package:provider/provider.dart';

class ConfiguracoesView extends StatelessWidget {
  const ConfiguracoesView({super.key});

  @override
  Widget build(BuildContext context) {
    final configController = context.watch<ConfiguracoesController>();
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(appLocalizations.translate('dark_mode')),
              value: configController.themeMode == ThemeMode.dark,
              onChanged: (value) {
                configController.toggleTheme(value);
              },
            ),
            DropdownButton<String>(
              value: configController.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'pt', child: Text('Português')),
              ],
              onChanged: (value) {
                if (value != null) {
                  configController.changeLanguage(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
