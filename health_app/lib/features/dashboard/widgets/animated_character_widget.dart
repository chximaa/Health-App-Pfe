import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Animated health mascot — a pulsing bunny placeholder.
/// Replace with a real Lottie file at assets/animations/bunny_active.json
/// by swapping out this widget with:
///   Lottie.asset('assets/animations/bunny_active.json', ...)
class AnimatedCharacterWidget extends StatefulWidget {
  final double size;
  final String mood; // 'happy' | 'sleeping' | 'active'

  const AnimatedCharacterWidget({
    super.key,
    this.size = 120,
    this.mood = 'happy',
  });

  @override
  State<AnimatedCharacterWidget> createState() =>
      _AnimatedCharacterWidgetState();
}

class _AnimatedCharacterWidgetState extends State<AnimatedCharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    return switch (widget.mood) {
      'sleeping' => AppColors.light,
      'active' => AppColors.muted,
      _ => AppColors.secondary.withOpacity(0.15),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _bgColor,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ears
            Positioned(
              top: widget.size * 0.06,
              left: widget.size * 0.22,
              child: _BunnyEar(size: widget.size * 0.18),
            ),
            Positioned(
              top: widget.size * 0.06,
              right: widget.size * 0.22,
              child: _BunnyEar(size: widget.size * 0.18),
            ),
            // Body
            Container(
              width: widget.size * 0.56,
              height: widget.size * 0.56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _buildFace(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFace() {
    if (widget.mood == 'sleeping') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tilde(),
              const SizedBox(width: 6),
              _tilde(),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _eye(),
            const SizedBox(width: 10),
            _eye(),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB7C5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _eye() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _tilde() {
    return Container(
      width: 10,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BunnyEar extends StatelessWidget {
  final double size;
  const _BunnyEar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.7,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.4),
      ),
      child: Center(
        child: Container(
          width: size * 0.35,
          height: size * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6E0),
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
        ),
      ),
    );
  }
}

/// Health score ring widget
class HealthScoreRing extends StatelessWidget {
  final double score; // 0–100
  final double size;

  const HealthScoreRing({
    super.key,
    required this.score,
    this.size = 100,
  });

  Color get _scoreColor {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Score',
                style: TextStyle(
                  fontSize: size * 0.11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.forward())
        .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.elasticOut);
  }
}
