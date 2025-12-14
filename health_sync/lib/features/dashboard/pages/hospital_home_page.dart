import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HospitalHomePage extends StatelessWidget {
  const HospitalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text("Hospital Dashboard"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      body: const Center(
        child: Text("Welcome, Admin! 🏥\n(Upload Reports & Manage Doctors)"),
      ),
    );
  }
}