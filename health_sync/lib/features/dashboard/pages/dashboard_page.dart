import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/user_profile_provider.dart';
import 'citizen_home_page.dart';
import 'doctor_home_page.dart';
import 'hospital_home_page.dart';
import 'diagnostic_home_page.dart';
import '../../../shared/pages/splash_page.dart'; // 🔥 Fix: Added missing import

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () =>
          const SplashPage(), // 🔥 Optimized: Show Splash Instead of simple Indicator
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)?.somethingWentWrong ??
                    "Something went wrong!",
              ),
              Text("Error: $err", style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(userProfileProvider), // রিট্রাই বাটন
                child: Text(AppLocalizations.of(context)?.retry ?? "Retry"),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)?.userNotFound ?? "User not found",
              ),
            ),
          );
        }

        final role = profile['role'] as String;
        debugPrint("Current Role: $role");

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
