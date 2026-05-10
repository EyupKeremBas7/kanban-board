import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/settings_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Görünüm (Tema ve Dil) Ayarları Ekranı
class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceAndLanguage)),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.theme,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              RadioGroup<ThemeMode>(
                groupValue: settingsVM.themeMode,
                onChanged: (val) {
                  if (val != null) settingsVM.setThemeMode(val);
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.systemDefault),
                      subtitle: Text(l10n.devicePreference),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.lightTheme),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(l10n.darkTheme),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Text(
                l10n.language,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              RadioGroup<Locale>(
                groupValue: settingsVM.locale,
                onChanged: (val) {
                  if (val != null) settingsVM.setLocale(val);
                },
                child: Column(
                  children: [
                    RadioListTile<Locale>(
                      title: Text(l10n.turkish),
                      value: const Locale('tr'),
                    ),
                    RadioListTile<Locale>(
                      title: Text(l10n.english),
                      value: const Locale('en'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Text(
                l10n.accessibility,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(l10n.highContrast),
                subtitle: Text(l10n.improveReadability),
                value: false, // Gelecekte eklenebilir
                onChanged: (val) {
                  // settingsVM.setHighContrast(val);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}