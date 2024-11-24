import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('SettingsView: Building...');
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aparência',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...ThemePreset.values.map((preset) {
            final isSelected = preset == themeProvider.currentPreset;
            return ListTile(
              leading: Icon(
                AppTheme.getThemeIcon(preset),
                color: isSelected ? colorScheme.primary : null,
              ),
              title: Text(AppTheme.getThemeName(preset)),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
              onTap: () => themeProvider.setThemePreset(preset),
            );
          }).toList(),
          const Divider(),
          // Aqui você pode adicionar mais seções de configurações
        ],
      ),
    );
  }
}
