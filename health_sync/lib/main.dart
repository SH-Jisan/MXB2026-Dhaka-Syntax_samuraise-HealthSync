import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// আপনার প্রোজেক্টের ফাইল ইম্পোর্ট
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';

// যদি FlutterFire CLI দিয়ে কনফিগার করে থাকেন তবে এটি আনকমেন্ট করবেন
// import 'firebase_options.dart';

// নোটিফিকেশন একবার ইনিশিয়ালাইজ হয়েছে কিনা ট্র্যাক করার জন্য
bool _notificationInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 1. Firebase Initialize
  // যদি firebase_options.dart থাকে তবে options প্যারামিটারটি আনকমেন্ট করুন
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 2. Supabase Initialize
  // আপনার দেওয়া ক্রেডেনশিয়াল ব্যবহার করা হয়েছে
  await Supabase.initialize(
    url: 'https://tyceawrbxbksrbmatyxr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y2Vhd3JieGJrc3JibWF0eXhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MjEyODEsImV4cCI6MjA4MTI5NzI4MX0.5ip891FpLXy1J8ZAstxHhg3iBuKrS9mT4j_F_fHC5lg',
  );

  // 🔹 3. Auth State Listener (লগইন ডিটেক্ট করে নোটিফিকেশন অন করা)
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;

    // ইউজার লগইন করলে
    if (session != null && !_notificationInitialized) {
      NotificationService().initialize();
      _notificationInitialized = true;
      debugPrint("🔔 Notification Service Started for User");
    }

    // ইউজার লগআউট করলে
    if (session == null) {
      // এখানে ফিউচারে নোটিফিকেশন ডিসপোজ করার লজিক থাকতে পারে
      _notificationInitialized = false;
      debugPrint("🔕 Notification Service Stopped (User Logged Out)");
    }
  });

  runApp(const ProviderScope(child: HealthSyncApp()));
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HealthSync',
      debugShowCheckedModeBanner: false,

      // 🔹 4. Professional App Theme
      theme: ThemeData(
        useMaterial3: true,

        // কালার স্কিম
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          background: AppColors.background,
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ফন্ট থিম (Poppins)
        textTheme: GoogleFonts.poppinsTextTheme(),

        // ইনপুট ফিল্ড (TextField) ডিজাইন
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),

        // বাটন (ElevatedButton) ডিজাইন
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // অ্যাপ বার (AppBar) ডিজাইন
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),

        // কার্ড (Card) ডিজাইন
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),

      // 🔹 5. Router Config
      routerConfig: appRouter,
    );
  }
}