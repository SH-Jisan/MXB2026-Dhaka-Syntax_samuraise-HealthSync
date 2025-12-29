import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';
import '../../timeline/pages/medical_timeline_view.dart';

class HospitalOverviewTab extends StatefulWidget {
  const HospitalOverviewTab({super.key});

  @override
  State<HospitalOverviewTab> createState() => _HospitalOverviewTabState();
}

class _HospitalOverviewTabState extends State<HospitalOverviewTab> {
  final _patientEmailController = TextEditingController();
  final _doctorEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _patientEmailController.dispose();
    _doctorEmailController.dispose();
    super.dispose();
  }

  // 🏥 1. পেশেন্ট সার্চ এবং অ্যাকশন
  Future<void> _searchPatient() async {
    if (_patientEmailController.text.isEmpty) return;

    setState(() => _isLoading = true);
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
        Navigator.pop(context); // ডায়ালগ বন্ধ
        _showPatientOptions(data); // অপশন দেখানো
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient not found! Please check email.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🩺 2. ডাক্তার অ্যাসাইন করা
  Future<void> _assignDoctor() async {
    if (_doctorEmailController.text.isEmpty) return;

    setState(() => _isLoading = true);
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
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No Doctor found with this email.")));
        return;
      }

      await Supabase.instance.client.from('hospital_doctors').insert({
        'hospital_id': hospitalId,
        'doctor_id': doctor['id']
      });

      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${doctor['full_name']} added to hospital list!")),
        );
      }
    } catch (e) {
      if (e.toString().contains("duplicate") || e.toString().contains("23505")) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Doctor is already assigned!")));
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // UI Helpers
  void _showPatientOptions(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(patient['full_name'][0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient['full_name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(patient['phone'] ?? 'No Phone', style: GoogleFonts.poppins(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

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
                    MaterialPageRoute(builder: (_) => Scaffold(
                      appBar: AppBar(title: Text("${patient['full_name']}'s History")),
                      body: MedicalTimelineView(patientId: patient['id']),
                    ))
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog({required String title, required String hint, required TextEditingController controller, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text("CONFIRM"),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Doctors", "View List", Icons.people, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Uploads Today", "12", Icons.upload_file, Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),
          Text("Quick Actions", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionCard(
            title: "Manage Patient",
            subtitle: "Search, View Details & Upload Reports",
            icon: Icons.person_search,
            color: Colors.teal,
            onTap: () {
              _patientEmailController.clear();
              _showInputDialog(title: "Find Patient", hint: "Enter patient email", controller: _patientEmailController, onConfirm: _searchPatient);
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: "Assign New Doctor",
            subtitle: "Add a doctor to this hospital",
            icon: Icons.person_add,
            color: Colors.purple,
            onTap: () {
              _doctorEmailController.clear();
              _showInputDialog(title: "Add Doctor", hint: "Enter doctor email", controller: _doctorEmailController, onConfirm: _assignDoctor);
            },
          ),
        ],
      ),
    );
  }
}