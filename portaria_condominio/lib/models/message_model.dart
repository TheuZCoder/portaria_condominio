import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  /// Converter mensagem em JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Criar uma mensagem a partir de um documento Firestore
  factory Message.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      content: data['content'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}
