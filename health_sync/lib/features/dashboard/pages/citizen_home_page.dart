import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../../shared/models/medical_event_model.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';
import 'ai_doctor_page.dart';
import 'medical_event_details_page.dart';

class CitizenHomePage extends ConsumerWidget {
  const CitizenHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Medical History"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiDoctorPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () =>
                Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const UploadBottomSheet(),
          );
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add_a_photo),
        elevation: 4,
      ),

      body: timelineAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error: $err")),
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildTimelineTile(
                context,
                event,
                isLast: index == events.length - 1,
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.history_edu,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No medical history yet!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Upload your first report to start tracking.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TIMELINE TILE ----------------

  Widget _buildTimelineTile(
      BuildContext context,
      MedicalEvent event, {
        required bool isLast,
      }) {
    final isPrescription =
        event.eventType == 'PRESCRIPTION';

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
            color: isPrescription
                ? Colors.purple.shade50
                : Colors.teal.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color:
              isPrescription ? Colors.purple : Colors.teal,
              width: 2,
            ),
          ),
          child: Icon(
            isPrescription
                ? Icons.medication_outlined
                : Icons.assignment_outlined,
            color:
            isPrescription ? Colors.purple : Colors.teal,
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
                  builder: (_) =>
                      MedicalEventDetailsPage(event: event),
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
                  // Date + Severity
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(event.eventDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                          AppColors.textSecondary,
                        ),
                      ),
                      _buildSeverityBadge(event.severity),
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

  // ---------------- SEVERITY BADGE ----------------

  Widget _buildSeverityBadge(String severity) {
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
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
