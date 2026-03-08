import 'package:flutter/material.dart';

/// Hesap (Profil & Ayarlar) ekranı — referans: hesap.jpeg
/// Kullanıcı profili, çalışma alanları, ayarlar.
/// ListView.separated kullanımı (settings pattern — Kural 8).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden AccountViewModel'den veri çekilecek
    final settingsSections = [
      _SettingsSection(
        title: 'Profil',
        items: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Profil Bilgileri',
            subtitle: 'Ad, e-posta, profil fotoğrafı',
          ),
          _SettingsItem(
            icon: Icons.lock_outline,
            title: 'Şifre Değiştir',
          ),
        ],
      ),
      _SettingsSection(
        title: 'Çalışma Alanları',
        items: [
          _SettingsItem(
            icon: Icons.workspaces_outline,
            title: 'DigiNova Staj VISION-B',
            subtitle: 'Yönetici',
          ),
          _SettingsItem(
            icon: Icons.workspaces_outline,
            title: 'NovaVision',
            subtitle: 'Üye',
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
      appBar: AppBar(
        title: const Text('Hesap'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil kartı
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      'EK',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          'Eyüp Kerem Baş',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'eyupkerem@example.com',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            ),
            const Divider(height: 1),

            // Ayarlar bölümleri
            ...settingsSections.map((section) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bölüm başlığı
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        section.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
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
                            // TODO: Ayar detay sayfalarına yönlendirme
                          },
                        );
                      },
                    ),
                  ],
                )),

            const SizedBox(height: 16),

            // Çıkış butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: ViewModel üzerinden çıkış
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış yapılıyor...')),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış Yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.error),
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
}

// Mock veri sınıfları — ViewModel entegrasyonunda kaldırılacak
class _SettingsSection {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
  });
}
