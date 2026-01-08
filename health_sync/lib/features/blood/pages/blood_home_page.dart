/// File: lib/features/blood/pages/blood_home_page.dart
/// Purpose: Main landing page for the Blood Bank feature, offering quick access to requests, donors, and history.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'donor_search_page.dart';
import 'blood_request_page.dart';
import 'blood_requests_feed_page.dart';
import 'donor_registration_page.dart';
import 'my_blood_requests_page.dart';
import '../../../l10n/app_localizations.dart';

/// Hub for all blood-related actions (Request, Donate, Search, Feed).
class BloodHomePage extends StatelessWidget {
  const BloodHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.bloodBank ?? "Blood Bank"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBloodRequestsPage()),
              );
            },
            icon: Icon(
              Icons.history,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            tooltip: AppLocalizations.of(context)?.myRequests ?? "My Requests",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)?.saveLifeToday ??
                  "Save a Life Today",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    theme.textTheme.displayMedium?.color ??
                    (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.chooseOption ??
                  "Choose an option below to proceed",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color:
                    theme.textTheme.bodyMedium?.color ??
                    (isDark ? Colors.grey.shade400 : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),

            _buildOptionCard(
              context,
              title:
                  AppLocalizations.of(context)?.requestBlood ??
                  "Request for Blood",
              subtitle:
                  AppLocalizations.of(context)?.findDonorsNearby ??
                  "Find donors nearby instantly",
              icon: Icons.bloodtype_outlined,
              color: Colors.red.shade600,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BloodRequestPage()),
              ),
            ),

            const SizedBox(height: 16),

            _buildOptionCard(
              context,
              title:
                  AppLocalizations.of(context)?.becomeDonor ?? "Become a Donor",
              subtitle:
                  AppLocalizations.of(context)?.registerToSaveLives ??
                  "Register to save lives",
              icon: Icons.volunteer_activism_outlined,
              color: Colors.teal.shade600,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DonorRegistrationPage(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildOptionCard(
              context,
              title:
                  AppLocalizations.of(context)?.findBloodDonors ??
                  "Find Blood Donors",
              subtitle:
                  AppLocalizations.of(context)?.searchByGroupLocation ??
                  "Search by group & location",
              icon: Icons.search,
              color: Colors.blue.shade600,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorSearchPage()),
              ),
            ),

            const SizedBox(height: 16),

            _buildOptionCard(
              context,
              title:
                  AppLocalizations.of(context)?.liveRequestsFeed ??
                  "Live Requests (Feed)",
              subtitle:
                  AppLocalizations.of(context)?.seeWhoNeedsHelp ??
                  "See who needs help right now",
              icon: Icons.emergency_outlined,
              color: Colors.orange.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BloodRequestsFeedPage(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildOptionCard(
              context,
              title:
                  AppLocalizations.of(context)?.myRequestsHistory ??
                  "My Requests & History",
              subtitle:
                  AppLocalizations.of(context)?.trackYourRequests ??
                  "Track your requests",
              icon: Icons.history_edu,
              color: Colors.purple.shade600,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBloodRequestsPage()),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isDark ? Border.all(color: Colors.grey.shade800) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
