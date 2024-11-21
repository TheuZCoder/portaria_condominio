import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';

class ChatInputField extends StatefulWidget {
  final ChatController chatController;
  final String receiverId;

  const ChatInputField({
    super.key,
    required this.chatController,
    required this.receiverId,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _messageController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isSending = false;

  void _sendMessage() async {
    final String? senderId = _authController.currentUser as String?;
    final String messageContent = _messageController.text.trim();

    if (senderId == null || messageContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem vazia ou usuário não autenticado.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final message = Message(
      senderId: senderId,
      receiverId: widget.receiverId,
      content: messageContent,
      timestamp: DateTime.now(),
    );

    try {
      await widget.chatController.sendMessage(message);
      _messageController.clear(); // Limpa o campo de entrada após o envio
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
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
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(), // Envia ao pressionar Enter
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isSending ? Icons.hourglass_empty : Icons.send,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
