import 'package:flutter/material.dart';

class MoradoresView extends StatelessWidget {
  const MoradoresView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moradores')),
      body: ListView.builder(
        itemCount: 10, // Simulação
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('Morador $index'),
            subtitle: const Text('Detalhes do morador'),
            onTap: () {
              // Navegar para detalhes
            },
          );
        },
      ),
    );
  }
}
