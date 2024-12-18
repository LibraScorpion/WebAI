import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MessageCacheManager {
  static const String key = 'message_cache';
  static MessageCacheManager? _instance;
  final DefaultCacheManager _cacheManager;

  MessageCacheManager._() : _cacheManager = DefaultCacheManager();

  static MessageCacheManager get instance {
    _instance ??= MessageCacheManager._();
    return _instance!;
  }

  Future<File> downloadAndCacheFile(String url) async {
    final fileInfo = await _cacheManager.downloadFile(url);
    return fileInfo.file;
  }

  Future<FileInfo?> getFileFromCache(String url) async {
    return await _cacheManager.getFileFromCache(url);
  }

  Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  Future<Directory> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory;
  }

  Future<int> getCacheSize() async {
    final directory = await getCacheDirectory();
    return await _calculateDirectorySize(directory);
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      print('Error calculating cache size: $e');
    }
    return totalSize;
  }

  String formatCacheSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
