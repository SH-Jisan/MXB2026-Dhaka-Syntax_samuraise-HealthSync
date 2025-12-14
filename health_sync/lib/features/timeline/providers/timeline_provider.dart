import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/medical_event_model.dart';

// ডাটাবেস থেকে মেডিকেল ইভেন্ট লোড করার প্রোভাইডার
final timelineProvider = FutureProvider.autoDispose<List<MedicalEvent>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  // ডাটাবেস কুয়েরি
  final response = await Supabase.instance.client
      .from('medical_events')
      .select()
      .eq('patient_id', user.id) // শুধু নিজের ডাটা
      .order('event_date', ascending: false); // নতুন তারিখ আগে থাকবে

  // লিস্ট কনভার্শন
  return (response as List).map((e) => MedicalEvent.fromJson(e)).toList();
});