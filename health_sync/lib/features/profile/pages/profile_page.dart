import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../blood/pages/my_blood_requests_page.dart';
import 'patient_history_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _assignedHospitals =
      []; // 🔥 ডাক্তারের জন্য হসপিটাল লিস্ট

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          _profileData = data;
          _isLoading = false;
        });

        // 🔥 যদি ইউজার ডাক্তার হয়, তবে তার হসপিটাল লিস্ট লোড হবে
        if (data['role'] == 'DOCTOR') {
          _fetchDoctorHospitals(user.id);
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  // 🏥 হসপিটাল লিস্ট আনার ফাংশন
  Future<void> _fetchDoctorHospitals(String doctorId) async {
    try {
      final response = await Supabase.instance.client
          .from('hospital_doctors')
          .select('*, hospital:hospital_id(full_name, address, phone)')
          .eq('doctor_id', doctorId);

      if (mounted) {
        setState(() {
          _assignedHospitals = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Error fetching hospitals: $e");
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();
      ref.invalidate(userProfileProvider);
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'No Email';
    final name = _profileData?['full_name'] ?? 'User';
    final phone = _profileData?['phone'] ?? 'No Phone';
    final role = _profileData?['role'] ?? 'CITIZEN';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("My Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Profile Header (Same as before)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardTheme.color : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary)
                                  .withValues(alpha: 0.1),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.grey.shade400
                                : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(role),
                          backgroundColor: isDark
                              ? Colors.blue.shade900
                              : Colors.blue.shade50,
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.blue.shade200
                                : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔥 DOCTOR ONLY: Assigned Hospitals Section
                  if (role == 'DOCTOR') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Text(
                          "My Associated Hospitals",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (_assignedHospitals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Not assigned to any hospital yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ..._assignedHospitals.map((item) {
                        final hospital = item['hospital'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(
                              Icons.local_hospital,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              hospital['full_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(hospital['address'] ?? 'No address'),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],

                  // 2. Info Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        "Personal Information",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  _buildInfoTile(
                    Icons.phone_outlined,
                    "Phone Number",
                    phone,
                    isDark,
                  ),
                  _buildInfoTile(
                    Icons.email_outlined,
                    "Email Address",
                    email,
                    isDark,
                  ),

                  const SizedBox(height: 24),

                  // 3. Settings & Activity
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        "Settings & Activity",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Care History (Patient Only)
                  if (role == 'CITIZEN')
                    _buildActionTile(
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                      title:
                          "My Appointments & History", // নাম পরিবর্তন করে স্পেসিফিক করা হলো
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientHistoryPage(),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),

                  _buildActionTile(
                    icon: Icons.bloodtype,
                    color: Colors.red,
                    title: "My Blood Requests",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyBloodRequestsPage(),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // 4. Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text("LOGOUT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
