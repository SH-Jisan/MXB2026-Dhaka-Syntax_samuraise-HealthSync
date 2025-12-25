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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPrescription = event.eventType == 'PRESCRIPTION';
    final primaryColor = isPrescription ? Colors.purple : AppColors.primary;
    // ডার্ক মোডের জন্য হালকা শেড ব্যবহার না করে একটু ডার্ক শেড ব্যবহার করা হলো
    final lightColor = isDark 
        ? (isPrescription ? Colors.purple.withOpacity(0.2) : AppColors.primary.withOpacity(0.2))
        : (isPrescription ? Colors.purple.shade50 : Colors.teal.shade50);

    return TimelineTile(
      isFirst: false,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: primaryColor.withOpacity(0.3),
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
              color: primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2)
              )
            ]
          ),
          child: Icon(
            isPrescription ? Icons.medication_outlined : Icons.assignment_outlined,
            color: primaryColor,
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
                // 🔥 ফিক্স: ডার্ক মোডে কার্ড কালার থিম থেকে আসবে
                color: theme.cardTheme.color, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + Severity Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: isDark ? Colors.grey.shade400 : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy').format(event.eventDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _SeverityBadge(severity: event.severity),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),

                  // Summary
                  if (event.summary != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  const SizedBox(height: 8),

                  // View Details Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "View Details",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor),
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

// Private helper widget just for the badge
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
        bg = isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50;
        break;
      case 'MEDIUM':
        color = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        bg = isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50;
        break;
      default:
        color = isDark ? Colors.green.shade300 : Colors.green.shade700;
        bg = isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(isDark ? 0.0 : 0.5)),
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