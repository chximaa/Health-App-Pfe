import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/health_card.dart';
import '../../auth/providers/auth_provider.dart';

// Analytics data provider
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.get('/analytics');
    return response.data as Map<String, dynamic>;
  } catch (_) {
    return _mockAnalytics();
  }
});

Map<String, dynamic> _mockAnalytics() {
  return {
    'water_7d': [1800, 2200, 2500, 1900, 2100, 2400, 2300],
    'sleep_7d': [6.5, 7.0, 8.0, 7.5, 6.0, 7.8, 7.2],
    'health_scores_7d': [72, 75, 80, 68, 74, 82, 78],
    'symptom_frequency': {
      'Headache': 3,
      'Fatigue': 5,
      'Cough': 2,
      'Fever': 1
    },
    'medication_adherence': 85.0,
  };
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(
            child: Text('Failed to load analytics',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (data) => _buildContent(data),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final waterData = List<double>.from(
        (data['water_7d'] as List).map((v) => (v as num).toDouble()));
    final sleepData = List<double>.from(
        (data['sleep_7d'] as List).map((v) => (v as num).toDouble()));
    final scoreData = List<double>.from(
        (data['health_scores_7d'] as List).map((v) => (v as num).toDouble()));
    final symptomFreq =
        data['symptom_frequency'] as Map<String, dynamic>? ?? {};
    final adherence = (data['medication_adherence'] as num?)?.toDouble() ?? 0;

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Score Timeline
          const SectionHeader(title: 'Health Score (7 Days)'),
          const SizedBox(height: 14),
          HealthCard(
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          dayLabels[v.toInt() % 7],
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          scoreData.length,
                          (i) => FlSpot(i.toDouble(), scoreData[i])),
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withOpacity(0.12),
                      ),
                      dotData: FlDotData(
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.secondary,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Water Intake Bar Chart
          const SectionHeader(title: 'Water Intake (7 Days)'),
          const SizedBox(height: 14),
          HealthCard(
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: 3000,
                  barGroups: List.generate(
                    waterData.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: waterData[i],
                          color: waterData[i] >= 2500
                              ? AppColors.success
                              : AppColors.secondary,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          dayLabels[v.toInt() % 7],
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1000,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                          '${(v / 1000).toStringAsFixed(0)}L',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sleep Pattern
          const SectionHeader(title: 'Sleep Pattern (7 Days)'),
          const SizedBox(height: 14),
          HealthCard(
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 12,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 3,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}h',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          dayLabels[v.toInt() % 7],
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          sleepData.length,
                          (i) => FlSpot(i.toDouble(), sleepData[i])),
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withOpacity(0.12),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                    // Recommended line
                    LineChartBarData(
                      spots: List.generate(
                          7, (i) => FlSpot(i.toDouble(), 8.0)),
                      isCurved: false,
                      color: AppColors.success.withOpacity(0.5),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Medication Adherence
          const SectionHeader(title: 'Medication Adherence'),
          const SizedBox(height: 14),
          HealthCard(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: adherence / 100,
                            strokeWidth: 8,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              adherence >= 80
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${adherence.toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            adherence >= 80
                                ? 'Great adherence! Keep it up.'
                                : 'Try to take medications on time.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Symptom Frequency
          if (symptomFreq.isNotEmpty) ...[
            const SectionHeader(title: 'Symptom Frequency'),
            const SizedBox(height: 14),
            HealthCard(
              child: Column(
                children: symptomFreq.entries.map((entry) {
                  final max = symptomFreq.values
                      .map((v) => (v as num).toDouble())
                      .reduce((a, b) => a > b ? a : b);
                  final freq = (entry.value as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${freq.toInt()}x',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: freq / max,
                            minHeight: 8,
                            backgroundColor: AppColors.divider,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
