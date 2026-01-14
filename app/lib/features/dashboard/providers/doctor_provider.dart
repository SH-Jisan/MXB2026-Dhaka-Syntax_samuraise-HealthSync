import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final doctorsBySpecialtyProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, specialty) async {

  
  final cleanSpecialty = specialty.replaceAll('_', ' ').trim();

  
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'DOCTOR') 
  
  
      .ilike('specialty', '%$cleanSpecialty%');

  return List<Map<String, dynamic>>.from(response);
});