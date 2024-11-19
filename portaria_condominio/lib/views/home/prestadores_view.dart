import 'package:flutter/material.dart';

class PrestadoresView extends StatelessWidget {
  const PrestadoresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prestadores')),
      body: ListView.builder(
        itemCount: 10, // Simulação
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.work),
            title: Text('Prestador $index'),
            subtitle: const Text('Detalhes do prestador'),
            onTap: () {
              // Navegar para detalhes
            },
          );
        },
      ),
    );
  }
}
