import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prestador_model.dart';

class PrestadorController {
  // Referência à coleção 'prestadores' no Firestore
  final CollectionReference _prestadoresCollection =
      FirebaseFirestore.instance.collection('prestadores');

  /// **CREATE** - Adicionar um novo prestador no Firestore
  Future<void> criarPrestador(Prestador prestador) async {
    try {
      await _prestadoresCollection.add(prestador.toJson());
    } catch (e) {
      throw Exception('Erro ao criar prestador: $e');
    }
  }

  Future<void> criarSolicitacao(Prestador prestador) async {
    final CollectionReference solicitacoesCollection =
        FirebaseFirestore.instance.collection('solicitacoes');

    try {
      // Criar uma solicitação com status "pendente"
      await solicitacoesCollection.add({
        'nome': prestador.nome,
        'cpf': prestador.cpf,
        'empresa': prestador.empresa,
        'telefone': prestador.telefone,
        'email': prestador.email,
        'senha': prestador.senha,
        'liberacaoCadastro': prestador.liberacaoCadastro,
        'role': prestador.role,
      });
    } catch (e) {
      throw Exception('Erro ao criar solicitação de acesso: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listarSolicitacoesPendentes() async {
    final CollectionReference solicitacoesCollection =
        FirebaseFirestore.instance.collection('solicitacoes');

    try {
      QuerySnapshot<Object?> snapshot = await solicitacoesCollection
          .where('liberacaoCadastro', isEqualTo: 'false')
          .get();

      // Retorna uma lista de mapas contendo as solicitações
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
          'cpf': doc['cpf'],
          'empresa': doc['empresa'],
          'telefone': doc['telefone'],
          'email': doc['email'],
          'senha': doc['senha'],
          'liberacaoCadastro': doc['liberacaoCadastro'],
          'role': doc['role'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Erro ao listar solicitações pendentes: $e');
    }
  }

  Future<void> avaliarSolicitacao(String solicitacaoId, String status,
      {String? portariaId}) async {
    final CollectionReference solicitacoesCollection =
        FirebaseFirestore.instance.collection('solicitacoes');

    try {
      // Atualizar o status da solicitação (aprovado ou rejeitado)
      await solicitacoesCollection.doc(solicitacaoId).update({
        'liberacaoCadastro': status == 'aprovado' ? true : false,
        'portariaId': portariaId, // ID da portaria que avaliou (opcional)
      });

      // Se aprovado, criar o prestador na coleção 'prestadores'
      if (status == 'aprovado') {
        DocumentSnapshot<Object?> solicitacao =
            await solicitacoesCollection.doc(solicitacaoId).get();

        final prestador = Prestador(
          id: '',
          nome: solicitacao['nome'],
          cpf: solicitacao['cpf'],
          empresa: solicitacao['empresa'],
          telefone: solicitacao['telefone'],
          email: solicitacao['email'],
          senha: solicitacao['senha'],
          liberacaoCadastro: true,
          role: solicitacao['role'],
        );

        await criarPrestador(prestador);
      }
    } catch (e) {
      throw Exception('Erro ao avaliar solicitação: $e');
    }
  }

  /// **READ** - Buscar um prestador pelo ID
  Future<Prestador?> buscarPrestador(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('prestador')
          .doc(id)
          .get();

      if (doc.exists) {
        return Prestador.fromDocument(doc);
      }
      return null; // Retorna null se o documento não existir
    } catch (e) {
      throw Exception('Erro ao buscar prestador: $e');
    }
  }

  /// **READ** - Buscar todos os prestadores
  Future<List<Prestador>> buscarTodosPrestadores() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('prestador').get();

      return snapshot.docs.map((doc) => Prestador.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar prestadores: $e');
    }
  }

  /// **UPDATE** - Atualizar os dados de um prestador no Firestore
  Future<void> atualizarPrestador(Prestador prestador) async {
    try {
      await _prestadoresCollection.doc(prestador.id).update(prestador.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar prestador: $e');
    }
  }

  /// **DELETE** - Excluir um prestador pelo ID
  Future<void> excluirPrestador(String id) async {
    try {
      await _prestadoresCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir prestador: $e');
    }
  }
}
