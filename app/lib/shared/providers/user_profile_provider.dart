/// File: lib/shared/providers/user_profile_provider.dart
/// Purpose: Fetches and caches the current user's profile data.
/// Author: HealthSync Team
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stream of auth state changes from Supabase.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser?.id;
});

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    debugPrint("userProfileProvider: No user ID found");
    return null;
  }

  try {
    debugPrint("userProfileProvider: Fetching profile for $userId");
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single()
        .timeout(const Duration(seconds: 15));

    return data;
  } catch (e) {
    debugPrint("userProfileProvider ERROR for $userId: $e");
    return null;
  }
});
