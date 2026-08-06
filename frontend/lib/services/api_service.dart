import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

// Backend base URL.
// - Windows/desktop/web running on this same PC: localhost works as-is.
// - Android emulator: change to http://10.0.2.2:4000/api/v1
// - Real phone on the same Wi-Fi: change to http://<your-pc-ip>:4000/api/v1
const String apiBaseUrl = 'http://localhost:4000/api/v1';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

// Thin wrapper around http calls: builds the URL, attaches the JWT,
// decodes JSON, and turns error responses into an ApiException.
class ApiService {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': Get.locale?.languageCode == 'ar' ? 'ar' : 'en',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _handle(http.Response response) {
    if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      String? message;
      if (decoded is Map) {
        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty && errors.first['message'] != null) {
          message = errors.first['message'];
        }
        message ??= decoded['error']?['message'] ?? decoded['message'];
      }
      throw ApiException(response.statusCode, message ?? 'Something went wrong');
    }

    return decoded;
  }

  static Future<dynamic> get(String path, {bool auth = false}) async {
    final response = await http
        .get(Uri.parse('$apiBaseUrl$path'), headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http
        .post(
          Uri.parse('$apiBaseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http
        .patch(
          Uri.parse('$apiBaseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  static Future<dynamic> put(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    final response = await http
        .put(
          Uri.parse('$apiBaseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  static Future<dynamic> delete(String path, {bool auth = false}) async {
    final response = await http
        .delete(Uri.parse('$apiBaseUrl$path'), headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }
}
