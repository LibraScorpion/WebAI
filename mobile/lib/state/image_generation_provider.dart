import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/image_model.dart';
import '../services/api_service.dart';
import '../services/chat/message_cache_manager.dart';

class ImageGenerationProvider with ChangeNotifier {
  final ApiService _apiService;
  final MessageCacheManager _cacheManager = MessageCacheManager.instance;
  List<GeneratedImage> _generatedImages = [];
  bool _isLoading = false;

  ImageGenerationProvider(this._apiService);

  List<GeneratedImage> get generatedImages => _generatedImages;
  bool get isLoading => _isLoading;

  Future<String> generateImage(String prompt) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.generateImage(prompt);
      final imageUrl = response['url'];

      // Download and cache the image
      final cachedFile = await _cacheManager.downloadAndCacheFile(imageUrl);

      // Create new generated image record
      final generatedImage = GeneratedImage(
        id: DateTime.now().toString(),
        prompt: prompt,
        imageUrl: imageUrl,
        localPath: cachedFile.path,
        timestamp: DateTime.now(),
      );

      _generatedImages.insert(0, generatedImage);
      notifyListeners();

      return cachedFile.path;
    } catch (e) {
      print('Error generating image: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(String id) async {
    try {
      final image = _generatedImages.firstWhere((img) => img.id == id);
      
      // Delete from cache if exists
      if (image.localPath != null) {
        final file = File(image.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _generatedImages.removeWhere((img) => img.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      // Delete all cached images
      for (var image in _generatedImages) {
        if (image.localPath != null) {
          final file = File(image.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      _generatedImages.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing image history: $e');
    }
  }

  Future<void> shareImage(String id) async {
    try {
      final image = _generatedImages.firstWhere((img) => img.id == id);
      if (image.localPath != null) {
        // Implement sharing logic here
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }
}
