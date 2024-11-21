import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';

class ChatInputField extends StatefulWidget {
  final ChatController chatController;
  final String receiverId;

  const ChatInputField({super.key, required this.chatController, required this.receiverId});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final AuthController _authController = AuthController();

  void _sendMessage() async {
    final String? senderId = _authController.currentUserId;
    if (senderId == null || _controller.text.trim().isEmpty) {
      return; // Não faz nada se o ID do remetente não estiver disponível ou a mensagem estiver vazia
    }

    final message = Message(
      senderId: senderId,
      receiverId: widget.receiverId,
      content: _controller.text.trim(),
      timestamp: DateTime.now(),
    );

    try {
      await widget.chatController.sendMessage(message);
      _controller.clear(); // Limpa o campo de entrada após o envio
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
