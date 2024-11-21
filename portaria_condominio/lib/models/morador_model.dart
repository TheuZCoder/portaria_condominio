import 'package:cloud_firestore/cloud_firestore.dart';

class Morador {
  final String id; // ID do documento Firestore
  final String nome; // Nome do morador
  final String cpf; // CPF do morador
  final String telefone; // Telefone do morador
  final String email; // Email usado para login no Firebase Authentication
  final String senha; // Senha usada para login no Firebase Authentication
  final String endereco;
  final String role;

  // Construtor
  Morador({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.senha,
    required this.endereco,
    this.role = 'morador',
  });

  // Construtor para criar um Morador a partir de um documento Firestore
  factory Morador.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Morador(
      id: doc.id,
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      telefone: data['telefone'] ?? '',
      email: data['email'] ?? '',
      senha: data['senha'] ?? '',
      endereco: data['endereco'] ?? '',
      role: data['role'] ?? 'morador',
    );
  }

  // Método para converter o Morador em um mapa (JSON) para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'senha': senha,
      'endereco': endereco,
      'role': role,
    };
  }
}
