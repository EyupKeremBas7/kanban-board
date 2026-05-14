import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/domain/models/user.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth ViewModel — Giriş, kayıt ve oturum yönetimi.
/// Provider (ChangeNotifier) ile state yönetimi (MVVM — Kural 5).
class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  final SocketService? _socketService;

  AuthViewModel({
    required ApiService apiService,
    required AuthService authService,
    SocketService? socketService,
  }) : _apiService = apiService,
       _authService = authService,
       _socketService = socketService;

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

        // Socket bağlantısını başlat
        _socketService?.connect();

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
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Kayıt olma — POST /users/signup
  Future<bool> signup(String email, String password, {String? fullName}) async {
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
      _errorMessage = 'Connection error: $e';
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
      if (_currentUser != null) {
        _socketService?.connect();
        return true;
      }
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
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Şifre sıfırlama e-postası gönder — POST /password-recovery/{email}
  Future<bool> recoverPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/password-recovery/$email',
        withAuth: false,
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'İşlem başarısız';
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
        _errorMessage =
            data['detail'] as String? ?? 'Şifre değiştirme başarısız';
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

  /// Hesap silme (soft delete) — DELETE /users/me
  /// Backend hesabı siler, ardından token temizlenir.
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/users/me');

      if (response.statusCode == 200) {
        // Hesap silindi → token geçersiz, temizle
        await _authService.clearToken();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = data['detail'] as String? ?? 'Hesap silme başarısız';
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
    _socketService?.disconnect();
    await _authService.clearToken();
    _currentUser = null;
    _errorMessage = null;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    notifyListeners();
  }

  /// Google ile Giriş
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleSignIn = GoogleSignIn.instance;
      // Initialize if needed
      await googleSignIn.initialize(
        serverClientId: '480173408364-o51tp09af5s6h34dqh8mpv9c3cvt1tm2.apps.googleusercontent.com',
      );

      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage = 'Google yetkilendirme hatası (Token alınamadı).';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Backend çağrısı (Örnek: POST /oauth/google/token)
      final response = await _apiService.post(
        '/oauth/google/token',
        body: {'id_token': idToken},
        withAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        await _authService.saveToken(token);
        await fetchCurrentUser();
        _socketService?.connect();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Google giriş entegrasyonu backend tarafında eksik.';
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
