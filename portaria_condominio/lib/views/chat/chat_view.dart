import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data/hora
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import 'chat_input_field.dart';

class ChatView extends StatelessWidget {
  final String receiverId;
  final String receiverName;

  const ChatView({super.key, required this.receiverId, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = ChatController();
    final AuthController authController = AuthController();

    final String? userId = authController.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat com $receiverName')),
        body: const Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chat com $receiverName')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatController.getMessages(userId, receiverId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma mensagem ainda.'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByUser = message.senderId == userId;

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isSentByUser
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(message.timestamp),
                              style: TextStyle(
                                color: isSentByUser
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(chatController: chatController, receiverId: receiverId),
        ],
      ),
    );
  }
}