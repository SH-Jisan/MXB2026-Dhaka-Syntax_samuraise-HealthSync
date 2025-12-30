import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ১. Auth State শোনার জন্য Stream Provider
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ২. প্রোফাইল ডাটা প্রোভাইডার (এখন Reactive)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {

  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return null;

  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return data;
  } catch (e) {
    return null;
  }
});