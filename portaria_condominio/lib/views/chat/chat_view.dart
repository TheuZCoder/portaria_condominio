import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/message_model.dart';
import 'chat_input_field.dart';

class ChatView extends StatelessWidget {
  final String receiverId;
  final String receiverName;

  const ChatView({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = ChatController();
    final authController = AuthController();
    final userId = authController.currentUser?.uid;

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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem ainda.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true, // Desative o reverse para exibir em ordem de envio
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByUser = message.senderId == userId;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: isSentByUser
                            ? MainAxisAlignment.end // Mensagem do usuário à direita
                            : MainAxisAlignment.start, // Mensagem recebida à esquerda
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSentByUser
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isSentByUser
                                      ? const Radius.circular(12)
                                      : const Radius.circular(0),
                                  bottomRight: isSentByUser
                                      ? const Radius.circular(0)
                                      : const Radius.circular(12),
                                ),
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
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            chatController: chatController,
            receiverId: receiverId,
          ),
        ],
      ),
    );
  }
}
