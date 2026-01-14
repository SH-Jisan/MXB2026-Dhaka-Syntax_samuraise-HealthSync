/// File: lib/features/profile/pages/profile_page.dart
/// Purpose: Displays user profile, stats, and settings.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../blood/pages/my_blood_requests_page.dart';
import '../providers/doctor_hospitals_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';

import '../../../l10n/app_localizations.dart';

/// User profile screen showing personal details, role-specific stats, and settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.logout ?? "Logout"),
        content: Text(
          AppLocalizations.of(context)?.logoutConfirmation ??
              "Are you sure you want to log out?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? "Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)?.logout ?? "Logout",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.myProfile ?? "My Profile"),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (profileData) {
          if (profileData == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context)?.userNotFound ?? "User not found",
              ),
            );
          }

          final user = Supabase.instance.client.auth.currentUser;
          final email = user?.email ?? 'No Email';
          final name = profileData['full_name'] ?? 'User';
          final phone = profileData['phone'] ?? 'No Phone';
          final role = profileData['role'] ?? 'CITIZEN';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardTheme.color : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.08,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            (isDark ? AppColors.darkPrimary : AppColors.primary)
                                .withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "U",
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(role),
                        backgroundColor: isDark
                            ? Colors.blue.shade900
                            : Colors.blue.shade50,
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.blue.shade200
                              : Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (role == 'DOCTOR' && user != null) ...[
                  _DoctorHospitalsSection(doctorId: user.id),
                  const SizedBox(height: 24),
                ],

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Text(
                      AppLocalizations.of(context)?.personalInformation ??
                          "Personal Information",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                _buildInfoTile(
                  Icons.phone_outlined,
                  AppLocalizations.of(context)?.phoneNumber ?? "Phone Number",
                  phone,
                  isDark,
                ),
                _buildInfoTile(
                  Icons.email_outlined,
                  AppLocalizations.of(context)?.emailLabel ?? "Email Address",
                  email,
                  isDark,
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Text(
                      AppLocalizations.of(context)?.settingsActivity ??
                          "Settings & Activity",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                _buildActionTile(
                  icon: Icons.bloodtype,
                  color: Colors.red,
                  title:
                      AppLocalizations.of(context)?.myBloodRequests ??
                      "My Blood Requests",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyBloodRequestsPage(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: Text(
                      AppLocalizations.of(context)?.logout ?? "LOGOUT",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DoctorHospitalsSection extends ConsumerWidget {
  final String doctorId;
  const _DoctorHospitalsSection({required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(doctorHospitalsProvider(doctorId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              AppLocalizations.of(context)?.myAssociatedHospitals ??
                  "My Associated Hospitals",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        hospitalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text("Error: $err"),
          data: (hospitals) {
            if (hospitals.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)?.notAssignedToHospital ??
                      "Not assigned yet.",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
            return Column(
              children: hospitals.map((item) {
                final hospital = item['hospital'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_hospital,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      hospital['full_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(hospital['address'] ?? 'No address'),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
