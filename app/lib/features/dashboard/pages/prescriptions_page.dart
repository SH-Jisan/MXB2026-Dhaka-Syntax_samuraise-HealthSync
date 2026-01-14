import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';
import 'medical_event_details_page.dart';

// Simple model for combined view
class PrescriptionItem {
  final String id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String? summary;
  final String uploaderName;
  final String? paymentStatus;
  final String? reportStatus;
  final MedicalEvent? originalEvent; // For navigation

  PrescriptionItem({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    this.summary,
    required this.uploaderName,
    this.paymentStatus,
    this.reportStatus,
    this.originalEvent,
  });
}

final prescriptionsProvider = FutureProvider.autoDispose<List<PrescriptionItem>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  // 1. Fetch Doctor Orders (PRESCRIPTION, TEST_ORDER)
  final doctorEventsResponse = await Supabase.instance.client
      .from('medical_events')
      .select('*, uploader:uploader_id(full_name, specialty)')
      .eq('patient_id', user.id)
      .filter('event_type', 'in', [
        'PRESCRIPTION',
        'TEST_ORDER',
      ]) // Use .in_ or .filter based on version
      .order('event_date', ascending: false);

  // Note: Using 'in_' as we found it in other files, checking if it works here or if we need .filter like timeline

  // 2. Fetch Diagnostic Invoices
  final invoicesResponse = await Supabase.instance.client
      .from('patient_payments')
      .select('*, provider:provider_id(full_name)')
      .eq('patient_id', user.id)
      .order('created_at', ascending: false);

  List<PrescriptionItem> items = [];

  // Process Doctor Events
  for (var evt in doctorEventsResponse) {
    // Attempt to map using shared model
    MedicalEvent? eventModel;
    try {
      eventModel = MedicalEvent.fromJson(evt);
    } catch (_) {}

    items.add(
      PrescriptionItem(
        id: evt['id'],
        title: evt['title'] ?? 'Untitled',
        eventType: evt['event_type'],
        eventDate: DateTime.parse(evt['event_date']),
        summary: evt['summary'],
        uploaderName: evt['uploader']?['full_name'] ?? 'Unknown Doctor',
        originalEvent: eventModel,
      ),
    );
  }

  // Process Invoices
  for (var inv in invoicesResponse) {
    items.add(
      PrescriptionItem(
        id: inv['id'],
        title: (inv['test_names'] as List?)?.join(', ') ?? 'Diagnostic Invoice',
        eventType: 'DIAGNOSTIC_REPORT',
        eventDate: DateTime.parse(inv['created_at']),
        summary:
            "Invoice #${inv['id'].toString().substring(0, 8).toUpperCase()}",
        uploaderName: inv['provider']?['full_name'] ?? 'Diagnostic Center',
        paymentStatus: inv['status'],
        reportStatus: inv['report_status'],
      ),
    );
  }

  // Sort
  items.sort((a, b) => b.eventDate.compareTo(a.eventDate));
  return items;
});

class PrescriptionsPage extends ConsumerStatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  ConsumerState<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends ConsumerState<PrescriptionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncItems = ref.watch(prescriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescriptions & Tests"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          tabs: const [
            Tab(
              text: "Prescriptions",
              icon: Icon(PhosphorIconsRegular.prescription),
            ),
            Tab(
              text: "Tests & Reports",
              icon: Icon(PhosphorIconsRegular.flask),
            ),
          ],
        ),
      ),
      body: asyncItems.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (allItems) {
          if (allItems.isEmpty) {
            return const Center(child: Text("No records found"));
          }

          final prescriptions = allItems
              .where((i) => i.eventType == 'PRESCRIPTION')
              .toList();
          final tests = allItems
              .where((i) => i.eventType != 'PRESCRIPTION')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(prescriptions, isDark),
              _buildList(tests, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<PrescriptionItem> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.fileText,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text("No items found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (item.originalEvent != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MedicalEventDetailsPage(event: item.originalEvent!),
                  ),
                );
              } else {
                // Handle Invoice Tap? Maybe show details dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invoice Details coming soon")),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(
                            item.eventType,
                            isDark,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIcon(item.eventType),
                          color: _getBadgeColor(item.eventType, isDark),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(item.eventDate),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.paymentStatus != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.paymentStatus == 'PAID'
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.paymentStatus!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.paymentStatus == 'PAID'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.uploaderName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (item.reportStatus != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          item.reportStatus == 'COMPLETED'
                              ? Icons.check_circle
                              : Icons.hourglass_empty,
                          size: 14,
                          color: item.reportStatus == 'COMPLETED'
                              ? Colors.green
                              : Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.reportStatus!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBadgeColor(String type, bool isDark) {
    if (type == 'PRESCRIPTION') return Colors.teal;
    if (type == 'TEST_ORDER') return Colors.indigo;
    return Colors.orange;
  }

  IconData _getIcon(String type) {
    if (type == 'PRESCRIPTION') return PhosphorIconsRegular.prescription;
    if (type == 'TEST_ORDER') return PhosphorIconsRegular.flask;
    return PhosphorIconsRegular.receipt;
  }
}
