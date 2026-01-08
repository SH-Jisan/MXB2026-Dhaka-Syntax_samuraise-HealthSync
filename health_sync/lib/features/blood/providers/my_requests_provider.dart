/// File: lib/features/blood/providers/my_requests_provider.dart
/// Purpose: Fetches blood requests made by the current user.
/// Author: HealthSync Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider returning the current user's blood requests and their acceptance status.
final myRequestsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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
      ''')
          .eq('requester_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    });
