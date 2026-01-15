/// File: lib/features/profile/pages/profile_page.dart
/// Purpose: Displays user profile, stats, and settings with enhanced UI.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../blood/pages/my_blood_requests_page.dart';
import '../providers/doctor_hospitals_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';

import '../../../l10n/app_localizations.dart';

/// User profile screen using a minimalist design language.
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

    // Minimalist Background Color
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.myProfile ?? "My Profile",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold, // Clean, modern font choice
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // 1. Clean Centered Header
                _SimpleProfileHeader(
                      name: name,
                      email: email,
                      role: role,
                      isDark: isDark,
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut),

                const SizedBox(height: 32),

                // 2. Doctor Specifics (if applicable)
                if (role == 'DOCTOR' && user != null) ...[
                  _DoctorSection(
                    doctorId: user.id,
                    isDark: isDark,
                    cardColor: cardColor,
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),
                ],

                // 3. Grouped Info Sections
                _InfoSection(
                  title:
                      AppLocalizations.of(context)?.personalInformation ??
                      "Personal Information",
                  isDark: isDark,
                  cardColor: cardColor,
                  children: [
                    _MinimalTile(
                      icon: PhosphorIconsDuotone.phone,
                      title:
                          AppLocalizations.of(context)?.phoneNumber ?? "Phone",
                      value: phone,
                      isDark: isDark,
                      isFirst: true,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    _MinimalTile(
                      icon: PhosphorIconsDuotone.envelope,
                      title:
                          AppLocalizations.of(context)?.emailLabel ?? "Email",
                      value: email,
                      isDark: isDark,
                      isLast: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),

                const SizedBox(height: 24),

                // 4. Settings & Actions
                _InfoSection(
                  title:
                      AppLocalizations.of(context)?.settingsActivity ??
                      "Settings",
                  isDark: isDark,
                  cardColor: cardColor,
                  children: [
                    _MinimalActionTile(
                      icon: PhosphorIconsDuotone.drop,
                      title:
                          AppLocalizations.of(context)?.myBloodRequests ??
                          "My Blood Requests",
                      color: Colors.redAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyBloodRequestsPage(),
                        ),
                      ),
                      isDark: isDark,
                      isFirst: true,
                      isLast: true, // Only one item for now
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05),

                const SizedBox(height: 48),

                // 5. Minimal Logout
                TextButton(
                  onPressed: () => _handleLogout(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.signOut, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.logout ?? "Log Out",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SimpleProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isDark;

  const _SimpleProfileHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 2,
                ),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundColor: isDark
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFE0F2F1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: GoogleFonts.manrope(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF121212)
                        : const Color(0xFFF5F7FA),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  PhosphorIconsFill.user,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? Colors.blueAccent : Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? Colors.blueAccent[100] : Colors.blue[800],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color cardColor;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.isDark,
    required this.cardColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MinimalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _MinimalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _MinimalActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _MinimalActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              PhosphorIconsBold.caretRight,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorSection extends ConsumerWidget {
  final String doctorId;
  final bool isDark;
  final Color cardColor;

  const _DoctorSection({
    required this.doctorId,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(doctorHospitalsProvider(doctorId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            (AppLocalizations.of(context)?.myAssociatedHospitals ??
                    "My Associated Hospitals")
                .toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        hospitalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text("Error: $err"),
          data: (hospitals) {
            if (hospitals.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)?.notAssignedToHospital ??
                        "Not assigned to any hospital yet.",
                    style: GoogleFonts.manrope(color: Colors.grey),
                  ),
                ),
              );
            }
            return Column(
              children: hospitals.map((item) {
                final hospital = item['hospital'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.hospital,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      hospital['full_name'],
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      hospital['address'] ?? 'No address',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
