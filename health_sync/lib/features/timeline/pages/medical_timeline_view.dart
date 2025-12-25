import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';
import '../widgets/empty_timeline_view.dart';
import '../widgets/medical_timeline_tile.dart';
import '../../../core/constants/app_colors.dart';

class MedicalTimelineView extends ConsumerWidget {
  const MedicalTimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 🔥 ফিক্স: থিমের ব্যাকগ্রাউন্ড কালার ব্যবহার করা হলো
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Failed to load timeline.\n$err", 
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
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
      ),
    );
  }
}