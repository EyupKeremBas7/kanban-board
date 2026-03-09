import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/user.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';

/// Auth ViewModel — Giriş, kayıt ve oturum yönetimi.
/// Provider (ChangeNotifier) ile state yönetimi (MVVM — Kural 5).
class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  AuthViewModel({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Oturum açma — POST /login/access-token (OAuth2 form-urlencoded)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.postForm(
        '/login/access-token',
        body: {
          'username': email, // OAuth2 "username" alanı
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        await _authService.saveToken(token);

        // Token kaydedildikten sonra kullanıcı bilgisini çek
        await fetchCurrentUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Giriş başarısız';
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

  /// Kayıt olma — POST /users/signup
  Future<bool> signup(String email, String password,
      {String? fullName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/users/signup',
        body: {
          'email': email,
          'password': password,
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        },
        withAuth: false,
      );

      if (response.statusCode == 200) {
        // Kayıt başarılı → otomatik giriş yap
        return await login(email, password);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Kayıt başarısız';
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

  /// Mevcut kullanıcı bilgisini çek — GET /users/me
  Future<void> fetchCurrentUser() async {
    try {
      final response = await _apiService.get('/users/me');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = User.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Kullanıcı bilgisi alınamadı: $e');
    }
  }

  /// Kayıtlı token ile otomatik giriş kontrolü
  Future<bool> tryAutoLogin() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await fetchCurrentUser();
      return _currentUser != null;
    }
    return false;
  }

  /// Profil güncelleme — PATCH /users/me
  Future<bool> updateProfile({String? fullName, String? email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) {
        body['full_name'] = fullName;
      }
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      if (body.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final response = await _apiService.patch('/users/me', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = User.fromJson(data);
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

  /// Şifre değiştirme — PATCH /users/me/password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.patch(
        '/users/me/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Şifre değiştirme başarısız';
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

  /// Çıkış yap
  Future<void> logout() async {
    await _authService.clearToken();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
