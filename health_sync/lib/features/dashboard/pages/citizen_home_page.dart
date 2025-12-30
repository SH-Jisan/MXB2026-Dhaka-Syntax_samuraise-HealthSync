import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../../../shared/widgets/ai_doctor_button.dart'; // 🔥 Fix: Shared Widget

// পেজ ইম্পোর্ট
import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MedicalTimelineView(), // Tab 0
    const HealthPlanPage(), // Tab 1: AI Health Plan
    const ProfilePage(), // Tab 2
  ];

  final List<String> _titles = [
    "My Medical History",
    "Health Plan",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const SideDrawer(),

      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: false,
        actions: const [
          AiDoctorButton(), // 🔥 Fix: Used Shared Widget
        ],
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: isDark ? theme.cardTheme.color : Colors.white,
        indicatorColor: isDark
            ? AppColors.darkPrimary.withValues(alpha: 0.3)
            : AppColors.primary.withValues(alpha: 0.2),
        elevation: 3,
        destinations: [
          // 1. Timeline
          NavigationDestination(
            icon: const Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(
              Icons.history_edu,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Timeline',
          ),

          // 2. Health Plan
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: Icon(
              Icons.spa,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Health Plan',
          ),

          // 3. Profile
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
