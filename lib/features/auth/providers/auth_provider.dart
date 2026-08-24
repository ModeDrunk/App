import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
// ignore: unused_import
import '../../../core/constants/app_constants.dart';

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? userEmail;
  final String? errorMessage;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.userId,
    this.userEmail,
    this.errorMessage,
  });

  // Estado inicial
  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  // Copiar con modificaciones
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? userEmail,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage,
    );
  }
}

// Provider del estado de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthNotifier(dioClient, secureStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  AuthNotifier(this._dioClient, this._secureStorage)
      : super(AuthState.initial()) {
    // Verificar si ya hay sesión al iniciar
    _checkAuthStatus();
  }

  // Verificar estado de autenticación al iniciar
  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await _secureStorage.isAuthenticated();

    if (isAuthenticated) {
      final userInfo = await _secureStorage.getUserInfo();
      state = state.copyWith(
        isAuthenticated: true,
        userId: userInfo['userId'],
        userEmail: userInfo['email'],
      );
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dioClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userId = data['user']['id'];
        final userEmail = data['user']['email'];

        // Guardar tokens y datos
        await _secureStorage.saveAccessToken(accessToken);
        await _secureStorage.saveRefreshToken(refreshToken);
        await _secureStorage.saveUserInfo(userId: userId, email: userEmail);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userId: userId,
          userEmail: userEmail,
        );

        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al iniciar sesión',
      );
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Email o contraseña incorrectos';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Datos inválidos';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado',
      );
      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String? pinCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dioClient.post('/auth/register', data: {
        'email': email,
        'phone': phone,
        'password': password,
        'fullName': fullName,
        if (pinCode != null) 'pinCode': pinCode,
      });

      if (response.statusCode == 201) {
        // Después de registrar, hacer login automático
        return await login(email, password);
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al registrar usuario',
      );
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response?.statusCode == 409) {
        errorMessage = 'El email o teléfono ya está registrado';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Intentar cerrar sesión en el backend
      await _dioClient.post('/auth/logout');
    } catch (e) {
      // Ignorar errores en logout
    } finally {
      // Siempre limpiar storage local
      await _secureStorage.clearAll();

      state = AuthState.initial();
    }
  }
}
