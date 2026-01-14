/// File: lib/shared/widgets/side_drawer.dart
/// Purpose: Navigation drawer for the application, matching web sidebar design.
/// Author: HealthSync Team
library;

import 'dart:ui'; // For BackdropFilter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../features/about/about_app_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/blood/pages/blood_home_page.dart';
import '../../features/dashboard/pages/notifications_page.dart'; // Import NotificationsPage
import '../../features/dashboard/pages/prescriptions_page.dart'; // Import PrescriptionsPage
import '../../features/dashboard/pages/doctor_list_page.dart'; // Import DoctorListPage
import '../../features/profile/pages/patient_history_page.dart'; // Import PatientHistoryPage
import '../providers/theme_provider.dart';
import 'language_selector_widget.dart';

/// Global side drawer for navigation and settings.
class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Guest";
    final name = user?.userMetadata?['full_name'] ?? "User";
    final role = user?.userMetadata?['role'] ?? "CITIZEN";
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "U";

    // Menu Item Definition
    // Using a list of maps to easily render items. In a real app, strict typing or classes are better.
    final List<Map<String, dynamic>> menuItems = [
      {
        'key': 'dashboard',
        'icon': PhosphorIconsRegular.squaresFour,
        'label': AppLocalizations.of(context)?.dashboard ?? "Dashboard",
        'onTap': () => context
            .pop(), // Closes drawer, assumes we are on dashboard or shell handles nav
      },
      if (role == 'CITIZEN' || role == 'DOCTOR')
        {
          'key': 'prescriptions',
          'icon': PhosphorIconsRegular.prescription,
          'label': "Prescriptions", // Missing l10n key for now
          'onTap': () {
            context.pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrescriptionsPage()),
            );
          },
        },
      {
        'key': 'blood',
        'icon': PhosphorIconsFill.drop, // Fill for color emphasis
        'iconColor': Colors.redAccent,
        'label': AppLocalizations.of(context)?.bloodBank ?? "Blood Bank",
        'onTap': () {
          context.pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BloodHomePage()),
          );
        },
      },
      {
        'key': 'doctors',
        'icon': PhosphorIconsRegular.firstAid,
        'label': "Doctors", // Missing l10n
        'onTap': () {
          context.pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorListPage(specialty: 'All'),
            ),
          );
        },
      },
      if (role == 'CITIZEN') ...[
        {
          'key': 'appointments',
          'icon': PhosphorIconsRegular.calendarCheck,
          'label': "My Appointments", // Missing l10n
          'onTap': () {
            context.pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PatientHistoryPage(),
              ), // Reuse History Page for now
            );
          },
        },
      ],
      {
        'key': 'profile',
        'icon': PhosphorIconsRegular.user,
        'label': AppLocalizations.of(context)?.myProfile ?? "Profile",
        'onTap': () {
          context.pop();
          // In dashboard this is usually an index change, here we just close for now or nav
          // For now, assuming profile is part of home tabs, so closing drawer is fine if we were external
          // But if we want to "Go to Profile", we might need to change the dashboard index.
          // However, to keep it simple as per request:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Access Profile from Bottom Bar")),
          );
        },
      },
      {
        'key': 'about',
        'icon': PhosphorIconsRegular.info,
        'iconColor': Colors.blueAccent,
        'label': AppLocalizations.of(context)?.aboutApp ?? "About App",
        'onTap': () {
          context.pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutAppPage()),
          );
        },
      },
    ];

    return Drawer(
      backgroundColor: Colors.transparent, // Transparent for blur effect
      elevation: 0,
      width:
          MediaQuery.of(context).size.width *
          0.85, // Slightly wider like web mobile
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ), // Flutter drawer is usually rectangular
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          "WELCOME BACK", // Localize me
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00796B),
                                Color(0xFF004D40),
                              ], // Primary -> Secondary
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00796B,
                                ).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  firstLetter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      email,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Navigation ---
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ...menuItems.map((item) {
                          // Define active logic (simplified)
                          bool isActive =
                              item['key'] ==
                              'dashboard'; // Default active for now as we don't track route perfectly here

                          return _buildNavItem(
                            context,
                            icon: item['icon'],
                            label: item['label'],
                            onTap: item['onTap'],
                            isActive: isActive,
                            iconColor: item['iconColor'],
                            isDark: isDark,
                          );
                        }),

                        // Notifications Link
                        _buildNavItem(
                          context,
                          icon: PhosphorIconsBold.bell,
                          label: "Notifications", // Localize me safely
                          onTap: () {
                            context.pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                          isDark: isDark,
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),

                        // Settings Group (Theme + Language)
                        Row(
                          children: [
                            // Theme Toggle
                            Expanded(
                              child: InkWell(
                                onTap: () => ref
                                    .read(themeProvider.notifier)
                                    .toggleTheme(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isDark
                                        ? PhosphorIconsFill.moon
                                        : PhosphorIconsRegular.sun,
                                    color: isDark
                                        ? Colors.amber
                                        : Colors.grey.shade700,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Language
                            Expanded(
                              flex: 2,
                              child: LanguageSelectorWidget(
                                isDropdown: true,
                                contentColor: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Footer ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: InkWell(
                      onTap: () async {
                        await ref.read(authStateProvider.notifier).logout();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsRegular.signOut,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)?.logout ?? "Logout",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? iconColor,
    required bool isDark,
  }) {
    final activeColor = AppColors.primary;
    // Fix: Make inactive color darker in light mode for better contrast against white background
    final inactiveColor = isDark ? Colors.white70 : const Color(0xFF1F2937);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(
                            alpha: 0.1,
                          )) // Increased alpha for visibility
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  color: isActive ? activeColor : (iconColor ?? inactiveColor),
                  size: 24,
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                ),
                // Active Indicator (Pill style on Right)
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
