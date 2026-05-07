import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _selectedQuality = 2; // 0=Poor, 1=Fair, 2=Good, 3=Excellent
  double _waterGoal = 2500;
  int _waterConsumed = 1850;

  final List<double> _sleepData = [6.5, 7.2, 5.2, 8.0, 7.8, 8.5, 8.3];
  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _addWater(int ml) {
    setState(() {
      _waterConsumed = (_waterConsumed + ml).clamp(0, 5000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sleepHours = _sleepData.last;
    final sleepGoal = 8.0;
    final sleepPct = (sleepHours / sleepGoal).clamp(0.0, 1.0);
    final waterPct = (_waterConsumed / _waterGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Sleep Header ──────────────────────────────────────────────
            _SleepHeader(
              sleepHours: sleepHours,
              sleepPct: sleepPct,
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 14),

            // ── Sleep quality card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SleepQualityCard(
                selected: _selectedQuality,
                onSelect: (i) => setState(() => _selectedQuality = i),
              ),
            ).animate().fadeIn(delay: 80.ms, duration: 350.ms),

            const SizedBox(height: 12),

            // ── Weekly sleep chart ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SleepChartCard(
                data: _sleepData,
                days: _days,
              ),
            ).animate().fadeIn(delay: 140.ms, duration: 350.ms),

            const SizedBox(height: 12),

            // ── Water tracker card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WaterTrackerCard(
                consumed: _waterConsumed,
                goal: _waterGoal.toInt(),
                pct: waterPct,
                onAdd: _addWater,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

            const SizedBox(height: 12),

            // ── Wednesday alert ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.rose50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.rose200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wednesday Alert',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.rose700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Only 5.2h — below 6h minimum. Reflected in your health score.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 260.ms, duration: 350.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─── Sleep Header ─────────────────────────────────────────────────────────────

class _SleepHeader extends StatelessWidget {
  final double sleepHours;
  final double sleepPct;

  const _SleepHeader({required this.sleepHours, required this.sleepPct});

  @override
  Widget build(BuildContext context) {
    final h = sleepHours.floor();
    final m = ((sleepHours - h) * 60).round();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.plum900, Color(0xFF5C3060), AppColors.plum600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Sleep & ',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'Wellness',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.plum300,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tonight\'s Sleep Goal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.44),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ring
                  SizedBox(
                    width: 144,
                    height: 144,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(144, 144),
                          painter: _SleepRingPainter(progress: sleepPct),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'hours',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.42),
                              ),
                            ),
                            Text(
                              '${(sleepPct * 100).round()}% of goal',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.plum300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bed/wake pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimePill(label: 'Bed Time', value: '11:00 PM'),
                      const SizedBox(width: 12),
                      _TimePill(label: 'Wake Up', value: '07:20 AM'),
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

class _TimePill extends StatelessWidget {
  final String label;
  final String value;
  const _TimePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepRingPainter extends CustomPainter {
  final double progress;
  const _SleepRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.shortestSide - 16) / 2;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white.withOpacity(0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      progress.clamp(0, 1) * 2 * math.pi,
      false,
      Paint()
        ..color = AppColors.plum300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SleepRingPainter old) =>
      old.progress != progress;
}

// ─── Sleep Quality Card ───────────────────────────────────────────────────────

class _SleepQualityCard extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _SleepQualityCard({required this.selected, required this.onSelect});

  static const _opts = [
    ('😔', 'Poor'),
    ('😐', 'Fair'),
    ('😊', 'Good'),
    ('😄', 'Excl.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: 'Sleep ',
                    style: AppTextStyles.cardTitle),
                TextSpan(
                  text: 'Quality',
                  style: AppTextStyles.cardTitle
                      .copyWith(
                          color: AppColors.plum500,
                          fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _opts.asMap().entries.map((e) {
              final i = e.key;
              final opt = e.value;
              final isOn = selected == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isOn ? AppColors.plum700 : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOn ? AppColors.plum700 : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(opt.$1, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          opt.$2,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isOn
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isOn
                                ? Colors.white
                                : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Sleep Chart Card ────────────────────────────────────────────────────────

class _SleepChartCard extends StatelessWidget {
  final List<double> data;
  final List<String> days;

  const _SleepChartCard({required this.data, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxH = data.reduce(math.max);

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'Weekly ', style: AppTextStyles.cardTitle),
                TextSpan(
                  text: 'Chart',
                  style: AppTextStyles.cardTitle
                      .copyWith(
                          color: AppColors.plum500,
                          fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Avg ${(data.reduce((a, b) => a + b) / data.length).toStringAsFixed(1)}h · Quality: Good',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.asMap().entries.map((e) {
                final i = e.key;
                final h = e.value;
                final barH = (h / maxH) * 68;
                final isToday = i == data.length - 1;
                final isLow = h < 6;

                Color barColor;
                if (isLow) {
                  barColor = AppColors.rose400;
                } else if (isToday) {
                  barColor = AppColors.plum500;
                } else {
                  final colors = [
                    AppColors.plum400,
                    AppColors.plum300,
                    AppColors.plum500,
                    AppColors.plum300,
                    AppColors.plum700,
                    AppColors.plum800,
                  ];
                  barColor = colors[i % colors.length];
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barH,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        border: isToday
                            ? Border.all(color: AppColors.plum700, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isLow
                            ? AppColors.rose600
                            : isToday
                                ? AppColors.plum900
                                : AppColors.neutral400,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Water Tracker Card ───────────────────────────────────────────────────────

class _WaterTrackerCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final double pct;
  final ValueChanged<int> onAdd;

  const _WaterTrackerCard({
    required this.consumed,
    required this.goal,
    required this.pct,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('💧 Water Intake', style: AppTextStyles.cardTitle),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.sage200),
                ),
                child: Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sage700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress
          Row(
            children: [
              Text(
                '${(consumed / 1000).toStringAsFixed(2)} L',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${(goal / 1000).toStringAsFixed(1)}L goal',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.sage500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Quick add buttons
          Row(
            children: [
              _WaterBtn(label: '+150ml', onTap: () => onAdd(150)),
              const SizedBox(width: 8),
              _WaterBtn(label: '+250ml', onTap: () => onAdd(250)),
              const SizedBox(width: 8),
              _WaterBtn(label: '+500ml', onTap: () => onAdd(500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WaterBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.sage100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.sage200),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.sage700,
            ),
          ),
        ),
      ),
    );
  }
}
