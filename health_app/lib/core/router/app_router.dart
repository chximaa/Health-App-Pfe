import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/medications/screens/add_medication_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/sleep/screens/sleep_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final isAuth = token != null;

      final publicPaths = ['/login', '/register', '/welcome'];
      final isPublic = publicPaths.any(
          (p) => state.matchedLocation.startsWith(p));

      if (!isAuth && !isPublic) return '/welcome';
      if (isAuth &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/welcome')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // Auth / Onboarding
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app (bottom nav)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainScaffold(initialIndex: 0),
      ),
      GoRoute(
        path: '/symptoms',
        builder: (context, state) => const MainScaffold(initialIndex: 1),
      ),
      GoRoute(
        path: '/nutrition',
        builder: (context, state) => const MainScaffold(initialIndex: 2),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const MainScaffold(initialIndex: 3),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainScaffold(initialIndex: 4),
      ),

      // Detail screens
      GoRoute(
        path: '/sleep',
        builder: (context, state) => const SleepScreen(),
      ),
      GoRoute(
        path: '/add-medication',
        builder: (context, state) => const AddMedicationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔍', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
