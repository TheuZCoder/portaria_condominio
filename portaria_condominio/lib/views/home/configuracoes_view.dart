import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';

class ConfiguracoesView extends StatelessWidget {
  const ConfiguracoesView({super.key});

  void _pickColor(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Selecionar'),
            ),
          ],
        );
      },
    );
  }

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
            Row(
              children: [
                Text(appLocalizations.translate('language')),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Cor Primária'),
              trailing: CircleAvatar(backgroundColor: configController.primaryColor),
              onTap: () => _pickColor(context, configController.primaryColor, (color) {
                configController.changePrimaryColor(color);
              }),
            ),
            ListTile(
              title: const Text('Cor dos Ícones'),
              trailing: CircleAvatar(backgroundColor: configController.iconColor),
              onTap: () => _pickColor(context, configController.iconColor, (color) {
                configController.changeIconColor(color);
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Voltar ao Padrão'),
              onPressed: () {
                configController.resetToDefaults();
              },
            ),
          ],
        ),
      ),
    );
  }
}
