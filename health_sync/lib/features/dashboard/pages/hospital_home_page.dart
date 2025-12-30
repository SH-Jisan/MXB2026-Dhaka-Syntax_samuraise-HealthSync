import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../widgets/hospital_overview_tab.dart';
import '../widgets/hospital_doctors_tab.dart';
import 'hospital_patients_page.dart'; // 🔥 Import New Page

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 🔥 Changed to 3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Hospital Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Overview", icon: Icon(Icons.dashboard)),
            Tab(text: "Patients", icon: Icon(Icons.people_outline)), // 🔥 New Tab
            Tab(text: "Doctors", icon: Icon(Icons.medical_services)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HospitalOverviewTab(),
          HospitalPatientsPage(), // 🔥 New Page Added
          HospitalDoctorsTab(),
        ],
      ),
    );
  }
}