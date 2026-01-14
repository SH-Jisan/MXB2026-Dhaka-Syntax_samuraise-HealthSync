/// File: lib/features/blood/providers/donor_provider.dart
/// Purpose: Logic for searching and filtering blood donors.
/// Author: HealthSync Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Filter criteria for searching donors.
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

/// Provider that fetches donors based on the [DonorFilter] criteria.
final donorSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DonorFilter>((
      ref,
      filter,
    ) async {
      var query = Supabase.instance.client
          .from('blood_donors')
          .select('*, profiles!inner(*)')
          .eq('availability', true);

      if (filter.bloodGroup != null) {
        query = query.eq('profiles.blood_group', filter.bloodGroup!);
      }

      if (filter.district != null && filter.district!.isNotEmpty) {
        query = query.ilike('profiles.district', '%${filter.district}%');
      }

      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    });
