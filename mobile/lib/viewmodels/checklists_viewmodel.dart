import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/checklist_item.dart';
import 'package:mobile/services/api_service.dart';

class ChecklistsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ChecklistsViewModel({required ApiService apiService})
    : _apiService = apiService;

  List<ChecklistItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChecklistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Karta ait checklist öğelerini çek — GET /checklists/?card_id={id}
  Future<void> fetchItems(String cardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/checklists/?card_id=$cardId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List;
        _items = list.map((json) => ChecklistItem.fromJson(json)).toList();
        _items.sort((a, b) => a.position.compareTo(b.position));
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Checklist yüklenemedi: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checklist öğesi ekle — POST /checklists/
  Future<bool> createItem({
    required String cardId,
    required String title,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      double nextPosition = 65535.0;
      if (_items.isNotEmpty) {
        nextPosition = _items.last.position + 1024.0;
      }

      final body = {
        'card_id': cardId,
        'title': title,
        'position': nextPosition,
      };

      final response = await _apiService.post('/checklists/', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newItem = ChecklistItem.fromJson(data);
        _items.add(newItem);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Öğe eklenemedi.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Checklist öğesi güncelle — PATCH /checklists/{id}
  Future<bool> updateItem({
    required String itemId,
    String? title,
    bool? isCompleted,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (isCompleted != null) body['is_completed'] = isCompleted;

      final response = await _apiService.patch(
        '/checklists/$itemId',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updated = ChecklistItem.fromJson(data);
        final idx = _items.indexWhere((i) => i.id == itemId);
        if (idx != -1) _items[idx] = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Güncelleme başarısız.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Checklist toggle — POST /checklists/{id}/toggle
  Future<bool> toggleItem(String itemId) async {
    try {
      final response = await _apiService.post(
        '/checklists/$itemId/toggle',
        body: {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updated = ChecklistItem.fromJson(data);
        final idx = _items.indexWhere((i) => i.id == itemId);
        if (idx != -1) _items[idx] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      notifyListeners();
      return false;
    }
  }

  /// Checklist öğesi sil — DELETE /checklists/{id}
  Future<bool> deleteItem(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/checklists/$itemId');

      if (response.statusCode == 200) {
        _items.removeWhere((i) => i.id == itemId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Silme başarısız.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _items = [];
    _errorMessage = null;
    notifyListeners();
  }
}
