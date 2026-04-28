import 'package:flutter/material.dart';

/// Etkinlik (Bildirimler) ekranı — referans: etkinlik.jpeg
/// Bildirim listesi, tür filtreleme, okunmamış filtresi.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden ActivityViewModel'den veri çekilecek
    // Şimdilik mock veri
    final mockNotifications = [
      _MockNotification(
        title: 'Kart atandı',
        message: 'NV - Pose Estimation kartı size atandı',
        timeAgo: '2 saat önce',
        isRead: false,
        icon: Icons.assignment_ind,
      ),
      _MockNotification(
        title: 'Yeni yorum',
        message: 'Eyüp yorum ekledi: "API entegrasyonunu tamamladım"',
        timeAgo: '5 saat önce',
        isRead: true,
        icon: Icons.comment,
      ),
      _MockNotification(
        title: 'Bitiş tarihi yaklaşıyor',
        message: 'NV - Heat Map kartının bitiş tarihi yarın',
        timeAgo: '1 gün önce',
        isRead: true,
        icon: Icons.schedule,
      ),
    ];

    final filteredNotifications = _showUnreadOnly
        ? mockNotifications.where((n) => !n.isRead).toList()
        : mockNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik'),
        actions: [
          FilterChip(
            label: const Text('Okunmamış'),
            selected: _showUnreadOnly,
            onSelected: (value) {
              setState(() => _showUnreadOnly = value);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: filteredNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bildirim yok',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredNotifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      notification.icon,
                      color: notification.isRead
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    notification.message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  trailing: Text(
                    notification.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    // TODO: Bildirime tıklayınca ilgili karta git
                  },
                );
              },
            ),
    );
  }
}

// Mock veri sınıfı — ViewModel entegrasyonunda kaldırılacak
class _MockNotification {
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final IconData icon;
  const _MockNotification({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isRead,
    required this.icon,
  });
}
