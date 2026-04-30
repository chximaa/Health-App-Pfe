import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/health_card.dart';
import '../providers/symptoms_provider.dart';

class SymptomsScreen extends ConsumerStatefulWidget {
  const SymptomsScreen({super.key});

  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.microtask(
        () => ref.read(symptomsProvider.notifier).loadRecentLogs());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _logAndPredict() async {
    final notifier = ref.read(symptomsProvider.notifier);
    final logged = await notifier.logSymptoms(notes: _notesCtrl.text);
    if (logged) {
      await notifier.predict();
      _tabCtrl.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symptomsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text('Symptoms'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Log Symptoms'),
            Tab(text: 'AI Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildLogTab(state),
          _buildInsightsTab(state),
        ],
      ),
    );
  }

  Widget _buildLogTab(SymptomsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you experiencing?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select all that apply, then set severity',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Symptom chips grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.symptomList.map((symptom) {
              final selected =
                  ref.read(symptomsProvider.notifier).isSelected(symptom);
              return GestureDetector(
                onTap: () {
                  ref
                      .read(symptomsProvider.notifier)
                      .toggleSymptom(symptom);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Severity sliders for selected symptoms
          if (state.selected.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'Set Severity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...state.selected.map((symptom) {
              return HealthCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          symptom.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _severityColor(symptom.severity)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${symptom.severity}/10',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _severityColor(symptom.severity),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: symptom.severity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: _severityColor(symptom.severity),
                      onChanged: (v) => ref
                          .read(symptomsProvider.notifier)
                          .updateSeverity(symptom.name, v.round()),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 20),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Additional notes (optional)',
              hintText: 'Any other details...',
              prefixIcon:
                  Icon(Icons.notes_rounded, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 24),

          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(state.error!,
                  style: const TextStyle(color: AppColors.error)),
            ),

          const SizedBox(height: 16),
          GradientButton(
            label: state.selected.isEmpty
                ? 'Select symptoms first'
                : 'Log & Get AI Prediction',
            isLoading: state.isLoading || state.isPredicting,
            onPressed: state.selected.isEmpty ? null : _logAndPredict,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(SymptomsState state) {
    if (state.isPredicting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Analyzing your symptoms...',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (state.latestPrediction == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            const Text(
              'No predictions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log your symptoms to get AI-powered insights',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final predictions = state.latestPrediction!['predictions'] as List? ?? [];
    final tips = state.latestPrediction!['health_tips'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Prediction Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Based on your reported symptoms',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ...List.generate(predictions.length, (i) {
            final p = predictions[i] as Map<String, dynamic>;
            final disease = p['disease'] as String;
            final confidence = (p['confidence'] as num).toDouble();
            final actions = List<String>.from(p['actions'] as List? ?? []);
            return _PredictionCard(
              rank: i + 1,
              disease: disease,
              confidence: confidence,
              actions: actions,
            ).animate().fadeIn(delay: (i * 100).ms).slideX(begin: 0.2);
          }),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Health Tips'),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HealthCard(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.muted.withOpacity(0.15),
                    withShadow: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.warning.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is not a medical diagnosis. Always consult a healthcare professional.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(int severity) {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

class _PredictionCard extends StatelessWidget {
  final int rank;
  final String disease;
  final double confidence;
  final List<String> actions;

  const _PredictionCard({
    required this.rank,
    required this.disease,
    required this.confidence,
    required this.actions,
  });

  Color get _confidenceColor {
    if (confidence >= 0.7) return AppColors.error;
    if (confidence >= 0.4) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: HealthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _confidenceColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disease,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _confidenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: _confidenceColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_confidenceColor),
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Suggested Actions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...actions.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            a,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
