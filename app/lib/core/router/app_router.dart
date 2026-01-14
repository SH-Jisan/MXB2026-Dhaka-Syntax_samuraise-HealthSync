import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/signup_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/landing/pages/landing_page.dart';
import 'go_router_refresh_stream.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provides the GoRouter configuration for the app.
/// Handles redirection based on authentication state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),

    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    ],

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isLanding = state.matchedLocation == '/landing';

      // If not logged in and not on login/signup pages, go to landing
      if (session == null && !isLoggingIn && !isLanding) return '/landing';

      // If logged in and trying to login/signup/landing, go to dashboard
      if (session != null && (isLoggingIn || isLanding)) return '/';

      return null;
    },
  );
});
