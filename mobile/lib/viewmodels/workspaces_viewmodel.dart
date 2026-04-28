import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/domain/models/workspace.dart';
import 'package:mobile/domain/models/workspace_member.dart';
import 'package:mobile/services/api_service.dart';

class WorkspacesViewModel extends ChangeNotifier {
  final ApiService _apiService;

  WorkspacesViewModel({required ApiService apiService})
    : _apiService = apiService;

  List<Workspace> _workspaces = [];
  List<WorkspaceMemberDetail> _currentMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Workspace> get workspaces => _workspaces;
  List<WorkspaceMemberDetail> get currentMembers => _currentMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Workspace listesini çek — GET /workspaces/
  Future<void> fetchWorkspaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/workspaces/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        _workspaces = items.map((json) => Workspace.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Workspace\'ler yüklenemedi: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Workspace oluştur — POST /workspaces/
  Future<bool> createWorkspace({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await _apiService.post('/workspaces/', body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newWorkspace = Workspace.fromJson(data);
        _workspaces.add(newWorkspace);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Workspace oluşturulamadı.';
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

  /// Workspace güncelle — PUT /workspaces/{id}
  Future<bool> updateWorkspace({
    required String workspaceId,
    String? name,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;

      final response = await _apiService.put(
        '/workspaces/$workspaceId',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updated = Workspace.fromJson(data);
        final idx = _workspaces.indexWhere((w) => w.id == workspaceId);
        if (idx != -1) _workspaces[idx] = updated;
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

  /// Workspace sil — DELETE /workspaces/{id}
  Future<bool> deleteWorkspace(String workspaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/workspaces/$workspaceId');

      if (response.statusCode == 200) {
        _workspaces.removeWhere((w) => w.id == workspaceId);
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

  // ── Member Management ───────────────────────────────────────────────────

  /// Workspace üyelerini çek — GET /workspaces/{id}/members
  Future<void> fetchWorkspaceMembers(String workspaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/workspaces/$workspaceId/members',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        final rawMembers = items
            .map((json) => WorkspaceMember.fromJson(json))
            .toList();

        final List<WorkspaceMemberDetail> details = [];
        // Fetch user info for each member (N+1 query as fallback)
        for (final member in rawMembers) {
          final userResponse = await _apiService.get('/users/${member.userId}');
          if (userResponse.statusCode == 200) {
            final userData =
                jsonDecode(userResponse.body) as Map<String, dynamic>;
            details.add(
              WorkspaceMemberDetail(
                member: member,
                email: userData['email'] as String?,
                fullName: userData['full_name'] as String?,
              ),
            );
          } else {
            details.add(WorkspaceMemberDetail(member: member));
          }
        }

        _currentMembers = details;
        _isLoading = false;
        notifyListeners();
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Üyeler alınamadı.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Workspace üye rolünü güncelle — PUT /workspaces/{id}/members/{member_id}
  Future<bool> updateMemberRole(
    String workspaceId,
    String memberId,
    String role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '/workspaces/$workspaceId/members/$memberId',
        body: {'role': role},
      );

      if (response.statusCode == 200) {
        // Just refresh the members list
        await fetchWorkspaceMembers(workspaceId);
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Rol güncellenemedi.';
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

  /// Workspace üyesini çıkar — DELETE /workspaces/{id}/members/{member_id}
  Future<bool> removeMember(String workspaceId, String memberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        '/workspaces/$workspaceId/members/$memberId',
      );

      if (response.statusCode == 200) {
        _currentMembers.removeWhere((detail) => detail.member.id == memberId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = err['detail'] as String? ?? 'Üye çıkarılamadı.';
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
