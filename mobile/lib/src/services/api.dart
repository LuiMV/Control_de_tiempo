import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://172.20.8.165:8000/api/'));
  final storage = FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> login(String email, String password) {
    return _dio.post('auth/token/', data: {'email': email, 'password': password});
  }

  Future<Response> usageSummary(String period) {
    return _dio.get('usage/summary/', queryParameters: {'period': period});
  }

  Future<Response> uploadUsage(List<Map<String, dynamic>> records) {
    return _dio.post('usage/', data: records);
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        'register/',
        data: {
          'username': name,
          'email': email,
          'password': password,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return false;
    }
  }

}
