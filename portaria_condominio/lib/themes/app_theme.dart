import 'package:flutter/material.dart';

enum ThemePreset {
  defaultLight,
  defaultDark,
  indigoLight,
  indigoDark,
  tealLight,
  tealDark,
  orangeLight,
  orangeDark,
}

class AppTheme {
  static const _defaultSeedColor = Color(0xFF1A73E8); // Google Blue
  static const _indigoSeedColor = Color(0xFF3F51B5); // Indigo
  static const _tealSeedColor = Color(0xFF009688); // Teal
  static const _orangeSeedColor = Color(0xFFFF5722); // Deep Orange

  static ThemeData getThemeByPreset(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.defaultLight:
        return _createTheme(_defaultSeedColor, Brightness.light);
      case ThemePreset.defaultDark:
        return _createTheme(_defaultSeedColor, Brightness.dark);
      case ThemePreset.indigoLight:
        return _createTheme(_indigoSeedColor, Brightness.light);
      case ThemePreset.indigoDark:
        return _createTheme(_indigoSeedColor, Brightness.dark);
      case ThemePreset.tealLight:
        return _createTheme(_tealSeedColor, Brightness.light);
      case ThemePreset.tealDark:
        return _createTheme(_tealSeedColor, Brightness.dark);
      case ThemePreset.orangeLight:
        return _createTheme(_orangeSeedColor, Brightness.light);
      case ThemePreset.orangeDark:
        return _createTheme(_orangeSeedColor, Brightness.dark);
    }
  }

  static ThemeData _createTheme(Color seedColor, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        dragHandleColor: Colors.grey,
        backgroundColor: Colors.transparent,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        elevation: 0,
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        elevation: 0,
        labelType: NavigationRailLabelType.all,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Nomes amigáveis para os temas
  static String getThemeName(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.defaultLight:
        return 'Padrão Claro';
      case ThemePreset.defaultDark:
        return 'Padrão Escuro';
      case ThemePreset.indigoLight:
        return 'Índigo Claro';
      case ThemePreset.indigoDark:
        return 'Índigo Escuro';
      case ThemePreset.tealLight:
        return 'Teal Claro';
      case ThemePreset.tealDark:
        return 'Teal Escuro';
      case ThemePreset.orangeLight:
        return 'Laranja Claro';
      case ThemePreset.orangeDark:
        return 'Laranja Escuro';
    }
  }

  // Ícones para os temas
  static IconData getThemeIcon(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.defaultLight:
      case ThemePreset.defaultDark:
        return Icons.palette_outlined;
      case ThemePreset.indigoLight:
      case ThemePreset.indigoDark:
        return Icons.color_lens_outlined;
      case ThemePreset.tealLight:
      case ThemePreset.tealDark:
        return Icons.brush_outlined;
      case ThemePreset.orangeLight:
      case ThemePreset.orangeDark:
        return Icons.format_paint_outlined;
    }
  }
}
