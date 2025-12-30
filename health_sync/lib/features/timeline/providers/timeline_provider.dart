import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/medical_event_model.dart';

// 🔥 আপডেট: .family ব্যবহার করা হয়েছে যাতে patientId পাস করা যায়
final timelineProvider = FutureProvider.autoDispose.family<List<MedicalEvent>, String?>((ref, patientId) async {

  // ১. যদি patientId দেওয়া থাকে, তবে সেই রোগীর ডাটা আনবে (ডাক্তারের জন্য)
  // ২. যদি না থাকে (null), তবে লগইন করা ইউজারের ডাটা আনবে (সিটিজেনের জন্য)
  final targetUserId = patientId ?? Supabase.instance.client.auth.currentUser?.id;

  if (targetUserId == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('medical_events')
        .select()
        .eq('patient_id', targetUserId) // 🔥 ডায়নামিক আইডি
        .order('event_date', ascending: false);

    return (response as List).map((e) => MedicalEvent.fromJson(e)).toList();
  } catch (e) {
    throw Exception("Error loading timeline: $e");
  }
});