/// File: lib/features/auth/providers/auth_provider.dart
/// Purpose: Manages authentication state and business logic (Login, Signup, Logout).
/// Author: HealthSync Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for [AuthController]. Returns true if an async operation is loading.
final authStateProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  /// Controller for authentication operations.
  /// State represents loading status (true = loading).
  AuthController() : super(false);

  /// Signs up a new user with metadata (Full Name, Phone, Role).
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    state = true;
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone, 'role': role},
      );
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

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

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
