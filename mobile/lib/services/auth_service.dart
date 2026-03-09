import 'package:shared_preferences/shared_preferences.dart';

/// JWT token saklama ve yönetimi.
/// SharedPreferences ile kalıcı token depolama.
class AuthService {
  static const String _tokenKey = 'jwt_token';

  /// Kayıtlı token'ı getir
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Token'ı kaydet
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Token'ı sil (çıkış yap)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Kullanıcı giriş yapmış mı kontrol et
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
