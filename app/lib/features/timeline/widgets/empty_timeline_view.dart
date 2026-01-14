/// File: lib/features/timeline/widgets/empty_timeline_view.dart
/// Purpose: Placeholder widget displayed when no medical history exists.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Widget to show when the timeline list is empty.
class EmptyTimelineView extends StatelessWidget {
  const EmptyTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Icon(
              Icons.history_edu,
              size: 64,
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No medical history yet!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Upload your first report to start tracking.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
