import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final waterState = ref.watch(waterProvider);
    final sleepState = ref.watch(sleepProvider);

    final name = profile?.fullName?.split(' ').first ?? 'there';
    final initials = (profile?.fullName ?? 'U')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join()
        .toUpperCase();

    final waterPct =
        (waterState.totalMl / AppConstants.dailyWaterGoalMl).clamp(0.0, 1.0);
    final sleepPct =
        (sleepState.lastNightHours / AppConstants.recommendedSleepHours)
            .clamp(0.0, 1.0);
    final medsPct = 0.66; // placeholder until med adherence wired
    final planPct = ((waterPct + sleepPct + medsPct) / 3).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar: avatar + greeting + notif ──────────────────────
              _TopBar(initials: initials, name: name)
                  .animate()
                  .fadeIn(duration: 350.ms),

              const SizedBox(height: 22),

              // ── Plan-of-day hero card ───────────────────────────────────
              _PlanHero(percent: planPct)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),

              const SizedBox(height: 22),

              // ── Week strip ──────────────────────────────────────────────
              _WeekStrip()
                  .animate()
                  .fadeIn(delay: 140.ms, duration: 400.ms),

              const SizedBox(height: 22),

              // ── 2x2 colored category grid ───────────────────────────────
              _CategoryGrid(
                waterPct: waterPct,
                sleepPct: sleepPct,
                waterMl: waterState.totalMl,
                sleepHours: sleepState.lastNightHours,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 22),

              // ── Daily tip ──────────────────────────────────────────────
              const _TipCard()
                  .animate()
                  .fadeIn(delay: 280.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Top bar
// ──────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String initials;
  final String name;

  const _TopBar({required this.initials, required this.name});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.light,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initials.isEmpty ? 'U' : initials,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hi, $name 👋',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 20, color: AppColors.textPrimary),
              Positioned(
                top: 12,
                right: 13,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Plan hero — circular progress on green gradient
// ──────────────────────────────────────────────────────────────────────────────

class _PlanHero extends StatelessWidget {
  final double percent;
  const _PlanHero({required this.percent});

  @override
  Widget build(BuildContext context) {
    final pctInt = (percent * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8AD3A8), Color(0xFF6BBE8E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular ring
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(96, 96),
                  painter: _RingPainter(
                    progress: percent,
                    bg: Colors.white.withOpacity(0.25),
                    fg: Colors.white,
                    stroke: 8,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pctInt%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My plan for today',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percent * 3).floor()} of 3 complete',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Keep going!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _RingPainter extends CustomPainter {
  final double progress;
  final Color bg;
  final Color fg;
  final double stroke;

  _RingPainter({
    required this.progress,
    required this.bg,
    required this.fg,
    this.stroke = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      progress.clamp(0, 1) * 2 * math.pi,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.bg != bg ||
      old.fg != fg ||
      old.stroke != stroke;
}

// ──────────────────────────────────────────────────────────────────────────────
// Week strip
// ──────────────────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day.day == today.day &&
            day.month == today.month &&
            day.year == today.year;
        return Column(
          children: [
            Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? AppColors.primaryDark
                    : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isToday ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Pastel category grid
// ──────────────────────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final double waterPct;
  final double sleepPct;
  final int waterMl;
  final double sleepHours;

  const _CategoryGrid({
    required this.waterPct,
    required this.sleepPct,
    required this.waterMl,
    required this.sleepHours,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Sleep + Water
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                label: 'Sleep',
                value: '${sleepHours.toStringAsFixed(1)}h',
                emoji: '😴',
                bg: AppColors.sleepBg,
                fg: AppColors.sleepFg,
                visualization: _SleepBars(),
                onTap: () => context.go('/sleep'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                label: 'Water',
                value: '${(waterMl / 1000).toStringAsFixed(1)} L',
                emoji: '💧',
                bg: AppColors.waterBg,
                fg: AppColors.waterFg,
                visualization: _WaterWave(progress: waterPct),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Symptoms + Medications
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                label: 'Symptoms',
                value: 'Log',
                emoji: '🩺',
                bg: AppColors.foodBg,
                fg: AppColors.foodFg,
                visualization: _CalorieRing(),
                onTap: () => context.go('/symptoms'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                label: 'Meds',
                value: 'Track',
                emoji: '💊',
                bg: AppColors.medsBg,
                fg: AppColors.medsFg,
                visualization: _PillsIcon(),
                onTap: () => context.go('/medications'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3: Analytics + Mind
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                label: 'Analytics',
                value: 'View',
                emoji: '📊',
                bg: AppColors.exerciseBg,
                fg: AppColors.exerciseFg,
                visualization: _ExerciseDots(),
                onTap: () => context.go('/analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                label: 'AI Insights',
                value: 'Predict',
                emoji: '🧠',
                bg: AppColors.mindBg,
                fg: AppColors.mindFg,
                visualization: _SparkLine(),
                onTap: () => context.go('/symptoms'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color bg;
  final Color fg;
  final Widget visualization;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.bg,
    required this.fg,
    required this.visualization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 138,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // emoji top-right
            Align(
              alignment: Alignment.topRight,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            // label + value bottom-left
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // visualization bottom-right
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: 60,
                height: 36,
                child: visualization,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tiny mini-visualizations for each card

class _SleepBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.7, 1.0, 0.6, 0.85, 0.5];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights
          .map((h) => Container(
                width: 5,
                height: 30 * h,
                decoration: BoxDecoration(
                  color: AppColors.sleepFg,
                  borderRadius: BorderRadius.circular(3),
                ),
              ))
          .toList(),
    );
  }
}

class _WaterWave extends StatelessWidget {
  final double progress;
  const _WaterWave({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.waterFg.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 36 * progress.clamp(0.15, 1.0),
            decoration: BoxDecoration(
              color: AppColors.waterFg,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(
        progress: 0.65,
        bg: AppColors.foodFg.withOpacity(0.2),
        fg: AppColors.foodFg,
        stroke: 5,
      ),
    );
  }
}

class _PillsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.medsFg.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.medication_rounded,
            color: AppColors.medsFg, size: 20),
      ),
    );
  }
}

class _ExerciseDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(5, (i) {
        return Positioned(
          left: i * 11.0,
          top: 8 + (i.isEven ? 6 : 0).toDouble(),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.exerciseFg
                  .withOpacity(0.3 + (i * 0.15).clamp(0, 0.7)),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _SparkLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparkPainter(),
    );
  }
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mindFg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final pts = [0.7, 0.5, 0.6, 0.3, 0.45, 0.2];
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = i * size.width / (pts.length - 1);
      final y = pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// Tip card
// ──────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('💡', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the day',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'A 20-min walk daily improves mood and lowers stress.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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
