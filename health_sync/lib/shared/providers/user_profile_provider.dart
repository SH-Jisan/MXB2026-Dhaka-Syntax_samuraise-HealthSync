import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ১. Auth State শোনার জন্য Stream Provider
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// 🔥 OPTIMIZED: Reactive but pulls directly from current session for speed/reliability
final currentUserIdProvider = Provider<String?>((ref) {
  // We watch the stream to trigger rebuilds, but return the current user ID
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser?.id;
});

// ২. প্রোফাইল ডাটা প্রোভাইডার (এখন Reactive এবং Optimized)
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
