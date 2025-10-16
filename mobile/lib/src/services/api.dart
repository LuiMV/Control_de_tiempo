import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/'));
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  //  Iniciar sesión y guardar tokens
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/token/',
        data: {'email': email, 'password': password},
      );

      // Guardar tokens JWT
      await storage.write(key: 'access_token', value: response.data['access']);
      await storage.write(key: 'refresh_token', value: response.data['refresh']);

      return true;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  /// Registrar nuevo usuario
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

  ///  Resumen del uso
  Future<Response> usageSummary(String period) {
    return _dio.get(
      'usage/summary/',
      queryParameters: {'period': period},
    );
  }

  /// ️ Subir registros de uso
  Future<Response> uploadUsage(List<Map<String, dynamic>> records) {
    return _dio.post('usage/', data: records);
  }

  ///  Cerrar sesión
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  ///  Verificar si el usuario sigue logueado
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }


  Future<Response> setAppLimit(String appName, int limitMinutes) {
    return _dio.post('set_limit/', data: {
      'app_name': appName,
      'limit_minutes': limitMinutes,
    });
  }

}

