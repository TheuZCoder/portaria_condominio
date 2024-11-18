import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
