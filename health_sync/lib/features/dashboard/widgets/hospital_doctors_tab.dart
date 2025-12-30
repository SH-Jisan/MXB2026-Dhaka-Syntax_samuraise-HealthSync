import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class HospitalDoctorsTab extends StatefulWidget {
  const HospitalDoctorsTab({super.key});

  @override
  State<HospitalDoctorsTab> createState() => _HospitalDoctorsTabState();
}

class _HospitalDoctorsTabState extends State<HospitalDoctorsTab> {
  @override
  Widget build(BuildContext context) {
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;

    return FutureBuilder(
      future: Supabase.instance.client
          .from('hospital_doctors')
          .select('*, profiles:doctor_id(*)')
          .eq('hospital_id', hospitalId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text("No doctors assigned yet."),
              ],
            ),
          );
        }

        final doctors = snapshot.data as List;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doc = doctors[index]['profiles'];
            final joinDate = DateTime.parse(
              doctors[index]['joined_at'],
            ).toLocal();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(
                  doc['full_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['specialty'] ?? 'General Physician'),
                    Text(
                      "Joined: ${DateFormat.yMMMd().format(joinDate)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await Supabase.instance.client
                        .from('hospital_doctors')
                        .delete()
                        .eq('id', doctors[index]['id']);
                    setState(() {}); // লিস্ট রিফ্রেশ
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
