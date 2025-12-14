import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event.dart';

class TimelineCard extends StatelessWidget {
  final MedicalEvent event;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.event,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(color: Color(0xFFE2E8F0), thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: _getColorBySeverity(event.severity),
        iconStyle: IconStyle(iconData: _getIconByType(event.eventType), color: Colors.white),
      ),
      endChild: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              DateFormat('dd MMM yyyy').format(event.eventDate),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            // Summary (যদি থাকে)
            if (event.summary != null) ...[
              const SizedBox(height: 8),
              Text(
                event.summary!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }

  // কালার লজিক
  Color _getColorBySeverity(String severity) {
    switch (severity) {
      case 'HIGH': return AppColors.error;
      case 'MEDIUM': return AppColors.warning;
      case 'LOW': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  // আইকন লজিক
  IconData _getIconByType(String type) {
    switch (type) {
      case 'SURGERY': return Icons.local_hospital;
      case 'REPORT': return Icons.article;
      case 'VACCINE': return Icons.vaccines;
      default: return Icons.medical_services;
    }
  }
}