import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    // 🌗 Theme state
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (profile) {
          final role = profile?['role'] ?? 'CITIZEN';
          final name = profile?['full_name'] ?? 'User';
          final email = profile?['email'] ?? '';
          final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return Column(
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  bottom: 24,
                  left: 24,
                  right: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        firstLetter,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ================= MENU =================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.dashboard_outlined,
                      text: "Dashboard",
                      isActive: true,
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/dashboard');
                      },
                    ),

                    const Divider(),

                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        "BLOOD BANK",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // 🔥 ROLE BASED MENU
                    if (role == 'HOSPITAL') ...[
                      _drawerItem(
                        context,
                        icon: Icons.bloodtype,
                        text: "My Blood Bank",
                        subtitle: "Manage inventory",
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/hospital/blood-bank');
                        },
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.campaign,
                        text: "Post Blood Request",
                        iconColor: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/blood/request');
                        },
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.history,
                        text: "Request History",
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/blood/my-requests');
                        },
                      ),
                    ] else ...[
                      _drawerItem(
                        context,
                        icon: Icons.search,
                        text: "Find Donors",
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/donors');
                        },
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.volunteer_activism,
                        text: "Be a Donor",
                        iconColor: Colors.pink,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/donor/register');
                        },
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(),

                    // ================= DARK MODE =================
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          "Dark Mode",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color:
                          isDark ? Colors.amber : Colors.grey.shade600,
                        ),
                        value: isDark,
                        onChanged: (_) {
                          ref
                              .read(themeProvider.notifier)
                              .toggleTheme();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ================= LOGOUT =================
              Padding(
                padding: const EdgeInsets.all(16),
                child: _drawerItem(
                  context,
                  icon: Icons.logout,
                  text: "Logout",
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Logout"),
                        content:
                        const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= DRAWER ITEM =================
  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        String? subtitle,
        required VoidCallback onTap,
        Color? iconColor,
        Color? textColor,
        bool isActive = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconFinalColor = isActive
        ? AppColors.primary
        : (iconColor ?? (isDark ? Colors.white70 : Colors.grey.shade600));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconFinalColor),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight:
            isActive ? FontWeight.w600 : FontWeight.w500,
            color: textColor ?? theme.textTheme.bodyMedium?.color,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? Colors.white54
                : Colors.grey.shade500,
          ),
        )
            : null,
        onTap: onTap,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
