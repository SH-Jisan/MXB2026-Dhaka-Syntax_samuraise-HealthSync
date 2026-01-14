import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorsBySpecialtyProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      specialty,
    ) async {
      final cleanSpecialty = specialty.replaceAll('_', ' ').trim();

      var query = Supabase.instance.client
          .from('profiles')
          .select()
          .eq('role', 'DOCTOR');

      if (cleanSpecialty.toLowerCase() != 'all') {
        query = query.ilike('specialty', '%$cleanSpecialty%');
      }

      final response = await query;

      return List<Map<String, dynamic>>.from(response);
    });
