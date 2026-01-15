import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final diagnosticPatientsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, diagnosticId) async {
      final response = await Supabase.instance.client
          .from('diagnostic_patients')
          .select('*, profiles:patient_id(*)')
          .eq('diagnostic_id', diagnosticId)
          .order('assigned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

final pendingReportsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, diagnosticId) async {
      final response = await Supabase.instance.client
          .from('patient_payments')
          .select('*, profiles:patient_id(*)')
          .eq('provider_id', diagnosticId)
          .eq('report_status', 'PENDING')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

final doctorOrdersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, patientId) async {
      final response = await Supabase.instance.client
          .from('medical_events')
          .select('*, uploader:uploader_id(full_name)')
          .eq('patient_id', patientId)
          .eq('event_type', 'TEST_ORDER')
          .order('created_at', ascending: false)
          .limit(5);
      return List<Map<String, dynamic>>.from(response);
    });
