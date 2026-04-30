import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class WaterState {
  final int totalMl;
  final List<Map<String, dynamic>> logs;
  final bool isLoading;

  const WaterState({
    this.totalMl = 0,
    this.logs = const [],
    this.isLoading = false,
  });

  WaterState copyWith({int? totalMl, List<Map<String, dynamic>>? logs, bool? isLoading}) {
    return WaterState(
      totalMl: totalMl ?? this.totalMl,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WaterNotifier extends StateNotifier<WaterState> {
  final ApiClient _client;

  WaterNotifier(this._client) : super(const WaterState());

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _client.get(
        '/water',
        queryParameters: {
          'date': DateTime.now().toIso8601String().split('T').first,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final logs = List<Map<String, dynamic>>.from(data['logs'] as List? ?? []);
      final total = (data['total_ml'] as num?)?.toInt() ?? 0;
      state = WaterState(totalMl: total, logs: logs);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addWater(int amountMl) async {
    try {
      await _client.post('/water', data: {'amount_ml': amountMl});
      state = state.copyWith(totalMl: state.totalMl + amountMl);
    } catch (_) {}
  }
}

final waterProvider =
    StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  return WaterNotifier(ref.watch(apiClientProvider));
});
