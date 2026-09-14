import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl = kIsWeb 
    ? 'http://127.0.0.1:8000/api/v1' 
    : (defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api/v1'
        : 'http://127.0.0.1:8000/api/v1');

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static const Duration requestTimeout = Duration(seconds: 4);

  Future<dynamic> get(String endpoint) async {
    final response = await http
        .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
        .timeout(requestTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers)
        .timeout(requestTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> uploadMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, String>? filePaths,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (filePaths != null && !kIsWeb) {
      for (final entry in filePaths.entries) {
        final path = entry.value;
        if (path.isNotEmpty) {
          final file = File(path);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              entry.key,
              path,
            ));
          }
        }
      }
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
         return jsonDecode(response.body);
      }
      return null;
    } else {
      throw ApiException('Error ${response.statusCode}: ${response.body}', response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}
