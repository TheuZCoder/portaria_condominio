import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/notificacoes_controller.dart';
import '../../models/notificacao_model.dart';
import '../../controllers/auth_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  // Método para abrir o pop-up de envio de notificação
  void _showNotificationDialog(
      BuildContext context, NotificationController notificationController) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enviar Notificação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;

                if (title.isNotEmpty && description.isNotEmpty) {
                  final notification = NotificationModel(
                    id: '',
                    title: title,
                    description: description,
                    timestamp: DateTime.now(),
                    status: 'unread', // Definindo o status como 'não lido'
                  );

                  // Enviar a notificação
                  await notificationController.sendNotification(notification);
                  Navigator.pop(context); // Fechar o diálogo após enviar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notificação enviada com sucesso!')),
                  );
                } else {
                  // Exibir erro se os campos estiverem vazios
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, preencha todos os campos!')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  // Método para alternar o status da notificação
  void _toggleReadStatus(
      BuildContext context,
      NotificationController notificationController,
      NotificationModel notification) async {
    final updatedStatus = notification.status == 'unread' ? 'read' : 'unread';
    final updatedNotification = notification.copyWith(status: updatedStatus);

    await notificationController.updateNotificationStatus(updatedNotification);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificação marcada como $updatedStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        NotificationController();
    final AuthController authController = AuthController();

    return FutureBuilder<String?>(
      future: authController.currentUserRole,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userRole = snapshot.data;

        return Scaffold(
          appBar: AppBar(title: const Text('Notificações')),
          floatingActionButton: userRole == 'portaria'
              ? FloatingActionButton(
                  onPressed: () {
                    _showNotificationDialog(context,
                        notificationController); // Chama o pop-up de notificação
                  },
                  tooltip: 'Enviar Notificação',
                  child: const Icon(Icons.add),
                )
              : null,
          body: StreamBuilder<List<NotificationModel>>(
            stream: notificationController.getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('Nenhuma notificação disponível.'));
              }

              final notifications = snapshot.data!;

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.description),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(notification.timestamp),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          notification.status == 'unread'
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread,
                          color: notification.status == 'unread'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleReadStatus(
                              context, notificationController, notification);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
