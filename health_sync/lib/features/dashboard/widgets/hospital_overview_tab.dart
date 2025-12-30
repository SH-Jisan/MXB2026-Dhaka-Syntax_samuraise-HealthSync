import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../upload/widgets/upload_bottom_sheet.dart';
import '../../timeline/pages/medical_timeline_view.dart';

class HospitalOverviewTab extends StatefulWidget {
  const HospitalOverviewTab({super.key});

  @override
  State<HospitalOverviewTab> createState() => _HospitalOverviewTabState();
}

class _HospitalOverviewTabState extends State<HospitalOverviewTab> {
  final _patientEmailController = TextEditingController();
  final _doctorEmailController = TextEditingController();

  // 🏥 1. পেশেন্ট সার্চ এবং অ্যাকশন
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
        Navigator.pop(context); // আগের ডায়ালগ বন্ধ
        _showPatientOptions(data); // অপশন মেনু ওপেন
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

  // 📅 2. অ্যাপয়েন্টমেন্ট বুকিং ফাংশন (NEW FEATURE)
  Future<void> _bookAppointment(Map<String, dynamic> patient) async {
    final hospitalId = Supabase.instance.client.auth.currentUser!.id;

    // হসপিটালের ডাক্তারদের লিস্ট আনা
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
            title: const Text("Book Appointment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Patient: ${patient['full_name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Doctor Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Doctor",
                    border: OutlineInputBorder(),
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

                // Date Picker
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? "Select Date"
                        : DateFormat.yMMMd().format(selectedDate!),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) setStateDialog(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 8),

                // Time Picker
                ListTile(
                  title: Text(
                    selectedTime == null
                        ? "Select Time"
                        : selectedTime!.format(context),
                  ),
                  leading: const Icon(Icons.access_time),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
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

                  // ফাইনাল ডেটটাইম তৈরি করা
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
                      Navigator.pop(context); // মেইন শিট বন্ধ
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

  // 🩺 3. ডাক্তার অ্যাসাইন করা (আগের মতোই)
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

  // UI Helpers
  void _showPatientOptions(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    patient['full_name'][0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                      ),
                    ),
                    Text(
                      patient['phone'] ?? 'No Phone',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            // 🔥 Book Appointment Option
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.teal),
              title: const Text("Book Appointment"),
              subtitle: const Text("Assign a doctor & schedule visit"),
              onTap: () => _bookAppointment(patient),
            ),

            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.blue),
              title: const Text("Upload Report"),
              subtitle: const Text("Add lab reports or prescriptions"),
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
              leading: const Icon(Icons.history, color: Colors.purple),
              title: const Text("View Medical History"),
              subtitle: const Text("See previous records"),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  // Cards (Same as before)
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
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
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Doctors",
                  "View List",
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Total Appointments",
                  "Checking...",
                  Icons.calendar_today,
                  Colors.orange,
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
            ),
          ),
          const SizedBox(height: 16),

          // Manage Patient (Book Appointment Inside)
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
          ),
          const SizedBox(height: 16),

          // Add Doctor
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
          ),
        ],
      ),
    );
  }
}
