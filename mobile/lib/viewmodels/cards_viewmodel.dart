import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/board_card.dart';
import 'package:mobile/services/api_service.dart';

class CardsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  CardsViewModel({required ApiService apiService}) : _apiService = apiService;

  List<BoardCard> _cards = [];
  final Map<String, int> _commentCounts = {};
  final Map<String, String> _checklistProgressByCard = {};
  final Set<String> _statsLoadedCardIds = {};
  final Set<String> _statsLoadingCardIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<BoardCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int getCommentCount(String cardId) {
    final cached = _commentCounts[cardId];
    if (cached != null) return cached;
    final card = _cards.where((c) => c.id == cardId).firstOrNull;
    return card?.commentCount ?? 0;
  }

  String getChecklistProgress(String cardId) {
    final cached = _checklistProgressByCard[cardId];
    if (cached != null) return cached;
    final card = _cards.where((c) => c.id == cardId).firstOrNull;
    return card?.checklistProgress ?? '0/0';
  }

  Future<void> prefetchCardStats(
    Iterable<String> cardIds, {
    bool forceRefresh = false,
  }) async {
    final targets = cardIds.where((id) {
      if (_statsLoadingCardIds.contains(id)) return false;
      if (forceRefresh) return true;
      return !_statsLoadedCardIds.contains(id);
    }).toList();

    if (targets.isEmpty) return;

    _statsLoadingCardIds.addAll(targets);

    for (final cardId in targets) {
      try {
        final commentsRes = await _apiService.get('/comments/?card_id=$cardId');
        if (commentsRes.statusCode == 200) {
          final commentsData =
              jsonDecode(commentsRes.body) as Map<String, dynamic>;
          final comments = commentsData['data'] as List? ?? [];
          _commentCounts[cardId] = comments.length;
        }

        final checklistRes = await _apiService.get(
          '/checklists/?card_id=$cardId',
        );
        if (checklistRes.statusCode == 200) {
          final checklistData =
              jsonDecode(checklistRes.body) as Map<String, dynamic>;
          final items = checklistData['data'] as List? ?? [];
          final completedCount = items.where((item) {
            final json = item as Map<String, dynamic>;
            return json['is_completed'] == true;
          }).length;
          _checklistProgressByCard[cardId] = '$completedCount/${items.length}';
        }
      } catch (_) {
      } finally {
        _statsLoadingCardIds.remove(cardId);
        _statsLoadedCardIds.add(cardId);
      }
    }

    notifyListeners();
  }

  /// Belirli bir liste altındaki kartları döndürür
  List<BoardCard> getCardsForList(String listId) {
    final filtered = _cards.where((c) => c.listId == listId).toList();
    filtered.sort((a, b) => a.position.compareTo(b.position));
    return filtered;
  }

  double _calculateNextPositionForList({
    required String listId,
    String? excludeCardId,
  }) {
    final listCards = getCardsForList(
      listId,
    ).where((card) => card.id != excludeCardId).toList();

    if (listCards.isEmpty) {
      return 65535.0;
    }

    final lastCard = listCards.last;
    return lastCard.position + 1024.0;
  }

  /// REST api'den bütün kartları çeker ve önbelleğe (state'e) atar.
  Future<void> fetchCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Şimdilik tüm kartları çekip, UI katmanında filtreleyeceğiz
      final response = await _apiService.get('/cards/?skip=0&limit=1000');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _cards = items.map((json) => BoardCard.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();

        final cardIds = _cards.map((c) => c.id).toList();
        Future.microtask(() => prefetchCardStats(cardIds));
      } else {
        _errorMessage = 'Kartlar yüklenemedi: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kart Oluşturma — POST /cards/
  Future<bool> createCard({
    required String listId,
    required String title,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPosition = _calculateNextPositionForList(listId: listId);

      final body = {
        'list_id': listId,
        'title': title,
        'description': description ?? '',
        'position': nextPosition,
      };

      final response = await _apiService.post('/cards/', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newCard = BoardCard.fromJson(data);
        _cards.add(newCard);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Kart oluşturulamadı.';
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

  /// Kart taşıma — başka listeye geçirir veya aynı liste içinde sıralar (PUT /cards/{id})
  Future<bool> moveCardToList({
    required String cardId,
    required String targetListId,
  }) async {
    final cardIndex = _cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) {
      _errorMessage = 'Kart bulunamadı.';
      notifyListeners();
      return false;
    }

    final currentCard = _cards[cardIndex];

    // Aynı liste: listedeki son karta sonra koy (position değiştirme sıralaması)
    if (currentCard.listId == targetListId) {
      final listCards = getCardsForList(
        targetListId,
      ).where((c) => c.id != cardId).toList();

      if (listCards.isEmpty) {
        return true; // Hiç başka kart yoksa zaten son
      }

      final lastCard = listCards.last;
      final newPosition = lastCard.position + 1024.0;

      return updateCard(cardId: cardId, position: newPosition);
    }

    // Farklı liste
    final nextPosition = _calculateNextPositionForList(
      listId: targetListId,
      excludeCardId: cardId,
    );

    return updateCard(
      cardId: cardId,
      listId: targetListId,
      position: nextPosition,
    );
  }

  /// Kart Güncelleme — PUT /cards/{id}
  Future<bool> updateCard({
    required String cardId,
    String? title,
    String? description,
    String? listId,
    double? position,
    DateTime? dueDate,
    String? assignedTo,
    String? coverImage,
    bool clearDueDate = false,
    bool clearAssignedTo = false,
    bool clearCoverImage = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (listId != null) body['list_id'] = listId;
      if (position != null) body['position'] = position;

      if (clearDueDate) {
        body['due_date'] = null;
      } else if (dueDate != null) {
        body['due_date'] = dueDate.toIso8601String();
      }

      if (clearAssignedTo) {
        body['assigned_to'] = null;
      } else if (assignedTo != null) {
        body['assigned_to'] = assignedTo;
      }

      if (clearCoverImage) {
        body['cover_image'] = null;
      } else if (coverImage != null) {
        body['cover_image'] = coverImage;
      }

      final response = await _apiService.put('/cards/$cardId', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedCard = BoardCard.fromJson(data);

        final idx = _cards.indexWhere((c) => c.id == cardId);
        if (idx != -1) {
          _cards[idx] = updatedCard;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Kart güncellenemedi.';
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

  /// Kapak resmi yükle
  Future<bool> uploadCoverImage({
    required String cardId,
    required String filePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.uploadImage(
        '/uploads/image',
        filePath: filePath,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['url'] as String;

        // updateCard metodunu çağırarak modeli de güncelle
        return await updateCard(cardId: cardId, coverImage: url);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Resim yüklenemedi';
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

  /// Kart Silme — DELETE /cards/{id}
  Future<bool> deleteCard(String cardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/cards/$cardId');

      if (response.statusCode == 200) {
        _cards.removeWhere((c) => c.id == cardId);
        _commentCounts.remove(cardId);
        _checklistProgressByCard.remove(cardId);
        _statsLoadedCardIds.remove(cardId);
        _statsLoadingCardIds.remove(cardId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Kart silinemedi.';
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
