import 'package:cloud_firestore/cloud_firestore.dart';

class Portaria {
  final String id;
  final String nome;
  final String email; // Email usado para login no Firebase Authentication
  final String senha; // Senha usada para login no Firebase Authentication
  final String telefone;
  final String role; // Adicionado

  Portaria({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.telefone,
    this.role = 'admin', // Valor fixo para admins
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'role': role,
    };
  }

  factory Portaria.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Portaria(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      senha: data['senha'] ?? '',
      telefone: data['telefone'] ?? '',
      role: data['role'] ?? 'admin', // Valor padrão
    );
  }
}
