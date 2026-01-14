import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/medical_event_model.dart';
import 'header_info_card.dart';
import 'vitals_grid.dart';

class OverviewTab extends StatelessWidget {
  final MedicalEvent event;
  final bool isDark;
  final bool isBangla;

  const OverviewTab({
    super.key,
    required this.event,
    required this.isDark,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    final aiData = event.aiDetails;
    final simpleExplanation =
        aiData?[isBangla ? 'simple_explanation_bn' : 'simple_explanation_en'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          HeaderInfoCard(event: event, isDark: isDark),

          const SizedBox(height: 24),

          // Vitals Grid
          if (event.vitals != null && event.vitals!.isNotEmpty) ...[
            Text(
              "Vitals",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            VitalsGrid(vitals: event.vitals!, isDark: isDark),
            const SizedBox(height: 24),
          ],

          // Simple Explanation Card
          if (simpleExplanation != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.green.shade900.withOpacity(0.3),
                          Colors.green.shade900.withOpacity(0.1),
                        ]
                      : [Colors.green.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.green.shade800 : Colors.green.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsFill.robot,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBangla ? 'সহজ ব্যাখ্যা' : 'Simple Explanation',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Text(
                              isBangla
                                  ? 'বাচ্চাদের মতো সহজ করে বুঝুন'
                                  : 'Easy to understand summary',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    simpleExplanation,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark
                          ? Colors.green.shade100
                          : Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            )
          else
            // Fallback Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.fileText,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Summary",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.summary ?? 'No summary available.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.grey.shade300 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Key Findings
          if (event.keyFindings.isNotEmpty) ...[
            Text(
              "Key Findings",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.keyFindings
                  .map(
                    (tag) => Chip(
                      label: Text(
                        "# $tag",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.blue.shade50,
                      side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.blue.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
