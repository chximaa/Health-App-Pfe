import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class SleepState {
  final double lastNightHours;
  final int lastNightQuality; // 1–5
  final List<Map<String, dynamic>> recentLogs;
  final bool isLoading;

  const SleepState({
    this.lastNightHours = 0,
    this.lastNightQuality = 0,
    this.recentLogs = const [],
    this.isLoading = false,
  });

  SleepState copyWith({
    double? lastNightHours,
    int? lastNightQuality,
    List<Map<String, dynamic>>? recentLogs,
    bool? isLoading,
  }) {
    return SleepState(
      lastNightHours: lastNightHours ?? this.lastNightHours,
      lastNightQuality: lastNightQuality ?? this.lastNightQuality,
      recentLogs: recentLogs ?? this.recentLogs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SleepNotifier extends StateNotifier<SleepState> {
  final ApiClient _client;

  SleepNotifier(this._client) : super(const SleepState());

  Future<void> loadRecent() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _client.get('/sleep', queryParameters: {'limit': 7});
      final data = response.data as Map<String, dynamic>;
      final logs =
          List<Map<String, dynamic>>.from(data['logs'] as List? ?? []);
      double lastHours = 0;
      int lastQuality = 0;
      if (logs.isNotEmpty) {
        lastHours = (logs.first['duration_hours'] as num?)?.toDouble() ?? 0;
        lastQuality = (logs.first['quality'] as num?)?.toInt() ?? 0;
      }
      state = SleepState(
        lastNightHours: lastHours,
        lastNightQuality: lastQuality,
        recentLogs: logs,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> logSleep({
    required DateTime sleepStart,
    required DateTime sleepEnd,
    required int quality,
    String? notes,
  }) async {
    try {
      await _client.post('/sleep', data: {
        'sleep_start': sleepStart.toIso8601String(),
        'sleep_end': sleepEnd.toIso8601String(),
        'quality': quality,
        'notes': notes,
      });
      await loadRecent();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final sleepProvider =
    StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  return SleepNotifier(ref.watch(apiClientProvider));
});
