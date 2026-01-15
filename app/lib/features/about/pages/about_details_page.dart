/// File: lib/features/about/pages/about_details_page.dart
/// Purpose: Detailed information about the app's purpose, usage, and tech stack.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';

class AboutDetailsPage extends StatelessWidget {
  const AboutDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              "About & Guide",
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 120,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // --- Introduction ---
                  Text(
                    "Your AI-Powered Healthcare Companion",
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ).animate().fadeIn().slideY(),
                  const SizedBox(height: 16),
                  Text(
                    "HealthSync Pro centralizes your medical history, "
                    "provides instant AI-powered symptom analysis, and connects you with life-saving resources like blood donors.",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 48),

                  // --- How to Use App (New Section) ---
                  _SectionHeader(
                    title: "How to Use the App",
                    icon: PhosphorIconsDuotone.bookOpenText,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _InstructionGroup(
                    title: "Getting Started",
                    icon: PhosphorIconsRegular.userCircle,
                    isDark: isDark,
                    children: [
                      _InstructionStep(
                        step: "1",
                        text:
                            "Create an Account: Sign up as a 'Citizen', 'Doctor', or 'Hospital'.",
                      ),
                      _InstructionStep(
                        step: "2",
                        text:
                            "Complete Profile: Add your personal details and medical background for better AI insights.",
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  _InstructionGroup(
                    title: "Track Your Health",
                    icon: PhosphorIconsRegular.heartbeat,
                    isDark: isDark,
                    children: [
                      _InstructionStep(
                        step: "1",
                        text:
                            "Dashboard: View your vitals and upcoming activities.",
                      ),
                      _InstructionStep(
                        step: "2",
                        text:
                            "Timeline: Upload prescriptions or reports. The AI will analyze them automatically.",
                      ),
                      _InstructionStep(
                        step: "3",
                        text:
                            "Health Plan: Generate a personalized daily routine based on your medical history.",
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  _InstructionGroup(
                    title: "AI & Doctors",
                    icon: PhosphorIconsRegular.stethoscope,
                    isDark: isDark,
                    children: [
                      _InstructionStep(
                        step: "1",
                        text:
                            "AI Doctor: Chat with the AI for instant symptom analysis and advice.",
                      ),
                      _InstructionStep(
                        step: "2",
                        text:
                            "Find Doctors: Browse specialists and book appointments directly.",
                      ),
                      _InstructionStep(
                        step: "3",
                        text:
                            "Consultation: Manage your appointments and view prescriptions.",
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms),

                  _InstructionGroup(
                    title: "Blood Bank",
                    icon: PhosphorIconsRegular.drop,
                    isDark: isDark,
                    children: [
                      _InstructionStep(
                        step: "1",
                        text:
                            "Find Donors: Search for donors by blood group and location.",
                      ),
                      _InstructionStep(
                        step: "2",
                        text:
                            "Request Blood: Post a request in case of emergencies.",
                      ),
                      _InstructionStep(
                        step: "3",
                        text:
                            "Donate: Register as a donor to help others nearby.",
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 48),

                  // --- Key Features ---
                  _SectionHeader(
                    title: "Key Features",
                    icon: PhosphorIconsDuotone.star,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _FeatureCard(
                    title: "Medical Timeline",
                    description:
                        "AI automatically organizes your uploaded reports into a visual history.",
                    icon: PhosphorIconsFill.clockCounterClockwise,
                    color: Colors.blue,
                    isDark: isDark,
                    delay: 450.ms,
                  ),
                  _FeatureCard(
                    title: "AI Doctor",
                    description:
                        "24/7 symptom analysis and health guidance powered by Gemini.",
                    icon: PhosphorIconsFill.robot,
                    color: Colors.purple,
                    isDark: isDark,
                    delay: 500.ms,
                  ),
                  _FeatureCard(
                    title: "Blood Bank",
                    description:
                        "Connect with donors instantly based on location and blood group.",
                    icon: PhosphorIconsFill.drop,
                    color: Colors.red,
                    isDark: isDark,
                    delay: 550.ms,
                  ),

                  const SizedBox(height: 48),

                  // --- Tech Stack ---
                  _SectionHeader(
                    title: "Powered By",
                    icon: PhosphorIconsDuotone.lightning,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _TechPill(
                        name: "Flutter",
                        icon: PhosphorIconsFill.code,
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                      _TechPill(
                        name: "Supabase",
                        icon: PhosphorIconsFill.database,
                        color: Colors.green,
                        isDark: isDark,
                      ),
                      _TechPill(
                        name: "Gemini AI",
                        icon: PhosphorIconsFill.brain,
                        color: Colors.purpleAccent,
                        isDark: isDark,
                      ),
                      _TechPill(
                        name: "Riverpod",
                        icon: PhosphorIconsFill.arrowsSplit,
                        color: Colors.teal,
                        isDark: isDark,
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isDark;

  const _InstructionGroup({
    required this.title,
    required this.icon,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: children,
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String step;
  final String text;

  const _InstructionStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Duration delay;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1);
  }
}

class _TechPill extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _TechPill({
    required this.name,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252A34) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            name,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
