import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../../../l10n/app_localizations.dart';

import '../../timeline/pages/medical_timeline_view.dart';
import '../../profile/pages/profile_page.dart';
import '../../health_plan/pages/health_plan_page.dart';
import '../../ai_doctor/pages/ai_doctor_page.dart';
import '../../upload/providers/upload_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'add_report_fab',
              onPressed: () => _handleUpload(context, ref),
              icon: const Icon(Icons.add),
              label: Text(
                AppLocalizations.of(context)?.addReport ?? "Add Report",
              ),
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            )
          : null,
    );
  }

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    // Show modal bottom sheet to choose between Camera and Gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Show loading snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading and analyzing report...')),
      );

      final status = await ref
          .read(uploadProvider.notifier)
          .uploadAndAnalyze(file);

      if (!mounted) return;
      if (status == UploadStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report uploaded successfully!')),
        );
      } else if (status == UploadStatus.duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This report has already been uploaded.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
