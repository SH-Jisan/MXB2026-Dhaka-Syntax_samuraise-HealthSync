import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../pages/doctor_patient_profile_page.dart';

class DoctorWorkTab extends StatefulWidget {
  const DoctorWorkTab({super.key});

  @override
  State<DoctorWorkTab> createState() => _DoctorWorkTabState();
}

class _DoctorWorkTabState extends State<DoctorWorkTab> {
  final String _doctorId = Supabase.instance.client.auth.currentUser!.id;

  late Future<List<dynamic>> _hospitalsFuture;
  late Future<List<dynamic>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    // 🔥 ফিক্স: initState এর ভেতর সরাসরি ফাংশন কল করা হয়েছে, setState নয়।
    _refreshHospitals();
    _refreshPatients();
  }

  // ডাটা লোড বা রিফ্রেশ করার ফাংশন
  void _refreshHospitals() {
    setState(() {
      _hospitalsFuture = Supabase.instance.client
          .from('doctor_hospitals')
          .select()
          .eq('doctor_id', _doctorId);
    });
  }

  void _refreshPatients() {
    setState(() {
      _patientsFuture = Supabase.instance.client
          .from('doctor_patients')
          .select('patient_id, profiles:patient_id(*)')
          .eq('doctor_id', _doctorId)
          .order('assigned_at', ascending: false);
    });
  }

  // 🏥 Add New Hospital Dialog
  void _addHospital() {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Hospital"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Hospital Name")),
            const SizedBox(height: 8),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Visiting Hours (e.g. 5-9 PM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await Supabase.instance.client.from('doctor_hospitals').insert({
                  'doctor_id': _doctorId,
                  'hospital_name': nameCtrl.text,
                  'visiting_hours': timeCtrl.text,
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  _refreshHospitals(); // 🔥 লিস্ট রিফ্রেশ
                }
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // 🔍 Search & Add Patient Logic
  void _searchAndAddPatient() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Patient"),
        content: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Patient Email", hintText: "Enter email to search")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = await Supabase.instance.client
                    .from('profiles')
                    .select('id')
                    .eq('email', emailCtrl.text.trim())
                    .maybeSingle();

                if (data != null) {
                  await Supabase.instance.client.from('doctor_patients').insert({
                    'doctor_id': _doctorId,
                    'patient_id': data['id']
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    _refreshPatients(); // 🔥 লিস্ট রিফ্রেশ
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Patient Added Successfully!")));
                  }
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Patient not found!")));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Already assigned or Error")));
              }
            },
            child: const Text("Add Patient"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section 1: My Hospitals ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current Chambers", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _addHospital, icon: const Icon(Icons.add_circle, color: AppColors.primary)),
            ],
          ),

          FutureBuilder(
            future: _hospitalsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              if (!snapshot.hasData) return const SizedBox.shrink();

              final hospitals = snapshot.data as List;
              if (hospitals.isEmpty) return const Text("No hospitals added.", style: TextStyle(color: Colors.grey));

              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final h = hospitals[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital, color: isDark ? Colors.white70 : Colors.blue.shade700),
                          const SizedBox(height: 8),
                          Text(h['hospital_name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(h['visiting_hours'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // --- Section 2: Patients ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Under Treatment", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _searchAndAddPatient,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text("New Patient"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          FutureBuilder(
            future: _patientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data as List? ?? [];

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text("No patients assigned yet."),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final patient = list[index]['profiles'];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        child: Text(patient['full_name'][0]),
                      ),
                      title: Text(patient['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Phone: ${patient['phone'] ?? 'N/A'}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DoctorPatientProfilePage(patient: patient)),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}