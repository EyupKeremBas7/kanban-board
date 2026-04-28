import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/activity_log.dart';
import 'package:mobile/services/api_service.dart';

class ActivityViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ActivityViewModel({required ApiService apiService})
    : _apiService = apiService;

  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Workspace aktiviteleri çek — GET /activity/workspace/{workspace_id}
  Future<void> fetchWorkspaceActivity(String workspaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/activity/workspace/$workspaceId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _logs = items.map((json) => ActivityLog.fromJson(json)).toList();
        _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _errorMessage = 'Aktivite yüklenemedi: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Board aktiviteleri çek — GET /activity/board/{board_id}
  Future<void> fetchBoardActivity(String boardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/activity/board/$boardId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _logs = items.map((json) => ActivityLog.fromJson(json)).toList();
        // En yeni ilk
        _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _errorMessage = 'Aktivite yüklenemedi: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Card aktiviteleri çek — GET /activity/card/{card_id}
  Future<void> fetchCardActivity(String cardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/activity/card/$cardId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _logs = items.map((json) => ActivityLog.fromJson(json)).toList();
        _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _errorMessage = 'Aktivite yüklenemedi: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _logs = [];
    notifyListeners();
  }
}
