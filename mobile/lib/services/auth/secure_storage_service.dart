import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAllSecureData() async {
    await _storage.deleteAll();
  }

  Future<void> saveSecureJson(String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await saveSecureData(key, jsonString);
  }

  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final jsonString = await getSecureData(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // Specific methods for token management
  Future<void> saveAuthToken(String token) async {
    await saveSecureData('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureData('auth_token');
  }

  Future<void> deleteAuthToken() async {
    await deleteSecureData('auth_token');
  }

  // Methods for user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await saveSecureJson('user_data', userData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await getSecureJson('user_data');
  }

  Future<void> deleteUserData() async {
    await deleteSecureData('user_data');
  }

  // Methods for app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await saveSecureJson('app_settings', settings);
  }

  Future<Map<String, dynamic>?> getSettings() async {
    return await getSecureJson('app_settings');
  }
}
