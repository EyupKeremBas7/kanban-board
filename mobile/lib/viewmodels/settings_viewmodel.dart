import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  final ApiService? _apiService;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('tr');
  bool _highContrastEnabled = false;

  // Notification Preferences
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _commentsEnabled = true;
  bool _assignmentsEnabled = true;
  bool _boardUpdatesEnabled = true;
  bool _mentionsEnabled = true;
  bool _isLoadingNotificationPreferences = false;
  bool _isSavingNotificationPreferences = false;
  bool _notificationPreferencesLoaded = false;
  String? _notificationSettingsError;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get pushEnabled => _pushEnabled;
  bool get emailEnabled => _emailEnabled;
  bool get commentsEnabled => _commentsEnabled;
  bool get assignmentsEnabled => _assignmentsEnabled;
  bool get boardUpdatesEnabled => _boardUpdatesEnabled;
  bool get mentionsEnabled => _mentionsEnabled;
  bool get isLoadingNotificationPreferences =>
      _isLoadingNotificationPreferences;
  bool get isSavingNotificationPreferences => _isSavingNotificationPreferences;
  String? get notificationSettingsError => _notificationSettingsError;

  SettingsViewModel({ApiService? apiService}) : _apiService = apiService {
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
    _locale = langCode == 'en' ? const Locale('en') : const Locale('tr');

    // Accessibility
    _highContrastEnabled = prefs.getBool('highContrastEnabled') ?? false;

    // Notifications
    _pushEnabled = prefs.getBool('pushEnabled') ?? true;
    _emailEnabled = prefs.getBool('emailEnabled') ?? true;
    _commentsEnabled = prefs.getBool('commentsEnabled') ?? true;
    _assignmentsEnabled = prefs.getBool('assignmentsEnabled') ?? true;
    _boardUpdatesEnabled = prefs.getBool('boardUpdatesEnabled') ?? true;
    _mentionsEnabled = prefs.getBool('mentionsEnabled') ?? true;

    notifyListeners();
  }

  Future<void> fetchNotificationPreferences({bool force = false}) async {
    if (_apiService == null) return;
    if (_notificationPreferencesLoaded && !force) return;

    _isLoadingNotificationPreferences = true;
    _notificationSettingsError = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/notifications/preferences');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _applyRemoteNotificationPreferences(data);
        _notificationPreferencesLoaded = true;
      } else {
        _notificationSettingsError = 'Bildirim tercihleri alınamadı.';
      }
    } catch (_) {
      _notificationSettingsError = 'Bildirim tercihleri alınamadı.';
    } finally {
      _isLoadingNotificationPreferences = false;
      notifyListeners();
    }
  }

  Future<void> _applyRemoteNotificationPreferences(
    Map<String, dynamic> data,
  ) async {
    _pushEnabled = data['in_app_enabled'] as bool? ?? _pushEnabled;
    _emailEnabled = data['email_enabled'] as bool? ?? _emailEnabled;
    _commentsEnabled = data['comments_enabled'] as bool? ?? _commentsEnabled;
    _assignmentsEnabled =
        data['assignments_enabled'] as bool? ?? _assignmentsEnabled;
    final cardMovesEnabled =
        data['card_moves_enabled'] as bool? ?? _boardUpdatesEnabled;
    final checklistEnabled =
        data['checklist_enabled'] as bool? ?? _boardUpdatesEnabled;
    _boardUpdatesEnabled = cardMovesEnabled && checklistEnabled;
    _mentionsEnabled = data['mentions_enabled'] as bool? ?? _mentionsEnabled;
    await _persistNotificationSettings();
  }

  Future<void> _persistNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushEnabled', _pushEnabled);
    await prefs.setBool('emailEnabled', _emailEnabled);
    await prefs.setBool('commentsEnabled', _commentsEnabled);
    await prefs.setBool('assignmentsEnabled', _assignmentsEnabled);
    await prefs.setBool('boardUpdatesEnabled', _boardUpdatesEnabled);
    await prefs.setBool('mentionsEnabled', _mentionsEnabled);
  }

  Future<void> _updateRemoteNotificationPreferences(
    Map<String, dynamic> body,
  ) async {
    if (_apiService == null) return;

    _isSavingNotificationPreferences = true;
    _notificationSettingsError = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '/notifications/preferences',
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _applyRemoteNotificationPreferences(data);
        _notificationPreferencesLoaded = true;
      } else {
        _notificationSettingsError = 'Bildirim tercihi kaydedilemedi.';
      }
    } catch (_) {
      _notificationSettingsError = 'Bildirim tercihi kaydedilemedi.';
    } finally {
      _isSavingNotificationPreferences = false;
      notifyListeners();
    }
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
    _locale = locale.languageCode == 'en'
        ? const Locale('en')
        : const Locale('tr');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _locale.languageCode);
    notifyListeners();
  }

  Future<void> setHighContrastEnabled(bool value) async {
    if (_highContrastEnabled == value) return;
    _highContrastEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrastEnabled', value);
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
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({'in_app_enabled': value});
  }

  Future<void> setEmailEnabled(bool value) async {
    _emailEnabled = value;
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({'email_enabled': value});
  }

  Future<void> setCommentsEnabled(bool value) async {
    _commentsEnabled = value;
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({'comments_enabled': value});
  }

  Future<void> setAssignmentsEnabled(bool value) async {
    _assignmentsEnabled = value;
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({'assignments_enabled': value});
  }

  Future<void> setBoardUpdatesEnabled(bool value) async {
    _boardUpdatesEnabled = value;
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({
      'card_moves_enabled': value,
      'checklist_enabled': value,
    });
  }

  Future<void> setMentionsEnabled(bool value) async {
    _mentionsEnabled = value;
    await _persistNotificationSettings();
    notifyListeners();
    await _updateRemoteNotificationPreferences({'mentions_enabled': value});
  }
}
