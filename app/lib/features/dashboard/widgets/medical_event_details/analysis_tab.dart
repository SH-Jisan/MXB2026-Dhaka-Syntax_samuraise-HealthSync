import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/medical_event_model.dart';
import 'disease_insight_card.dart';

class AnalysisTab extends StatelessWidget {
  final MedicalEvent event;
  final bool isDark;
  final bool isBangla;

  const AnalysisTab({
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
    final detailedAnalysis =
        aiData?[isBangla ? 'detailed_analysis_bn' : 'detailed_analysis_en'];
    final diseaseInsight =
        aiData?[isBangla ? 'disease_insight_bn' : 'disease_insight_en'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Refresher
          if (simpleExplanation != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.checkCircle,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBangla ? 'এক নজরে' : 'Overview',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    simpleExplanation,
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // Condition Insight
          if (diseaseInsight != null) ...[
            DiseaseInsightCard(
              insight: diseaseInsight,
              isDark: isDark,
              isBangla: isBangla,
            ),
            const SizedBox(height: 24),
          ],

          // Detailed Analysis
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsFill.fileText,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isBangla
                      ? 'বিস্তারিত রিপোর্ট বিশ্লেষণ'
                      : 'Detailed Report Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.transparent,
              ),
            ),
            child: Text(
              detailedAnalysis ?? event.summary ?? 'No analysis available.',
              style: GoogleFonts.poppins(
                height: 1.8,
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
