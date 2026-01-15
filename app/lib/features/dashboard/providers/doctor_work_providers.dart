import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorChambersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      final response = await Supabase.instance.client
          .from('doctor_hospitals')
          .select()
          .eq('doctor_id', doctorId);
      return List<Map<String, dynamic>>.from(response);
    });

final doctorPatientsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      final response = await Supabase.instance.client
          .from('doctor_patients')
          .select('patient_id, profiles:patient_id(*)')
          .eq('doctor_id', doctorId)
          .order('assigned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

final doctorAppointmentsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, doctorId) async {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, profiles:patient_id(full_name, phone, blood_group)')
          .eq('doctor_id', doctorId)
          .order('appointment_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    });
