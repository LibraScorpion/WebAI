import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/message_model.dart';

class ApiService {
  final Dio _dio;
  final String? _token;

  ApiService({String? token}) : 
    _token = token,
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.getHeaders(token),
    ));

  Future<Response> chat(String message) async {
    try {
      final response = await _dio.post(
        ApiConfig.chat,
        data: {'message': message},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> generateImage(String prompt) async {
    try {
      final response = await _dio.post(
        ApiConfig.imageGeneration,
        data: {'prompt': prompt},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
