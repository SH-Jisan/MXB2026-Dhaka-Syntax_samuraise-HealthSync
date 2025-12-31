import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
