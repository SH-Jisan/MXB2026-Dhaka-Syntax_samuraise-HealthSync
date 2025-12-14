import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../../shared/models/medical_event_model.dart';

class CitizenHomePage extends ConsumerWidget {
  const CitizenHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medical History"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      // 🔥 আপলোড বাটন (পরের ধাপে কাজ করবে)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open Upload BottomSheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload Feature Coming Next!")),
          );
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildTimelineTile(event, isLast: index == events.length - 1);
            },
          );
        },
      ),
    );
  }

  // 🟡 এম্পটি স্টেট ডিজাইন
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No medical history yet!",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text("Upload your first report to start tracking."),
        ],
      ),
    );
  }

  // 🟢 টাইমলাইন টাইল ডিজাইন
  Widget _buildTimelineTile(MedicalEvent event, {required bool isLast}) {
    final isPrescription = event.eventType == 'PRESCRIPTION';

    return TimelineTile(
      isFirst: false,
      isLast: isLast,
      beforeLineStyle: const LineStyle(color: AppColors.primary, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: Container(
          decoration: BoxDecoration(
            color: isPrescription ? Colors.purple.shade100 : Colors.teal.shade100,
            shape: BoxShape.circle,
            border: Border.all(
                color: isPrescription ? Colors.purple : Colors.teal,
                width: 2
            ),
          ),
          child: Icon(
            isPrescription ? Icons.medication : Icons.assignment,
            color: isPrescription ? Colors.purple : Colors.teal,
            size: 20,
          ),
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(event.eventDate),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                _buildSeverityBadge(event.severity),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              event.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // Summary (if available)
            if (event.summary != null) ...[
              const SizedBox(height: 8),
              Text(
                event.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // 🔴 Severity Badge (High/Medium/Low)
  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity) {
      case 'HIGH': color = Colors.red; break;
      case 'MEDIUM': color = Colors.orange; break;
      default: color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}