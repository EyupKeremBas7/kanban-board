import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/notifications_viewmodel.dart';
import 'package:mobile/domain/models/notification.dart';
import 'package:mobile/utils/enums.dart';

/// Gelen Kutusu (Bildirimler) ekranı
/// Kullanıcının tüm bildirimlerini yönettiği alan.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<NotificationsViewModel>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          Consumer<NotificationsViewModel>(
            builder: (context, vm, child) {
              if (vm.notifications.isEmpty || vm.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Tümünü okundu işaretle',
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final success = await vm.markAllAsRead();
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tümü okundu olarak işaretlendi'),
                            ),
                          );
                        }
                      },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<NotificationsViewModel>().fetchNotifications(),
          ),
        ],
      ),
      body: Consumer<NotificationsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null && vm.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(vm.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => vm.fetchNotifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (vm.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bildiriminiz yok',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tüm gelişmelerden haberdar olduğunuzda burada görünecek.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchNotifications(),
            child: ListView.separated(
              itemCount: vm.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = vm.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.workspaceInvitation:
        return Icons.mail_outline;
      case NotificationType.invitationAccepted:
        return Icons.check_circle_outline;
      case NotificationType.invitationRejected:
        return Icons.cancel_outlined;
      case NotificationType.commentAdded:
        return Icons.comment_outlined;
      case NotificationType.cardAssigned:
        return Icons.person_add_alt_1_outlined;
      case NotificationType.cardDueSoon:
        return Icons.access_time;
      case NotificationType.mentioned:
        return Icons.alternate_email;
      case NotificationType.cardMoved:
        return Icons.compare_arrows;
      case NotificationType.checklistToggled:
        return Icons.checklist;
    }
  }

  Color _getColorForType(BuildContext context, NotificationType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case NotificationType.workspaceInvitation:
      case NotificationType.mentioned:
      case NotificationType.cardAssigned:
        return colors.primary;
      case NotificationType.invitationAccepted:
      case NotificationType.checklistToggled:
        return Colors.green;
      case NotificationType.cardDueSoon:
      case NotificationType.invitationRejected:
        return colors.error;
      case NotificationType.commentAdded:
      case NotificationType.cardMoved:
        return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationsViewModel>().deleteNotification(
          notification.id,
        );
      },
      child: Material(
        color: isRead
            ? Colors.transparent
            : Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: InkWell(
          onTap: () {
            if (!isRead) {
              context.read<NotificationsViewModel>().markAsRead(
                notification.id,
              );
            }
            // İleride referanslara göre navigasyon eklenebilir
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _getColorForType(
                    context,
                    notification.type,
                  ).withValues(alpha: 0.1),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: _getColorForType(context, notification.type),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Az önce';
        }
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
