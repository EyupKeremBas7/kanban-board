import 'package:flutter/material.dart';

/// Görünüm (Tema) Ayarları Ekranı
class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _themeMode = 'system'; // 'system', 'light', 'dark'
  bool _useHighContrast = false;
  bool _useDynamicColors = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görünüm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tema',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Yeni RadioGroup widget'ı ile sarmalıyoruz
          RadioGroup<String>(
            groupValue: _themeMode,
            onChanged: (val) {
              if (val != null) setState(() => _themeMode = val);
            },
            child: Column(
              children: const [
                RadioListTile<String>(
                  title: Text('Sistem Varsayılanı'),
                  subtitle: Text('Cihazınızın tercihine göre'),
                  value: 'system',
                ),
                RadioListTile<String>(
                  title: Text('Açık Tema'),
                  value: 'light',
                ),
                RadioListTile<String>(
                  title: Text('Koyu Tema'),
                  value: 'dark',
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Text(
            'Erişilebilirlik',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Yüksek Kontrastlı Renkler'),
            subtitle: const Text('Okunabilirliği iyileştir'),
            value: _useHighContrast,
            onChanged: (val) {
              setState(() => _useHighContrast = val);
            },
          ),
          SwitchListTile(
            title: const Text('Dinamik Renkler'),
            subtitle: const Text('Cihaz teması renklerini kullan'),
            value: _useDynamicColors,
            onChanged: (val) {
              setState(() => _useDynamicColors = val);
            },
          ),
        ],
      ),
    );
  }
}