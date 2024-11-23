import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  /// Converter para JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Criar a partir de um documento do Firestore
  factory NotificationModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}
