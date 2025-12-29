import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart'; // 🔥 Import Drawer
import '../widgets/hospital_overview_tab.dart';
import '../widgets/hospital_doctors_tab.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 🔥 Sidebar যুক্ত করা হলো এখানে
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
            Tab(text: "Doctors", icon: Icon(Icons.medical_services)),
          ],
        ),
        actions: [
          // লগআউট বাটনটি এখানেও রাখতে পারেন অথবা সাইডবারে নিয়ে যেতে পারেন
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
          HospitalDoctorsTab(),
        ],
      ),
    );
  }
}