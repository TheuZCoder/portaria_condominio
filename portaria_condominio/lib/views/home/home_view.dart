import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<String> _getUserRole() async {
    // Obtenha o ID do usuário autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'unknown';
    }

    // Busque o papel do usuário no Firestore
    final doc = await FirebaseFirestore.instance.collection('moradores').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'unknown';
    }

    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenha as configurações e as traduções
    final configController = Provider.of<ConfiguracoesController>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/configuracoes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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

          // Defina os itens do menu com base no papel do usuário
          final menuItems = <Widget>[
            if (userRole == 'portaria')
              _menuItem(context, 'Moradores', Icons.people, '/moradores'),
            _menuItem(context, 'Prestadores', Icons.work, '/prestadores'),
            _menuItem(context, 'Visitas', Icons.person_add, '/visitas'),
            _menuItem(context, 'Pedidos', Icons.shopping_cart, '/pedidos'),
            _menuItem(context, 'Notificações', Icons.notifications, '/notificacoes'),
            _menuItem(context, 'Mapa', Icons.map, '/mapa'),
            _menuItem(context, 'Chat', Icons.chat_bubble, '/usersListView'),
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
              color:
                  configController.iconColor ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: configController.iconColor ??
                    Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
