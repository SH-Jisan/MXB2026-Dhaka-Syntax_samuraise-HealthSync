/// File: lib/features/auth/pages/login_page.dart
/// Purpose: Handles user authentication via Email/Password.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

import '../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/shared_auth_layout.dart';

/// Screen for existing users to sign in.
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
    final l10n = AppLocalizations.of(context);

    return SharedAuthLayout(
      title: l10n?.loginTitle ?? "Welcome Back!",
      subtitle: l10n?.loginSubtitle ?? "Sign in to access your health records",
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Input
          _buildInputLabel("Email Address"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: "Enter your email",
              icon: PhosphorIconsRegular.envelope,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 20),

          // Password Input
          _buildInputLabel("Password"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: _inputDecoration(
              hint: "Enter your password",
              icon: PhosphorIconsRegular.lock,
              isDark: isDark,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style:
                ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled))
                      return Colors.grey;
                    return isDark ? AppColors.darkPrimary : AppColors.primary;
                  }),
                ),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              // Hack to apply gradient if needed, but solid color is fine for now as per plan
              // Plan said Gradient background, let's stick to simple primary for consistency or use decorating container
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      l10n?.loginButton ?? "LOGIN",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n?.dontHaveAccount ?? "Don't have an account?",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(
                  l10n?.signupLink ?? "Sign Up",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
          width: 2,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: ${e.toString().split('\n').first}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
