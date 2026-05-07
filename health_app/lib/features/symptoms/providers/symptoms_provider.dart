import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class SymptomEntry {
  final String name;
  final int severity; // 1–10

  const SymptomEntry({required this.name, required this.severity});

  Map<String, dynamic> toJson() => {'name': name, 'severity': severity};
}

class SymptomsState {
  final List<SymptomEntry> selected;
  final List<Map<String, dynamic>> recentLogs;
  final Map<String, dynamic>? latestPrediction;
  final bool isLoading;
  final bool isPredicting;
  final String? error;

  const SymptomsState({
    this.selected = const [],
    this.recentLogs = const [],
    this.latestPrediction,
    this.isLoading = false,
    this.isPredicting = false,
    this.error,
  });

  SymptomsState copyWith({
    List<SymptomEntry>? selected,
    List<Map<String, dynamic>>? recentLogs,
    Map<String, dynamic>? latestPrediction,
    bool? isLoading,
    bool? isPredicting,
    String? error,
  }) {
    return SymptomsState(
      selected: selected ?? this.selected,
      recentLogs: recentLogs ?? this.recentLogs,
      latestPrediction: latestPrediction ?? this.latestPrediction,
      isLoading: isLoading ?? this.isLoading,
      isPredicting: isPredicting ?? this.isPredicting,
      error: error ?? this.error,
    );
  }
}

class SymptomsNotifier extends StateNotifier<SymptomsState> {
  final ApiClient _client;

  SymptomsNotifier(this._client) : super(const SymptomsState());

  void toggleSymptom(String name) {
    final current = List<SymptomEntry>.from(state.selected);
    final idx = current.indexWhere((s) => s.name == name);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(SymptomEntry(name: name, severity: 5));
    }
    state = state.copyWith(selected: current);
  }

  void updateSeverity(String name, int severity) {
    final current = state.selected.map((s) {
      return s.name == name ? SymptomEntry(name: name, severity: severity) : s;
    }).toList();
    state = state.copyWith(selected: current);
  }

  bool isSelected(String name) =>
      state.selected.any((s) => s.name == name);

  Future<bool> logSymptoms({String? notes, double? temperature}) async {
    if (state.selected.isEmpty) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _client.post('/symptoms', data: {
        'symptoms': state.selected.map((s) => s.toJson()).toList(),
        'notes': notes,
        'body_temp_c': temperature,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to log symptoms');
      return false;
    }
  }

  Future<void> predict() async {
    if (state.selected.isEmpty) return;
    state = state.copyWith(isPredicting: true, error: null);
    try {
      final response = await _client.post('/predict', data: {
        'symptoms': state.selected.map((s) => s.toJson()).toList(),
      });
      state = state.copyWith(
        isPredicting: false,
        latestPrediction: response.data as Map<String, dynamic>,
      );
    } catch (_) {
      state = state.copyWith(
          isPredicting: false, error: 'Prediction failed');
    }
  }

  Future<void> loadRecentLogs() async {
    try {
      final response =
          await _client.get('/symptoms', queryParameters: {'limit': 10});
      final data = response.data as Map<String, dynamic>;
      state = state.copyWith(
        recentLogs: List<Map<String, dynamic>>.from(
            data['logs'] as List? ?? []),
      );
    } catch (_) {}
  }

  void clearSelection() {
    state = state.copyWith(
        selected: [], latestPrediction: null, error: null);
  }
}

final symptomsProvider =
    StateNotifierProvider<SymptomsNotifier, SymptomsState>((ref) {
  return SymptomsNotifier(ref.watch(apiClientProvider));
});
