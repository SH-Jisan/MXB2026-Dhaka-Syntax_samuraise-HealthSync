import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../l10n/app_localizations.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded strings for now to match the React code,
    // ideally these should come from AppLocalizations
    const tagline = "Advanced Healthcare Assistant";
    const titlePart1 = "Your Personal";
    const highlight = " AI Doctor";
    const titlePart2 = " & \nHealth Manager";
    const subtitle = "One Life, One Record, Total Care";
    const description =
        "Experience the future of healthcare with our AI-powered assistant. "
        "Get instant symptom triage, manage your medical history, and find blood donors in real-time.";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tagline.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  children: [
                    TextSpan(text: "$titlePart1 "),
                    TextSpan(
                      text: highlight,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(text: titlePart2),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 40),
          Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/login'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(PhosphorIconsBold.caretRight),
                      label: const Text("Get Started"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {}, // Navigate to About or generic info
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(PhosphorIconsRegular.playCircle),
                      label: const Text("Learn More"),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
