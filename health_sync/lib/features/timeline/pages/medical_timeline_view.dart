import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';
import '../widgets/empty_timeline_view.dart';
import '../widgets/medical_timeline_tile.dart';
import '../../../core/constants/app_colors.dart';

class MedicalTimelineView extends ConsumerWidget {
  final String? patientId;
  final bool isEmbedded; // 🔥 নতুন ফ্ল্যাগ: এটি অন্য পেজের ভেতরে আছে কিনা

  const MedicalTimelineView({
    super.key,
    this.patientId,
    this.isEmbedded = false
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 আপডেট: প্রোভাইডারে patientId পাস করা হচ্ছে
    final timelineAsync = ref.watch(timelineProvider(patientId));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 মেইন কন্টেন্ট উইজেট (লিস্ট/লোডিং/এরর)
    final content = timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyTimelineView();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return MedicalTimelineTile(
              event: events[index],
              isLast: index == events.length - 1,
            );
          },
        );
      },
    );

    // ১. যদি এমবেডেড হয় (যেমন ডাক্তারের পেজে), তবে শুধু কন্টেন্ট রিটার্ন করো (Scaffold ছাড়া)
    if (isEmbedded) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: content,
      );
    }

    // ২. যদি আলাদা পেজ হয় (যেমন সিটিজেন ড্যাশবোর্ডে), তবে Scaffold সহ রিটার্ন করো
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
        icon: const Icon(Icons.add_a_photo_outlined),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: content,
    );
  }
}