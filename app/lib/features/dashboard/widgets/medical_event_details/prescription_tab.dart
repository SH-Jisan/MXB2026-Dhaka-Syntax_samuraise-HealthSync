import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/medical_event_model.dart';
import 'package:intl/intl.dart';

class PrescriptionTab extends StatelessWidget {
  final MedicalEvent event;
  final bool isDark;

  const PrescriptionTab({super.key, required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HealthSync",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        "Smart Healthcare Solution",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Dr. System / Self",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(event.eventDate),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 48, thickness: 1),
            // RX Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Rx",
                style: GoogleFonts.notoSerif(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Medicines List
            if (event.medicines != null && event.medicines!.isNotEmpty)
              ...event.medicines!
                  .map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6, right: 12),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.black54,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['name'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (m['dosage'] != null ||
                                    m['duration'] != null)
                                  Text(
                                    "${m['dosage']} - ${m['duration']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()
            else
              Text(
                event.summary ?? 'No data.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 60),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Generated by HealthSync",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
                Text(
                  "Doctor's Signature",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
