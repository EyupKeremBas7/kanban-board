import 'package:flutter/material.dart';

/// Planlayıcı ekranı — referans: planlayıcı.jpeg
/// Takvim entegrasyonu, kartları etkinliklere ve odaklanma zamanına bağlama.
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Takvim entegrasyonu ve ViewModel bağlantısı
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planlayıcı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              // TODO: Bugüne git
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Basit takvim başlık alanı
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                Text(
                  '${_monthName(now.month)} ${now.year}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Boş durum
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Planlanmış kart yok',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bitiş tarihi olan kartlarınız burada takvim üzerinde görünecek.',
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
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
