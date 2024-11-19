import 'package:flutter/material.dart';

class NotificacoesView extends StatelessWidget {
  const NotificacoesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: ListView.builder(
        itemCount: 10, // Simulação
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notificação $index'),
            subtitle: const Text('Detalhes da notificação'),
            onTap: () {
              // Navegar para detalhes
            },
          );
        },
      ),
    );
  }
}
