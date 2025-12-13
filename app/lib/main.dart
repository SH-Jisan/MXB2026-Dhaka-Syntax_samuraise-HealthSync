import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  // TODO: Replace with your actual URL and Anon Key from Supabase Dashboard
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL_HERE',
    anonKey: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );

  runApp(const ProviderScope(child: NiramoyApp()));
}

class NiramoyApp extends StatelessWidget {
  const NiramoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niramoy AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // আমাদের কাস্টম থিম
      home: const Scaffold(
        body: Center(child: Text("Splash Screen Placeholder")), // আপাতত এটা থাকবে
      ),
    );
  }
}