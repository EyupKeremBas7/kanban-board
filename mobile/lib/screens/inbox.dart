import 'package:flutter/material.dart';

/// Gelen Kutusu ekranı — referans: gelen-kutusu.jpeg
/// Kişisel inbox, hızlı kart ekleme alanı.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden InboxViewModel'den veri çekilecek
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Kutusu'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Gelen kutunuz boş',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Size atanan kartlar ve bildirimler burada görünecek.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
