import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../timeline/widgets/medical_timeline_tile.dart';

class DoctorPatientTimelinePage extends StatelessWidget {
  final Map<String, dynamic> patientProfile;

  const DoctorPatientTimelinePage({super.key, required this.patientProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patientProfile['full_name'] ?? 'Patient Timeline', style: const TextStyle(fontSize: 16)),
            Text("Medical History View", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('medical_events')
            .select()
            .eq('patient_id', patientProfile['id']) 
            .order('event_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data as List? ?? [];

          if (events.isEmpty) {
            return const Center(child: Text("No medical records found for this patient."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return MedicalTimelineTile(
                event: events[index],
                isLast: index == events.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}