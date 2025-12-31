import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the list of chambers (hospitals) a doctor works at.
final doctorChambersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      final response = await Supabase.instance.client
          .from('doctor_hospitals')
          .select()
          .eq('doctor_id', doctorId);
      return List<Map<String, dynamic>>.from(response);
    });

/// Provider for the list of patients assigned to a doctor.
final doctorPatientsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      final response = await Supabase.instance.client
          .from('doctor_patients')
          .select('patient_id, profiles:patient_id(*)')
          .eq('doctor_id', doctorId)
          .order('assigned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });
