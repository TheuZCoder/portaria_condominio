import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/notificacoes_controller.dart';
import '../../models/notificacao_model.dart';
import '../../controllers/auth_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController = NotificationController();
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
                    Navigator.pushNamed(context, '/notificacoesAdmin');
                  },
                  child: const Icon(Icons.add),
                  tooltip: 'Enviar Notificação',
                )
              : null,
          body: StreamBuilder<List<NotificationModel>>(
            stream: notificationController.getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma notificação disponível.'));
              }

              final notifications = snapshot.data!;

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.description),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
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
