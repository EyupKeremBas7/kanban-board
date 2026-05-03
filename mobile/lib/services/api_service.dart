import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/auth_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Merkezi HTTP istemcisi — tüm API çağrıları buradan yapılır.
/// JWT token otomatik olarak header'a eklenir.
class ApiService {
  String get baseUrl => dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000/api/v1';

  final AuthService _authService;

  ApiService(this._authService);

  /// Ortak header'ları oluştur (JWT varsa ekle)
  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _authService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// GET isteği
  Future<http.Response> get(
    String endpoint, {
    bool withAuth = true,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _headers(withAuth: withAuth);
    return http.get(uri, headers: headers);
  }

  /// POST isteği
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(withAuth: withAuth);
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  /// POST form-urlencoded (login OAuth2 uyumlu)
  Future<http.Response> postForm(
    String endpoint, {
    required Map<String, String> body,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    return http.post(uri, headers: headers, body: body);
  }

  /// PUT isteği
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(withAuth: withAuth);
    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  /// PATCH isteği
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(withAuth: withAuth);
    return http.patch(uri, headers: headers, body: jsonEncode(body));
  }

  /// DELETE isteği
  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(withAuth: withAuth);
    return http.delete(uri, headers: headers);
  }

  /// IMAGE UPLOAD isteği
  Future<http.Response> uploadImage(String endpoint, {required String filePath}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    
    // Auth headers
    final token = await _authService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Attach file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
