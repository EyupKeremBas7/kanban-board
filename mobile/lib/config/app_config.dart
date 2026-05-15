import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const _apiUrlFromBuild = String.fromEnvironment('API_URL');
  static const _defaultApiUrl = 'http://10.0.2.2:8000/api/v1';

  static String get apiUrl {
    final buildValue = _apiUrlFromBuild.trim();
    if (buildValue.isNotEmpty) return _normalizeApiUrl(buildValue);

    final envValue = dotenv.env['API_URL']?.trim();
    if (envValue != null && envValue.isNotEmpty) {
      return _normalizeApiUrl(envValue);
    }

    return _defaultApiUrl;
  }

  static String get socketUrl => apiUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

  static String _normalizeApiUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
