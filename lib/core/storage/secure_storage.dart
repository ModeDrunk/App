import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para acceder al storage desde cualquier parte
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Mayor seguridad en Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility
          .first_unlock, // iOS: solo disponible después del primer desbloqueo
    ),
  );

  // Guardar access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Obtener access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Guardar refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Obtener refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Guardar información del usuario
  Future<void> saveUserInfo(
      {required String userId, required String email}) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
  }

  // Obtener información del usuario
  Future<Map<String, String?>> getUserInfo() async {
    final userId = await _storage.read(key: _userIdKey);
    final userEmail = await _storage.read(key: _userEmailKey);
    return {
      'userId': userId,
      'email': userEmail,
    };
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Limpiar todos los datos (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Eliminar solo tokens (mantener otros datos si es necesario)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
