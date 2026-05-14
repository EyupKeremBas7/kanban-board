import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/services/auth_service.dart';

class SocketService extends ChangeNotifier {
  static const List<String> _serverEvents = [
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
  ];

  socket_io.Socket? _socket;
  final AuthService _authService;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Event stream to notify listeners of incoming events
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  SocketService(this._authService);

  void connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _authService.getToken();
    final baseUrl = dotenv.env['API_URL']?.replaceAll('/api/v1', '') ?? 'http://10.0.2.2:8000';

    _socket = socket_io.io(
      baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) print('Socket.IO: Connected');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) print('Socket.IO: Disconnected');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onConnectError((err) {
      if (kDebugMode) print('Socket.IO: Connect Error: $err');
    });

    _socket!.onError((err) {
      if (kDebugMode) print('Socket.IO: Error: $err');
    });

    for (final eventName in _serverEvents) {
      _socket!.on(eventName, (data) => _publishEvent(eventName, data));
    }

    // Useful while debugging newly added backend events.
    _socket!.onAny((event, data) {
      if (kDebugMode) print('Socket.IO Any Event: $event -> $data');
    });

    _socket!.connect();
  }

  void _publishEvent(String event, dynamic data) {
    final payload = data is List && data.isNotEmpty ? data.first : data;
    if (kDebugMode) print('Socket.IO Event: $event -> $payload');
    _eventController.add({
      'event': event,
      'data': payload,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    }
  }

  @override
  void dispose() {
    _eventController.close();
    disconnect();
    super.dispose();
  }
}
