/// File: lib/features/dashboard/widgets/hospital_doctors_tab.dart
/// Purpose: Tab to manage doctors assigned to a hospital.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/hospital_work_providers.dart';

/// List of doctors associated with the current hospital.
class HospitalDoctorsTab extends ConsumerStatefulWidget {
  const HospitalDoctorsTab({super.key});

  @override
  ConsumerState<HospitalDoctorsTab> createState() => _HospitalDoctorsTabState();
}

class _HospitalDoctorsTabState extends ConsumerState<HospitalDoctorsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;
    final doctorsAsync = ref.watch(hospitalDoctorsProvider(hospitalId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(hospitalDoctorsProvider(hospitalId));
        await ref.read(hospitalDoctorsProvider(hospitalId).future);
      },
      child: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (doctors) {
          if (doctors.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index]['doctor'];
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
                      ref.invalidate(hospitalDoctorsProvider(hospitalId));
                    },
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
