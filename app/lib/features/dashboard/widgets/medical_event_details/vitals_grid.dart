import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class VitalsGrid extends StatelessWidget {
  final Map<String, dynamic> vitals;
  final bool isDark;

  const VitalsGrid({super.key, required this.vitals, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        if (vitals['bp'] != null)
          _VitalCard(
            label: "Blood Pressure",
            value: vitals['bp'],
            unit: "mmHg",
            icon: PhosphorIconsFill.drop,
            color: Colors.red,
            isDark: isDark,
          ),
        if (vitals['hr'] != null)
          _VitalCard(
            label: "Heart Rate",
            value: vitals['hr'],
            unit: "bpm",
            icon: PhosphorIconsFill.heartbeat,
            color: Colors.pink,
            isDark: isDark,
          ),
        if (vitals['temp'] != null)
          _VitalCard(
            label: "Temperature",
            value: vitals['temp'],
            unit: "°F",
            icon: PhosphorIconsFill.thermometer,
            color: Colors.orange,
            isDark: isDark,
          ),
        if (vitals['weight'] != null)
          _VitalCard(
            label: "Weight",
            value: vitals['weight'],
            unit: "kg",
            icon: PhosphorIconsFill.scales,
            color: Colors.green,
            isDark: isDark,
          ),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _VitalCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$value",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: " $unit",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
