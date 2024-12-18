import 'package:shared_preferences.dart';
import 'package:flutter/material.dart';
import '../chat/message_cache_manager.dart';
import '../auth/secure_storage_service.dart';

class SettingsService {
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String chatNotificationsKey = 'chat_notifications_enabled';
  static const String biometricKey = 'biometric_enabled';

  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;
  final MessageCacheManager _cacheManager;

  SettingsService(this._prefs, this._secureStorage, this._cacheManager);

  // Theme Settings
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(themeKey, mode.toString());
  }

  ThemeMode getThemeMode() {
    final String? themeStr = _prefs.getString(themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeStr,
      orElse: () => ThemeMode.system,
    );
  }

  // Language Settings
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(languageKey) ?? 'en';
  }

  // Notification Settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(notificationsKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(notificationsKey) ?? true;
  }

  Future<void> setChatNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(chatNotificationsKey, enabled);
  }

  bool getChatNotificationsEnabled() {
    return _prefs.getBool(chatNotificationsKey) ?? true;
  }

  // Biometric Settings
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(biometricKey, enabled);
  }

  bool getBiometricEnabled() {
    return _prefs.getBool(biometricKey) ?? false;
  }

  // Cache Management
  Future<String> getCacheSize() async {
    final size = await _cacheManager.getCacheSize();
    return _cacheManager.formatCacheSize(size);
  }

  Future<void> clearCache() async {
    await _cacheManager.clearCache();
  }

  // Chat History
  Future<void> clearChatHistory() async {
    // Clear chat messages from secure storage
    await _secureStorage.deleteSecureData('chat_history');
    // Clear any cached files
    await _cacheManager.clearCache();
  }

  // App Data
  Future<void> clearAppData() async {
    // Clear preferences
    await _prefs.clear();
    // Clear secure storage
    await _secureStorage.deleteAllSecureData();
    // Clear cache
    await _cacheManager.clearCache();
  }

  // Export Settings
  Future<Map<String, dynamic>> exportSettings() async {
    return {
      'theme': getThemeMode().toString(),
      'language': getLanguage(),
      'notifications': {
        'enabled': getNotificationsEnabled(),
        'chat': getChatNotificationsEnabled(),
      },
      'biometric': getBiometricEnabled(),
    };
  }

  // Import Settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('theme')) {
      await setThemeMode(ThemeMode.values.firstWhere(
        (e) => e.toString() == settings['theme'],
        orElse: () => ThemeMode.system,
      ));
    }

    if (settings.containsKey('language')) {
      await setLanguage(settings['language']);
    }

    if (settings.containsKey('notifications')) {
      final notifications = settings['notifications'];
      if (notifications['enabled'] != null) {
        await setNotificationsEnabled(notifications['enabled']);
      }
      if (notifications['chat'] != null) {
        await setChatNotificationsEnabled(notifications['chat']);
      }
    }

    if (settings.containsKey('biometric')) {
      await setBiometricEnabled(settings['biometric']);
    }
  }
}
