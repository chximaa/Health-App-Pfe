import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isWeekly = true;
  int _activeTab = 0; // All / Symptoms / Sleep / Water

  static const _tabs = ['All', 'Symptoms', 'Sleep', 'Water'];

  // Sparkline data: health scores Mon–Sun (0–100 scale, inverted for drawing)
  static const _sparkData = [46.0, 36.0, 41.0, 26.0, 20.0, 28.0, 15.0];

  // Sleep bar data (hours)
  static const _sleepData = [6.5, 5.8, 7.2, 6.0, 7.8, 8.2, 7.0];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            color: AppColors.card,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Health ',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.plum900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Reports',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.rose500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Mon 18 – Sun 24 Sept 2025',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.plum50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.plum200),
                          ),
                          child: Text(
                            _isWeekly ? 'Weekly' : 'Monthly',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.plum700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle weekly/monthly
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        _ToggleBtn(
                          label: 'Weekly',
                          isActive: _isWeekly,
                          onTap: () => setState(() => _isWeekly = true),
                        ),
                        const SizedBox(width: 8),
                        _ToggleBtn(
                          label: 'Monthly',
                          isActive: !_isWeekly,
                          onTap: () => setState(() => _isWeekly = false),
                        ),
                      ],
                    ),
                  ),

                  // Tab chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: _tabs.asMap().entries.map((e) {
                        final i = e.key;
                        final t = e.value;
                        final isActive = _activeTab == i;
                        return GestureDetector(
                          onTap: () => setState(() => _activeTab = i),
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.sage100
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.sage300
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppColors.sage700
                                    : AppColors.neutral500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          // ── Scrollable body ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Health Score Timeline
                  _SparklineCard(data: _sparkData)
                      .animate()
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 12),

                  // Sleep Pattern
                  _SleepBarsCard(data: _sleepData, days: _days)
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 300.ms),

                  const SizedBox(height: 12),

                  // Medication Adherence
                  const _AdherenceCard()
                      .animate()
                      .fadeIn(delay: 160.ms, duration: 300.ms),

                  const SizedBox(height: 12),

                  // Export buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ExportBtn(
                          label: '📄 PDF',
                          bg: AppColors.plum900,
                          fg: Colors.white,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ExportBtn(
                          label: '📊 CSV',
                          bg: AppColors.surface,
                          fg: AppColors.plum900,
                          border: AppColors.border,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ExportBtn(
                          label: '↗ Share',
                          bg: AppColors.sage600,
                          fg: Colors.white,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 220.ms, duration: 300.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.plum900 : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: isActive
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.neutral500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sparkline Card ──────────────────────────────────────────────────────────

class _SparklineCard extends StatelessWidget {
  final List<double> data;
  const _SparklineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Score Timeline', style: AppTextStyles.cardTitle),
          const SizedBox(height: 2),
          Text('Avg 81% · +6% vs last week', style: AppTextStyles.caption),
          const SizedBox(height: 14),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _SparklinePainter(data: data),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .asMap()
                .entries
                .map((e) => Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: e.key == 6
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: e.key == 6
                            ? AppColors.plum700
                            : AppColors.neutral400,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  const _SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minY = data.reduce(math.min);
    final maxY = data.reduce(math.max);
    final range = (maxY - minY).clamp(1.0, double.infinity);

    final pts = data.asMap().entries.map((e) {
      final x = e.key * size.width / (data.length - 1);
      final y = size.height - ((e.value - minY) / range) * size.height;
      return Offset(x, y);
    }).toList();

    // Fill gradient
    final gradPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      gradPath.lineTo(p.dx, p.dy);
    }
    gradPath
      ..lineTo(pts.last.dx, size.height)
      ..close();

    canvas.drawPath(
      gradPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sage600.withOpacity(0.2),
            AppColors.sage600.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.sage600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot on last point
    final last = pts.last;
    canvas.drawCircle(last, 5, Paint()..color = AppColors.sage600);
    canvas.drawCircle(
        last,
        9,
        Paint()
          ..color = AppColors.sage600.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data;
}

// ─── Sleep Bars Card ─────────────────────────────────────────────────────────

class _SleepBarsCard extends StatelessWidget {
  final List<double> data;
  final List<String> days;

  const _SleepBarsCard({required this.data, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxH = data.reduce(math.max);

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sleep Pattern', style: AppTextStyles.cardTitle),
          const SizedBox(height: 2),
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

                final colors = [
                  AppColors.plum400,
                  AppColors.plum300,
                  AppColors.plum500,
                  AppColors.plum300,
                  AppColors.plum700,
                  AppColors.plum800,
                  AppColors.plum500,
                ];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barH,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                        border: isToday
                            ? Border.all(
                                color: AppColors.plum700, width: 2)
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
                        color: isToday
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

// ─── Adherence Gauge Card ────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medication Adherence', style: AppTextStyles.cardTitle),
              Text('Weekly · 5 medications', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          // Gauge arc
          SizedBox(
            width: 140,
            height: 80,
            child: CustomPaint(
              painter: _GaugePainter(pct: 0.80),
              child: Align(
                alignment: const Alignment(0, 0.4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '80%',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plum900,
                      ),
                    ),
                    Text('on-time doses', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.sage100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '✓ 24 Taken',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.rose100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '✗ 6 Missed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.rose700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  const _GaugePainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height);
    const r = 60.0;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      startAngle,
      sweepAngle * pct,
      false,
      Paint()
        ..color = AppColors.sage600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.pct != pct;
}

// ─── Export Button ────────────────────────────────────────────────────────────

class _ExportBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback onTap;

  const _ExportBtn({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border != null
              ? Border.all(color: border!, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
