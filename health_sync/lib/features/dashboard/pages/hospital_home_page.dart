import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../widgets/hospital_overview_tab.dart';
import '../widgets/hospital_doctors_tab.dart';
import 'hospital_patients_page.dart'; 

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Hospital Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          tabs: const [
            Tab(text: "Overview", icon: Icon(Icons.dashboard)),
            Tab(
              text: "Patients",
              icon: Icon(Icons.people_outline),
            ), 
            Tab(text: "Doctors", icon: Icon(Icons.medical_services)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HospitalOverviewTab(),
          HospitalPatientsPage(), 
          HospitalDoctorsTab(),
        ],
      ),
    );
  }
}
