import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/morador_model.dart';

class MoradorController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _moradoresCollection =
      FirebaseFirestore.instance.collection('moradores');

  /// **CREATE** - Adicionar um novo morador no Firestore e Firebase Authentication
  Future<void> cadastrarMorador(Morador morador) async {
    try {
      // Criar o usuário no Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: morador.email,
        password: morador.senha,
      );

      // Obter o UID do usuário criado
      String uid = userCredential.user!.uid;

      // Salvar os dados no Firestore
      await _moradoresCollection.doc(uid).set({
        ...morador.toJson(),
        'id': uid,
      });
    } catch (e) {
      throw Exception('Erro ao criar morador: $e');
    }
  }

  /// **READ** - Buscar um morador pelo ID (UID do Firebase Authentication)
  Future<Morador?> buscarMorador(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _moradoresCollection
          .doc(id)
          .get() as DocumentSnapshot<Map<String, dynamic>>;

      if (doc.exists) {
        return Morador.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar morador: $e');
    }
  }

  /// **READ** - Buscar todos os moradores
  Future<List<Morador>> buscarTodosMoradores() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _moradoresCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      return snapshot.docs
          .map((doc) => Morador.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar moradores: $e');
    }
  }

  /// **UPDATE** - Atualizar os dados de um morador
  Future<void> atualizarMorador(Morador morador) async {
    try {
      await _moradoresCollection.doc(morador.id).update(morador.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar morador: $e');
    }
  }

  /// **DELETE** - Excluir um morador
  Future<void> excluirMorador(String id) async {
    try {
      // Excluir do Firestore
      await _moradoresCollection.doc(id).delete();

      // Tentar excluir do Firebase Authentication se o usuário existir
      try {
        User? user = _auth.currentUser;
        if (user != null && user.uid == id) {
          await user.delete();
        }
      } catch (authError) {
        print('Aviso: Não foi possível excluir o usuário do Authentication: $authError');
      }
    } catch (e) {
      throw Exception('Erro ao excluir morador: $e');
    }
  }

  /// **LOGIN** - Autenticar um morador usando email e senha
  Future<User?> loginMorador(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// **LOGOUT** - Sair do Firebase Authentication
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}
