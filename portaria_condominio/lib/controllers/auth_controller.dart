import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna o usuário atual autenticado
  User? get currentUser => _auth.currentUser;

  /// Faz login com email e senha e retorna o tipo de usuário (role)
  Future<String?> signIn(String email, String password) async {
    try {
      // Login no Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter UID do usuário
      String uid = userCredential.user!.uid;

      // Buscar role no Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('moradores').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? 'morador';
      }

      // Caso não seja um morador, verificar se é uma portaria
      userDoc = await _firestore.collection('portarias').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? 'admin';
      }

      // Retornar null se não encontrar o usuário
      return null;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Faz logout do usuário
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  Future<String?> get currentUserRole async {
    final user = currentUser;
    if (user == null) return null;

    final uid = user.uid;

    // Verifica se o usuário é morador
    final moradorDoc = await _firestore.collection('moradores').doc(uid).get();
    if (moradorDoc.exists) {
      return moradorDoc.data()?['role'] ?? 'morador';
    }

    // Verifica se o usuário é da portaria
    final portariaDoc = await _firestore.collection('portarias').doc(uid).get();
    if (portariaDoc.exists) {
      return portariaDoc.data()?['role'] ?? 'portaria';
    }

    return null; // Retorna null se o usuário não estiver registrado
  }
}
