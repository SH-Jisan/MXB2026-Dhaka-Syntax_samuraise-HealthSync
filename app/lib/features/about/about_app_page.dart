import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import 'pages/about_details_page.dart';
import 'pages/developers_page.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gradient Background for a premium feel
    final backgroundGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFF0F4F8), Color(0xFFE1E8ED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "About HealthSync",
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // --- Pulsing Logo Section ---
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child:
                      Image.asset('assets/logo/logo.png', fit: BoxFit.contain)
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 2.seconds,
                          ),
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 20),

              Text(
                "HealthSync Pro",
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ).animate().fadeIn(delay: 200.ms),

              Text(
                "v1.0.0 • Production Build",
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 60),

              // --- Premium Menu Cards ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _PremiumMenuCard(
                      title: "About & Guide",
                      subtitle: "Learn about features & usage",
                      icon: PhosphorIconsDuotone.bookOpenText,
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutDetailsPage(),
                        ),
                      ),
                      delay: 400.ms,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _PremiumMenuCard(
                      title: "Meet the Developers",
                      subtitle: "Team Syntax_Samuraies",
                      icon: PhosphorIconsDuotone.code,
                      color: Colors.purpleAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DevelopersPage(),
                        ),
                      ),
                      delay: 500.ms,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _PremiumMenuCard(
                      title: "Privacy Policy",
                      subtitle: "Data protection & safety",
                      icon: PhosphorIconsDuotone.shieldCheck,
                      color: Colors.teal,
                      onTap: () async {
                        final uri = Uri.parse(
                          "https://google.com",
                        ); // Placeholder
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      delay: 600.ms,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- Footer ---
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsFill.heart,
                      color: Colors.redAccent,
                      size: 16,
                    ).animate().scale(
                      duration: 1.seconds,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Made with love using Flutter",
                      style: GoogleFonts.manrope(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Duration delay;
  final bool isDark;

  const _PremiumMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF252A34) : Colors.white,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsBold.caretRight,
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.1);
  }
}
