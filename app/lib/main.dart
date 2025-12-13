import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  // TODO: Replace with your actual URL and Anon Key from Supabase Dashboard
  await Supabase.initialize(
    url: 'https://jrcgtabeytqfntghcdet.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpyY2d0YWJleXRxZm50Z2hjZGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NDIwMjksImV4cCI6MjA4MTIxODAyOX0.dIc-nvxkLZGwMBhz-tG0KNk5-ZicZtqHP_cGtK5ieDg',
  );

  runApp(const ProviderScope(child: NiramoyApp()));
}

class NiramoyApp extends StatelessWidget {
  const NiramoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // আমাদের কাস্টম থিম
      home: const AuthGate(),
    );
  }
}