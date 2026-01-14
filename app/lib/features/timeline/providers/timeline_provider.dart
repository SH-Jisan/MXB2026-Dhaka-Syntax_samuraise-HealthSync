import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/medical_event_model.dart';

final timelineProvider = FutureProvider.autoDispose
    .family<List<MedicalEvent>, String?>((ref, patientId) async {
      final targetUserId =
          patientId ?? Supabase.instance.client.auth.currentUser?.id;

      if (targetUserId == null) return [];

      try {
        final response = await Supabase.instance.client
            .from('medical_events')
            .select()
            .eq('patient_id', targetUserId)
            .filter('event_type', 'in', [
              'REPORT',
              'VACCINATION',
              'SURGERY',
              'GENERIC',
            ]) // Match Web Filter
            .order('event_date', ascending: false);

        return (response as List).map((e) => MedicalEvent.fromJson(e)).toList();
      } catch (e) {
        throw Exception("Error loading timeline: $e");
      }
    });
