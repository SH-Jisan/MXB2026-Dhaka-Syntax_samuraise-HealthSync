import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../../../shared/widgets/ai_doctor_button.dart'; // 🔥 Fix: Shared Widget

// পেজ ইম্পোর্ট
import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart'; // 🔥 Health Plan Import
// import 'ai_doctor_page.dart'; // Removed
import '../tabs/doctor_work_tab.dart'; // আমাদের তৈরি করা ওয়ার্ক ট্যাব

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;

  // পেজগুলোর লিস্ট (Health Plan সহ)
  final List<Widget> _pages = [
    const DoctorWorkTab(), // Tab 0: Doctor Panel (রোগীদের লিস্ট)
    const MedicalTimelineView(), // Tab 1: My Timeline (নিজের হিস্ট্রি)
    const HealthPlanPage(), // Tab 2: Health Plan (🔥 New)
    const ProfilePage(), // Tab 3: Profile
  ];

  // টাইটেল লিস্ট
  final List<String> _titles = [
    "Doctor Panel",
    "My Medical History",
    "My Health Plan",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const SideDrawer(), // কমন সাইড ড্রয়ার

      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: false,
        actions: [
          // 🔥 AI Doctor Button (New)
          const AiDoctorButton(), // 🔥 Fix: Used Shared Widget
          // নোটিফিকেশন বাটন
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),

      // পেজ সুইচ করার সময় স্টেট ধরে রাখার জন্য IndexedStack ব্যবহার করা ভালো
      body: IndexedStack(index: _selectedIndex, children: _pages),

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
          // 1. Doctor Panel (Extra Feature)
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(
              Icons.medical_services,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Panel',
          ),

          // 2. Personal Timeline
          NavigationDestination(
            icon: const Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(
              Icons.history_edu,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Timeline',
          ),

          // 3. Health Plan (🔥 New)
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: Icon(
              Icons.spa,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'Plan',
          ),

          // 4. Profile
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
