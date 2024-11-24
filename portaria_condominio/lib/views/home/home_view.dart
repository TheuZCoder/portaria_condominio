import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});


  /// Obtém o papel (role) do usuário autenticado
  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;


    // Verifica se o usuário está autenticado
    if (user == null) {
      return 'unknown';
    }


    // Busca o papel no Firestore
    final doc = await FirebaseFirestore.instance.collection('moradores').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'unknown';
    }
    return 'unknown';
  }


  @override
  Widget build(BuildContext context) {
    // Obtém configurações e traduções
    final configController = Provider.of<ConfiguracoesController>(context);
    final localizations = AppLocalizations.of(context);


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
              leading: Icon(Icons.settings, color: configController.iconColor),
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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }


          final userRole = snapshot.data ?? 'unknown';


          // Definir itens de menu com base no papel do usuário
          final menuItems = <Widget>[
            if (userRole == 'portaria' || userRole == 'admin')
              _menuItem(context, localizations.translate('residents'), Icons.people, '/moradores', configController),
            if (userRole != 'visitor')
              _menuItem(context, localizations.translate('providers'), Icons.work, '/prestadores', configController),
            if (userRole != 'visitor')
              _menuItem(context, localizations.translate('visits'), Icons.person_add, '/visitas', configController),
            _menuItem(context, localizations.translate('orders'), Icons.shopping_cart, '/pedidos', configController),
            _menuItem(context, localizations.translate('notifications'), Icons.notifications, '/notificacoes', configController),
            _menuItem(context, localizations.translate('map'), Icons.map, '/mapa', configController),
            if (userRole != 'visitor')
              _menuItem(context, localizations.translate('chat'), Icons.chat_bubble, '/usersListView', configController),
          ];


          return GridView(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            children: menuItems,
          );
        },
      ),
    );
  }


  Widget _menuItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    ConfiguracoesController configController,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: configController.iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: configController.iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
