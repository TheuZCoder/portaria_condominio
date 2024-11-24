import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String status;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  /// Converter para JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  /// Criar a partir de um documento do Firestore
  factory NotificationModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      status: data['status'] ?? 'unread',
    );
  }

  // Método copyWith para criar uma nova instância com status alterado
  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? status,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
