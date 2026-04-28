import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/invitation.dart';
import 'package:mobile/services/api_service.dart';

/// Davetiyeler ViewModel — Gelen ve gönderilen davetiyelerin yönetimi.
class InvitationsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  InvitationsViewModel({required ApiService apiService})
    : _apiService = apiService;

  // State
  List<Invitation> _receivedInvitations = [];
  List<Invitation> _sentInvitations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Invitation> get receivedInvitations => _receivedInvitations;
  List<Invitation> get sentInvitations => _sentInvitations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Bana gelen davetleri çek (pending olanları) — GET /invitations/
  Future<void> fetchReceivedInvitations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/invitations/?status=pending');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        _receivedInvitations = list
            .map((json) => Invitation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Davetler alınamadı';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Benim gönderdiğim davetleri çek — GET /invitations/sent
  Future<void> fetchSentInvitations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/invitations/sent');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        _sentInvitations = list
            .map((json) => Invitation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Davetler alınamadı';
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Daveti yanıtla (kabul/red) — POST /invitations/{id}/respond
  Future<bool> respondToInvitation(String id, bool accept) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/invitations/$id/respond',
        body: {'accept': accept},
      );

      if (response.statusCode == 200) {
        // Listeden çıkar
        _receivedInvitations.removeWhere((inv) => inv.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Yanıt başarısız';
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

  /// Gönderilen daveti iptal et — DELETE /invitations/{id}
  Future<bool> cancelInvitation(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/invitations/$id');

      if (response.statusCode == 200) {
        _sentInvitations.removeWhere((inv) => inv.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'İptal başarısız';
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

  /// Workspace'e üye davet et — POST /invitations/
  Future<bool> sendInvitation({
    required String workspaceId,
    required String inviteeEmail,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/invitations/',
        body: {
          'workspace_id': workspaceId,
          'invitee_email': inviteeEmail,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newInv = Invitation.fromJson(data);
        _sentInvitations.insert(0, newInv);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Davet gönderilemedi';
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
