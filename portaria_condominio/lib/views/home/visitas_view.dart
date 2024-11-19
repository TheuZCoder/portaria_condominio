import 'package:flutter/material.dart';

class VisitasView extends StatelessWidget {
  const VisitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitas')),
      body: ListView.builder(
        itemCount: 10, // Simulação
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person_add),
            title: Text('Visita $index'),
            subtitle: const Text('Detalhes da visita'),
            onTap: () {
              // Navegar para detalhes
            },
          );
        },
      ),
    );
  }
}
