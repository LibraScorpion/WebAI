class ApiConfig {
  static const String baseUrl = 'http://your-api-base-url';
  static const String wsUrl = 'ws://your-websocket-url';
  
  // API endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String chat = '/api/chat';
  static const String imageGeneration = '/api/image/generate';
  
  // API headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
