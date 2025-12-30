import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../timeline/pages/medical_timeline_view.dart';

class HospitalPatientsPage extends StatelessWidget {
  const HospitalPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      body: FutureBuilder(
        // আমরা অ্যাপয়েন্টমেন্ট টেবিল থেকে ইউনিক পেশেন্ট খুঁজছি
        future: Supabase.instance.client
            .from('appointments')
            .select(
              'appointment_date, patient_id, doctor_id, profiles:patient_id(full_name, id), doctor:doctor_id(full_name)',
            )
            .eq('hospital_id', hospitalId)
            .order('appointment_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("No patient records found."));
          }

          final appointments = snapshot.data as List;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final apt = appointments[index];
              final patient = apt['profiles'];
              final doctorName = apt['doctor']['full_name'] ?? 'Unknown Doctor';
              final date = DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(DateTime.parse(apt['appointment_date']));

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      patient['full_name'][0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  title: Text(
                    patient['full_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Dr. $doctorName\nDate: $date"),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // ক্লিক করলে রোগীর মেডিকেল হিস্ট্রি দেখাবে
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text("${patient['full_name']}'s History"),
                          ),
                          body: MedicalTimelineView(patientId: patient['id']),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
