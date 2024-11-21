import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Envia uma mensagem para o Firestore
  Future<void> sendMessage(Message message) async {
    try {
      final chatId = _generateChatId(message.senderId, message.receiverId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson());
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  /// Obtém as mensagens de um chat específico
  Stream<List<Message>> getMessages(String userId, String receiverId) {
    final chatId = _generateChatId(userId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromDocument(doc))
            .toList());
  }

  /// Gera um ID único para o chat com base nos dois usuários envolvidos
  String _generateChatId(String userId, String receiverId) {
    return userId.hashCode <= receiverId.hashCode
        ? '$userId\_$receiverId'
        : '$receiverId\_$userId';
  }

  
}
