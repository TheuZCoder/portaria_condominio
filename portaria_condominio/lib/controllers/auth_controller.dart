import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna o usuário atual autenticado
  User? get currentUser => _auth.currentUser;

  /// Retorna o UID do usuário atual
  String? get currentUserId => _auth.currentUser?.uid;

  /// Faz login com email e senha
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
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

  /// Registra um novo usuário (opcional)
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }
}
