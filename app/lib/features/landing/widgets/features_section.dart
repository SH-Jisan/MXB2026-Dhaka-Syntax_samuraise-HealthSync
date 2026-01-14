import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        icon: PhosphorIconsDuotone.robot,
        title: "AI Symptom Triage",
        desc:
            "Instant assessment of your symptoms using advanced AI algorithms.",
      ),
      (
        icon: PhosphorIconsDuotone.fileText,
        title: "Smart Reports",
        desc:
            "Upload medical reports and get simplified summaries and insights.",
      ),
      (
        icon: PhosphorIconsDuotone.heart,
        title: "Health Monitoring",
        desc: "Track your vitals and get personalized health recommendations.",
      ),
      (
        icon: PhosphorIconsDuotone.drop,
        title: "Blood Network",
        desc: "Connect with donors instantly in case of emergencies.",
      ),
      (
        icon: PhosphorIconsDuotone.squaresFour,
        title: "Integrated Timeline",
        desc: "View your entire medical history in one organized timeline.",
      ),
      (
        icon: PhosphorIconsDuotone.shieldCheck,
        title: "Secure & Private",
        desc: "Your health data is encrypted and secure with us.",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Choose Health Sync?",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            "Experience the next generation of healthcare technology.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature.icon,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature.title,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feature.desc,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (200 + (index * 100)).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          ),
        ],
      ),
    );
  }
}
