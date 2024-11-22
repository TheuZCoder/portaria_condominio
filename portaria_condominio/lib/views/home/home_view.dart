import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final configController = context.watch<ConfiguracoesController>();
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('home_title')),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text(
                  appLocalizations.translate('menu'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: configController.iconColor),
              title: Text(appLocalizations.translate('settings')),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.pushNamed(context, '/configuracoes');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: configController.iconColor),
              title: Text(appLocalizations.translate('logout')),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        children: [
          _menuItem(context, appLocalizations.translate('residents'),
              Icons.people, '/moradores', configController.iconColor),
          _menuItem(context, appLocalizations.translate('service_providers'),
              Icons.work, '/prestadores', configController.iconColor),
          _menuItem(context, appLocalizations.translate('visits'),
              Icons.person_add, '/visitas', configController.iconColor),
          _menuItem(context, appLocalizations.translate('orders'),
              Icons.shopping_cart, '/pedidos', configController.iconColor),
          _menuItem(context, appLocalizations.translate('notifications'),
              Icons.notifications, '/notificacoes', configController.iconColor),
          _menuItem(context, appLocalizations.translate('map'), Icons.map,
              '/mapa', configController.iconColor),
          _menuItem(context, appLocalizations.translate('chat'),
              Icons.chat_bubble, '/usersListView', configController.iconColor),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
