import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event.dart';

class EventDetailsPage extends StatelessWidget {
  final MedicalEvent event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // ইভেন্টের ধরন অনুযায়ী আইকন
    IconData getIcon() {
      switch (event.eventType) {
        case 'SURGERY': return Icons.local_hospital;
        case 'REPORT': return Icons.article;
        case 'PRESCRIPTION': return Icons.medication;
        default: return Icons.medical_services;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(event.eventType.toUpperCase()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
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
                      Text("AI Analysis", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
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

            // 3. Report Image (Zoomable)
            const Text("Attached Report", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),

            // আমরা ধরে নিচ্ছি attachment_urls এর লিস্টে প্রথমটা ইমেজ
            // TODO: In production, check if list is not empty
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white,
                height: 400, // ফিক্সড হাইট যাতে দেখতে সুন্দর লাগে
                width: double.infinity,
                child: InteractiveViewer(
                  // Zoom Feature
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.network(
                    // ইমেজ না থাকলে প্লেসহোল্ডার
                    // Note: হ্যাকাথনের জন্য আমরা ধরে নিচ্ছি ১টা ইমেজ আছেই
                    // আপনার মডেল ক্লাস আপডেট না করে থাকলে এখানে event.attachmentUrls ব্যবহার করতে সমস্যা হতে পারে
                    // তাই আমরা নিচে মডেল ক্লাসের একটা ছোট আপডেট দিচ্ছি
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
    );
  }
  String _getImageUrl() {
    if (event.attachmentUrls.isNotEmpty) {
      return event.attachmentUrls.first;
    }
    return "https://via.placeholder.com/300";
  }
}