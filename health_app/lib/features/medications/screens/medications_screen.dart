import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/health_card.dart';
import '../providers/medication_provider.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() =>
      _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(medicationProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/add-medication'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : state.medications.isEmpty
              ? _buildEmptyState(context)
              : _buildMedicationList(state),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medication_outlined, size: 72, color: AppColors.divider),
          const SizedBox(height: 16),
          const Text(
            'No medications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your medications to track and get reminders',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-medication'),
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(MedicationState state) {
    final active = state.medications.where((m) => m.isActive).toList();
    final inactive = state.medications.where((m) => !m.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active.isNotEmpty) ...[
            const SectionHeader(title: 'Active Medications'),
            const SizedBox(height: 14),
            ...active.map((med) => _MedicationCard(
                  medication: med,
                  onDelete: () =>
                      ref.read(medicationProvider.notifier).delete(med.id!),
                  onMarkTaken: () => ref
                      .read(medicationProvider.notifier)
                      .markTaken(med.id!, DateTime.now()),
                )),
          ],
          if (inactive.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Inactive'),
            const SizedBox(height: 14),
            ...inactive.map((med) => _MedicationCard(
                  medication: med,
                  isInactive: true,
                  onDelete: () =>
                      ref.read(medicationProvider.notifier).delete(med.id!),
                  onMarkTaken: null,
                )),
          ],
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onDelete;
  final VoidCallback? onMarkTaken;
  final bool isInactive;

  const _MedicationCard({
    required this.medication,
    required this.onDelete,
    this.onMarkTaken,
    this.isInactive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: HealthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isInactive
                        ? AppColors.divider
                        : const Color(0xFF43A047).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: isInactive
                        ? AppColors.textHint
                        : const Color(0xFF43A047),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isInactive
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${medication.dosage} · ${medication.frequencyLabel}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textHint),
                  onSelected: (v) {
                    if (v == 'delete') {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Medication'),
                          content: Text(
                              'Remove ${medication.name} from your list?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                              child: const Text('Delete',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (medication.scheduleTimes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: medication.scheduleTimes.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          t,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (onMarkTaken != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onMarkTaken,
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 16),
                  label: const Text('Mark as Taken'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF43A047),
                    side: const BorderSide(color: Color(0xFF43A047)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
