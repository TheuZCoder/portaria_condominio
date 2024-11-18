import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localizations/app_localizations.dart';
import 'routes/app_routes.dart';
import 'themes/app_theme.dart';
import 'controllers/configuracoes_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConfiguracoesController _configController = ConfiguracoesController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _configController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Gestão de Condomínio',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _configController.themeMode,
          locale: _configController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
