import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:mobile/screens/profile_edit.dart';
import 'package:mobile/screens/change_password.dart';
import 'package:mobile/screens/workspaces.dart';
import 'package:mobile/screens/splash.dart';

/// Hesap (Profil & Ayarlar) ekranı — referans: hesap.jpeg
/// AuthViewModel üzerinden gerçek kullanıcı verisi gösterir.
/// ListView.separated kullanımı (settings pattern — Kural 8).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsSections = [
      _SettingsSection(
        title: 'Profil',
        items: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Profil Bilgileri',
            subtitle: 'Ad, e-posta, profil fotoğrafı',
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
            title: 'Şifre Değiştir',
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
        title: 'Çalışma Alanları',
        items: [
          _SettingsItem(
            icon: Icons.workspaces_outline,
            title: 'Çalışma Alanlarını Yönet',
            subtitle: 'Oluştur, düzenle, sil',
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
        title: 'Tercihler',
        items: [
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Bildirim Ayarları',
          ),
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            title: 'Görünüm',
            subtitle: 'Sistem varsayılanı',
          ),
          _SettingsItem(
            icon: Icons.language_outlined,
            title: 'Dil',
            subtitle: 'Türkçe',
          ),
        ],
      ),
      _SettingsSection(
        title: 'Hakkında',
        items: [
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'Uygulama Bilgileri',
            subtitle: 'Sürüm 1.0.0',
          ),
          _SettingsItem(
            icon: Icons.description_outlined,
            title: 'Kullanım Koşulları',
          ),
          _SettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hesap')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil kartı — AuthViewModel'den gerçek veri
            Consumer<AuthViewModel>(
              builder: (context, authVM, child) {
                final user = authVM.currentUser;
                final displayName = user?.fullName ?? 'Kullanıcı';
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
                  label: const Text('Çıkış Yap'),
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
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Hesabı Sil'),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınız kalıcı olarak silinecektir. '
          'Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
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
                      authVM.errorMessage ?? 'Hesap silme başarısız',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hesabı Sil'),
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
