import 'package:flutter/material.dart';

/// Bildirim Ayarları Ekranı
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enableCardComments = true;
  bool _enableCardAssignments = true;
  bool _enableBoardUpdates = true;
  bool _enableMentions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bildirim Türleri',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Push Bildirimleri'),
            subtitle: const Text('Uygulama içi ve cihaz bildirimleri'),
            value: _enablePushNotifications,
            onChanged: (val) {
              setState(() => _enablePushNotifications = val);
            },
          ),
          SwitchListTile(
            title: const Text('E-posta Bildirimleri'),
            subtitle: const Text('Önemli güncellemelerin e-postası'),
            value: _enableEmailNotifications,
            onChanged: (val) {
              setState(() => _enableEmailNotifications = val);
            },
          ),
          const Divider(height: 24),
          Text(
            'Bildirim Kategor ileri',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Kart Yorumları'),
            subtitle: const Text('Kartlara yorum yapıldığında bilgilendir'),
            value: _enableCardComments,
            onChanged: (val) {
              setState(() => _enableCardComments = val);
            },
          ),
          SwitchListTile(
            title: const Text('Kart Atanması'),
            subtitle: const Text('Sana kart atandığında bilgilendir'),
            value: _enableCardAssignments,
            onChanged: (val) {
              setState(() => _enableCardAssignments = val);
            },
          ),
          SwitchListTile(
            title: const Text('Pano Güncellemeleri'),
            subtitle: const Text('Panonuzdaki önemli değişiklikler'),
            value: _enableBoardUpdates,
            onChanged: (val) {
              setState(() => _enableBoardUpdates = val);
            },
          ),
          SwitchListTile(
            title: const Text('Anılan Bildirimler'),
            subtitle: const Text('Sizi anılanlar için bildirim al'),
            value: _enableMentions,
            onChanged: (val) {
              setState(() => _enableMentions = val);
            },
          ),
        ],
      ),
    );
  }
}
