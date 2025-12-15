import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
// Blood & About পেজ আমরা পরে বানাবো, তাই আপাতত ইম্পোর্ট বাদে রাখছি
// import '../../features/blood/pages/blood_home_page.dart';
import '../../features/about/about_app_page.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Guest";
    final name = user?.userMetadata?['full_name'] ?? "User";

    return Drawer(
      child: Column(
        children: [
          // 1. Header with User Info
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: AppColors.primary),
              ),
            ),
          ),

          // 2. Menu Items
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context); // ড্রয়ার বন্ধ
              // হোম পেজে যেহেতু অলরেডি আছি, তাই কিছু করার দরকার নেই
            },
          ),

          const Divider(),

          // 🔥 Blood Section
          ListTile(
            leading: const Icon(Icons.bloodtype, color: Colors.red),
            title: const Text("Blood Bank"),
            subtitle: const Text("Find donors & Request blood"),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Blood Page
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Blood Section Coming Next!")));
            },
          ),

          // 🔥 About App
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text("About App"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppPage())
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text("Logout"),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}