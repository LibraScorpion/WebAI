import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/image_model.dart';
import '../services/api_service.dart';

class ImageGenerationProvider with ChangeNotifier {
  final ApiService _apiService;
  final SharedPreferences _prefs;
  static const String _historyKey = 'image_history';
  
  List<GeneratedImage> _images = [];
  bool _isLoading = false;
  String? _error;

  ImageGenerationProvider(this._apiService, this._prefs) {
    _loadHistory();
  }

  List<GeneratedImage> get images => _images;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final historyJson = _prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _images = historyList
            .map((item) => GeneratedImage.fromJson(item))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateImage(String prompt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.generateImage(prompt);
      final newImage = GeneratedImage(
        id: DateTime.now().toString(),
        url: response.data['url'],
        prompt: prompt,
        createdAt: DateTime.now(),
      );

      _images.insert(0, newImage);
      await _saveHistory();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveHistory() async {
    final historyJson = json.encode(
      _images.map((image) => image.toJson()).toList(),
    );
    await _prefs.setString(_historyKey, historyJson);
  }

  Future<void> clearHistory() async {
    _images.clear();
    await _prefs.remove(_historyKey);
    notifyListeners();
  }

  Future<void> deleteImage(String id) async {
    _images.removeWhere((image) => image.id == id);
    await _saveHistory();
    notifyListeners();
  }
}
