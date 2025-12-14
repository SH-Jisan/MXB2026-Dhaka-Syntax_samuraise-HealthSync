import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ১. Auth State শোনার জন্য Stream Provider
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ২. প্রোফাইল ডাটা প্রোভাইডার (এখন Reactive)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // 🔥 এই লাইনটি ম্যাজিক করবে: Auth State চেঞ্জ হলেই এই প্রোভাইডার রিবিল্ড হবে
  ref.watch(authStateChangesProvider);

  final user = Supabase.instance.client.auth.currentUser;

  // ইউজার না থাকলে null রিটার্ন
  if (user == null) return null;

  try {
    // ডাটাবেস থেকে ফ্রেশ ডাটা আনা
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return data;
  } catch (e) {
    // প্রোফাইল না থাকলে (যেমন সাইনআপের ঠিক পর মুহূর্ত)
    return null;
  }
});