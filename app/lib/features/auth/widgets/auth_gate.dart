import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
// আমরা পরে Home Page বানাব, আপাতত একটা Placeholder দিচ্ছি
import 'package:flutter/widgets.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Supabase এর অথেন্টিকেশন স্ট্রিম লিসেন করবে
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {

        // 1. লোডিং অবস্থা
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. সেশন চেক করা
        final session = snapshot.data?.session;

        if (session != null) {
          // ইউজার লগইন আছে! -> Home Page এ পাঠাও
          // (আপাতত একটা টেক্সট দেখাচ্ছি, পরের স্টেপে এখানে Home Page বসাব)
          return const Scaffold(
            body: Center(child: Text("Logged In! Welcome to Dashboard")),
          );
        } else {
          // ইউজার লগইন নেই -> Login Page এ পাঠাও
          return const LoginPage();
        }
      },
    );
  }
}