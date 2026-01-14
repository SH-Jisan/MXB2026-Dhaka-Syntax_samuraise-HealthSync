/// File: lib/features/auth/widgets/shared_auth_layout.dart
/// Purpose: Reusable layout for authentication screens (Login/Signup) with brand header and form container.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/language_selector_widget.dart';

class SharedAuthLayout extends StatelessWidget {
  final Widget formContent;
  final String? title;
  final String? subtitle;
  final bool showBackButton;

  const SharedAuthLayout({
    super.key,
    required this.formContent,
    this.title,
    this.subtitle,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.primary,
      body: Stack(
        children: [
          // Background Gradient & Effects
          Positioned.fill(
            child:
                Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  AppColors.darkBackground,
                                  AppColors.darkSurface,
                                ]
                              : [AppColors.secondary, AppColors.primary],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      duration: 4.seconds,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
          ),

          // Header Content (Logo & Brand)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35,
            child: SafeArea(
              child: Stack(
                children: [
                  // Navigation Bar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showBackButton && context.canPop())
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              PhosphorIconsBold.arrowLeft,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        const LanguageSelectorWidget(isDropdown: true),
                      ],
                    ),
                  ),

                  // Center Brand Logo
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/logo.png',
                                height: 60,
                                width: 60,
                                fit: BoxFit.contain,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 2.seconds,
                            ),

                        const SizedBox(height: 16),

                        Text(
                          "HealthSync",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn().moveY(begin: 10, end: 0),

                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Form Sheet
          Positioned(
            top: size.height * 0.32,
            left: 0,
            right: 0,
            bottom: 0,
            child:
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        children: [
                          if (title != null) ...[
                            Text(
                              title!,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          formContent,
                        ],
                      ),
                    ),
                  ),
                ).animate().moveY(
                  begin: 100,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }
}
