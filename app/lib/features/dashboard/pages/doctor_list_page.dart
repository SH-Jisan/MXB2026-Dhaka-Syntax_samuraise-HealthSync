import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/doctor_provider.dart';

class DoctorListPage extends ConsumerStatefulWidget {
  final String specialty;
  final List<dynamic> internetDoctors;

  const DoctorListPage({
    super.key,
    required this.specialty,
    this.internetDoctors = const [],
  });

  @override
  ConsumerState<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends ConsumerState<DoctorListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appDoctorsAsync = ref.watch(
      doctorsBySpecialtyProvider(widget.specialty),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.specialty}s"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          tabs: const [
            Tab(text: "App Doctors"),
            Tab(text: "From Google"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          appDoctorsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (doctors) {
              if (doctors.isEmpty) {
                return _buildEmptyState(
                  "No registered doctors found in our app.",
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary.withValues(alpha: 0.2)
                            : Colors.teal.shade100,
                        child: Icon(
                          Icons.person,
                          color: isDark ? AppColors.darkPrimary : Colors.teal,
                        ),
                      ),
                      title: Text(
                        doc['full_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(doc['specialty'] ?? widget.specialty),
                      trailing: ElevatedButton(
                        onPressed: () => _showBookingDialog(
                          context,
                          doc['id'],
                          doc['full_name'],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                        ),
                        child: const Text("Book"),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          widget.internetDoctors.isEmpty
              ? _buildEmptyState("No results found on Google.")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.internetDoctors.length,
                  itemBuilder: (context, index) {
                    final doc = widget.internetDoctors[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue.shade900.withValues(alpha: 0.3)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.public,
                            color: isDark ? Colors.blue.shade200 : Colors.blue,
                          ),
                        ),
                        title: Text(
                          doc['title'] ?? 'Unknown Doctor',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              doc['address'] ?? 'No address available',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (doc['rating'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      " ${doc['rating']} (${doc['userRatingsTotal'] ?? 0})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.map, color: Colors.green),
                        onTap: () async {
                          final query = Uri.encodeComponent(
                            "${doc['title']} ${doc['address'] ?? ""}",
                          );
                          final url = Uri.parse(
                            "https://www.google.com/maps/search/?api=1&query=$query",
                          );
                          if (await canLaunchUrl(url)) launchUrl(url);
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _showBookingDialog(
    BuildContext context,
    String doctorId,
    String doctorName,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to book appointments.")),
      );
      return;
    }

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              title: Text("Book Appointment with $doctorName"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Date"),
                      subtitle: Text(
                        DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: "Reason for visit",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final combinedDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    try {
                      Navigator.pop(context); // Close dialog first

                      // Ideally show loading indicator here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processing request...")),
                      );

                      await Supabase.instance.client
                          .from('appointments')
                          .insert({
                            'doctor_id': doctorId,
                            'patient_id': user.id,
                            'appointment_date': combinedDateTime
                                .toIso8601String(),
                            'reason': reasonController.text.trim(),
                            'status': 'PENDING',
                          });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Appointment requested successfully!",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to book: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
