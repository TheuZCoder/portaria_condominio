import 'package:cloud_firestore/cloud_firestore.dart';

class Visita {
  final String id; // ID do documento no Firestore
  final String nome; // Nome do visitante
  final String cpf; // CPF do visitante
  final bool liberacaoEntrada; // Indica se a entrada foi liberada
  final String role; 

  // Construtor
  Visita({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.liberacaoEntrada,
    this.role = 'visitante',
  });

  // Construtor para criar uma Visita a partir de um documento Firestore
  factory Visita.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Visita(
      id: doc.id,
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      liberacaoEntrada: data['liberacaoEntrada'] ?? false,
      role: data['role'] ?? 'visitante',
    );
  }

  // Método para converter uma Visita em JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'liberacaoEntrada': liberacaoEntrada,
      'role': role,
    };
  }
}
