import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListView extends StatelessWidget {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('moradores').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final userName = user['nome'] ?? 'Usuário';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(userName),
                subtitle: Text('ID: $userId'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat', // Navega para a rota definida
                    arguments: {
                      'id': userId,
                      'nome': userName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
