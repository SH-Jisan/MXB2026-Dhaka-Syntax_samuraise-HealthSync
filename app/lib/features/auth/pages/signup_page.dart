/// File: lib/features/auth/pages/signup_page.dart
/// Purpose: Allows new users to register an account with a specific role.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/shared_auth_layout.dart';

/// Registration screen supporting multiple user roles (Citizen, Doctor, Hospital, Diagnostic).
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'CITIZEN';

  final List<String> _roles = ['CITIZEN', 'DOCTOR', 'HOSPITAL', 'DIAGNOSTIC'];

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SharedAuthLayout(
      title: "Create Account",
      subtitle: "Join HealthSync today",
      formContent: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Type Dropdown
            _buildInputLabel("Account Type"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: _inputDecoration(
                hint: "Select Account Type",
                icon: PhosphorIconsRegular.users,
                isDark: isDark,
              ),
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              icon: Icon(
                PhosphorIconsRegular.caretDown,
                color: AppColors.textSecondary,
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(
                    role == 'CITIZEN' ? 'Normal User (Citizen)' : role,
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 20),

            // Name Input
            _buildInputLabel("Full Name / Hospital Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: "Enter full name",
                icon: PhosphorIconsRegular.user,
                isDark: isDark,
              ),
              validator: (v) => v!.isEmpty ? "Name is required" : null,
            ),
            const SizedBox(height: 20),

            // Phone Input
            _buildInputLabel("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                hint: "Enter phone number",
                icon: PhosphorIconsRegular.phone,
                isDark: isDark,
              ),
              validator: (v) => v!.isEmpty ? "Phone is required" : null,
            ),
            const SizedBox(height: 20),

            // Email Input
            _buildInputLabel("Email Address"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                hint: "Enter email address",
                icon: PhosphorIconsRegular.envelope,
                isDark: isDark,
              ),
              validator: (v) => v!.contains("@") ? null : "Invalid Email",
            ),
            const SizedBox(height: 20),

            // Password Input
            _buildInputLabel("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration(
                hint: "Create a password",
                icon: PhosphorIconsRegular.lock,
                isDark: isDark,
              ),
              validator: (v) => v!.length < 6 ? "Min 6 chars required" : null,
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: isLoading ? null : _handleSignup,
              style:
                  ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(MaterialState.disabled))
                        return Colors.grey;
                      return isDark ? AppColors.darkPrimary : AppColors.primary;
                    }),
                  ),
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "CREATE ACCOUNT",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    "Log In",
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authStateProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account Created! Please check email for verification.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString().split('\n').first}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
