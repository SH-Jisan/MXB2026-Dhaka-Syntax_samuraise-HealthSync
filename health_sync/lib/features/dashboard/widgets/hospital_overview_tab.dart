/// File: lib/features/dashboard/widgets/hospital_overview_tab.dart
/// Purpose: Overview tab for Hospital dashboard (Stats, Quick Actions).
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../upload/widgets/upload_bottom_sheet.dart';
import '../../timeline/pages/medical_timeline_view.dart';

/// Main view for hospital staff to manage patients and appointments.
class HospitalOverviewTab extends StatefulWidget {
  const HospitalOverviewTab({super.key});

  @override
  State<HospitalOverviewTab> createState() => _HospitalOverviewTabState();
}

class _HospitalOverviewTabState extends State<HospitalOverviewTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _patientEmailController = TextEditingController();
  final _doctorEmailController = TextEditingController();

  Future<void> _searchPatient() async {
    if (_patientEmailController.text.isEmpty) return;

    try {
      final email = _patientEmailController.text.trim();
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('email', email)
          .eq('role', 'CITIZEN')
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        Navigator.pop(context);
        _showPatientOptions(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Patient not found! Please check email."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {}
  }

  Future<void> _bookAppointment(Map<String, dynamic> patient) async {
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final doctorsResponse = await Supabase.instance.client
        .from('hospital_doctors')
        .select('doctor_id, profiles:doctor_id(full_name, specialty)')
        .eq('hospital_id', hospitalId);

    final doctors = List<Map<String, dynamic>>.from(doctorsResponse);

    if (doctors.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No doctors available in your hospital. Please assign doctors first.",
            ),
          ),
        );
      }
      return;
    }

    String? selectedDoctorId;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            title: Text(
              "Book Appointment",
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Patient: ${patient['full_name']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Doctor",
                    labelStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  dropdownColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  items: doctors.map((doc) {
                    final profile = doc['profiles'];
                    return DropdownMenuItem(
                      value: doc['doctor_id'] as String,
                      child: Text(
                        "${profile['full_name']} (${profile['specialty'] ?? 'GP'})",
                      ),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedDoctorId = val),
                ),
                const SizedBox(height: 12),

                ListTile(
                  title: Text(
                    selectedDate == null
                        ? "Select Date"
                        : DateFormat.yMMMd().format(selectedDate!),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  leading: Icon(
                    Icons.calendar_today,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  tileColor: isDark
                      ? AppColors.darkBackground
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      builder: (context, child) {
                        return Theme(
                          data: isDark ? ThemeData.dark() : ThemeData.light(),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setStateDialog(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 8),

                ListTile(
                  title: Text(
                    selectedTime == null
                        ? "Select Time"
                        : selectedTime!.format(context),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  leading: Icon(
                    Icons.access_time,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  tileColor: isDark
                      ? AppColors.darkBackground
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: isDark ? ThemeData.dark() : ThemeData.light(),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) setStateDialog(() => selectedTime = time);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDoctorId == null ||
                      selectedDate == null ||
                      selectedTime == null) {
                    return;
                  }

                  final finalDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  try {
                    await Supabase.instance.client.from('appointments').insert({
                      'patient_id': patient['id'],
                      'doctor_id': selectedDoctorId,
                      'hospital_id': hospitalId,
                      'appointment_date': finalDateTime.toIso8601String(),
                      'status': 'CONFIRMED',
                    });

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Appointment Booked Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint("Error: $e");
                  }
                },
                child: const Text("Confirm Booking"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assignDoctor() async {
    if (_doctorEmailController.text.isEmpty) return;

    try {
      final email = _doctorEmailController.text.trim();
      final hospitalId = Supabase.instance.client.auth.currentUser!.id;

      final doctor = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('email', email)
          .eq('role', 'DOCTOR')
          .maybeSingle();

      if (doctor == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No Doctor found with this email.")),
          );
        }
        return;
      }

      await Supabase.instance.client.from('hospital_doctors').insert({
        'hospital_id': hospitalId,
        'doctor_id': doctor['id'],
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${doctor['full_name']} added to hospital list!"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {}
  }

  void _showPatientOptions(Map<String, dynamic> patient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark
                      ? AppColors.darkPrimary.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    patient['full_name'][0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['full_name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      patient['phone'] ?? 'No Phone',
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            ListTile(
              leading: Icon(
                Icons.calendar_month,
                color: isDark ? AppColors.darkPrimary : Colors.teal,
              ),
              title: Text(
                "Book Appointment",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                "Assign a doctor & schedule visit",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              onTap: () => _bookAppointment(patient),
            ),

            ListTile(
              leading: Icon(
                Icons.upload_file,
                color: isDark ? AppColors.darkPrimary : Colors.blue,
              ),
              title: Text(
                "Upload Report",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                "Add lab reports or prescriptions",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => UploadBottomSheet(
                    patientId: patient['id'],
                    patientName: patient['full_name'],
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.history,
                color: isDark ? AppColors.darkPrimary : Colors.purple,
              ),
              title: Text(
                "View Medical History",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                "See previous records",
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: Text("${patient['full_name']}'s History"),
                      ),
                      body: MedicalTimelineView(
                        patientId: patient['id'],
                        isEmbedded: false,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog({
    required String title,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
              foregroundColor: isDark ? AppColors.textPrimary : Colors.white,
            ),
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? AppColors.darkPrimary : color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDark ? AppColors.darkPrimary : color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Doctors",
                  "View List",
                  Icons.people,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Total Appointments",
                  "Checking...",
                  Icons.calendar_today,
                  Colors.orange,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            title: "Manage Patient / Appointment",
            subtitle: "Search patient, Book Appointment, Upload Reports",
            icon: Icons.calendar_month_outlined,
            color: Colors.teal,
            onTap: () {
              _patientEmailController.clear();
              _showInputDialog(
                title: "Find Patient",
                hint: "Enter patient email",
                controller: _patientEmailController,
                onConfirm: _searchPatient,
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            title: "Assign New Doctor",
            subtitle: "Add a doctor to this hospital",
            icon: Icons.person_add,
            color: Colors.purple,
            onTap: () {
              _doctorEmailController.clear();
              _showInputDialog(
                title: "Add Doctor",
                hint: "Enter doctor email",
                controller: _doctorEmailController,
                onConfirm: _assignDoctor,
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
