import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SymptomsScreen extends ConsumerStatefulWidget {
  const SymptomsScreen({super.key});

  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen> {
  final Set<String> _selected = {'🌡️ Fever', '🤕 Headache', '😴 Fatigue'};
  bool _analyzed = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const List<String> _allSymptoms = [
    '🌡️ Fever',
    '🤕 Headache',
    '😮‍💨 Cough',
    '😴 Fatigue',
    '🤢 Nausea',
    '🫁 Sore throat',
    '😵 Dizziness',
    '😰 Stress',
    '💧 Runny nose',
    '🦴 Body aches',
    '😶‍🌫️ Chest pain',
    '🥴 Vomiting',
  ];

  static const List<_AiResult> _results = [
    _AiResult(
      condition: 'Viral Flu (Influenza)',
      pct: 82,
      note: '💊 Paracetamol 500mg · Rest · Fluids',
    ),
    _AiResult(
      condition: 'Common Cold',
      pct: 64,
      note: '💊 Vitamin C · Warm liquids',
    ),
    _AiResult(
      condition: 'Stress-Related Fatigue',
      pct: 45,
      note: '🧘 Breathing exercises · Sleep hygiene',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filtered => _searchQuery.isEmpty
      ? _allSymptoms
      : _allSymptoms
          .where((s) =>
              s.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Fixed header ────────────────────────────────────────────────
          Container(
            color: AppColors.card,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Symptom ',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.plum900,
                                ),
                              ),
                              TextSpan(
                                text: 'Check',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.plum500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Select all that apply — AI analyses potential causes',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.neutral700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search symptoms...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 14, right: 8),
                            child: Text('🔍', style: TextStyle(fontSize: 15)),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 0, minHeight: 0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symptom chips
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filtered.map((s) {
                        final isOn = _selected.contains(s);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isOn) {
                                _selected.remove(s);
                              } else {
                                _selected.add(s);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isOn ? AppColors.plum700 : AppColors.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isOn
                                    ? AppColors.plum700
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isOn
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isOn
                                    ? Colors.white
                                    : AppColors.neutral600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  // Analyze button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _analyzed = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sage600,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('🧠 Analyse with AI'),
                      ),
                    ),
                  ),

                  // AI Results
                  if (_analyzed && _selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _AiAnalysisCard(results: _results),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 350.ms)
                        .slideY(begin: 0.05, end: 0),

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

// ─── Severity Card ────────────────────────────────────────────────────────────

class _SeverityCard extends StatelessWidget {
  final double severity;
  final ValueChanged<double> onChanged;

  const _SeverityCard({required this.severity, required this.onChanged});

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
              Text('Severity level', style: AppTextStyles.bodySemiBold),
              Text(
                '${severity.round()} / 10',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: AppColors.plum700,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.plum700,
              overlayColor: AppColors.plum700.withOpacity(0.12),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: severity,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mild', style: AppTextStyles.caption),
              Text('Moderate', style: AppTextStyles.caption),
              Text('Severe', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AI Analysis Card ────────────────────────────────────────────────────────

class _AiResult {
  final String condition;
  final int pct;
  final String note;
  const _AiResult({
    required this.condition,
    required this.pct,
    required this.note,
  });
}

class _AiAnalysisCard extends StatelessWidget {
  final List<_AiResult> results;
  const _AiAnalysisCard({required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Banner
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.plum900, AppColors.plum700],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🧠', style: TextStyle(fontSize: 17)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Analysis Results',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'scikit-learn · Random Forest',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          ...results.asMap().entries.map((e) {
            final r = e.value;
            final isLast = e.key == results.length - 1;
            return _AiResultRow(result: r, isLast: isLast);
          }),

          // Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.rose50,
              border: Border(top: BorderSide(color: AppColors.rose200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Not a medical diagnosis. Consult a healthcare professional.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.rose600),
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

class _AiResultRow extends StatelessWidget {
  final _AiResult result;
  final bool isLast;

  const _AiResultRow({required this.result, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(result.condition,
                    style: AppTextStyles.bodySemiBold),
              ),
              Text(
                '${result.pct}%',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: result.pct / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.plum200, AppColors.plum600],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(result.note, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
