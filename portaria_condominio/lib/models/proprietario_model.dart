import 'package:cloud_firestore/cloud_firestore.dart';

class Proprietario {
  final String id;
  final String nome;
  final String cpf;
  final String endereco;
  final String telefone;

  Proprietario({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.endereco,
    required this.telefone,
  });

  // Converter um snapshot do Firebase para o Model
  factory Proprietario.fromDocument(DocumentSnapshot doc) {
    return Proprietario(
      id: doc.id,
      nome: doc['nome'],
      cpf: doc['cpf'],
      endereco: doc['endereco'],
      telefone: doc['telefone'],
    );
  }

  // Converter o Model para JSON (para salvar no Firebase)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'endereco': endereco,
      'telefone': telefone,
    };
  }
}
