import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/board.dart';
import 'package:mobile/domain/models/workspace.dart';
import 'package:mobile/services/api_service.dart';

/// Boards ViewModel — Pano listesi yönetimi.
/// Provider (ChangeNotifier) ile state yönetimi (MVVM — Kural 5).
class BoardsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  BoardsViewModel({required ApiService apiService}) : _apiService = apiService;

  // State
  List<Board> _boards = [];
  List<Workspace> _workspaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Board> get boards => _boards;
  List<Workspace> get workspaces => _workspaces;
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

  /// Workspace listesini API'den çek — GET /workspaces
  /// (Board oluştururken workspace seçimi için gerekli)
  Future<void> fetchWorkspaces() async {
    try {
      final response = await _apiService.get('/workspaces');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final wsList = data['data'] as List<dynamic>;
        _workspaces = wsList
            .map((json) => Workspace.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Workspace listesi alınamadı: $e');
    }
  }

  /// Yeni Board oluştur — POST /boards
  Future<bool> createBoard({
    required String name,
    required String workspaceId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/boards/',
        body: {'name': name, 'workspace_id': workspaceId},
      );

      if (response.statusCode == 200) {
        // Yeni board oluşturuldu, listeye ekle
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newBoard = Board.fromJson(data);
        _boards.insert(0, newBoard); // Başa ekle

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Pano oluşturulamadı';
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

  /// Pano Güncelleme — PUT /boards/{id}
  Future<bool> updateBoard({
    required String boardId,
    String? name,
    String? visibility,
    String? backgroundImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (visibility != null) body['visibility'] = visibility;
      if (backgroundImage != null) body['background_image'] = backgroundImage;

      final response = await _apiService.put('/boards/$boardId', body: body);

      if (response.statusCode == 200) {
        // Obje döndü, yerelde de güncelleyelim
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedBoard = Board.fromJson(data);

        final index = _boards.indexWhere((b) => b.id == boardId);
        if (index != -1) {
          _boards[index] = updatedBoard;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Güncelleme başarısız';
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

  /// Pano Silme — DELETE /boards/{id}
  Future<bool> deleteBoard(String boardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/boards/$boardId');

      if (response.statusCode == 200) {
        // Listeden çıkar
        _boards.removeWhere((b) => b.id == boardId);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Silme başarısız';
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
}
