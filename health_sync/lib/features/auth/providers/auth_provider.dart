import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. State Provider (লোডিং অবস্থা বোঝার জন্য)
final authStateProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false); // false = not loading

  // 2. Sign Up Function (Role সহ)
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role, // 'PATIENT', 'DOCTOR', 'HOSPITAL', 'DIAGNOSTIC'
  }) async {
    state = true; // Loading start
    try {
      // মেটাডাটা হিসেবে রোল এবং অন্যান্য তথ্য পাঠাচ্ছি
      // এটি ডাটাবেসের 'handle_new_user' ট্রিগার দিয়ে প্রোফাইল টেবিলে সেভ হবে
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );
    } catch (e) {
      rethrow; // UI তে এরর দেখানোর জন্য পাঠালাম
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

  // 4. Logout
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}