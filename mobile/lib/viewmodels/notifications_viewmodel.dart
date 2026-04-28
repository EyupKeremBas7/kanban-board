import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/notification.dart';
import 'package:mobile/services/api_service.dart';

/// Notifications ViewModel — Bildirim listesi yönetimi.
/// Provider (ChangeNotifier) ile state yönetimi (MVVM — Kural 5).
class NotificationsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  NotificationsViewModel({required ApiService apiService})
    : _apiService = apiService;

  // State
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Bildirimleri getir — GET /notifications/
  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParam = unreadOnly ? '?unread_only=true' : '';
      final response = await _apiService.get('/notifications/$queryParam');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final notificationsList = data['data'] as List<dynamic>;
        _notifications = notificationsList
            .map(
              (json) => AppNotification.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        _unreadCount = data['unread_count'] as int? ?? 0;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Bildirimler alınamadı';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Okunmamış bildirim sayısını getir — GET /notifications/unread-count
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _unreadCount = data['unread_count'] as int? ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Okunmamış sayı alınamadı: $e');
    }
  }

  /// Bildirimi okundu işaretle — PUT /notifications/{id}/read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _apiService.put('/notifications/$id/read');

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1 && !_notifications[index].isRead) {
          final oldNotif = _notifications[index];
          _notifications[index] = AppNotification(
            id: oldNotif.id,
            userId: oldNotif.userId,
            type: oldNotif.type,
            title: oldNotif.title,
            message: oldNotif.message,
            isRead: true,
            referenceId: oldNotif.referenceId,
            referenceType: oldNotif.referenceType,
            createdAt: oldNotif.createdAt,
          );
          if (_unreadCount > 0) _unreadCount--;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Bildirim okundu işaretlenemedi: $e');
      return false;
    }
  }

  /// Tüm bildirimleri okundu işaretle — PUT /notifications/read-all
  Future<bool> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/notifications/read-all');

      if (response.statusCode == 200) {
        for (int i = 0; i < _notifications.length; i++) {
          final oldNotif = _notifications[i];
          if (!oldNotif.isRead) {
            _notifications[i] = AppNotification(
              id: oldNotif.id,
              userId: oldNotif.userId,
              type: oldNotif.type,
              title: oldNotif.title,
              message: oldNotif.message,
              isRead: true,
              referenceId: oldNotif.referenceId,
              referenceType: oldNotif.referenceType,
              createdAt: oldNotif.createdAt,
            );
          }
        }
        _unreadCount = 0;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Tümü okundu işaretlenemedi: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Bildirimi sil — DELETE /notifications/{id}
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _apiService.delete('/notifications/$id');

      if (response.statusCode == 200) {
        final notif = _notifications.firstWhere((n) => n.id == id);
        if (!notif.isRead && _unreadCount > 0) {
          _unreadCount--;
        }
        _notifications.removeWhere((n) => n.id == id);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Silme başarısız';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      notifyListeners();
      return false;
    }
  }
}
