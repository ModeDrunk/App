// ignore_for_file: unused_field

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

class ProfileState {
  final bool isLoading;
  final String? phone;
  final bool notificationsEnabled;

  ProfileState({
    required this.isLoading,
    this.phone,
    required this.notificationsEnabled,
  });

  factory ProfileState.initial() {
    return ProfileState(
      isLoading: false,
      notificationsEnabled: true,
    );
  }

  ProfileState copyWith({
    bool? isLoading,
    String? phone,
    bool? notificationsEnabled,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return ProfileNotifier(dioClient, secureStorage);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  ProfileNotifier(this._dioClient, this._secureStorage)
      : super(ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _dioClient.get('/auth/me');
      final phone = response.data['phone'] as String?;

      state = state.copyWith(
        isLoading: false,
        phone: phone,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> changePin(
      {required String currentPin, required String newPin}) async {
    try {
      // Endpoint para cambiar PIN (a implementar en backend)
      final response = await _dioClient.post('/auth/change-pin', data: {
        'currentPin': currentPin,
        'newPin': newPin,
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void toggleNotifications() {
    state = state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    );
    // TODO: Guardar preferencia en backend
  }
}
