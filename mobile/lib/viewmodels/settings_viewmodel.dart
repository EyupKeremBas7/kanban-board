import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('tr');

  // Notification Preferences
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _commentsEnabled = true;
  bool _assignmentsEnabled = true;
  bool _boardUpdatesEnabled = true;
  bool _mentionsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get pushEnabled => _pushEnabled;
  bool get emailEnabled => _emailEnabled;
  bool get commentsEnabled => _commentsEnabled;
  bool get assignmentsEnabled => _assignmentsEnabled;
  bool get boardUpdatesEnabled => _boardUpdatesEnabled;
  bool get mentionsEnabled => _mentionsEnabled;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    final themeStr = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == themeStr,
      orElse: () => ThemeMode.system,
    );

    // Locale
    final langCode = prefs.getString('languageCode') ?? 'tr';
    _locale = Locale(langCode);

    // Notifications
    _pushEnabled = prefs.getBool('pushEnabled') ?? true;
    _emailEnabled = prefs.getBool('emailEnabled') ?? true;
    _commentsEnabled = prefs.getBool('commentsEnabled') ?? true;
    _assignmentsEnabled = prefs.getBool('assignmentsEnabled') ?? true;
    _boardUpdatesEnabled = prefs.getBool('boardUpdatesEnabled') ?? true;
    _mentionsEnabled = prefs.getBool('mentionsEnabled') ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushEnabled', value);
    notifyListeners();
  }

  Future<void> setEmailEnabled(bool value) async {
    _emailEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailEnabled', value);
    notifyListeners();
  }

  Future<void> setCommentsEnabled(bool value) async {
    _commentsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('commentsEnabled', value);
    notifyListeners();
  }

  Future<void> setAssignmentsEnabled(bool value) async {
    _assignmentsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('assignmentsEnabled', value);
    notifyListeners();
  }

  Future<void> setBoardUpdatesEnabled(bool value) async {
    _boardUpdatesEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('boardUpdatesEnabled', value);
    notifyListeners();
  }

  Future<void> setMentionsEnabled(bool value) async {
    _mentionsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mentionsEnabled', value);
    notifyListeners();
  }
}
