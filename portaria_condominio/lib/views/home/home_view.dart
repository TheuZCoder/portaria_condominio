import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../controllers/notificacoes_controller.dart';
import '../../localizations/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Obtém o papel (role) do usuário autenticado
  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'unknown';
    }

    // Busca o papel no Firestore
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
    int notificationCount = 0, // Contador de notificações opcional
  }) {
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
                    color: configController.iconColor,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: configController.iconColor,
                    ),
                  ),
                ],
              ),
              if (notificationCount > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Cor do círculo de notificação
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
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
    final notificationController =
        NotificationController(); // Criando uma instância do NotificationController

    return Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('home_title')),
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
                    localizations.translate('menu'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.settings, color: configController.iconColor),
                title: Text(localizations.translate('settings')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/configuracoes');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: configController.iconColor),
                title: Text(localizations.translate('logout')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
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

            // Aqui, snapshot.data já é o número de notificações não lidas
            final notificationCount = snapshot.data ?? 0;

            // Obtém o papel do usuário
            return FutureBuilder<String>(
              future: _getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (roleSnapshot.hasError) {
                  return Center(
                      child:
                          Text(localizations.translate('error_fetching_role')));
                }

                final userRole =
                    roleSnapshot.data ?? 'unknown'; // Pega o papel do usuário

                final menuItems = <Widget>[
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
                    notificationCount:
                        notificationCount, // Passa o contador em tempo real
                  ),
                  _menuItem(
                    context,
                    localizations.translate('map'),
                    Icons.map,
                    '/mapa',
                    configController,
                  ),
                  if (userRole != 'visitor')
                    _menuItem(
                      context,
                      localizations.translate('chat'),
                      Icons.chat_bubble,
                      '/usersListView',
                      configController,
                    ),
                ];

                if (menuItems.isEmpty) {
                  return Center(
                    child: Text(localizations.translate('no_access')),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) => menuItems[index],
                );
              },
            );
          },
        ));
  }
}
