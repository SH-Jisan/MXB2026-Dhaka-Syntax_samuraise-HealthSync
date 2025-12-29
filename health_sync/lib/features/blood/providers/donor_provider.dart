import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonorFilter {
  final String? bloodGroup;
  final String? district;

  DonorFilter({this.bloodGroup, this.district});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DonorFilter &&
              runtimeType == other.runtimeType &&
              bloodGroup == other.bloodGroup &&
              district == other.district;

  @override
  int get hashCode => bloodGroup.hashCode ^ district.hashCode;
}

final donorSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, DonorFilter>((ref, filter) async {

  // 🔥 UPDATE: জয়েনিং এবং ফিল্টারিং লজিক আপডেট
  // blood_donors থেকে availability চেক করব
  // profiles থেকে blood_group এবং district ফিল্টার করব

  var query = Supabase.instance.client
      .from('blood_donors')
      .select('*, profiles!inner(*)') // !inner ব্যবহার করছি যাতে profiles এর ফিল্টার কাজ করে
      .eq('availability', true);

  if (filter.bloodGroup != null) {
    // profiles টেবিলের কলামে ফিল্টার
    query = query.eq('profiles.blood_group', filter.bloodGroup!);
  }

  if (filter.district != null && filter.district!.isNotEmpty) {
    // profiles টেবিলের কলামে ফিল্টার
    query = query.ilike('profiles.district', '%${filter.district}%');
  }

  final data = await query;
  return List<Map<String, dynamic>>.from(data);
});