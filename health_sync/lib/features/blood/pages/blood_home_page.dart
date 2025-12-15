import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'donor_search_page.dart';
import 'blood_request_page.dart';
import 'blood_requests_feed_page.dart';
import 'donor_registration_page.dart';
import 'my_blood_requests_page.dart';

class BloodHomePage extends StatelessWidget {
  const BloodHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Bank"),
        // অপশনাল: আইকনটি রাখতেও পারেন শর্টকাট হিসেবে, না রাখলে মুছে দিন
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBloodRequestsPage()));
            },
            icon: const Icon(Icons.history, color: AppColors.primary),
            tooltip: "My Requests",
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🚑 Option 1: Request Blood
              _buildOptionCard(
                context,
                title: "Request for Blood",
                subtitle: "Find donors nearby instantly",
                icon: Icons.bloodtype,
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodRequestPage())),
              ),

              const SizedBox(height: 16),

              // 🤝 Option 2: Become a Donor
              _buildOptionCard(
                context,
                title: "Become a Donor",
                subtitle: "Register to save lives",
                icon: Icons.volunteer_activism,
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorRegistrationPage())),
              ),

              const SizedBox(height: 16),

              // 🔍 Option 3: Find Donors
              _buildOptionCard(
                context,
                title: "Find Blood Donors",
                subtitle: "Search by group & location",
                icon: Icons.search,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorSearchPage())),
              ),

              const SizedBox(height: 16),

              // 🆘 Option 4: Live Requests
              _buildOptionCard(
                context,
                title: "Live Requests (Feed)",
                subtitle: "See who needs help right now",
                icon: Icons.emergency,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodRequestsFeedPage())),
              ),

              const SizedBox(height: 16),

              // 🔥 Option 5: My Requests (NEW) - এখন ইউজাররা সহজেই খুঁজে পাবে
              _buildOptionCard(
                context,
                title: "My Requests & History",
                subtitle: "Check donors for your requests",
                icon: Icons.history_edu,
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBloodRequestsPage())),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}