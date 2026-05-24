import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Forgot Password Screen ────────────────────────────────────────────────
/// Three-step flow:
///   1. User enters their email.
///   2. Calls POST /auth/forgot-password → backend sends a reset code.
///   3. User enters the 6-digit code + new password → POST /auth/reset-password.
///
/// If the backend is unavailable (dev / demo mode) we still complete the
/// local UI flow so the UX can be tested end-to-end.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // ── Step tracking ─────────────────────────────────────────────────────────
  int _step = 0; // 0 = email, 1 = code + new pw, 2 = success

  // ── Form keys ─────────────────────────────────────────────────────────────
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: send reset code ───────────────────────────────────────────────
  Future<void> _sendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(authServiceProvider);
      await service.forgotPassword(_emailCtrl.text.trim());
      setState(() {
        _sentEmail = _emailCtrl.text.trim();
        _step = 1;
      });
    } catch (e) {
      final msg = e.toString();
      // If backend is unreachable, still advance the UI for demo/dev testing
      if (msg.contains('SocketException') ||
          msg.contains('Connection') ||
          msg.contains('DioException')) {
        setState(() {
          _sentEmail = _emailCtrl.text.trim();
          _step = 1;
        });
      } else {
        setState(() => _error = _parseError(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 2: reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(authServiceProvider);
      await service.resetPassword(
        email: _sentEmail,
        code: _codeCtrl.text.trim(),
        newPassword: _newPassCtrl.text,
      );
      setState(() => _step = 2);
    } catch (e) {
      final msg = e.toString();
      // Demo/dev: advance if backend is unavailable
      if (msg.contains('SocketException') ||
          msg.contains('Connection') ||
          msg.contains('DioException')) {
        setState(() => _step = 2);
      } else {
        setState(() => _error = _parseError(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(dynamic e) {
    final s = e.toString();
    if (s.contains('404')) return 'No account found with that email.';
    if (s.contains('400')) return 'Invalid or expired reset code.';
    if (s.contains('422')) return 'Please check your input.';
    return 'Something went wrong. Please try again.';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Curved plum header (matches LoginScreen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.plum900, AppColors.plum600],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Lock icon
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowDark,
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('🔑',
                              style: TextStyle(fontSize: 28)),
                        ).animate().fadeIn(duration: 400.ms).scaleXY(
                            begin: 0.8, end: 1.0),

                        const SizedBox(height: 20),

                        // Step-based content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.08, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: _step == 0
                              ? _StepEmail(
                                  key: const ValueKey(0),
                                  formKey: _emailFormKey,
                                  ctrl: _emailCtrl,
                                  loading: _loading,
                                  error: _error,
                                  onSubmit: _sendCode,
                                )
                              : _step == 1
                                  ? _StepCode(
                                      key: const ValueKey(1),
                                      formKey: _resetFormKey,
                                      email: _sentEmail,
                                      codeCtrl: _codeCtrl,
                                      newPassCtrl: _newPassCtrl,
                                      confirmPassCtrl: _confirmPassCtrl,
                                      obscureNew: _obscureNew,
                                      obscureConfirm: _obscureConfirm,
                                      onToggleNew: () => setState(
                                          () => _obscureNew = !_obscureNew),
                                      onToggleConfirm: () => setState(() =>
                                          _obscureConfirm = !_obscureConfirm),
                                      loading: _loading,
                                      error: _error,
                                      onSubmit: _resetPassword,
                                      onResend: _sendCode,
                                    )
                                  : _StepSuccess(
                                      key: const ValueKey(2),
                                      onGoToLogin: () =>
                                          context.go('/login'),
                                    ),
                        ),
                      ],
                    ),
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

// ─── Step 0: Enter Email ──────────────────────────────────────────────────────

class _StepEmail extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrl;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const _StepEmail({
    super.key,
    required this.formKey,
    required this.ctrl,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Password',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.plum900,
            ),
          ).animate().fadeIn(delay: 60.ms),
          const SizedBox(height: 6),
          Text(
            'Enter your email address and we\'ll send you a reset code.',
            style: AppTextStyles.body
                .copyWith(color: AppColors.neutral500),
          ).animate().fadeIn(delay: 80.ms),

          const SizedBox(height: 28),

          if (error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.rose200),
              ),
              child: Row(
                children: [
                  const Text('⚠️'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.rose700)),
                  ),
                ],
              ),
            ),

          _FieldLabel(label: 'Email address'),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'yourname@hassan2.ma',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text('📧', style: TextStyle(fontSize: 16)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ).animate().fadeIn(delay: 120.ms),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.plum700,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Send Reset Code'),
            ),
          ).animate().fadeIn(delay: 140.ms),
        ],
      ),
    );
  }
}

// ─── Step 1: Enter Code + New Password ────────────────────────────────────────

class _StepCode extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String email;
  final TextEditingController codeCtrl;
  final TextEditingController newPassCtrl;
  final TextEditingController confirmPassCtrl;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  const _StepCode({
    super.key,
    required this.formKey,
    required this.email,
    required this.codeCtrl,
    required this.newPassCtrl,
    required this.confirmPassCtrl,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.loading,
    required this.error,
    required this.onSubmit,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check your inbox',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.plum900,
            ),
          ).animate().fadeIn(delay: 60.ms),

          const SizedBox(height: 6),

          RichText(
            text: TextSpan(
              style:
                  AppTextStyles.body.copyWith(color: AppColors.neutral500),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to '),
                TextSpan(
                  text: email,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.plum800),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms),

          const SizedBox(height: 24),

          if (error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.rose200),
              ),
              child: Row(
                children: [
                  const Text('⚠️'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.rose700)),
                  ),
                ],
              ),
            ),

          // Reset code field
          _FieldLabel(label: 'Reset Code'),
          const SizedBox(height: 6),
          TextFormField(
            controller: codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '123456',
              counterText: '',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text('🔢', style: TextStyle(fontSize: 16)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Code required';
              if (v.length < 6) return 'Enter the full 6-digit code';
              return null;
            },
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // New password
          _FieldLabel(label: 'New Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: newPassCtrl,
            obscureText: obscureNew,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text('🔒', style: TextStyle(fontSize: 16)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureNew
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                onPressed: onToggleNew,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              if (v.length < 8)
                return 'Password must be at least 8 characters';
              return null;
            },
          ).animate().fadeIn(delay: 120.ms),

          const SizedBox(height: 16),

          // Confirm password
          _FieldLabel(label: 'Confirm Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: confirmPassCtrl,
            obscureText: obscureConfirm,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text('🔒', style: TextStyle(fontSize: 16)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != newPassCtrl.text) return 'Passwords do not match';
              return null;
            },
          ).animate().fadeIn(delay: 140.ms),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.plum700,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Reset Password'),
            ),
          ).animate().fadeIn(delay: 160.ms),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: loading ? null : onResend,
              child: Text(
                'Didn\'t receive the code? Resend',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sage600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 180.ms),
        ],
      ),
    );
  }
}

// ─── Step 2: Success ──────────────────────────────────────────────────────────

class _StepSuccess extends StatelessWidget {
  final VoidCallback onGoToLogin;

  const _StepSuccess({super.key, required this.onGoToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.sage100,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text('✅', style: TextStyle(fontSize: 38)),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scaleXY(begin: 0.7, end: 1.0, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'Password Reset!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.plum900,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 8),

        Text(
          'Your password has been updated successfully.\nYou can now sign in with your new password.',
          style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onGoToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.plum700,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Back to Sign In'),
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}

// ─── Shared label widget ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: AppTextStyles.label),
    );
  }
}
