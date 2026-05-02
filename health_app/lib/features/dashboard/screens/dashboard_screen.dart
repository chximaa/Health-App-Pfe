import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/health_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../water/providers/water_provider.dart';
import '../../sleep/providers/sleep_provider.dart';
import '../widgets/animated_character_widget.dart';
import '../widgets/feature_card_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(waterProvider.notifier).loadToday();
      ref.read(sleepProvider.notifier).loadRecent();
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final waterState = ref.watch(waterProvider);
    final sleepState = ref.watch(sleepProvider);

    final greeting = _getGreeting();
    final name = profile?.fullName?.split(' ').first ?? 'there';
    final healthScore = _calculateHealthScore(waterState, sleepState);
    final mood = healthScore >= 75 ? 'thriving' : healthScore >= 50 ? 'growing' : 'wilting';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Top app bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(44, 44),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Hero vitality card ────────────────────────────────────
                _VitalityCard(
                  healthScore: healthScore.toDouble(),
                  mood: mood,
                  name: name,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // ── Quick-log habit strip ─────────────────────────────────
                _QuickLogStrip(
                  waterState: waterState,
                  sleepState: sleepState,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── Features grid ─────────────────────────────────────────
                SectionHeader(
                  title: 'Health Tools',
                  actionLabel: 'See all',
                  onAction: () {},
                ),
                const SizedBox(height: 14),
                _FeaturesGrid(waterState: waterState)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── Health tip ────────────────────────────────────────────
                SectionHeader(title: "Today's Tip"),
                const SizedBox(height: 12),
                _HealthTipCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int _calculateHealthScore(WaterState water, SleepState sleep) {
    double score = 60;
    score += (water.totalMl / AppConstants.dailyWaterGoalMl).clamp(0, 1) * 20;
    score +=
        (sleep.lastNightHours / AppConstants.recommendedSleepHours).clamp(0, 1) * 20;
    return score.clamp(0, 100).toInt();
  }
}

// ─── Vitality hero card ──────────────────────────────────────────────────────

class _VitalityCard extends StatelessWidget {
  final double healthScore;
  final String mood;
  final String name;

  const _VitalityCard({
    required this.healthScore,
    required this.mood,
    required this.name,
  });

  String get _statusLabel {
    if (healthScore >= 80) return 'Thriving';
    if (healthScore >= 60) return 'Growing';
    return 'Needs care';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Plant mascot
          AnimatedCharacterWidget(size: 90, mood: mood),

          const SizedBox(width: 20),

          // Score + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vitality',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${healthScore.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -3,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/100',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: healthScore / 100,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick-log habit strip ───────────────────────────────────────────────────

class _QuickLogStrip extends ConsumerWidget {
  final WaterState waterState;
  final SleepState sleepState;

  const _QuickLogStrip({
    required this.waterState,
    required this.sleepState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterPct =
        waterState.totalMl / AppConstants.dailyWaterGoalMl;
    final sleepPct =
        sleepState.lastNightHours / AppConstants.recommendedSleepHours;

    return Row(
      children: [
        Expanded(
          child: _HabitTile(
            label: 'Water',
            value: '${(waterState.totalMl / 1000).toStringAsFixed(1)}L',
            goal: '${(AppConstants.dailyWaterGoalMl / 1000).toInt()}L goal',
            icon: Icons.water_drop_rounded,
            color: AppColors.chartBlue,
            progress: waterPct,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HabitTile(
            label: 'Sleep',
            value: '${sleepState.lastNightHours.toStringAsFixed(1)}h',
            goal: '${AppConstants.recommendedSleepHours.toInt()}h goal',
            icon: Icons.bedtime_rounded,
            color: AppColors.chartPurple,
            progress: sleepPct,
            onTap: () => context.go('/sleep'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HabitTile(
            label: 'Meds',
            value: 'Today',
            goal: 'Tap to check',
            icon: Icons.medication_rounded,
            color: AppColors.secondary,
            progress: 0.75,
            onTap: () => context.go('/medications'),
          ),
        ),
      ],
    );
  }
}

class _HabitTile extends StatelessWidget {
  final String label;
  final String value;
  final String goal;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const _HabitTile({
    required this.label,
    required this.value,
    required this.goal,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Text(
                  '${(progress * 100).clamp(0, 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Features grid ───────────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  final WaterState waterState;

  const _FeaturesGrid({required this.waterState});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.08,
      children: [
        FeatureCard(
          title: 'Symptoms',
          subtitle: 'Log & analyse',
          icon: Icons.health_and_safety_outlined,
          iconColor: AppColors.chartCoral,
          bgColor: const Color(0xFFFFF5F2),
          onTap: () => context.go('/symptoms'),
        ),
        FeatureCard(
          title: 'Analytics',
          subtitle: 'View your trends',
          icon: Icons.bar_chart_rounded,
          iconColor: AppColors.chartBlue,
          bgColor: const Color(0xFFF0F6FF),
          onTap: () => context.go('/analytics'),
        ),
        FeatureCard(
          title: 'Medications',
          subtitle: 'Track your meds',
          icon: Icons.medication_outlined,
          iconColor: AppColors.secondary,
          bgColor: const Color(0xFFF0FAF4),
          onTap: () => context.go('/medications'),
        ),
        FeatureCard(
          title: 'Sleep',
          subtitle: 'Log your rest',
          icon: Icons.bedtime_outlined,
          iconColor: AppColors.chartPurple,
          bgColor: const Color(0xFFF7F0FF),
          onTap: () => context.go('/sleep'),
        ),
        FeatureCard(
          title: 'Hydration',
          subtitle:
              '${waterState.totalMl} / ${AppConstants.dailyWaterGoalMl} ml',
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.chartBlue,
          bgColor: const Color(0xFFF0F6FF),
          badge: waterState.totalMl >= AppConstants.dailyWaterGoalMl
              ? const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D52), size: 16)
              : null,
          onTap: () {},
        ),
        FeatureCard(
          title: 'AI Predict',
          subtitle: 'Disease insights',
          icon: Icons.psychology_rounded,
          iconColor: AppColors.chartTeal,
          bgColor: const Color(0xFFF0FAFA),
          onTap: () => context.go('/symptoms'),
        ),
      ],
    );
  }
}

// ─── Health tip card ─────────────────────────────────────────────────────────

class _HealthTipCard extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = const [
    {
      'title': 'Stay Hydrated',
      'body': 'Drinking enough water daily can boost your energy and focus by up to 14%.',
      'icon': Icons.water_drop_rounded,
      'gradient': [Color(0xFF4A90D9), Color(0xFF357ABD)],
    },
    {
      'title': 'Move Your Body',
      'body': 'A 20-minute walk lowers cortisol, the stress hormone, significantly.',
      'icon': Icons.directions_walk_rounded,
      'gradient': [Color(0xFF2E7D52), Color(0xFF5FAD80)],
    },
    {
      'title': 'Prioritise Sleep',
      'body': '7–9 hours of sleep each night strengthens your immune system and memory.',
      'icon': Icons.bedtime_rounded,
      'gradient': [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    },
    {
      'title': 'Breathe Deeply',
      'body': 'Box breathing (4-4-4-4) activates your parasympathetic nervous system.',
      'icon': Icons.air_rounded,
      'gradient': [Color(0xFF14B8A6), Color(0xFF0F766E)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    final gradientColors = tip['gradient'] as List<Color>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withOpacity(0.12),
            gradientColors[1].withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tip['icon'] as IconData,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: gradientColors[0],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['body'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
