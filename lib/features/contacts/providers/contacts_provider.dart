// ignore_for_file: unused_field

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

class ContactsState {
  final bool isLoading;
  final List<Map<String, dynamic>> contacts;
  final String? errorMessage;

  ContactsState({
    required this.isLoading,
    required this.contacts,
    this.errorMessage,
  });

  factory ContactsState.initial() {
    return ContactsState(
      isLoading: false,
      contacts: [],
    );
  }

  ContactsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? contacts,
    String? errorMessage,
  }) {
    return ContactsState(
      isLoading: isLoading ?? this.isLoading,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage,
    );
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return ContactsNotifier(dioClient, secureStorage);
});

class ContactsNotifier extends StateNotifier<ContactsState> {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  ContactsNotifier(this._dioClient, this._secureStorage)
      : super(ContactsState.initial());

  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _dioClient.get('/safe-contacts');
      final contacts = response.data['contacts'] as List? ?? [];

      state = state.copyWith(
        isLoading: false,
        contacts: contacts.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar contactos',
      );
    }
  }

  Future<bool> createContact(Map<String, dynamic> contactData) async {
    try {
      final response =
          await _dioClient.post('/safe-contacts', data: contactData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadContacts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateContact(
      String id, Map<String, dynamic> contactData) async {
    try {
      final response =
          await _dioClient.patch('/safe-contacts/$id', data: contactData);

      if (response.statusCode == 200) {
        await loadContacts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleContact(String id) async {
    try {
      final response = await _dioClient.patch('/safe-contacts/$id/toggle');

      if (response.statusCode == 200) {
        await loadContacts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteContact(String id) async {
    try {
      final response = await _dioClient.delete('/safe-contacts/$id');

      if (response.statusCode == 200) {
        await loadContacts();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
