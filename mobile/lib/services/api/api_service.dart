import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../auth/secure_storage_service.dart';
import '../../config/api_config.dart';

class ApiService {
  final SecureStorageService _secureStorage;
  final String baseUrl;

  ApiService(this._secureStorage, {this.baseUrl = ApiConfig.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ApiException(
        'API Error: ${response.statusCode}',
        response.statusCode,
        response.body,
      );
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = await _handleResponse(response);
    if (data['token'] != null) {
      await _secureStorage.saveAuthToken(data['token']);
    }
    return data;
  }

  Future<void> logout() async {
    await _secureStorage.deleteAuthToken();
  }

  // Chat
  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.chatEndpoint}'),
      headers: await _getHeaders(),
      body: json.encode({
        'message': message,
      }),
    );

    final data = await _handleResponse(response);
    return data['response'];
  }

  // Image Generation
  Future<Map<String, dynamic>> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.imageGenerationEndpoint}'),
      headers: await _getHeaders(),
      body: json.encode({
        'prompt': prompt,
      }),
    );

    return await _handleResponse(response);
  }

  // File Upload
  Future<String> uploadImage(File image) async {
    final uri = Uri.parse('$baseUrl${ApiConfig.uploadEndpoint}');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    // Add file to request
    final file = await http.MultipartFile.fromPath(
      'file',
      image.path,
      filename: image.path.split('/').last,
    );
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = await _handleResponse(response);
    return data['url'];
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.profileEndpoint}'),
      headers: await _getHeaders(),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl${ApiConfig.profileEndpoint}'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    return await _handleResponse(response);
  }

  // Settings
  Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.settingsEndpoint}'),
      headers: await _getHeaders(),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    final response = await http.put(
      Uri.parse('$baseUrl${ApiConfig.settingsEndpoint}'),
      headers: await _getHeaders(),
      body: json.encode(settings),
    );

    return await _handleResponse(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  ApiException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  @override
  String toString() => 'Unauthorized';
}
