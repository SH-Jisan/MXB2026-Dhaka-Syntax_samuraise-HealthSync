import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/language_provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_secrets.dart'; // 🔥 Fix: Added secrets import
import 'core/router/app_router.dart'; // appRouter এখানে আছে
import 'core/services/notification_service.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/user_profile_provider.dart'; // 🔥 Fix: Added missing import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(),
    Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnonKey,
    ),
  ]);

  // 🔥 GLOBAL AUTH LISTENER (Notification Only)
  // Routing Logic এখন AppRouter এর দায়িত্বে
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    // ⚠️ আমরা এখানে নোটিফিকেশন লজিক রাখছি না।
    // এটা এখন Riverpod Provider এর মাধ্যমে build() মেথডে হ্যান্ডেল হবে।
  });

  runApp(const ProviderScope(child: HealthSyncApp()));
}

class HealthSyncApp extends ConsumerWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // থিম মোড প্রোভাইডার থেকে নেওয়া
    final themeMode = ref.watch(themeProvider);

    // 🔥 Watch the Router Provider
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(languageProvider);

    // 🔥 Global Notification Manager (Reactive)
    // Auth State Listen করে নোটিফিকেশন সার্ভিস স্টার্ট/স্টপ করবে
    ref.listen(authStateChangesProvider, (previous, next) {
      final session = next.value?.session;
      final notifier = ref.read(notificationServiceProvider.notifier);

      if (session != null) {
        notifier.initialize();
      } else {
        notifier.disposeSubscriptions();
      }
    });

    return MaterialApp.router(
      title: 'HealthSync',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // 🔥 থিম মোড সেট করা (System / Light / Dark)
      themeMode: themeMode,

      // ☀️ লাইট থিম
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,

          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

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
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
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
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),

      // 🌙 ডার্ক থিম
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkPrimary,
          primary: AppColors.darkPrimary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          // background: AppColors.darkBackground, // Deprecated, handled by surface/scaffoldBackgroundColor
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
            .apply(
              bodyColor: AppColors.darkTextPrimary,
              displayColor: AppColors.darkTextPrimary,
            ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.darkPrimary,
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.black,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 3,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          modalBackgroundColor: AppColors.darkSurface,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.darkSurface,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),

      routerConfig: router,
    );
  }
}
