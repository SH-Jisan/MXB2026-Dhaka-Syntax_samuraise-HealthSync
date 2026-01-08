/// File: lib/features/dashboard/pages/citizen_home_page.dart
/// Purpose: Main dashboard for Citizen users, showing timeline, stats, and quick actions.
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

/// Dashboard screen for users with 'CITIZEN' role.
class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
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
        actions: const [AiDoctorButton()],
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
            label: AppLocalizations.of(context)?.healthPlan ?? 'Health Plan',
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
        return AppLocalizations.of(context)?.myMedicalHistory ??
            "My Medical History";
      case 1:
        return AppLocalizations.of(context)?.healthPlan ?? "Health Plan";
      case 2:
        return AppLocalizations.of(context)?.myProfile ?? "My Profile";
      default:
        return "";
    }
  }
}
