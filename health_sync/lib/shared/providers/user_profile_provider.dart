import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// প্রোফাইল ডাটার জন্য মডেল (সিম্পল ম্যাপ হিসেবে রাখছি আপাতত)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  // ডাটাবেস থেকে প্রোফাইল আনছি
  final data = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  return data;
});