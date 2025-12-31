import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. State Provider (লোডিং অবস্থা বোঝার জন্য)
final authStateProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false); // false = not loading

  // 2. Sign Up Function
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role, // 'CITIZEN', 'DOCTOR', 'HOSPITAL', 'DIAGNOSTIC'
  }) async {
    state = true; // Loading start
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone, 'role': role},
      );
    } catch (e) {
      rethrow;
    } finally {
      state = false; // Loading stop
    }
  }

  // 3. Login Function
  Future<void> login({required String email, required String password}) async {
    state = true;
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  // 🔥 4. Logout Function (Updated)
  // নাম 'signOut' থেকে বদলে 'logout' করা হয়েছে যাতে ProfilePage এর সাথে মিলে যায়
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
