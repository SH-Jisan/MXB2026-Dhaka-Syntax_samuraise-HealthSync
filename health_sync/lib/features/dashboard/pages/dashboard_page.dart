import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/user_profile_provider.dart';
import 'citizen_home_page.dart';
import 'doctor_home_page.dart';
import 'hospital_home_page.dart';
import 'diagnostic_home_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Error loading profile: $err")),
      ),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text("User not found")),
          );
        }

        final role = profile['role'] as String;

        // 🔥 ROLE BASED NAVIGATION
        switch (role) {
          case 'DOCTOR':
            return const DoctorHomePage();
          case 'HOSPITAL':
            return const HospitalHomePage();
          case 'DIAGNOSTIC':
            return const DiagnosticHomePage();
          case 'CITIZEN':
          default:
            return const CitizenHomePage();
        }
      },
    );
  }
}
