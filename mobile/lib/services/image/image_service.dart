import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ImageService {
  static const int maxImageSize = 1024 * 1024; // 1MB
  static const int targetQuality = 85;

  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need storage permission
  }

  Future<File?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final fileSize = await file.length();
      if (fileSize <= maxImageSize) {
        return file;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: targetQuality,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> shareImage(String path, {String? text}) async {
    try {
      if (await File(path).exists()) {
        final xFile = XFile(path);
        await Share.shareXFiles(
          [xFile],
          text: text,
        );
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  Future<String?> saveImageToGallery(File file) async {
    try {
      if (!await checkStoragePermission()) {
        throw Exception('Storage permission not granted');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await file.copy('${appDir.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image to gallery: $e');
      return null;
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<List<String>> getImageHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory(appDir.path);
      
      if (!await directory.exists()) {
        return [];
      }

      final List<String> imageFiles = [];
      await for (final entity in directory.list()) {
        if (entity is File && 
            entity.path.toLowerCase().endsWith('.jpg') || 
            entity.path.toLowerCase().endsWith('.jpeg') ||
            entity.path.toLowerCase().endsWith('.png')) {
          imageFiles.add(entity.path);
        }
      }

      return imageFiles;
    } catch (e) {
      print('Error getting image history: $e');
      return [];
    }
  }

  Future<void> clearImageHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory(appDir.path);
      
      if (!await directory.exists()) {
        return;
      }

      await for (final entity in directory.list()) {
        if (entity is File && 
            (entity.path.toLowerCase().endsWith('.jpg') || 
             entity.path.toLowerCase().endsWith('.jpeg') ||
             entity.path.toLowerCase().endsWith('.png'))) {
          await entity.delete();
        }
      }
    } catch (e) {
      print('Error clearing image history: $e');
    }
  }
}
