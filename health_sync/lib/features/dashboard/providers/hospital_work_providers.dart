import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final hospitalPatientsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, hospitalId) async {
      final response = await Supabase.instance.client
          .from('appointments')
          .select(
            'appointment_date, patient_id, doctor_id, profiles:patient_id(full_name, id), doctor:doctor_id(full_name)',
          )
          .eq('hospital_id', hospitalId)
          .order('appointment_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

final hospitalDoctorsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, hospitalId) async {
      final response = await Supabase.instance.client
          .from('hospital_doctors')
          .select('*, doctor:profiles!doctor_id(*)')
          .eq('hospital_id', hospitalId);
      return List<Map<String, dynamic>>.from(response);
    });
