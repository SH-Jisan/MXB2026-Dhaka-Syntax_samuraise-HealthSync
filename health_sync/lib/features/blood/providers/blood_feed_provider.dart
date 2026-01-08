/// File: lib/features/blood/providers/blood_feed_provider.dart
/// Purpose: Fetches live blood requests for the feed.
/// Author: HealthSync Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that returns a list of open blood requests, ordered by creation time.
final bloodFeedProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final response = await Supabase.instance.client
          .from('blood_requests')
          .select('*, profiles(full_name, phone)')
          .eq('status', 'OPEN')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    });
