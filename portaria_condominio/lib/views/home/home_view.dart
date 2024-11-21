import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
                  'Menu',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge // Substituímos headline6 por titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.pushNamed(context, '/configuracoes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
          _menuItem(context, 'Moradores', Icons.people, '/moradores'),
          _menuItem(context, 'Prestadores', Icons.work, '/prestadores'),
          _menuItem(context, 'Visitas', Icons.person_add, '/visitas'),
          _menuItem(context, 'Pedidos', Icons.shopping_cart, '/pedidos'),
          _menuItem(context, 'Notificações', Icons.notifications, '/notificacoes'),
          _menuItem(context, 'Mapa', Icons.map, '/mapa'),
          _menuItem(context, 'Chat', Icons.chat_bubble, '/UsersListView')
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
