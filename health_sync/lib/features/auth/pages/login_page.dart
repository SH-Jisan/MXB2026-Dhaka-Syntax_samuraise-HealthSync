import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo & Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkPrimary.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 64,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      theme.textTheme.displayMedium?.color ??
                      (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue to HealthSync",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      theme.textTheme.bodyMedium?.color ??
                      (isDark ? Colors.grey.shade400 : AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 40),

              // Inputs
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              // Forgot Password (Placeholder)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 16),

              // Action Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.black : Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("LOGIN"),
              ),

              const SizedBox(height: 24),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    try {
      await ref
          .read(authStateProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 🔥 Manual Redirect Fallback
      // Router *should* handle this, but explicit navigation ensures
      // the user isn't stuck if the stream has a race condition.
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login Failed: ${e.toString().split('\n').first}",
            ), // Simpler error
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
