import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../controllers/notificacoes_controller.dart';
import '../../localizations/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../settings/settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Obtém o papel (role) do usuário autenticado
  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'unknown';
    }

    final doc = await FirebaseFirestore.instance
        .collection('moradores')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'unknown';
    }
    return 'unknown';
  }

  /// Widget de menu item
  Widget _menuItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    ConfiguracoesController configController, {
    int notificationCount = 0,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (notificationCount > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.error,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configController = Provider.of<ConfiguracoesController>(context);
    final localizations = AppLocalizations.of(context);
    final notificationController = NotificationController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('home_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatList),
            tooltip: localizations.translate('chats'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  localizations.translate('menu'),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: colorScheme.primary),
              title: Text(localizations.translate('settings')),
              onTap: () {
                debugPrint('HomeView: Navigating to settings');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsView()),
                ).then((_) {
                  debugPrint('HomeView: Returned from settings');
                }).catchError((error) {
                  debugPrint('HomeView: Error navigating to settings: $error');
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.primary),
              title: Text(localizations.translate('logout')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (route) => false);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<int>(
        stream: notificationController.getUnreadNotificationCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(localizations.translate('error_fetching_data')));
          }

          final notificationCount = snapshot.data ?? 0;

          return FutureBuilder<String>(
            future: _getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.hasError) {
                return Center(
                    child: Text(localizations.translate('error_fetching_role')));
              }

              final userRole = roleSnapshot.data ?? 'unknown';

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (userRole == 'admin' || userRole == 'portaria')
                    _menuItem(
                      context,
                      localizations.translate('residents'),
                      Icons.people,
                      '/moradores',
                      configController,
                    ),
                  if (userRole != 'visitor')
                    _menuItem(
                      context,
                      localizations.translate('providers'),
                      Icons.work,
                      '/prestadores',
                      configController,
                    ),
                  if (userRole != 'visitor')
                    _menuItem(
                      context,
                      localizations.translate('visits'),
                      Icons.person_add,
                      '/visitas',
                      configController,
                    ),
                  _menuItem(
                    context,
                    localizations.translate('orders'),
                    Icons.shopping_cart,
                    '/pedidos',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('notifications'),
                    Icons.notifications,
                    '/notificacoes',
                    configController,
                    notificationCount: notificationCount,
                  ),
                  if (userRole == 'admin')
                    _menuItem(
                      context,
                      'Cadastro de Notificações',
                      Icons.notification_add,
                      '/notificacoesAdmin',
                      configController,
                    ),
                  if (userRole == 'admin' || userRole == 'portaria')
                    _menuItem(
                      context,
                      localizations.translate('qr_code_reader'),
                      Icons.qr_code_scanner,
                      '/qr-scanner',
                      configController,
                    ),
                  _menuItem(
                    context,
                    localizations.translate('map'),
                    Icons.map,
                    '/mapa',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('chats'),
                    Icons.chat,
                    AppRoutes.chatList,
                    configController,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
