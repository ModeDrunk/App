import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  // Callback opcional para notificar logout
  void Function()? onUnauthorized;

  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Obtener token almacenado
    final token = await _secureStorage.getAccessToken();

    // Si existe token, agregarlo al header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el error es 401 (Unauthorized), limpiar tokens y cerrar sesión
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAll();
      if (onUnauthorized != null) {
        onUnauthorized!();
      }
    }

    return handler.next(err);
  }
}
