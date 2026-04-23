import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/board_list.dart';
import 'package:mobile/services/api_service.dart';

/// BoardList ViewModel — Pano içi liste yönetimi (Sütunlar).
class ListsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ListsViewModel({required ApiService apiService})
      : _apiService = apiService;

  List<BoardList> _lists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BoardList> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Bir panoya ait listeleri getir — GET /lists/board/{boardId}
  Future<void> fetchLists(String boardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/lists/board/$boardId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final listsData = data['data'] as List<dynamic>;
        
        _lists = listsData
            .map((json) => BoardList.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Pozisyona göre sırala
        _lists.sort((a, b) => a.position.compareTo(b.position));
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Listeler alınamadı';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Yeni liste oluştur — POST /lists/
  Future<bool> createList({
    required String boardId,
    required String name,
    double? position,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Eğer position verilmemişse, en sona ekle (mevcut en büyük position + 65535.0)
      double newPosition = position ?? 65535.0;
      if (position == null && _lists.isNotEmpty) {
        newPosition = _lists.last.position + 65535.0;
      }

      final response = await _apiService.post(
        '/lists/',
        body: {
          'board_id': boardId,
          'name': name,
          'position': newPosition,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newList = BoardList.fromJson(data);
        
        _lists.add(newList);
        _lists.sort((a, b) => a.position.compareTo(b.position));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Liste oluşturulamadı';
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

  /// Reset state (Farklı boarda girildiğinde eski listeleri temizle)
  void clear() {
    _lists = [];
    _errorMessage = null;
    notifyListeners();
  }
}
