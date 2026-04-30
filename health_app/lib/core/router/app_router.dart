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
    initialLocation: '/login',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final isAuth = token != null;
      final isLoginPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuth && !isLoginPage) return '/login';
      if (isAuth && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app (bottom nav)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const MainScaffold(initialIndex: 0),
      ),
      GoRoute(
        path: '/symptoms',
        builder: (context, state) =>
            const MainScaffold(initialIndex: 1),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) =>
            const MainScaffold(initialIndex: 2),
      ),
      GoRoute(
        path: '/medications',
        builder: (context, state) =>
            const MainScaffold(initialIndex: 3),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const MainScaffold(initialIndex: 4),
      ),

      // Detail screens (no bottom nav)
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 18),
            ),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
});
