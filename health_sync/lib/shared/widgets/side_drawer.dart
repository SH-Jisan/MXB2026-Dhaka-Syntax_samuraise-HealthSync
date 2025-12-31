import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../features/blood/pages/blood_home_page.dart';
import 'language_selector_widget.dart';
import '../../features/about/about_app_page.dart';
import '../providers/theme_provider.dart'; // Import Theme Provider
import '../../features/auth/providers/auth_provider.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Guest";
    final name = user?.userMetadata?['full_name'] ?? "User";
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "U";

    // Watch Theme State
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // 1. Header with Gradient & User Info
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
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

          const SizedBox(height: 16),

          // 2. Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  text: AppLocalizations.of(context)?.dashboard ?? "Dashboard",
                  onTap: () => Navigator.pop(context),
                  isActive:
                      true, // Assuming we are on dashboard if drawer is opened usually
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.bloodtype_outlined,
                  text: AppLocalizations.of(context)?.bloodBank ?? "Blood Bank",
                  subtitle:
                      AppLocalizations.of(context)?.bloodBankSubtitle ??
                      "Find donors & Request blood",
                  iconColor: Colors.red.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodHomePage()),
                    );
                  },
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  text: AppLocalizations.of(context)?.aboutApp ?? "About App",
                  iconColor: Colors.blue.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutAppPage()),
                    );
                  },
                ),

                const Divider(),

                const Divider(),

                // 🌐 Language Selector
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LanguageSelectorWidget(isDropdown: false),
                ),

                // 🌗 Theme Toggle Switch
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)?.darkMode ?? "Dark Mode",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.amber : Colors.grey.shade600,
                    ),
                    value: isDark,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleTheme();
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

          // 3. Logout Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDrawerItem(
              context,
              icon: Icons.logout,
              text: AppLocalizations.of(context)?.logout ?? "Logout",
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
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

    final color = isActive
        ? AppColors.primary
        : (iconColor ?? (isDark ? Colors.white70 : Colors.grey.shade600));

    final textStyle = GoogleFonts.poppins(
      color: isActive
          ? AppColors.primary
          : (textColor ?? theme.textTheme.bodyMedium?.color),
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      fontSize: 15,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text, style: textStyle),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
