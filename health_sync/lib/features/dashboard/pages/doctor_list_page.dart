import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/doctor_provider.dart';

class DoctorListPage extends ConsumerWidget {
  final String specialty;

  const DoctorListPage({super.key, required this.specialty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // প্রোভাইডার কল করছি
    final doctorsAsync = ref.watch(doctorsBySpecialtyProvider(specialty));

    return Scaffold(
      appBar: AppBar(title: Text("$specialty Doctors")),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (doctors) {
          if (doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("No $specialty found nearby."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(doc['full_name'][0].toUpperCase()),
                  ),
                  title: Text(doc['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['specialty'] ?? 'Specialist'),
                      if (doc['district'] != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(doc['district'], style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Appointment Booking Coming Soon!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text("Book"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}