import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/board.dart';
import 'package:mobile/services/api_service.dart';

/// Boards ViewModel — Pano listesi yönetimi.
/// Provider (ChangeNotifier) ile state yönetimi (MVVM — Kural 5).
class BoardsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  BoardsViewModel({required ApiService apiService})
      : _apiService = apiService;

  // State
  List<Board> _boards = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Board> get boards => _boards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Board listesini API'den çek — GET /boards
  Future<void> fetchBoards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/boards');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final boardsList = data['data'] as List<dynamic>;
        _boards = boardsList
            .map((json) => Board.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Board listesi alınamadı';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
