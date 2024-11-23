import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenha as configurações e as traduções
    final configController = Provider.of<ConfiguracoesController>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Card com as informações do usuário
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagem do usuário
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: const NetworkImage(
                          'https://www.example.com/default-profile.png',
                        ),
                        backgroundColor:
                            configController.iconColor ?? Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      // Informações do usuário
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'João da Silva',
                              style: TextStyle(
                                fontSize: 18,
                                color: configController.iconColor ??
                                    Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.translate('user_role') ?? 'Morador',
                              style: TextStyle(
                                fontSize: 16,
                                color: configController.iconColor ??
                                    Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${localizations.translate('cpf') ?? 'CPF'}: 123.***.***-01',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Botão de configurações
                      PopupMenuButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.settings),
                              title: Text(localizations.translate('settings') ??
                                  'Configurações'),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/configuracoes');
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.logout),
                              title: Text(localizations.translate('logout') ??
                                  'Logout'),
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
                  _menuItem(
                    context,
                    localizations.translate('residents') ?? 'Moradores',
                    Icons.people,
                    '/moradores',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('providers') ?? 'Prestadores',
                    Icons.work,
                    '/prestadores',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('visits') ?? 'Visitas',
                    Icons.person_add,
                    '/visitas',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('orders') ?? 'Pedidos',
                    Icons.shopping_cart,
                    '/pedidos',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('notifications') ?? 'Notificações',
                    Icons.notifications,
                    '/notificacoes',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('map') ?? 'Mapa',
                    Icons.map,
                    '/mapa',
                    configController,
                  ),
                  _menuItem(
                    context,
                    localizations.translate('chat') ?? 'Chat',
                    Icons.chat_bubble,
                    '/chat',
                    configController,
                  ),
                ],
              ),
            ),
          ],
        ),
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
