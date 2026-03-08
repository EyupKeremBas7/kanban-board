import 'package:flutter/material.dart';

/// Kart detay ekranı
/// Constructor ile cardId alır (Navigator ID taşıma kuralı).
/// Başlık, açıklama, checklist, yorumlar, atama, due date gösterir.
class CardDetailScreen extends StatelessWidget {
  final String cardId;
  final String cardTitle;

  const CardDetailScreen({
    super.key,
    required this.cardId,
    required this.cardTitle,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden CardDetailViewModel'den veri çekilecek
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cardTitle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Kart menüsü
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üye bilgisi
            _buildSection(
              context,
              icon: Icons.person_outline,
              title: 'Üyeler',
              child: const Wrap(
                spacing: 8,
                children: [
                  CircleAvatar(radius: 16, child: Text('EA')),
                  CircleAvatar(radius: 16, child: Text('RO')),
                ],
              ),
            ),
            const Divider(height: 32),

            // Açıklama
            _buildSection(
              context,
              icon: Icons.description_outlined,
              title: 'Açıklama',
              child: Text(
                'Bu kart için henüz bir açıklama eklenmemiş.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
            const Divider(height: 32),

            // Checklist
            _buildSection(
              context,
              icon: Icons.check_box_outlined,
              title: 'Kontrol Listesi',
              child: Column(
                children: [
                  // İlerleme çubuğu
                  Row(
                    children: [
                      const Text('0/9'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.0.clamp(0.0, 1.0),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Mock checklist öğeleri
                  ...List.generate(3, (index) {
                    return CheckboxListTile(
                      value: false,
                      onChanged: (value) {
                        // TODO: ViewModel üzerinden güncelleme
                      },
                      title: Text(
                        'Checklist öğesi ${index + 1}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 32),

            // Due date
            _buildSection(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Bitiş Tarihi',
              child: Text(
                'Belirlenmemiş',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
            const Divider(height: 32),

            // Yorumlar
            _buildSection(
              context,
              icon: Icons.comment_outlined,
              title: 'Yorumlar',
              child: Column(
                children: [
                  // Yorum ekleme alanı
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Yorum yaz...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onSubmitted: (value) {
                      // TODO: ViewModel üzerinden yorum ekleme
                      if (value.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Yorum ekleme yakında')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Mock yorumlar
                  const Text('Henüz yorum yok.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
