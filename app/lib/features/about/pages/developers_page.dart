import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

class DevelopersPage extends StatelessWidget {
  const DevelopersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final developers = [
      {
        "name": "Md Rifat Islam Rizvi",
        "role": "Project Lead, AI/ML Developer",
        "image": "assets/developers/rizvi.jpg",
        "contact": "01305612767",
      },
      {
        "name": "Sanjid Hasan Jisan",
        "role": "Frontend & Backend Developer",
        "image": "assets/developers/jisan.png",
        "contact": "01537284797",
      },
      {
        "name": "Md Nahid Hossain",
        "role": "AI/ML Developer",
        "image": "assets/developers/Nahid Vai.jpg",
        "contact": "01859232959",
      },
      {
        "name": "Munira Khondoker",
        "role": "Data Analyst and Researcher",
        "image": "assets/developers/munira.jpeg",
        "contact": "01876541001",
      },
      {
        "name": "Anisur Rahman",
        "role": "Video Editor & Graphic Designer",
        "image": "assets/developers/anisur.jpeg",
        "contact": "01616414541",
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          "Developers",
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // --- Hero Team Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/developers/syntax_samuraies team.jpeg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                  Text(
                    "Team Syntax_Samuraies",
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    "Innovating Healthcare with AI & Empathy",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Dept. of CSE, GSTU",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Individual Developers ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsDuotone.code,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "MEET THE MINDS",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...developers.map((dev) {
                    return _buildDeveloperCard(
                      context,
                      dev,
                      isDark,
                    ).animate().fadeIn().slideX(begin: 0.1);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- Footer Brand ---
            Opacity(
              opacity: 0.5,
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.favorite, color: Colors.red),
                  ), // Fallback if logo missing
                  const SizedBox(height: 8),
                  Text(
                    "HealthSync Pro © 2026",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context,
    Map<String, String> dev,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final number = dev['contact'];
            if (number != null) {
              final uri = Uri.parse("tel:$number");
              if (await canLaunchUrl(uri)) launchUrl(uri);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Image
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(dev['image']!),
                    onBackgroundImageError: (_, __) {
                      // Handled by default usually, but good to know
                    },
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dev['name']!,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dev['role']!,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.phone,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dev['contact']!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action
                Icon(
                  PhosphorIconsBold.phoneCall,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
