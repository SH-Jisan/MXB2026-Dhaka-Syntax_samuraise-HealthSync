import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    // 🔥 ট্যাব সংখ্যা বাড়িয়ে ৪ করা হলো (Appointments সহ)
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Care History"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          isScrollable: true, // বেশি ট্যাব হওয়ায় স্ক্রলেবল করা হলো
          tabs: const [
            Tab(
              text: "Appointments",
              icon: Icon(Icons.calendar_month),
            ), // 🔥 New Tab
            Tab(text: "Prescriptions", icon: Icon(Icons.description_outlined)),
            Tab(text: "Diagnostic", icon: Icon(Icons.analytics_outlined)),
            Tab(text: "Hospitals", icon: Icon(Icons.local_hospital_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(), // 🔥 New Content
          _buildPrescriptionsTab(),
          _buildDiagnosticsTab(),
          _buildHospitalsTab(),
        ],
      ),
    );
  }

  // 📅 TAB 1: Appointments (Future & Past)
  Widget _buildAppointmentsTab() {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('appointments')
          .select('''
            *,
            doctor:doctor_id(full_name, specialty),
            hospital:hospital_id(full_name, address)
          ''')
          .eq('patient_id', userId)
          .order('appointment_date', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return _emptyState("No appointments found.");
        }

        final appointments = snapshot.data as List;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index];
            final doctor = apt['doctor'] ?? {'full_name': 'Unknown Doctor'};
            final hospital =
                apt['hospital'] ?? {'full_name': 'Unknown Hospital'};
            final date = DateTime.parse(apt['appointment_date']);

            final formattedTime = DateFormat('hh:mm a').format(date);
            final status = apt['status'] ?? 'PENDING';

            Color statusColor = status == 'CONFIRMED'
                ? Colors.green
                : Colors.orange;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMM').format(date).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                DateFormat('dd').format(date),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['full_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                doctor['specialty'] ?? 'Specialist',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hospital['full_name'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 📝 TAB 2: Doctor Visits / Prescriptions (আগের Doctors Tab টি রিনেম করা হয়েছে)
  Widget _buildPrescriptionsTab() {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('medical_events')
          .select('*, uploader:uploader_id(full_name, specialty)')
          .eq('patient_id', userId)
          .eq('event_type', 'PRESCRIPTION')
          .order('event_date', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data as List;
        if (list.isEmpty) return _emptyState("No prescriptions found.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final event = list[index];
            final doctor = event['uploader'] ?? {'full_name': 'Doctor'};
            final date = DateFormat.yMMMd().format(
              DateTime.parse(event['event_date']),
            );

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.description, color: Colors.white),
                ),
                title: Text(
                  doctor['full_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Date: $date\nRx: ${event['title']}"),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // 🧪 TAB 3: Diagnostic (Same as before)
  Widget _buildDiagnosticsTab() {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('patient_payments')
          .select('*, provider:provider_id(full_name)')
          .eq('patient_id', userId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data as List;
        if (list.isEmpty) return _emptyState("No diagnostic records.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final center = item['provider'] ?? {'full_name': 'Lab'};
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.science, color: Colors.white),
                ),
                title: Text(center['full_name']),
                subtitle: Text("Status: ${item['report_status']}"),
              ),
            );
          },
        );
      },
    );
  }

  // 🏥 TAB 4: Hospitals (Same as before)
  Widget _buildHospitalsTab() {
    return _emptyState("Hospital admission history will appear here.");
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
