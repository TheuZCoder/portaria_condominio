import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portaria_condominio/models/notificacao_model.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Enviar notificação (usado pela portaria)
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _firestore.collection('notifications').add(notification.toJson());
    } catch (e) {
      throw Exception('Erro ao enviar notificação: $e');
    }
  }

  /// Obter todas as notificações para o usuário autenticado
  Stream<List<NotificationModel>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(
          []); // Retorna uma lista vazia se o usuário não estiver autenticado
    }

    return _firestore
        .collection('notifications')
        // .where('userId', isEqualTo: user.uid) // Filtro para o usuário autenticado
        .orderBy('timestamp', descending: true) // Ordena pelas mais recentes
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList());
  }

  /// Obtém o número de notificações não lidas para o usuário autenticado
  Future<int> _getNotificationCount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 0; // Retorna 0 se o usuário não estiver autenticado
    }

    try {
      // Consulta notificações no Firestore com status 'unread' e filtro pelo userId
      final querySnapshot = await _firestore
          .collection('notifications')
          // .where('userId', isEqualTo: user.uid) // Filtro por ID do usuário
          .where('status',
              isEqualTo: 'unread') // Filtro por notificações não lidas
          .get();

      debugPrint(
          'Notificações não lidas para o usuário: ${querySnapshot.size}'); // Log para depuração

      return querySnapshot.size; // Retorna o número de documentos encontrados
    } catch (e) {
      debugPrint('Erro ao buscar notificações: $e');
      return 0; // Retorna 0 em caso de erro
    }
  }

  /// Método público que chama o método privado para obter o contador
  Future<int> fetchNotificationCount() async {
    return await _getNotificationCount();
  }

  /// Atualiza o status da notificação no Firestore
  Future<void> updateNotificationStatus(NotificationModel notification) async {
    try {
      await _firestore.collection('notifications').doc(notification.id).update({
        'status': notification.status,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar o status da notificação: $e');
    }
  }

  /// Obtém um stream que envia a quantidade de notificações não lidas
  Stream<int> getUnreadNotificationCount() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(0); // Retorna 0 se o usuário não estiver autenticado
    }

    // Retorna um stream que emite o número de notificações não lidas em tempo real
    return _firestore
        .collection('notifications')
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .map((snapshot) => snapshot.size); // Conta o número de documentos
  }
}
