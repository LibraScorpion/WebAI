import 'package:shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final ApiService _apiService;
  final SharedPreferences _prefs;
  
  AuthService(this._apiService, this._prefs);
  
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }
  
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }
  
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, user.toJson().toString());
  }
  
  Future<User?> getUser() async {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      return User.fromJson(Map<String, dynamic>.from(
        // ignore: unnecessary_cast
        userStr as Map<String, dynamic>
      ));
    }
    return null;
  }
  
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
