import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ১. Auth State শোনার জন্য Stream Provider
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// 🔥 OPTIMIZED: Only rebuild profile when User ID changes
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.session?.user.id;
});

// ২. প্রোফাইল ডাটা প্রোভাইডার (এখন Reactive এবং Optimized)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // 🔥 Reactive But Smart: Only fetches if ID changes
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return null;

  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return data;
  } catch (e) {
    return null;
  }
});
