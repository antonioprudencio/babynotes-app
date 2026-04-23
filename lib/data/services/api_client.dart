import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers(String? userId) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (userId != null) headers['X-User-Id'] = userId;
    return headers;
  }

  Future<dynamic> get(String path, {String? userId, Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers(userId));
    _checkStatus(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {String? userId}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(uri,
        headers: _headers(userId), body: jsonEncode(body));
    _checkStatus(response);
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {String? userId}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.put(uri,
        headers: _headers(userId), body: jsonEncode(body));
    _checkStatus(response);
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<void> delete(String path, {String? userId}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.delete(uri, headers: _headers(userId));
    _checkStatus(response);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
