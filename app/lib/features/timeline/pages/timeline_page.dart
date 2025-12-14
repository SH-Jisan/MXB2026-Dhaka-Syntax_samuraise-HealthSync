import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event.dart';
import '../widgets/timeline_card.dart';
import '../../upload/pages/upload_bottom_sheet.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  // ডাটা লোড করার স্ট্রিম
  final _eventsStream = Supabase.instance.client
      .from('medical_events')
      .stream(primaryKey: ['id'])
      .order('event_date', ascending: false); // নতুন ঘটনা আগে দেখাবে

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No medical history found!"),
                  const Text("Upload your first report to start.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final events = snapshot.data!.map((json) => MedicalEvent.fromJson(json)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return TimelineCard(
                event: events[index],
                isFirst: index == 0,
                isLast: index == events.length - 1,
              );
            },
          );
        },
      ),
      // নতুন ইভেন্ট অ্যাড করার জন্য বাটন (পরে কাজ করব)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const UploadBottomSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}