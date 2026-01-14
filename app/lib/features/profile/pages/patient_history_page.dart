/// File: lib/features/profile/pages/patient_history_page.dart
/// Purpose: Shows patient's medical history (Appointments, Prescriptions, Diagnostics).
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

/// Tabbed view of patient's medical history.
class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.myCareHistory ?? "My Care History",
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
          isScrollable: true,
          tabs: [
            Tab(
              text:
                  AppLocalizations.of(context)?.appointments ?? "Appointments",
              icon: const Icon(Icons.calendar_month),
            ),
            Tab(
              text: AppLocalizations.of(context)?.diagnostic ?? "Diagnostic",
              icon: const Icon(Icons.analytics_outlined),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAppointmentsTab(theme), _buildDiagnosticsTab(theme)],
      ),
    );
  }

  Widget _buildAppointmentsTab(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return FutureBuilder(
      future: Supabase.instance.client
          .from('appointments')
          .select('''
            *,
            doctor:doctor_id(full_name, specialty),
            hospital:hospital_id(full_name, address)
          ''')
          .eq('patient_id', userId)
          .order('appointment_date', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return _emptyState(
            AppLocalizations.of(context)?.noAppointmentsFound ??
                "No appointments found.",
            theme,
          );
        }

        final appointments = snapshot.data as List;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index];
            final doctor =
                apt['doctor'] ??
                {
                  'full_name':
                      AppLocalizations.of(context)?.unknownDoctor ??
                      'Unknown Doctor',
                };
            final hospital =
                apt['hospital'] ??
                {
                  'full_name':
                      AppLocalizations.of(context)?.unknownHospital ??
                      'Unknown Hospital',
                };
            final date = DateTime.parse(apt['appointment_date']);

            final formattedTime = DateFormat('hh:mm a').format(date);
            final status = apt['status'] ?? 'PENDING';

            Color statusColor = status == 'CONFIRMED'
                ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                : (isDark ? Colors.orange.shade300 : Colors.orange.shade800);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMM').format(date).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                DateFormat('dd').format(date),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['full_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                doctor['specialty'] ??
                                    AppLocalizations.of(context)?.specialist ??
                                    'Specialist',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: theme.hintColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hospital['full_name'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosticsTab(ThemeData theme) {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('patient_payments')
          .select('*, provider:provider_id(full_name)')
          .eq('patient_id', userId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data as List;
        if (list.isEmpty) {
          return _emptyState(
            AppLocalizations.of(context)?.noDiagnosticRecords ??
                "No diagnostic records.",
            theme,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final center = item['provider'] ?? {'full_name': 'Lab'};
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.8,
                  ),
                  child: const Icon(Icons.science, color: Colors.white),
                ),
                title: Text(
                  center['full_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Status: ${item['report_status']}"),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(String text, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 60,
            color: theme.hintColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }
}
