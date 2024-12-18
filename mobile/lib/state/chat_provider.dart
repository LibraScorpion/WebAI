import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/chat/message_repository.dart';
import '../services/chat/message_cache_manager.dart';
import '../services/api_service.dart';
import 'dart:io';

class ChatProvider with ChangeNotifier {
  final MessageRepository _messageRepository = MessageRepository();
  final MessageCacheManager _cacheManager = MessageCacheManager.instance;
  final ApiService _apiService = ApiService();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadMessages({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final offset = refresh ? 0 : _messages.length;
      final messages = await _messageRepository.getMessages(
        offset: offset,
        limit: _pageSize,
      );

      if (refresh) {
        _messages = messages;
        _currentPage = 0;
      } else {
        _messages.addAll(messages);
        _currentPage++;
      }

      _hasMore = messages.length == _pageSize;
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    final message = Message(
      id: DateTime.now().toString(),
      content: content,
      type: type,
      timestamp: DateTime.now(),
      senderId: 'user', // Replace with actual user ID
      isAI: false,
    );

    // Add message to local storage first
    await _messageRepository.insertMessage(message);
    _messages.insert(0, message);
    notifyListeners();

    try {
      // Send message to API
      final response = await _apiService.sendMessage(content);
      
      // Create AI response message
      final aiMessage = Message(
        id: DateTime.now().toString(),
        content: response,
        type: MessageType.text,
        timestamp: DateTime.now(),
        senderId: 'ai',
        isAI: true,
      );

      // Save AI response to local storage
      await _messageRepository.insertMessage(aiMessage);
      _messages.insert(0, aiMessage);
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      // Handle error (e.g., show error message to user)
    }
  }

  Future<void> sendImage(File image) async {
    try {
      // Cache the image file
      final cachedFile = await _cacheManager.downloadAndCacheFile(image.path);
      
      // Create message with cached image path
      final message = Message(
        id: DateTime.now().toString(),
        content: cachedFile.path,
        type: MessageType.image,
        timestamp: DateTime.now(),
        senderId: 'user', // Replace with actual user ID
        isAI: false,
      );

      // Save message to local storage
      await _messageRepository.insertMessage(message);
      _messages.insert(0, message);
      notifyListeners();

      // Upload image to API
      final response = await _apiService.uploadImage(image);
      
      // Handle API response if needed
    } catch (e) {
      print('Error sending image: $e');
      // Handle error
    }
  }

  Future<List<Message>> searchMessages(String query) async {
    try {
      return await _messageRepository.searchMessages(query);
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  Future<void> clearChat() async {
    try {
      await _messageRepository.deleteAllMessages();
      await _cacheManager.clearCache();
      _messages = [];
      _currentPage = 0;
      _hasMore = true;
      notifyListeners();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  Future<String> getCacheSize() async {
    final size = await _cacheManager.getCacheSize();
    return _cacheManager.formatCacheSize(size);
  }

  @override
  void dispose() {
    _messageRepository.close();
    super.dispose();
  }
}
