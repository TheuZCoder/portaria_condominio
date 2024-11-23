import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final configController = context.watch<ConfiguracoesController>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove a seta para a esquerda
      ),
      body: Column(
        children: [
          // Card com as informações do usuário e menu
          Padding(
            padding: const EdgeInsets.all(16), // Mesma margem do grid
            child: Card(
              elevation: 4, // Adiciona elevação ao card
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding interno do card
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          'https://www.example.com/default-profile.png'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'João da Silva',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Morador',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CPF: 123.***.***-01',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    // Adiciona o menu como um PopupMenuButton
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.grey,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Configurações'),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/configuracoes');
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                          ),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Grid de opções
          Expanded(
            child: GridView(
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
                _menuItem(context, 'Notificações', Icons.notifications,
                    '/notificacoes'),
                _menuItem(context, 'Mapa', Icons.map, '/mapa'),
                _menuItem(context, 'Chat', Icons.chat_bubble, '/chat'),
              ],
            ),
          ),
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
