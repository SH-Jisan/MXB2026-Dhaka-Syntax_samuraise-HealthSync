import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';
import '../../dashboard/pages/medical_event_details_page.dart';

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
    final isPrescription = event.eventType == 'PRESCRIPTION';

    return TimelineTile(
      isFirst: false,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: AppColors.primary.withOpacity(0.3),
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 36,
        height: 36,
        indicator: Container(
          decoration: BoxDecoration(
            color: isPrescription ? Colors.purple.shade50 : Colors.teal.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color: isPrescription ? Colors.purple : Colors.teal,
              width: 2,
            ),
          ),
          child: Icon(
            isPrescription ? Icons.medication_outlined : Icons.assignment_outlined,
            color: isPrescription ? Colors.purple : Colors.teal,
            size: 18,
          ),
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalEventDetailsPage(event: event),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + Severity Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(event.eventDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      _SeverityBadge(severity: event.severity),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Summary
                  if (event.summary != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "View Details →",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Private helper widget just for the badge
class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;

    switch (severity) {
      case 'HIGH':
        color = Colors.red.shade700;
        bg = Colors.red.shade50;
        break;
      case 'MEDIUM':
        color = Colors.orange.shade800;
        bg = Colors.orange.shade50;
        break;
      default:
        color = Colors.green.shade700;
        bg = Colors.green.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}