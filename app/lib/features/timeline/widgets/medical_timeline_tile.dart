/// File: lib/features/timeline/widgets/medical_timeline_tile.dart
/// Purpose: Widget to display a single medical event in the timeline.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';
import '../../dashboard/pages/medical_event_details_page.dart';

/// A tile in the timeline representing a specific medical event.
class MedicalTimelineTile extends StatelessWidget {
  final MedicalEvent event;
  final bool isLast;

  const MedicalTimelineTile({
    super.key,
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPrescription = event.eventType == 'PRESCRIPTION';
    final primaryColor = isPrescription ? Colors.purple : AppColors.primary;
    final darkPrimaryColor = isPrescription
        ? Colors.purple.shade300
        : AppColors.darkPrimary;

    final lightColor = isDark
        ? (isPrescription
              ? Colors.purple.withValues(alpha: 0.2)
              : AppColors.darkPrimary.withValues(alpha: 0.2))
        : (isPrescription
              ? Colors.purple.shade50
              : AppColors.primary.withValues(alpha: 0.1));

    return TimelineTile(
      isFirst: false,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: (isDark ? darkPrimaryColor : primaryColor).withValues(
          alpha: 0.3,
        ),
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: Container(
          decoration: BoxDecoration(
            color: lightColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? darkPrimaryColor : primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? darkPrimaryColor : primaryColor).withValues(
                  alpha: 0.2,
                ),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPrescription
                ? Icons.medication_outlined
                : Icons.assignment_outlined,
            color: isDark ? darkPrimaryColor : primaryColor,
            size: 20,
          ),
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalEventDetailsPage(event: event),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy').format(event.eventDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _SeverityBadge(severity: event.severity),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),

                  if (event.summary != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],

                  if (event.keyFindings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: event.keyFindings
                          .map(
                            (test) => Chip(
                              label: Text(
                                test,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              backgroundColor: isDark
                                  ? AppColors.darkBackground
                                  : Colors.grey.shade100,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "View Details",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? darkPrimaryColor : primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: isDark ? darkPrimaryColor : primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color color;
    Color bg;

    switch (severity) {
      case 'HIGH':
        color = isDark ? Colors.red.shade300 : Colors.red.shade700;
        bg = isDark ? Colors.red.withValues(alpha: 0.15) : Colors.red.shade50;
        break;
      case 'MEDIUM':
        color = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        bg = isDark
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.orange.shade50;
        break;
      default:
        color = isDark ? Colors.green.shade300 : Colors.green.shade700;
        bg = isDark
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.green.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        severity,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
