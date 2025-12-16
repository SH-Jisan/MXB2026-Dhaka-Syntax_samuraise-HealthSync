import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import 'ai_doctor_page.dart';

// পেজ ইম্পোর্ট
import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart'; // 🔥 নতুন পেজ ইম্পোর্ট

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  int _selectedIndex = 0;

  // 🔥 পেজের লিস্টে HealthPlanPage যোগ করা হলো
  final List<Widget> _pages = [
    const MedicalTimelineView(), // Tab 0
    const HealthPlanPage(),      // Tab 1: AI Health Plan (NEW)
    const ProfilePage(),         // Tab 2
  ];

  final List<String> _titles = [
    "My Medical History",
    "Health Plan",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideDrawer(),

      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: false,
        actions: [
          // শুধু টাইমলাইনেই AI Doctor বাটন রাখা যেতে পারে, অথবা সবখানে
          IconButton(
            icon: const Icon(Icons.support_agent, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiDoctorPage()),
              );
            },
          ),
        ],
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        elevation: 3,
        destinations: const [
          // 1. Timeline
          NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu, color: AppColors.primary),
            label: 'Timeline',
          ),

          // 2. Health Plan (NEW)
          NavigationDestination(
            icon: Icon(Icons.spa_outlined), // Spa বা Leaf আইকন হেলথের জন্য ভালো
            selectedIcon: Icon(Icons.spa, color: AppColors.primary),
            label: 'Health Plan',
          ),

          // 3. Profile
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}