import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';

class MedicalEventDetailsPage extends StatelessWidget {
  final MedicalEvent event;

  const MedicalEventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Report Image Preview (Zoomable)
            if (event.attachmentUrls.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // TODO: Full screen image view logic can be added here
                },
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(event.attachmentUrls.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 2. Title & Meta Info
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                _buildSeverityBadge(event.severity),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${DateFormat('dd MMM yyyy').format(event.eventDate)}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const Divider(height: 30),

            // 3. AI Summary Section 🧠
            if (event.summary != null) ...[
              const Text(
                "AI Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Text(
                  event.summary!,
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Key Findings (যদি থাকে) - এটা আমাদের মডেলে অ্যাড করতে হবে যদি না থাকে
            // আপাতত আমরা 'summary' এর উপরই ফোকাস করছি।
            // যদি আপনার মডেলে 'keyFindings' থাকে, তবে এভাবে দেখাবেন:
            /*
            if (event.keyFindings != null && event.keyFindings!.isNotEmpty) ...[
              const Text("Key Findings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...event.keyFindings!.map((finding) => ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                title: Text(finding),
                dense: true,
                contentPadding: EdgeInsets.zero,
              )),
            ],
            */
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity) {
      case 'HIGH': color = Colors.red; break;
      case 'MEDIUM': color = Colors.orange; break;
      default: color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        severity,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}