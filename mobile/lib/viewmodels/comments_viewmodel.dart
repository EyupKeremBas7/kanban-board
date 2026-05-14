import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/card_comment.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/socket_service.dart';

class CommentsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  final SocketService? _socketService;
  String? _currentCardId;

  CommentsViewModel({required ApiService apiService, SocketService? socketService})
    : _apiService = apiService,
      _socketService = socketService {
    _listenToSockets();
  }

  void _listenToSockets() {
    _socketService?.eventStream.listen((eventData) {
      final String event = eventData['event'] ?? '';
      if (_currentCardId != null &&
          (event == 'CommentAddedEvent' ||
              event == 'CommentUpdatedEvent' ||
              event == 'CommentDeletedEvent')) {
        fetchComments(_currentCardId!);
      }
    });
  }

  List<CardComment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CardComment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Karta ait yorumları çek — GET /comments/?card_id={id}
  Future<void> fetchComments(String cardId) async {
    _currentCardId = cardId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/comments/?card_id=$cardId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _comments = items.map((json) => CardComment.fromJson(json)).toList();
        // En yeni yorum en üstte
        _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Yorumlar yüklenemedi: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yorum ekle — POST /comments/
  Future<bool> createComment({
    required String cardId,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {'card_id': cardId, 'content': content};

      final response = await _apiService.post('/comments/', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newComment = CardComment.fromJson(data);
        _comments.insert(0, newComment); // en üste ekle
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Yorum eklenemedi.';
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

  /// Yorum güncelle — PATCH /comments/{id}
  Future<bool> updateComment({
    required String commentId,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.patch(
        '/comments/$commentId',
        body: {'content': content},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updated = CardComment.fromJson(data);
        final idx = _comments.indexWhere((c) => c.id == commentId);
        if (idx != -1) _comments[idx] = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Yorum güncellenemedi.';
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

  /// Yorum sil — DELETE /comments/{id}
  Future<bool> deleteComment(String commentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/comments/$commentId');

      if (response.statusCode == 200) {
        _comments.removeWhere((c) => c.id == commentId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Yorum silinemedi.';
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
    _comments = [];
    _errorMessage = null;
    notifyListeners();
  }
}
