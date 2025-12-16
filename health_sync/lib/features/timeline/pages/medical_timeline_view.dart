import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';
import '../widgets/empty_timeline_view.dart'; // আগের স্টেপে বানানো
import '../widgets/medical_timeline_tile.dart'; // আগের স্টেপে বানানো

class MedicalTimelineView extends ConsumerWidget {
  const MedicalTimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);

    return Scaffold(
      // 🔥 শুধু এই পেজের জন্য FAB (Add Report Button)
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
      ),

      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (events) {
          if (events.isEmpty) {
            return const EmptyTimelineView();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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