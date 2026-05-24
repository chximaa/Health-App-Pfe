import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SmartWatchScreen extends StatelessWidget {
  const SmartWatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.plum100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('⌚', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Watch',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.plum900,
                        ),
                      ),
                      Text(
                        'Integration',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.neutral400),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // Coming Soon card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.plum900, AppColors.plum700],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Text('⌚', style: TextStyle(fontSize: 56))
                        .animate()
                        .slideY(begin: 0.2, end: 0, delay: 100.ms)
                        .fadeIn(delay: 100.ms),
                    const SizedBox(height: 20),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Smart watch integration will allow you to sync your\nhealth data automatically — heart rate, steps, sleep,\nand more — directly from your wearable device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(
                  begin: 0.06, end: 0),

              const SizedBox(height: 24),

              // Feature preview cards
              Text('Planned Features', style: AppTextStyles.sectionTitle)
                  .animate()
                  .fadeIn(delay: 150.ms),
              const SizedBox(height: 12),

              ...[
                (
                  '❤️',
                  'Heart Rate',
                  'Continuous monitoring & alerts',
                  AppColors.rose100
                ),
                (
                  '🚶',
                  'Step Count',
                  'Daily goals & activity streaks',
                  AppColors.sage100
                ),
                (
                  '😴',
                  'Auto Sleep',
                  'Hands-free sleep detection',
                  AppColors.plum100
                ),
                (
                  '🩸',
                  'SpO₂',
                  'Blood oxygen saturation tracking',
                  AppColors.rose50
                ),
              ].asMap().entries.map((e) {
                final i = e.key;
                final (emoji, title, sub, bg) = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTextStyles.bodySemiBold),
                              Text(sub, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Soon',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 180 + i * 60),
                          duration: 350.ms)
                      .slideX(begin: 0.04, end: 0),
                );
              }),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
