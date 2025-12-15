import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final myRequestsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final response = await Supabase.instance.client
      .from('blood_requests')
      .select('''
        *,
        request_acceptors (
          accepted_at,  
          profiles (
            full_name,
            phone
          )
        )
      ''') // 🔥 FIX: আগে এখানে 'created_at' ছিল, সেটা বদলে 'accepted_at' করা হলো
      .eq('requester_id', user.id)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});