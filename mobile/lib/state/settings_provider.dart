import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _chatNotificationsKey = 'chat_notifications';

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  bool _isDarkMode = false;
  String _currentLanguage = 'English';
  bool _pushNotificationsEnabled = true;
  bool _chatNotificationsEnabled = true;
  final String _appVersion = '1.0.0';

  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get chatNotificationsEnabled => _chatNotificationsEnabled;
  String get appVersion => _appVersion;

  final List<String> availableLanguages = [
    'English',
    'Chinese',
    'Spanish',
    'French',
    'German',
  ];

  Future<void> _loadSettings() async {
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    _currentLanguage = _prefs.getString(_languageKey) ?? 'English';
    _pushNotificationsEnabled = _prefs.getBool(_pushNotificationsKey) ?? true;
    _chatNotificationsEnabled = _prefs.getBool(_chatNotificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotificationsEnabled = value;
    await _prefs.setBool(_pushNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setChatNotifications(bool value) async {
    _chatNotificationsEnabled = value;
    await _prefs.setBool(_chatNotificationsKey, value);
    notifyListeners();
  }

  Future<void> clearChatHistory() async {
    // TODO: Implement chat history clearing
    notifyListeners();
  }

  Future<void> clearImageCache() async {
    // TODO: Implement image cache clearing
    notifyListeners();
  }

  Future<void> openPrivacyPolicy() async {
    const url = 'https://your-privacy-policy-url';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> openTermsOfService() async {
    const url = 'https://your-terms-of-service-url';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
