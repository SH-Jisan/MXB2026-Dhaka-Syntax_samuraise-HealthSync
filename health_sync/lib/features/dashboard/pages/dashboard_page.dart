import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'citizen_home_page.dart';
import 'doctor_home_page.dart';
import 'hospital_home_page.dart';
import 'diagnostic_home_page.dart';
import '../../../shared/pages/splash_page.dart'; 

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () {
        
        
        return const SplashPage();
      },
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.somethingWentWrong ??
                    "Something went wrong!",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Error: $err",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)?.retry ?? "Retry"),
              ),
              TextButton(
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
                child: const Text("Logout & Try Again"),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          
          
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.userNotFound ??
                        "Fetching user data...",
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    child: const Text("Refetch Profile"),
                  ),
                ],
              ),
            ),
          );
        }

        final role = profile['role'] as String;
        debugPrint("DashboardPage: Landing on $role dashboard");

        
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
