import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> scheduleTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;

  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.scheduleTimes = const [],
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int?,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      scheduleTimes:
          List<String>.from(json['schedule_times'] as List? ?? []),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'schedule_times': scheduleTimes,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'notes': notes,
        'is_active': isActive,
      };

  String get frequencyLabel {
    return switch (frequency) {
      'once_daily' => 'Once daily',
      'twice_daily' => 'Twice daily',
      'three_times_daily' => '3x daily',
      'four_times_daily' => '4x daily',
      'as_needed' => 'As needed',
      'weekly' => 'Weekly',
      _ => frequency,
    };
  }
}

class MedicationState {
  final List<Medication> medications;
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.medications = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final ApiClient _client;

  MedicationNotifier(this._client) : super(const MedicationState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get('/medications');
      final data = response.data as Map<String, dynamic>;
      final meds = (data['medications'] as List?)
              ?.map((m) =>
                  Medication.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      state = MedicationState(medications: meds);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load medications');
    }
  }

  Future<bool> add(Medication medication) async {
    try {
      final response = await _client.post(
        '/medications',
        data: medication.toJson(),
      );
      final newMed = Medication.fromJson(
          response.data as Map<String, dynamic>);
      state = state.copyWith(
          medications: [...state.medications, newMed]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _client.delete('/medications/$id');
      state = state.copyWith(
          medications:
              state.medications.where((m) => m.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markTaken(int medicationId, DateTime scheduledTime) async {
    try {
      await _client.post('/medications/$medicationId/log', data: {
        'scheduled_time': scheduledTime.toIso8601String(),
        'status': 'taken',
        'taken_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  return MedicationNotifier(ref.watch(apiClientProvider));
});
