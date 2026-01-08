/// File: lib/shared/widgets/ai_doctor_button.dart
/// Purpose: Floating button or icon to access the AI Health Assistant.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import '../../features/ai_doctor/pages/ai_doctor_page.dart';
import '../../core/constants/app_colors.dart';

/// Button that navigates to the AI Doctor chat page.
class AiDoctorButton extends StatelessWidget {
  const AiDoctorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.support_agent,
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
      ),
      tooltip: "AI Health Assistant",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiDoctorPage()),
        );
      },
    );
  }
}
