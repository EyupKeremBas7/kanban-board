import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:mobile/screens/profile_edit.dart';
import 'package:mobile/screens/change_password.dart';
import 'package:mobile/screens/workspaces.dart';
import 'package:mobile/screens/splash.dart';
import 'package:mobile/screens/contract_screen.dart';
import 'package:mobile/screens/notification_settings.dart';
import 'package:mobile/screens/appearance_settings.dart';
import 'package:mobile/viewmodels/settings_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Hesap (Profil & Ayarlar) ekranı — referans: hesap.jpeg
/// AuthViewModel üzerinden gerçek kullanıcı verisi gösterir.
/// ListView.separated kullanımı (settings pattern — Kural 8).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsVM = context.watch<SettingsViewModel>();
    final themeLabel = switch (settingsVM.themeMode) {
      ThemeMode.light => l10n.light,
      ThemeMode.dark => l10n.dark,
      ThemeMode.system => l10n.system,
    };
    final languageLabel =
        settingsVM.locale.languageCode == 'tr' ? l10n.turkish : l10n.english;
    final appearanceSubtitle = settingsVM.highContrastEnabled
        ? '$themeLabel · $languageLabel · ${l10n.highContrast}'
        : '$themeLabel · $languageLabel';
    final settingsSections = [
      _SettingsSection(
        title: l10n.editProfile,
        items: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: l10n.profileInfo,
            subtitle: l10n.profileInfoSubtitle,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
      _SettingsSection(
        title: l10n.workspaces,
        items: [
          _SettingsItem(
            icon: Icons.workspaces_outline,
            title: l10n.manageWorkspaces,
            subtitle: l10n.manageWorkspacesSubtitle,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const WorkspacesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      _SettingsSection(
        title: l10n.settings,
        items: [
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: l10n.appearanceAndLanguage,
            subtitle: appearanceSubtitle,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const AppearanceSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      _SettingsSection(
        title: l10n.about,
        items: [
          _SettingsItem(
            icon: Icons.info_outline,
            title: l10n.appInfo,
            subtitle: l10n.version('1.0.0'),
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => ContractScreen(
                    title: l10n.appInfo,
                    content:
                        '${l10n.appDescription}\n\n${l10n.developerLabel('Eyüp Kerem Baş')}\n${l10n.version('1.0.0')}\n${l10n.licenseLabel('MIT')}',
                  ),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => ContractScreen(
                    title: l10n.termsOfService,
                    content:
                        '${l10n.termsContent1}\n${l10n.termsContent2}\n${l10n.termsContent3}\n${l10n.termsContent4}\n\n${l10n.termsFooter}',
                  ),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: (ctx) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (context) => ContractScreen(
                    title: l10n.privacyPolicy,
                    content:
                        '${l10n.privacyContent}\n\n${l10n.whatDataCollect}\n${l10n.dataEmail}\n${l10n.dataFullName}\n${l10n.dataContent}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil kartı — AuthViewModel'den gerçek veri
            Consumer<AuthViewModel>(
              builder: (context, authVM, child) {
                final user = authVM.currentUser;
                final displayName = user?.fullName ?? l10n.username; // or user
                final email = user?.email ?? '';
                // İsmin baş harflerini al (nullable-safe)
                final initials = displayName
                    .split(' ')
                    .where((s) => s.isNotEmpty)
                    .take(2)
                    .map((s) => s[0].toUpperCase())
                    .join();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          initials.isNotEmpty ? initials : '?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1),

            // Ayarlar bölümleri
            ...settingsSections.map(
              (section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bölüm başlığı
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Bölüm öğeleri — ListView.separated (settings pattern)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: section.items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      final item = section.items[index];
                      return ListTile(
                        leading: Icon(item.icon),
                        title: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          if (item.onTap != null) {
                            item.onTap!(context);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Çıkış butonu — AuthViewModel.logout() çağırır
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authVM = context.read<AuthViewModel>();
                    await authVM.logout();

                    if (!context.mounted) return;

                    // Splash'a geri dön, tüm stack temizle
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hesabı Sil butonu — soft delete, onay dialogu ile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, l10n),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(l10n.deleteAccount),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authVM = context.read<AuthViewModel>();
              final success = await authVM.deleteAccount();

              if (!context.mounted) return;

              if (success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authVM.errorMessage ?? l10n.deleteAccountFailed,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }
}

// Yardımcı veri sınıfları (settings pattern)
class _SettingsSection {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final void Function(BuildContext)? onTap;
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
