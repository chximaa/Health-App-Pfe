import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../water/providers/water_provider.dart';
import '../../sleep/providers/sleep_provider.dart';

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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ·';
    if (h < 17) return 'Good afternoon ·';
    return 'Good evening ·';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final waterState = ref.watch(waterProvider);
    final sleepState = ref.watch(sleepProvider);

    final firstName = (profile?.fullName ?? '').split(' ').first;
    final lastName = (profile?.fullName ?? '').split(' ').skip(1).join(' ');

    final waterPct =
        (waterState.totalMl / AppConstants.dailyWaterGoalMl).clamp(0.0, 1.0);
    final sleepPct =
        (sleepState.lastNightHours / AppConstants.recommendedSleepHours)
            .clamp(0.0, 1.0);
    final healthScore = ((waterPct * 0.4 + sleepPct * 0.4 + 0.66 * 0.2) * 100)
        .round()
        .clamp(0, 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header ──────────────────────────────────────────
            _GradientHeader(
              greeting: _greeting,
              firstName: firstName.isEmpty ? 'there' : firstName,
              lastName: lastName,
              healthScore: healthScore,
              waterMl: waterState.totalMl,
              waterPct: waterPct,
              sleepHours: sleepState.lastNightHours,
              sleepPct: sleepPct,
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 14),

            // ── Mood & BMI row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniCard(
                      label: 'Mood Today',
                      iconBg: AppColors.rose100,
                      icon: '😊',
                      content: _MoodSelector(),
                      sub: 'Good · Logged 10m ago',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniCard(
                      label: 'BMI',
                      iconBg: AppColors.sage100,
                      icon: '⚖️',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('22.5',
                              style: AppTextStyles.num
                                  .copyWith(color: AppColors.sage700)),
                          const SizedBox(height: 2),
                          Text('Normal range',
                              style: AppTextStyles.caption),
                          const SizedBox(height: 8),
                          _ProgressBar(
                              value: 0.55, color: AppColors.sage500),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(
                begin: 0.06, end: 0),

            const SizedBox(height: 12),

            // ── Medications card ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MedicationsCard(),
            ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

            const SizedBox(height: 12),

            // ── Today's tip ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const _TipBanner(),
            ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

            // Spacing for floating nav
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient Header ─────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final String greeting;
  final String firstName;
  final String lastName;
  final int healthScore;
  final int waterMl;
  final double waterPct;
  final double sleepHours;
  final double sleepPct;

  const _GradientHeader({
    required this.greeting,
    required this.firstName,
    required this.lastName,
    required this.healthScore,
    required this.waterMl,
    required this.waterPct,
    required this.sleepHours,
    required this.sleepPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.plum900, AppColors.plum700],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Decorative orb
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status bar row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.48),
                                  fontWeight: FontWeight.w500,
                                )),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: firstName,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  if (lastName.isNotEmpty)
                                    TextSpan(
                                      text: ' $lastName',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification bell
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🔔', style: TextStyle(fontSize: 18)),
                          ),
                          Positioned(
                            top: 7,
                            right: 7,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.rose500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.plum900, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Score glass card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.14), width: 1),
                    ),
                    child: Row(
                      children: [
                        // Ring
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(64, 64),
                                painter: _RingPainter(
                                  progress: healthScore / 100,
                                  trackColor: Colors.white.withOpacity(0.12),
                                  fillColor: AppColors.sage300,
                                ),
                              ),
                              Text(
                                '$healthScore%',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                healthScore >= 80
                                    ? 'Looking Good! 🌿'
                                    : healthScore >= 60
                                        ? 'On Track 💪'
                                        : 'Needs Attention ⚠️',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2 glasses behind your daily hydration goal.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.55),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.sage300.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: AppColors.sage300.withOpacity(0.3)),
                          ),
                          child: Text(
                            '+3%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sage200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Metrics row
                  Row(
                    children: [
                      Expanded(
                        child: _MetricChip(
                          emoji: '💧',
                          value: '${(waterMl / 1000).toStringAsFixed(2)}L',
                          label: 'Water',
                          progress: waterPct,
                          color: AppColors.sage400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricChip(
                          emoji: '🌙',
                          value: '${sleepHours.toStringAsFixed(1)}h',
                          label: 'Sleep',
                          progress: sleepPct,
                          color: AppColors.plum400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricChip(
                          emoji: '👟',
                          value: '6.4k',
                          label: 'Steps',
                          progress: 0.64,
                          color: AppColors.sage300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final double progress;
  final Color color;

  const _MetricChip({
    required this.emoji,
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.shortestSide - 10) / 2;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      progress.clamp(0, 1) * 2 * math.pi,
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}

// ─── Mini Card ───────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  final String label;
  final Color iconBg;
  final String icon;
  final Widget content;
  final String sub;

  const _MiniCard({
    required this.label,
    required this.iconBg,
    required this.icon,
    required this.content,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─── Mood Selector ────────────────────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const moods = ['😢', '😐', '😊', '😄'];
    return Row(
      children: moods.map((m) {
        final isSelected = m == '😊';
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            m,
            style: TextStyle(
              fontSize: isSelected ? 18 : 14,
              color: isSelected ? null : null,
            ).copyWith(
              color: isSelected ? null : const Color(0x66000000),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Progress Bar ────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Medications Card ────────────────────────────────────────────────────────

class _MedicationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('💊 Medication Today', style: AppTextStyles.cardTitle),
                Text('See all',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.sage600)),
              ],
            ),
          ),
          const Divider(height: 1),
          _MedItem(
            emoji: '💊',
            bg: AppColors.sage100,
            name: 'Vitamin D — 1000 IU',
            time: '⏰ 8:00 AM · Daily',
            taken: true,
          ),
          const Divider(height: 1),
          _MedItem(
            emoji: '💉',
            bg: AppColors.rose100,
            name: 'Ventolin — 100mcg',
            time: '⏰ 1:00 PM · As needed',
            taken: false,
          ),
        ],
      ),
    );
  }
}

class _MedItem extends StatelessWidget {
  final String emoji;
  final Color bg;
  final String name;
  final String time;
  final bool taken;

  const _MedItem({
    required this.emoji,
    required this.bg,
    required this.name,
    required this.time,
    required this.taken,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodySemiBold),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: taken ? AppColors.sage100 : AppColors.plum700,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              taken ? '✓ Taken' : 'Mark',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: taken ? AppColors.sage700 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tip Banner ───────────────────────────────────────────────────────────────

class _TipBanner extends StatelessWidget {
  const _TipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sage50, AppColors.plum50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sage200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('💡', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Tip",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.sage700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You slept 45 min less than usual. Try a 10-min wind-down routine tonight.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 11,
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
