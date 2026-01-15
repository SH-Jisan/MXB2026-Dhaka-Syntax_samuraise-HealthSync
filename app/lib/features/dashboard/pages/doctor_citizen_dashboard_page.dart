/// File: lib/features/dashboard/pages/doctor_citizen_dashboard_page.dart
/// Purpose: A Citizen-like view for Doctors to manage their own health.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../ai_doctor/pages/ai_doctor_page.dart';
import '../../health_plan/pages/health_plan_page.dart';
import '../../timeline/pages/medical_timeline_view.dart';

/// Scoped dashboard for Doctors to access "Citizen" features.
class DoctorCitizenDashboardPage extends ConsumerStatefulWidget {
  const DoctorCitizenDashboardPage({super.key});

  @override
  ConsumerState<DoctorCitizenDashboardPage> createState() =>
      _DoctorCitizenDashboardPageState();
}

class _DoctorCitizenDashboardPageState
    extends ConsumerState<DoctorCitizenDashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = Supabase.instance.client.auth.currentUser;

    // Tabs mirroring the requested Citizen features
    final List<Widget> pages = [
      // 1. Medical History (Timeline)
      MedicalTimelineView(patientId: user?.id),

      // 2. Health Plan
      const HealthPlanPage(),

      // 3. AI Doctor
      const AiDoctorPage(),
    ];

    final titles = ["Medical History", "Health Plan", "AI Doctor"];

    return Scaffold(
      appBar:
          _currentIndex == 1 ||
              _currentIndex ==
                  2 // Health Plan and AI Doctor have their own app bars
          ? null
          : AppBar(title: Text(titles[_currentIndex]), centerTitle: true),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 2,
        destinations: [
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
            selectedIcon: Icon(
              PhosphorIconsFill.clockCounterClockwise,
              color: AppColors.primary,
            ),
            label: titles[0],
          ),
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.clipboardText),
            selectedIcon: Icon(
              PhosphorIconsFill.clipboardText,
              color: AppColors.primary,
            ),
            label: titles[1],
          ),
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.robot),
            selectedIcon: Icon(
              PhosphorIconsFill.robot,
              color: AppColors.primary,
            ),
            label: titles[2],
          ),
        ],
      ),
    );
  }
}
