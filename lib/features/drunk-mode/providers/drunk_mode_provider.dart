// ignore_for_file: unused_field

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

class DrunkModeState {
  final bool isLoading;
  final bool isActive;
  final String? sessionId;
  final String? errorMessage;

  DrunkModeState({
    required this.isLoading,
    required this.isActive,
    this.sessionId,
    this.errorMessage,
  });

  factory DrunkModeState.initial() {
    return DrunkModeState(isLoading: false, isActive: false);
  }

  DrunkModeState copyWith({
    bool? isLoading,
    bool? isActive,
    String? sessionId,
    String? errorMessage,
  }) {
    return DrunkModeState(
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage,
    );
  }
}

final drunkModeProvider =
    StateNotifierProvider<DrunkModeNotifier, DrunkModeState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return DrunkModeNotifier(dioClient, secureStorage);
});

class DrunkModeNotifier extends StateNotifier<DrunkModeState> {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  DrunkModeNotifier(this._dioClient, this._secureStorage)
      : super(DrunkModeState.initial());

  Future<void> checkCurrentStatus() async {
    try {
      final response = await _dioClient.get('/drunk-mode/active');
      final isActive = response.data['isActive'] ?? false;
      final sessionId = response.data['sessionId'];

      state = state.copyWith(isActive: isActive, sessionId: sessionId);
    } catch (e) {
      state = state.copyWith(isActive: false, sessionId: null);
    }
  }

  Future<bool> activate() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dioClient.post('/drunk-mode/activate', data: {
        'activationType': 'manual',
      });

      if (response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          isActive: true,
          sessionId: response.data['sessionId'],
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al activar el modo',
      );
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';
      if (e.response?.statusCode == 400) {
        errorMessage = 'Ya tienes un modo activo';
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

  // Agregar este método al DrunkModeNotifier
  Future<bool> deactivate(String pinCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dioClient.post('/drunk-mode/deactivate', data: {
        'pinCode': pinCode,
        'deactivationType': 'pin',
      });

      // Aceptar tanto 200 como 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ ACTUALIZAR EL ESTADO LOCAL INMEDIATAMENTE
        state = state.copyWith(
          isLoading: false,
          isActive: false, // Cambiar a inactivo
          sessionId: null, // Limpiar sessionId
          errorMessage: null,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al desactivar el modo',
      );
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';
      if (e.response?.statusCode == 400) {
        errorMessage = 'PIN incorrecto';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No hay un modo activo';
        // Si el backend dice que no hay modo activo, actualizar estado local
        state = state.copyWith(
          isLoading: false,
          isActive: false,
          sessionId: null,
        );
        return true; // Considerar como éxito porque ya está desactivado
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
}
