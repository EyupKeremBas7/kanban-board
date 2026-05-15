import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/activity_log.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/socket_service.dart';

enum ActivityFetchScope { workspace, board, card }

class ActivityViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService? _socketService;

  ActivityViewModel({
    required ApiService apiService,
    SocketService? socketService,
  }) : _apiService = apiService,
       _socketService = socketService {
    _listenToSockets();
  }

  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  Timer? _refreshDebounce;
  ActivityFetchScope? _activeScope;
  String? _activeTargetId;

  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const Set<String> _activityEvents = {
    'BoardCreatedEvent',
    'BoardUpdatedEvent',
    'BoardDeletedEvent',
    'CardMovedEvent',
    'CardAssignedEvent',
    'CardCreatedEvent',
    'CardDeletedEvent',
    'CardUpdatedEvent',
    'ChecklistCreatedEvent',
    'ChecklistUpdatedEvent',
    'ChecklistDeletedEvent',
    'ChecklistToggledEvent',
    'CommentAddedEvent',
    'CommentUpdatedEvent',
    'CommentDeletedEvent',
    'InvitationSentEvent',
    'InvitationRespondedEvent',
    'WorkspaceCreatedEvent',
    'WorkspaceUpdatedEvent',
    'WorkspaceDeletedEvent',
    'ListCreatedEvent',
    'ListUpdatedEvent',
    'ListDeletedEvent',
    'WorkspaceMemberAddedEvent',
    'WorkspaceMemberRemovedEvent',
  };

  void _listenToSockets() {
    _socketSubscription = _socketService?.eventStream.listen((eventData) {
      final eventName = eventData['event'] as String? ?? '';
      if (!_activityEvents.contains(eventName)) return;
      if (_activeScope == null || _activeTargetId == null) return;

      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 500), () {
        _refreshActiveScope();
      });
    });
  }

  Future<void> _refreshActiveScope() async {
    final scope = _activeScope;
    final targetId = _activeTargetId;
    if (scope == null || targetId == null) return;

    switch (scope) {
      case ActivityFetchScope.workspace:
        await fetchWorkspaceActivity(targetId);
        break;
      case ActivityFetchScope.board:
        await fetchBoardActivity(targetId);
        break;
      case ActivityFetchScope.card:
        await fetchCardActivity(targetId);
        break;
    }
  }

  /// Workspace aktiviteleri çek — GET /activity/workspace/{workspace_id}
  Future<void> fetchWorkspaceActivity(String workspaceId) async {
    _activeScope = ActivityFetchScope.workspace;
    _activeTargetId = workspaceId;
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
    _activeScope = ActivityFetchScope.board;
    _activeTargetId = boardId;
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
    _activeScope = ActivityFetchScope.card;
    _activeTargetId = cardId;
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
    _activeScope = null;
    _activeTargetId = null;
    _refreshDebounce?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _socketSubscription?.cancel();
    super.dispose();
  }
}
