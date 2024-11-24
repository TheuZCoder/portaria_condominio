import 'package:cloud_firestore/cloud_firestore.dart';

class Visita {
  final String id;
  final String nome;
  final String cpf;
  final bool liberacaoEntrada;
  final String role;
  final String dataPrevista;
  final String horaPrevista;
  final String apartamento;
  final String observacoes;
  final String status;

  Visita({
    required this.id,
    required this.nome,
    required this.cpf,
    this.liberacaoEntrada = false,
    this.role = 'visitante',
    required this.dataPrevista,
    required this.horaPrevista,
    required this.apartamento,
    this.observacoes = '',
    this.status = 'agendado',
  });

  factory Visita.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Visita(
      id: doc.id,
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      liberacaoEntrada: data['liberacaoEntrada'] ?? false,
      role: data['role'] ?? 'visitante',
      dataPrevista: data['dataPrevista'] ?? '',
      horaPrevista: data['horaPrevista'] ?? '',
      apartamento: data['apartamento'] ?? '',
      observacoes: data['observacoes'] ?? '',
      status: data['status'] ?? 'agendado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'liberacaoEntrada': liberacaoEntrada,
      'role': role,
      'dataPrevista': dataPrevista,
      'horaPrevista': horaPrevista,
      'apartamento': apartamento,
      'observacoes': observacoes,
      'status': status,
    };
  }
}
