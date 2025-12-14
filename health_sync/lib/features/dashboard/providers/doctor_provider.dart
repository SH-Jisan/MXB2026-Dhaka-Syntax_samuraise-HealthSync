import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// স্পেশালিস্ট অনুযায়ী ডাক্তার খোঁজার প্রোভাইডার
final doctorsBySpecialtyProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, specialty) async {

  // ১. AI এর আউটপুট একটু ক্লিন করে নিচ্ছি (Underscore থাকলে স্পেস দিয়ে রিপ্লেস)
  final cleanSpecialty = specialty.replaceAll('_', ' ').trim();

  // ২. ডাটাবেস কুয়েরি
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'DOCTOR') // শুধু ডাক্তারদের খুঁজবে
  // ilike ব্যবহার করছি যাতে ছোট/বড় হাতের অক্ষরে সমস্যা না হয়
  // %...% মানে এই শব্দের আশেপাশে অন্য কিছু থাকলেও খুঁজে আনবে
      .ilike('specialty', '%$cleanSpecialty%');

  return List<Map<String, dynamic>>.from(response);
});