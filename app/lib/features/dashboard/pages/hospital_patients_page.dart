import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../timeline/pages/medical_timeline_view.dart';
import '../providers/hospital_work_providers.dart';

class HospitalPatientsPage extends ConsumerStatefulWidget {
  const HospitalPatientsPage({super.key});

  @override
  ConsumerState<HospitalPatientsPage> createState() =>
      _HospitalPatientsPageState();
}

class _HospitalPatientsPageState extends ConsumerState<HospitalPatientsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;
    final patientsAsync = ref.watch(hospitalPatientsProvider(hospitalId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hospitalPatientsProvider(hospitalId));
          await ref.read(hospitalPatientsProvider(hospitalId).future);
        },
        child: patientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (appointments) {
            if (appointments.isEmpty) {
              return const Center(child: Text("No patient records found."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final apt = appointments[index];
                final patient = apt['profiles'];
                final doctorName =
                    apt['doctor']['full_name'] ?? 'Unknown Doctor';
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
      ),
    );
  }
}
