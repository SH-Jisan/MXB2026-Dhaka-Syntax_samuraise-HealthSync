import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          tabs: const [
            Tab(text: "Doctors", icon: Icon(Icons.person_outline)),
            Tab(text: "Diagnostic", icon: Icon(Icons.analytics_outlined)),
            Tab(text: "Hospitals", icon: Icon(Icons.local_hospital_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsTab(),
          _buildDiagnosticsTab(),
          _buildHospitalsTab(),
        ],
      ),
    );
  }

  // 👨‍⚕️ Tab 1: Doctors History (Appointments & Visits)
  // বর্তমানে আমাদের appointment টেবিল নেই, তাই আমরা medical_events চেক করব
  // যেখানে event_type = 'PRESCRIPTION' (মানে ডাক্তার দেখেছেন)
  Widget _buildDoctorsTab() {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('medical_events')
          .select('*, uploader:uploader_id(full_name, specialty, phone)') // ডাক্তারের ডিটেইলস জয়েন
          .eq('patient_id', userId)
          .eq('event_type', 'PRESCRIPTION') // শুধু প্রেসক্রিপশন মানেই ডাক্তার ভিজিট
          .order('event_date', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data as List;

        if (list.isEmpty) return _emptyState("No doctor visits found.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final event = list[index];
            final doctor = event['uploader'] ?? {'full_name': 'Unknown Doctor'};
            final date = DateFormat.yMMMd().format(DateTime.parse(event['event_date']));

            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.medical_services, color: Colors.white)),
                title: Text(doctor['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Visited on: $date\nDiagnosis: ${event['title']}"),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // প্রেসক্রিপশন ডিটেইলস পেজে যাওয়ার কোড এখানে হবে
                },
              ),
            );
          },
        );
      },
    );
  }

  // 🧪 Tab 2: Diagnostic & Tests (Pending & Completed)
  // আমরা patient_payments টেবিল থেকে ডাটা আনব যা আমরা ডায়াগনস্টিক ফিচারে বানিয়েছি
  Widget _buildDiagnosticsTab() {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('patient_payments')
          .select('*, provider:provider_id(full_name, address)') // ডায়াগনস্টিক সেন্টারের নাম
          .eq('patient_id', userId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data as List;

        if (list.isEmpty) return _emptyState("No diagnostic history.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final center = item['provider'] ?? {'full_name': 'Diagnostic Center'};
            final isPending = item['report_status'] == 'PENDING';
            final tests = List.from(item['test_names'] ?? []).join(", ");
            final date = DateFormat.yMMMd().format(DateTime.parse(item['created_at']));

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isPending ? Colors.orange.shade200 : Colors.transparent),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                  child: Icon(isPending ? Icons.hourglass_top : Icons.check, color: isPending ? Colors.orange : Colors.green),
                ),
                title: Text(center['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tests, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: Chip(
                  label: Text(item['report_status']),
                  backgroundColor: isPending ? Colors.orange.shade50 : Colors.green.shade50,
                  labelStyle: TextStyle(color: isPending ? Colors.orange : Colors.green, fontSize: 10),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🏥 Tab 3: Hospitals (Admissions or Visits)
  // আপাতত আমরা hospital_patients টেবিল চেক করব (যদি অ্যাসাইন করা থাকে) অথবা medical_events
  Widget _buildHospitalsTab() {
    // এখানে লজিক হতে পারে: যেসব medical_events এর uploader এর রোল 'HOSPITAL'
    // অথবা diagnostic_patients এর মতো hospital_patients টেবিল থাকলে সেটি।
    // আমরা আপাতত medical_events দিয়ে করছি।

    return FutureBuilder(
      future: Supabase.instance.client
          .from('medical_events')
          .select('*, uploader:uploader_id(full_name, role)')
          .eq('patient_id', userId)
      //.eq('uploader.role', 'HOSPITAL') // এটি জয়েন ফিল্টারিং, সুপাবেসে একটু ভিন্নভাবে লিখতে হয়
          .order('event_date', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // ক্লায়েন্ট সাইড ফিল্টারিং (সহজ উপায়ের জন্য)
        final allEvents = snapshot.data as List;
        final hospitalEvents = allEvents.where((e) => e['uploader'] != null && e['uploader']['role'] == 'HOSPITAL').toList();

        if (hospitalEvents.isEmpty) return _emptyState("No hospital records found.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hospitalEvents.length,
          itemBuilder: (context, index) {
            final event = hospitalEvents[index];
            final hospital = event['uploader'];
            final date = DateFormat.yMMMd().format(DateTime.parse(event['event_date']));

            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.local_hospital, color: Colors.white)),
                title: Text(hospital['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Date: $date\nEvent: ${event['title']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}