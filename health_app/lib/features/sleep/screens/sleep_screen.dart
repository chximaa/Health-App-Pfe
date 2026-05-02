import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/health_card.dart';
import '../providers/sleep_provider.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 3;
  bool _isSaving = false;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sleepProvider.notifier).loadRecent());
  }

  double _calculateDuration() {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    var wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60;
    return (wakeMinutes - bedMinutes) / 60.0;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final sleepStart = DateTime(
      now.year,
      now.month,
      now.day - 1,
      _bedtime.hour,
      _bedtime.minute,
    );
    final sleepEnd = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    final ok = await ref.read(sleepProvider.notifier).logSleep(
          sleepStart: sleepStart,
          sleepEnd: sleepEnd,
          quality: _quality,
        );
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sleep logged!'),
            backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepProvider);
    final duration = _calculateDuration();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add_rounded),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Last night summary
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Night',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: state.lastNightHours
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              const TextSpan(
                                text: ' hrs',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < state.lastNightQuality
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.bedtime_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Log form
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showForm
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: HealthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log Sleep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeSelector(
                            label: 'Bedtime',
                            time: _bedtime,
                            icon: Icons.nights_stay_outlined,
                            onChanged: (t) =>
                                setState(() => _bedtime = t),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _TimeSelector(
                            label: 'Wake Time',
                            time: _wakeTime,
                            icon: Icons.wb_sunny_outlined,
                            onChanged: (t) =>
                                setState(() => _wakeTime = t),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${duration.toStringAsFixed(1)} hours',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sleep Quality',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _quality = star),
                          child: Icon(
                            star <= _quality
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: star <= _quality
                                ? Colors.amber
                                : AppColors.divider,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Save Sleep Log',
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent logs
            if (state.recentLogs.isNotEmpty) ...[
              const SectionHeader(title: 'Recent Logs'),
              const SizedBox(height: 14),
              ...state.recentLogs.take(7).map((log) {
                final start = DateTime.parse(
                    log['sleep_start'] as String);
                final hours =
                    (log['duration_hours'] as num?)?.toDouble() ?? 0;
                final quality = (log['quality'] as num?)?.toInt() ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: HealthCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.bedtime_rounded,
                              color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEE, MMM d').format(start),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${hours.toStringAsFixed(1)} hours',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                              5,
                              (i) => Icon(
                                    i < quality
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  )),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final IconData icon;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
