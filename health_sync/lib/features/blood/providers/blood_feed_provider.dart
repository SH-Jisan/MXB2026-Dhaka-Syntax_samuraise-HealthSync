import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bloodFeedProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('blood_requests')
      .select('*, profiles(full_name, phone)') // 🔥 Join profiles
      .eq('status', 'OPEN') // শুধু ওপেন রিকোয়েস্ট
      .order('created_at', ascending: false); // নতুন গুলো আগে

  return List<Map<String, dynamic>>.from(response);
});