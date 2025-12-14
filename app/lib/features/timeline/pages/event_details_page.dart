import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event.dart';

class EventDetailsPage extends StatelessWidget {
  final MedicalEvent event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // ইভেন্টের ধরন অনুযায়ী আইকন হেল্পার
    IconData getIcon() {
      switch (event.eventType) {
        case 'SURGERY': return Icons.local_hospital;
        case 'REPORT': return Icons.article;
        case 'PRESCRIPTION': return Icons.medication;
        default: return Icons.medical_services;
      }
    }

    return DefaultTabController(
      length: 2, // ২টা ট্যাব: Analysis এবং Text
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(event.eventType.toUpperCase()),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.analytics_outlined), text: "AI Analysis"),
              Tab(icon: Icon(Icons.text_snippet_outlined), text: "Original Text"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // =========================================
            // TAB 1: AI ANALYSIS (Header + Summary + Findings + Image)
            // =========================================
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Section (Icon + Title + Date)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(getIcon(), color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMMM yyyy, hh:mm a').format(event.eventDate),
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. AI Summary Card
                  _buildSectionTitle("AI Summary"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text("Analysis", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.summary ?? "No summary available.",
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Key Findings (New Feature)
                  if (event.keyFindings.isNotEmpty) ...[
                    _buildSectionTitle("Key Findings"),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: event.keyFindings.map((finding) => ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          title: Text(finding),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. Report Image (Zoomable)
                  _buildSectionTitle("Attached Report"),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white,
                      height: 400,
                      width: double.infinity,
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.network(
                          _getImageUrl(),
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================================
            // TAB 2: ORIGINAL EXTRACTED TEXT (OCR)
            // =========================================
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      event.extractedText ?? "No text could be extracted from this image.",
                      style: const TextStyle(
                        fontFamily: 'Courier', // মনোস্পেস ফন্ট যাতে ডাটা দেখতে সুবিধা হয়
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Long press text to copy",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Helper to safely get image URL
  String _getImageUrl() {
    if (event.attachmentUrls.isNotEmpty) {
      return event.attachmentUrls.first;
    }
    return "https://via.placeholder.com/300";
  }
}