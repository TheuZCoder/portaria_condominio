import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus {
  sent,     // Mensagem enviada
  delivered, // Mensagem entregue ao dispositivo
  read      // Mensagem lida
}

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  /// Converter mensagem em JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
    };
  }

  /// Criar uma mensagem a partir de um documento Firestore
  factory Message.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Message(
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] is Timestamp 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      status: MessageStatus.values[data['status'] ?? 0],
    );
  }
}
