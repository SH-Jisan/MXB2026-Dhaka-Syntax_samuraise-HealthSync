import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DiseaseInsightCard extends StatelessWidget {
  final dynamic insight;
  final bool isDark;
  final bool isBangla;

  const DiseaseInsightCard({
    super.key,
    required this.insight,
    required this.isDark,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    String name = '';
    String localName = '';
    String seriousness = '';
    List<dynamic> symptoms = [];
    List<dynamic> causes = [];

    if (insight is String) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(insight, style: TextStyle(color: Colors.indigo.shade900)),
      );
    }

    try {
      name = insight['disease_name'] ?? '';
      localName = insight['local_name'] ?? '';
      seriousness = insight['seriousness'] ?? '';
      symptoms = insight['symptoms'] ?? [];
      causes = insight['causes'] ?? [];
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1B4B).withOpacity(0.5)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.indigo.shade800 : Colors.indigo.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.indigo.shade900
                      : Colors.indigo.shade100,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBangla
                            ? 'সম্ভাব্য রোগ ও অবস্থা'
                            : 'Condition Insight',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.indigo.shade200
                              : Colors.indigo.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$name ($localName)",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (seriousness.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.indigo.shade50,
                      ),
                    ),
                    child: Text(
                      seriousness,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.indigo.shade100
                            : Colors.indigo.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (symptoms.isNotEmpty) ...[
                  _InsightRow(
                    icon: PhosphorIconsRegular.warningCircle,
                    label: "Symptoms",
                    content: symptoms.join(', '),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                ],
                if (causes.isNotEmpty) ...[
                  _InsightRow(
                    icon: PhosphorIconsRegular.info,
                    label: "Causes",
                    content: causes.join(', '),
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String content;
  final bool isDark;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.indigo.shade300 : Colors.indigo,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: isDark ? Colors.indigo.shade50 : Colors.indigo.shade900,
                fontSize: 13,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
