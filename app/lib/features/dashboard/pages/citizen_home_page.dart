import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../../../l10n/app_localizations.dart';

import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart';
import '../../ai_doctor/pages/ai_doctor_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard screen for users with 'CITIZEN' role.
class CitizenHomePage extends ConsumerStatefulWidget {
  const CitizenHomePage({super.key});

  @override
  ConsumerState<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends ConsumerState<CitizenHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MedicalTimelineView(),
    const HealthPlanPage(),
    const AiDoctorPage(),
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
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: isDark ? theme.cardTheme.color : Colors.white,
        indicatorColor: isDark
            ? AppColors.darkPrimary.withOpacity(0.3)
            : AppColors.primary.withOpacity(0.2),
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
            icon: const Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(
              Icons.support_agent,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            label: 'AI Health',
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
      floatingActionButton: null,
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
        return "AI Health Assistant";
      case 3:
        return AppLocalizations.of(context)?.myProfile ?? "My Profile";
      default:
        return "";
    }
  }
}
