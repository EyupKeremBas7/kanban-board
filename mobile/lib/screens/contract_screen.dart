import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Sözleşme ve Bilgilendirme Ekranı
/// Gizlilik Politikası, Kullanım Koşulları ve Uygulama Bilgileri için ortak şablon.
class ContractScreen extends StatelessWidget {
  final String title;
  final String content;

  const ContractScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                l10n.lastUpdated('10 Mayıs 2026'), // date is still static but the label is localized
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

