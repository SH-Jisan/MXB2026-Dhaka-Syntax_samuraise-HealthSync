/// File: lib/features/timeline/pages/medical_timeline_view.dart
/// Purpose: Displays the patient's medical timeline (Events, Reports).
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../upload/widgets/upload_bottom_sheet.dart';
import '../widgets/empty_timeline_view.dart';
import '../widgets/medical_timeline_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Timeline view allowing filtering by event type and adding new reports.
class MedicalTimelineView extends ConsumerWidget {
  final String? patientId;
  final bool isEmbedded;

  const MedicalTimelineView({
    super.key,
    this.patientId,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider(patientId));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          "${AppLocalizations.of(context)?.error ?? 'Error'}: $err",
          style: const TextStyle(color: Colors.red),
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
    );

    if (isEmbedded) {
      return Container(color: theme.scaffoldBackgroundColor, child: content);
    }

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
        label: Text(AppLocalizations.of(context)?.addReport ?? "Add Report"),
        icon: const Icon(Icons.add_a_photo_outlined),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: content,
    );
  }
}
