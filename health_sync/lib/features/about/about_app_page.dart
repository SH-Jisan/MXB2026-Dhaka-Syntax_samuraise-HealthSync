import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About HealthSync")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Title
            const Center(
              child: Column(
                children: [
                  Icon(Icons.health_and_safety, size: 80, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text("HealthSync Pro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("v1.0.0", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // How to Use
            _buildSectionTitle("📖 How to use"),
            _buildBulletPoint("Upload your medical reports or prescriptions."),
            _buildBulletPoint("AI will analyze and save them to your timeline."),
            _buildBulletPoint("Use AI Doctor to check symptoms instantly."),
            _buildBulletPoint("Find doctors via App or Google Search."),
            _buildBulletPoint("Use Blood Bank to find donors nearby."),

            const SizedBox(height: 20),

            // Technology
            _buildSectionTitle("🛠️ Tech Stack"),
            const Text("This app is powered by cutting-edge technologies:"),
            const SizedBox(height: 10),
            _buildTechRow(Icons.flutter_dash, "Flutter", "Cross-platform UI"),
            _buildTechRow(Icons.storage, "Supabase", "Backend & Database"),
            _buildTechRow(Icons.psychology, "Gemini 2.5 AI", "Medical Analysis"),
            _buildTechRow(Icons.search, "Serper API", "Real-time Doctor Search"),

            const SizedBox(height: 40),
            const Center(
              child: Text("Made with ❤️ for Better Healthcare", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildTechRow(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}