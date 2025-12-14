import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/signup_page.dart';
import 'go_router_refresh_stream.dart'; // 🔥 নতুন ফাইলটি ইম্পোর্ট করুন

// Placeholder Home Page
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 🔥 লগআউট করার সঠিক নিয়ম
              await Supabase.instance.client.auth.signOut();
            },
          )
        ],
      ),
      body: const Center(child: Text("Welcome to HealthSync!")),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  // 🔥 এই লাইনটিই ম্যাজিক করবে (লগইন/লগআউট হলে অটো রিফ্রেশ হবে)
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),

  routes: [
    GoRoute(path: '/', builder: (context, state) => const PlaceholderHomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
  ],

  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/signup';

    if (session == null && !isLoggingIn) return '/login'; // লগইন না থাকলে লগইন পেজে পাঠাবে
    if (session != null && isLoggingIn) return '/'; // লগইন থাকলে ড্যাশবোর্ডে পাঠাবে

    return null;
  },
);