import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
// router ফাইলটি আমরা পরের ধাপে বানাব, তাই আপাতত কমেন্ট বা ডামি
// import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Setup
  await Supabase.initialize(
    url: 'https://tyceawrbxbksrbmatyxr.supabase.co', // ড্যাশবোর্ড থেকে নিন
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y2Vhd3JieGJrc3JibWF0eXhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MjEyODEsImV4cCI6MjA4MTI5NzI4MX0.5ip891FpLXy1J8ZAstxHhg3iBuKrS9mT4j_F_fHC5lg', // ড্যাশবোর্ড থেকে নিন
  );

  runApp(const ProviderScope(child: HealthSyncApp()));
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // হোম পেজ আমরা পরে রাউটার দিয়ে সেট করব
      home: const Scaffold(body: Center(child: Text("HealthSync Setup Complete!"))),
    );
  }
}