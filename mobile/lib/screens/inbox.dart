import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/notifications_viewmodel.dart';
import 'package:mobile/viewmodels/invitations_viewmodel.dart';
import 'package:mobile/domain/models/notification.dart';
import 'package:mobile/domain/models/invitation.dart';
import 'package:mobile/utils/enums.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';

/// Gelen Kutusu (Bildirimler ve Davetler) ekranı
/// Kullanıcının tüm bildirimlerini ve davetiyelerini yönettiği alan.
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
        context.read<InvitationsViewModel>().fetchReceivedInvitations();
        context.read<InvitationsViewModel>().fetchSentInvitations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gelen Kutusu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bildirimler'),
              Tab(text: 'Davetler'),
            ],
          ),
          actions: [
            Consumer<NotificationsViewModel>(
              builder: (context, vm, child) {
                if (vm.notifications.isEmpty || vm.unreadCount == 0) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.done_all),
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
              onPressed: () {
                context.read<NotificationsViewModel>().fetchNotifications();
                context.read<InvitationsViewModel>().fetchReceivedInvitations();
                context.read<InvitationsViewModel>().fetchSentInvitations();
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [_NotificationsTab(), _InvitationsTab()],
        ),
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
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
    );
  }
}

class _InvitationsTab extends StatelessWidget {
  const _InvitationsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<InvitationsViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading &&
            vm.receivedInvitations.isEmpty &&
            vm.sentInvitations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMessage != null &&
            vm.receivedInvitations.isEmpty &&
            vm.sentInvitations.isEmpty) {
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
                  onPressed: () {
                    vm.fetchReceivedInvitations();
                    vm.fetchSentInvitations();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await vm.fetchReceivedInvitations();
            await vm.fetchSentInvitations();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Gelen Davetler',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (vm.receivedInvitations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Bekleyen davetiniz bulunmuyor.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                ...vm.receivedInvitations.map(
                  (inv) => _ReceivedInvitationCard(invitation: inv),
                ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Gönderilen Davetler',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (vm.sentInvitations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Bekleyen gönderilmiş davetiniz bulunmuyor.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                ...vm.sentInvitations.map(
                  (inv) => _SentInvitationCard(invitation: inv),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReceivedInvitationCard extends StatelessWidget {
  final Invitation invitation;

  const _ReceivedInvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<InvitationsViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.workspaces),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.workspaceName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Davet eden: ${invitation.inviterName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.respondToInvitation(
                            invitation.id,
                            false,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Davet reddedildi'
                                      : (vm.errorMessage ?? 'Hata'),
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('Reddet'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.respondToInvitation(
                            invitation.id,
                            true,
                          );
                          if (context.mounted) {
                            if (success) {
                              context
                                  .read<WorkspacesViewModel>()
                                  .fetchWorkspaces();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Davet kabul edildi'
                                      : (vm.errorMessage ?? 'Hata'),
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('Kabul Et'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SentInvitationCard extends StatelessWidget {
  final Invitation invitation;

  const _SentInvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<InvitationsViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.mail_outline),
        ),
        title: Text(invitation.inviteeEmail),
        subtitle: Text('Çalışma Alanı: ${invitation.workspaceName}'),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: vm.isLoading
              ? null
              : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Daveti İptal Et'),
                      content: const Text(
                        'Bu daveti iptal etmek istediğinize emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hayır'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                          child: const Text('Evet, İptal Et'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    final success = await vm.cancelInvitation(invitation.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Davet iptal edildi'
                                : (vm.errorMessage ?? 'Hata'),
                          ),
                        ),
                      );
                    }
                  }
                },
        ),
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
