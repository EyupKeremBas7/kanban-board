import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// JWT token saklama ve yönetimi.
/// FlutterSecureStorage ile platformun güvenli alanında token depolama.
class AuthService {
  static const String _tokenKey = 'jwt_token';
  final FlutterSecureStorage _secureStorage;

  AuthService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Kayıtlı token'ı getir
  Future<String?> getToken() async {
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    // Eski sürümden kalan token varsa secure storage'a taşı.
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_tokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await saveToken(legacyToken);
      await prefs.remove(_tokenKey);
    }

    return legacyToken;
  }

  /// Token'ı kaydet
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Token'ı sil (çıkış yap)
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);

    // Eski sürümden kalmış olabilecek token'ı da temizle.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Kullanıcı giriş yapmış mı kontrol et
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
