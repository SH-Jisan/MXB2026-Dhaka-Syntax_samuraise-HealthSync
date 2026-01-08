/// File: lib/features/profile/providers/doctor_hospitals_provider.dart
/// Purpose: Fetches the list of hospitals a doctor is associated with.
/// Author: HealthSync Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to fetch associated hospitals for a given doctor ID.
final doctorHospitalsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      try {
        final response = await Supabase.instance.client
            .from('hospital_doctors')
            .select('*, hospital:hospital_id(full_name, address, phone)')
            .eq('doctor_id', doctorId);

        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        throw Exception("Error fetching doctor hospitals: $e");
      }
    });
