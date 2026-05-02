import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/dashboard/widgets/animated_character_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mascot hero
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background rings
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.light.withOpacity(0.4),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.light.withOpacity(0.5),
                        ),
                      ),
                      // Plant mascot
                      const AnimatedCharacterWidget(
                        size: 120,
                        mood: 'thriving',
                      ),
                    ],
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1.03, 1.03),
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 44),

                  Text(
                    'Your health,\ngrown daily',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.2,
                      height: 1.15,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Track symptoms, monitor habits, and get AI-powered health insights — all in one place.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 600.ms),
                ],
              ),
            ),

            // Feature pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _FeaturePill(
                      icon: Icons.psychology_rounded, label: 'AI Insights'),
                  _FeaturePill(
                      icon: Icons.bar_chart_rounded, label: 'Analytics'),
                  _FeaturePill(
                      icon: Icons.medication_outlined, label: 'Med Tracker'),
                  _FeaturePill(
                      icon: Icons.water_drop_outlined, label: 'Hydration'),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

            const SizedBox(height: 36),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/profile-setup'),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Set up your profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: Text(
                      'Continue without profile',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 650.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
