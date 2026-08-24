import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';

// Provider del Dio client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(secureStorageProvider));
});

class DioClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    // Obtener baseUrl con fallback
    String baseUrl;
    try {
      baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
    } catch (e) {
      print('⚠️ Error leyendo .env, usando default: $e');
      baseUrl = 'http://10.0.2.2:3000';
    }

    print('🌐 API Base URL: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores
    _dio.interceptors.add(AuthInterceptor(_secureStorage));

    // Logging interceptor para desarrollo
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Dio get dio => _dio;

  // Métodos convenientes para peticiones
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
