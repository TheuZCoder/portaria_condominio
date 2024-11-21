import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatController {
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  /// Enviar uma mensagem
  Future<void> sendMessage(Message message) async {
    try {
      await _messagesCollection.add(message.toJson());
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  /// Obter mensagens entre dois usuários
  Stream<List<Message>> getMessages(String userId, String contactId) {
    return _messagesCollection
        .where('senderId', whereIn: [userId, contactId])
        .where('receiverId', whereIn: [userId, contactId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromDocument(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    });
  }
}
