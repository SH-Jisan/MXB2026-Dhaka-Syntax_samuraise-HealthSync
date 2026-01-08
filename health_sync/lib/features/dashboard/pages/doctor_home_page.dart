/// File: lib/features/dashboard/pages/doctor_home_page.dart
/// Purpose: Main dashboard for Doctor users, showing appointments and patient overview.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../../../shared/widgets/ai_doctor_button.dart';
import '../../../l10n/app_localizations.dart';

import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart';

import '../tabs/doctor_work_tab.dart';

/// Dashboard screen for users with 'DOCTOR' role.
class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DoctorWorkTab(),
    const MedicalTimelineView(),
    const HealthPlanPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const SideDrawer(),

      appBar: AppBar(
        title: Text(_getTitle(context, _selectedIndex)),
        centerTitle: false,
        actions: [
          const AiDoctorButton(),

          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),

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
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(
              Icons.medical_services,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: AppLocalizations.of(context)?.panel ?? 'Panel',
          ),

          NavigationDestination(
            icon: const Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(
              Icons.history_edu,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: AppLocalizations.of(context)?.timeline ?? 'Timeline',
          ),

          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: Icon(
              Icons.spa,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: AppLocalizations.of(context)?.plan ?? 'Plan',
          ),

          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: AppLocalizations.of(context)?.myProfile ?? 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context, int index) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context)?.doctorPanel ?? "Doctor Panel";
      case 1:
        return AppLocalizations.of(context)?.myMedicalHistory ??
            "My Medical History";
      case 2:
        return AppLocalizations.of(context)?.myHealthPlan ?? "My Health Plan";
      case 3:
        return AppLocalizations.of(context)?.myProfile ?? "My Profile";
      default:
        return "";
    }
  }
}
