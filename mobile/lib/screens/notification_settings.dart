import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/settings_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Bildirim Ayarları Ekranı
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.notificationTypes,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(l10n.pushNotifications),
                subtitle: Text(l10n.inAppAndDevice),
                value: settingsVM.pushEnabled,
                onChanged: settingsVM.setPushEnabled,
              ),
              SwitchListTile(
                title: Text(l10n.emailNotifications),
                subtitle: Text(l10n.importantUpdatesEmail),
                value: settingsVM.emailEnabled,
                onChanged: settingsVM.setEmailEnabled,
              ),
              const Divider(height: 24),
              Text(
                l10n.notificationCategories,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(l10n.cardComments),
                subtitle: Text(l10n.notifyOnComments),
                value: settingsVM.commentsEnabled,
                onChanged: settingsVM.setCommentsEnabled,
              ),
              SwitchListTile(
                title: Text(l10n.cardAssignments),
                subtitle: Text(l10n.notifyOnAssignments),
                value: settingsVM.assignmentsEnabled,
                onChanged: settingsVM.setAssignmentsEnabled,
              ),
              SwitchListTile(
                title: Text(l10n.boardUpdates),
                subtitle: Text(l10n.importantBoardChanges),
                value: settingsVM.boardUpdatesEnabled,
                onChanged: settingsVM.setBoardUpdatesEnabled,
              ),
              SwitchListTile(
                title: Text(l10n.mentions),
                subtitle: Text(l10n.notifyOnMentions),
                value: settingsVM.mentionsEnabled,
                onChanged: settingsVM.setMentionsEnabled,
              ),
            ],
          );
        },
      ),
    );
  }
}

