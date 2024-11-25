import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/notificacoes_controller.dart';
import '../../models/notificacao_model.dart';
import '../../controllers/auth_controller.dart';
import '../../localizations/app_localizations.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with TickerProviderStateMixin {
  final NotificationController _controller = NotificationController();
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<int, AnimationController> _animationControllers = {};
  late Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _controller.getNotifications();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getAnimationController(int index) {
    if (!_animationControllers.containsKey(index)) {
      _animationControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    return _animationControllers[index]!;
  }

  void _showNotificationDialog() {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isLoading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: localizations.translate('send_notification'),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: Dialog.fullscreen(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(localizations.translate('new_notification')),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      FilledButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  try {
                                    final notification = NotificationModel(
                                      id: '',
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      timestamp: DateTime.now(),
                                      status: 'unread',
                                    );

                                    await _controller.sendNotification(notification);
                                    
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: colorScheme.onSecondaryContainer,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  localizations.translate('notification_sent'),
                                                  style: TextStyle(
                                                    color: colorScheme.onSecondaryContainer,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: colorScheme.secondaryContainer,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: colorScheme.onErrorContainer,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  '${localizations.translate('error')}: $e',
                                                  style: TextStyle(
                                                    color: colorScheme.onErrorContainer,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: colorScheme.errorContainer,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                }
                              },
                        icon: isLoading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(isLoading
                            ? localizations.translate('sending')
                            : localizations.translate('send')),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: localizations.translate('title'),
                              prefixIcon: const Icon(Icons.title),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate('fill_all_fields');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: localizations.translate('description'),
                              prefixIcon: const Icon(Icons.description),
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate('fill_all_fields');
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleReadStatus(NotificationModel notification) async {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final updatedStatus = notification.status == 'unread' ? 'read' : 'unread';
    final updatedNotification = notification.copyWith(status: updatedStatus);

    try {
      await _controller.updateNotificationStatus(updatedNotification);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  updatedStatus == 'read'
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.translate(
                      updatedStatus == 'read'
                          ? 'notification_marked_as_read'
                          : 'notification_marked_as_unread',
                    ),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${localizations.translate('error')}: $e',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String?>(
      future: _authController.currentUserRole,
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          );
        }

        final userRole = roleSnapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.translate('notifications')),
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButton: userRole == 'portaria'
              ? FloatingActionButton.extended(
                  onPressed: _showNotificationDialog,
                  tooltip: localizations.translate('add_notification'),
                  icon: const Icon(Icons.add),
                  label: Text(localizations.translate('add_notification')),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  elevation: 2,
                  highlightElevation: 4,
                )
              : null,
          body: StreamBuilder<List<NotificationModel>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${localizations.translate('error')}: ${snapshot.error}',
                    style: TextStyle(color: colorScheme.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('no_notifications'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                );
              }

              final notifications = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isUnread = notification.status == 'unread';
                  final controller = _getAnimationController(index);

                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final elevationAnimation = Tween<double>(
                        begin: 1,
                        end: 8,
                      ).animate(
                        CurvedAnimation(
                          parent: controller,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return Card(
                        elevation: elevationAnimation.value,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isUnread
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          onTap: () {
                            if (isUnread) {
                              _toggleReadStatus(notification);
                            }
                          },
                          onHover: (hovering) {
                            if (hovering) {
                              controller.forward();
                            } else {
                              controller.reverse();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isUnread
                                              ? colorScheme.onSurfaceVariant
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isUnread
                                            ? Icons.mark_email_read
                                            : Icons.mark_email_unread,
                                        color: isUnread
                                            ? colorScheme.primary
                                            : colorScheme.outline,
                                      ),
                                      onPressed: () => _toggleReadStatus(notification),
                                      tooltip: localizations.translate(
                                        isUnread
                                            ? 'mark_as_read'
                                            : 'mark_as_unread',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification.description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isUnread
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: colorScheme.outline,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(notification.timestamp),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
