import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ১. ফিল্টার মডেলে Equality Operator যোগ করা হলো (এটাই ফিক্স) 🛠️
class DonorFilter {
  final String? bloodGroup;
  final String? district;

  DonorFilter({this.bloodGroup, this.district});

  // এই অংশটি Riverpod কে লুপ আটকাতে সাহায্য করবে
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

// ২. প্রোভাইডার (বাকি সব আগের মতোই)
final donorSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, DonorFilter>((ref, filter) async {

  // কুয়েরি শুরু
  var query = Supabase.instance.client
      .from('blood_donors')
      .select('*, profiles(full_name, phone)') // 🔥 Join profiles table
      .eq('availability', true);

  // ফিল্টার লজিক
  if (filter.bloodGroup != null) {
    query = query.eq('blood_group', filter.bloodGroup!);
  }

  if (filter.district != null && filter.district!.isNotEmpty) {
    // ilike = Case insensitive search
    query = query.ilike('district', '%${filter.district}%');
  }

  final data = await query;
  return List<Map<String, dynamic>>.from(data);
});