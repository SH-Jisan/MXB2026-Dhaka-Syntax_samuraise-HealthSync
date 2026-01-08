/// File: lib/features/blood/pages/donor_registration_page.dart
/// Purpose: Registration form for users to become blood donors.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

/// Screen for users to register or update their donor profile.
class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({super.key});

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  bool _availability = true;
  bool _isAlreadyDonor = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndDonor();
  }

  Future<void> _fetchProfileAndDonor() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final donor = await Supabase.instance.client
          .from('blood_donors')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _selectedBloodGroup = profile['blood_group'];
        _districtController.text = profile['district'] ?? '';
        _phoneController.text = profile['phone'] ?? '';

        if (donor != null) {
          _isAlreadyDonor = true;
          _availability = donor['availability'] ?? true;
          if (donor['last_donation_date'] != null) {
            _lastDonationDate = DateTime.parse(donor['last_donation_date']);
          }
        }
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select blood group")),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'blood_group': _selectedBloodGroup,
            'district': _districtController.text.trim(),
            'phone': _phoneController.text.trim(),
          })
          .eq('id', user.id);

      final donorData = {
        'user_id': user.id,
        'availability': _availability,
        'last_donation_date': _lastDonationDate?.toIso8601String(),
      };

      if (_isAlreadyDonor) {
        await Supabase.instance.client
            .from('blood_donors')
            .update(donorData)
            .eq('user_id', user.id);
      } else {
        await Supabase.instance.client.from('blood_donors').insert(donorData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAlreadyDonor
                ? "Profile updated successfully!"
                : "Welcome to the donor family! ",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _lastDonationDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isAlreadyDonor ? "Manage Donor Profile" : "Become a Donor",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),

              _buildLabel("Blood Group", isDark),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                decoration: _inputDecoration(
                  "Select group",
                  Icons.bloodtype,
                  isDark,
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel("District / City", isDark),
              TextFormField(
                controller: _districtController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration(
                  "Dhaka, Chattogram...",
                  Icons.location_city,
                  isDark,
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Phone", isDark),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration(
                  "017xxxxxxxx",
                  Icons.phone,
                  isDark,
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Last Donation Date (Optional)", isDark),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _inputDecoration(
                    "",
                    Icons.calendar_today,
                    isDark,
                  ),
                  child: Text(
                    _lastDonationDate == null
                        ? "Tap to select"
                        : "${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}",
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  "Available for donation",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Turn off if you recently donated or are sick",
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                value: _availability,
                onChanged: (v) => setState(() => _availability = v),
                activeTrackColor: Colors.green,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            color: isDark ? Colors.black : Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isAlreadyDonor
                              ? "UPDATE PROFILE"
                              : "REGISTER AS DONOR",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    if (!_isAlreadyDonor) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _availability
            ? (isDark
                  ? Colors.green.shade900.withValues(alpha: 0.3)
                  : Colors.green.shade50)
            : (isDark
                  ? Colors.red.shade900.withValues(alpha: 0.3)
                  : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _availability
              ? (isDark ? Colors.green.shade700 : Colors.green.shade200)
              : (isDark ? Colors.red.shade700 : Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _availability ? Icons.check_circle : Icons.do_not_disturb_on,
            size: 40,
            color: _availability
                ? (isDark ? Colors.green.shade300 : Colors.green)
                : (isDark ? Colors.red.shade300 : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _availability
                ? "You are available to donate"
                : "You are currently unavailable",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: isDark ? Colors.grey : Colors.grey),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : Colors.white,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
    );
  }
}
