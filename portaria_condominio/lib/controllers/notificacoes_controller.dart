import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Obter todas as notificações (usado pelos moradores)
  Stream<List<NotificationModel>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList());
  }
}
