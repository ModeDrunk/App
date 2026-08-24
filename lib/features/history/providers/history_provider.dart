import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class HistoryState {
  final bool isLoading;
  final List<Map<String, dynamic>> sessions;
  final String? errorMessage;

  HistoryState({
    required this.isLoading,
    required this.sessions,
    this.errorMessage,
  });

  factory HistoryState.initial() {
    return HistoryState(
      isLoading: false,
      sessions: [],
    );
  }

  HistoryState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? sessions,
    String? errorMessage,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return HistoryNotifier(dioClient);
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  final DioClient _dioClient;

  HistoryNotifier(this._dioClient) : super(HistoryState.initial());

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _dioClient.get('/drunk-mode/history?limit=50');
      final sessions = response.data['sessions'] as List? ?? [];

      state = state.copyWith(
        isLoading: false,
        sessions: sessions.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar historial',
      );
    }
  }
}
