/// File: lib/features/about/pages/about_details_page.dart
/// Purpose: Detailed information about the app's purpose, usage, and tech stack.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AboutDetailsPage extends StatelessWidget {
  const AboutDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("About & How to Use")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purpose & Features
            Text(
              "HealthSync Pro",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "HealthSync Pro is an advanced healthcare assistant designed to centralize your medical history, "
              "provide instant AI-powered symptom analysis, and connect you with life-saving resources like blood donors.",
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // How to Use
            _buildSectionHeader("How to Use", isDark),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isDark ? Border.all(color: Colors.grey.shade800) : null,
              ),
              child: Column(
                children: [
                  _buildStepRow(
                    "1",
                    "Upload Reports: Maintain your digital medical history by uploading prescriptions and reports.",
                    isDark,
                  ),
                  _buildStepRow(
                    "2",
                    "AI Analysis: Our AI automatically analyzes your documents to build a health timeline.",
                    isDark,
                  ),
                  _buildStepRow(
                    "3",
                    "AI Doctor: Consult the AI Doctor for instant guidance on symptoms and health queries.",
                    isDark,
                  ),
                  _buildStepRow(
                    "4",
                    "Blood Bank: Find interested blood donors nearby or request blood urgently.",
                    isDark,
                  ),
                  _buildStepRow(
                    "5",
                    "Dashboard: View your vitals, recent events, and upcoming appointments at a glance.",
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tech Stack
            _buildSectionHeader("Powered By", isDark),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildTechCard(
                  Icons.code,
                  "Flutter",
                  "UI Framework",
                  Colors.blue,
                  isDark,
                ),
                _buildTechCard(
                  Icons.storage_rounded,
                  "Supabase",
                  "Backend DB",
                  Colors.green,
                  isDark,
                ),
                _buildTechCard(
                  Icons.psychology,
                  "Gemini AI",
                  "Intelligence",
                  Colors.purple,
                  isDark,
                ),
                _buildTechCard(
                  Icons.search,
                  "Serper API",
                  "Doc Search",
                  Colors.orange,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
