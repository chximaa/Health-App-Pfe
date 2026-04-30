import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Mascot + Score card
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
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
                              'Health Score',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$healthScore',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              healthScore >= 80
                                  ? 'Excellent! Keep it up!'
                                  : healthScore >= 60
                                      ? 'Good, room to improve'
                                      : 'Let\'s work on your health',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: healthScore / 100,
                                minHeight: 6,
                                backgroundColor:
                                    Colors.white.withOpacity(0.2),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedCharacterWidget(
                        size: 100,
                        mood: healthScore >= 70 ? 'happy' : 'sleeping',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Quick Stats
                const SectionHeader(title: 'Today\'s Summary'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: HealthCard(
                        padding: const EdgeInsets.all(16),
                        child: StatTile(
                          label: 'Water',
                          value: (waterState.totalMl / 1000)
                              .toStringAsFixed(1),
                          unit: 'L',
                          icon: Icons.water_drop_rounded,
                          iconColor: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HealthCard(
                        padding: const EdgeInsets.all(16),
                        child: StatTile(
                          label: 'Sleep',
                          value: sleepState.lastNightHours
                              .toStringAsFixed(1),
                          unit: 'hrs',
                          icon: Icons.bedtime_rounded,
                          iconColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Feature Grid
                const SectionHeader(title: 'Features'),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.05,
                  children: [
                    FeatureCard(
                      title: 'Symptoms',
                      subtitle: 'Log how you feel',
                      icon: Icons.sick_outlined,
                      iconColor: const Color(0xFFE53935),
                      bgColor: const Color(0xFFFFF3F3),
                      onTap: () => context.go('/symptoms'),
                    ),
                    FeatureCard(
                      title: 'Analytics',
                      subtitle: 'View your trends',
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.secondary,
                      bgColor: const Color(0xFFEDF4F6),
                      onTap: () => context.go('/analytics'),
                    ),
                    FeatureCard(
                      title: 'Medications',
                      subtitle: 'Track your meds',
                      icon: Icons.medication_outlined,
                      iconColor: const Color(0xFF43A047),
                      bgColor: const Color(0xFFF1FBF1),
                      onTap: () => context.go('/medications'),
                    ),
                    FeatureCard(
                      title: 'Sleep',
                      subtitle: 'Log your sleep',
                      icon: Icons.bedtime_outlined,
                      iconColor: AppColors.accent,
                      bgColor: const Color(0xFFF0F4F2),
                      onTap: () => context.go('/sleep'),
                    ),
                    FeatureCard(
                      title: 'Water',
                      subtitle: '${waterState.totalMl} / ${AppConstants.dailyWaterGoalMl} ml',
                      icon: Icons.water_drop_outlined,
                      iconColor: const Color(0xFF1E88E5),
                      bgColor: const Color(0xFFEEF6FF),
                      badge: waterState.totalMl >=
                              AppConstants.dailyWaterGoalMl
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF43A047), size: 18)
                          : null,
                      onTap: () {},
                    ),
                    FeatureCard(
                      title: 'AI Predict',
                      subtitle: 'Disease insights',
                      icon: Icons.psychology_rounded,
                      iconColor: const Color(0xFF7B1FA2),
                      bgColor: const Color(0xFFF7EEF9),
                      onTap: () => context.go('/symptoms'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tip of the day
                _TipCard(),
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
    // Water score (0–20)
    score += (water.totalMl / AppConstants.dailyWaterGoalMl).clamp(0, 1) * 20;
    // Sleep score (0–20)
    score +=
        (sleep.lastNightHours / AppConstants.recommendedSleepHours).clamp(0, 1) *
            20;
    return score.clamp(0, 100).toInt();
  }
}

class _TipCard extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = const [
    {
      'title': 'Stay Hydrated',
      'body':
          'Drinking 8 glasses of water daily can improve energy and skin health.',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF1E88E5),
    },
    {
      'title': 'Get Moving',
      'body':
          'Even a 20-minute walk can reduce stress and boost your mood.',
      'icon': Icons.directions_walk_rounded,
      'color': Color(0xFF43A047),
    },
    {
      'title': 'Sleep Well',
      'body':
          '7-9 hours of sleep supports immune function and mental clarity.',
      'icon': Icons.bedtime_rounded,
      'color': AppColors.accent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    return HealthCard(
      padding: const EdgeInsets.all(20),
      color: (tip['color'] as Color).withOpacity(0.07),
      withShadow: false,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (tip['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(tip['icon'] as IconData,
                color: tip['color'] as Color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip: ${tip['title']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['body'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
