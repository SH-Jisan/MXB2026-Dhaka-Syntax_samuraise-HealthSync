import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../blood/pages/my_blood_requests_page.dart';
import 'patient_history_page.dart'; // 🔥 নতুন ইমপোর্ট (Care History পেজ)

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

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
      } catch (e) {
        debugPrint("Error fetching profile: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
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
            // 1. Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: isDark ? theme.cardTheme.color : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "U",
                        style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkPrimary : AppColors.primary
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      name,
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary
                      )
                  ),
                  Text(
                      email,
                      style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                          fontSize: 14
                      )
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade100),
                    ),
                    child: Text(
                        role,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5
                        )
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary
                  ),
                ),
              ),
            ),
            _buildInfoTile(Icons.phone_outlined, "Phone Number", phone, isDark),
            _buildInfoTile(Icons.email_outlined, "Email Address", email, isDark),

            const SizedBox(height: 24),

            // 3. Settings & Activity Section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  "Settings & Activity",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary
                  ),
                ),
              ),
            ),

            // 🔥 Care History Button (New Feature)
            _buildActionTile(
                icon: Icons.history_edu,
                color: Colors.blue,
                title: "Care History",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientHistoryPage()));
                },
                isDark: isDark
            ),

            _buildActionTile(
                icon: Icons.bloodtype,
                color: Colors.red,
                title: "My Blood Requests",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBloodRequestsPage()));
                },
                isDark: isDark
            ),

            _buildActionTile(
                icon: Icons.lock_outline,
                color: Colors.teal,
                title: "Change Password",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature coming soon!")));
                },
                isDark: isDark
            ),

            const SizedBox(height: 32),

            // 4. Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 20),
                label: Text(
                    "LOGOUT",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
                    foregroundColor: isDark ? Colors.red.shade200 : Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isDark ? Colors.red.shade800 : Colors.red.shade100),
                    )
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 2))
          ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : AppColors.background,
                shape: BoxShape.circle
            ),
            child: Icon(icon, color: isDark ? Colors.grey.shade400 : AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.grey.shade500 : AppColors.textSecondary)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required Color color, required String title, required VoidCallback onTap, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 2))
          ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? AppColors.darkTextPrimary : Colors.black87)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}