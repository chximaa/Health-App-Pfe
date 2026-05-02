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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Symptoms'),
        backgroundColor: AppColors.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Log Symptoms'),
                Tab(text: 'AI Insights'),
              ],
            ),
          ),
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
            'What are you\nexperiencing?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select all symptoms that apply',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Symptom chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.symptomList.map((symptom) {
              final selected =
                  ref.read(symptomsProvider.notifier).isSelected(symptom);
              return GestureDetector(
                onTap: () =>
                    ref.read(symptomsProvider.notifier).toggleSymptom(symptom),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.divider,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Severity sliders
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
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: cardDecoration(radius: 16),
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
                            fontSize: 14,
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
                      inactiveColor:
                          _severityColor(symptom.severity).withOpacity(0.15),
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
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Any additional context... (optional)',
              hintStyle: const TextStyle(
                  color: AppColors.textHint, fontSize: 14),
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 24),

          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(state.error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          GradientButton(
            label: state.selected.isEmpty
                ? 'Select symptoms first'
                : 'Analyse with AI',
            isLoading: state.isLoading || state.isPredicting,
            onPressed: state.selected.isEmpty ? null : _logAndPredict,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(SymptomsState state) {
    if (state.isPredicting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Analysing your symptoms…',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (state.latestPrediction == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_outlined,
                  size: 36, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            const Text(
              'No analysis yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Log your symptoms and tap Analyse to get AI-powered health insights.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    final predictions =
        state.latestPrediction!['predictions'] as List? ?? [];
    final tips =
        state.latestPrediction!['health_tips'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Based on your reported symptoms',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ...List.generate(predictions.length, (i) {
            final p = predictions[i] as Map<String, dynamic>;
            return _PredictionCard(
              rank: i + 1,
              disease: p['disease'] as String,
              confidence: (p['confidence'] as num).toDouble(),
              actions:
                  List<String>.from(p['actions'] as List? ?? []),
            )
                .animate()
                .fadeIn(delay: (i * 80).ms)
                .slideX(begin: 0.15, end: 0);
          }),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Health Tips'),
            const SizedBox(height: 12),
            ...tips.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.light.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.warning.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.warning, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Not a medical diagnosis. Always consult a healthcare professional.',
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _confidenceColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
                    fontSize: 15,
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
              minHeight: 5,
              backgroundColor: AppColors.divider,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_confidenceColor),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Suggested actions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            ...actions.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          a,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
