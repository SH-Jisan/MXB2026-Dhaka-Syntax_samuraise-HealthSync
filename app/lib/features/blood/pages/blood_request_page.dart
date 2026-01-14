/// File: lib/features/blood/pages/blood_request_page.dart
/// Purpose: Form to post a new blood request, with AI autofill capabilities.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Page for users to create a blood request.
class BloodRequestPage extends StatefulWidget {
  const BloodRequestPage({super.key});

  @override
  State<BloodRequestPage> createState() => _BloodRequestPageState();
}

class _BloodRequestPageState extends State<BloodRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final _aiInputController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedBloodGroup;
  String _urgency = 'NORMAL';

  bool _isAnalyzing = false;
  bool _isSubmitting = false;

  Future<void> _analyzeWithAI() async {
    if (_aiInputController.text.isEmpty) return;

    setState(() => _isAnalyzing = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'extract-blood-request',
        body: {'text': _aiInputController.text},
      );

      if (response.status == 200) {
        final data = response.data;

        setState(() {
          if (data['blood_group'] != null) {
            const validGroups = [
              'A+',
              'A-',
              'B+',
              'B-',
              'O+',
              'O-',
              'AB+',
              'AB-',
            ];
            if (validGroups.contains(data['blood_group'])) {
              _selectedBloodGroup = data['blood_group'];
            }
          }
          _locationController.text = data['location'] ?? '';
          _noteController.text =
              data['patient_note'] ?? _aiInputController.text;

          if (data['urgency'] == 'CRITICAL') {
            _urgency = 'CRITICAL';
          } else {
            _urgency = 'NORMAL';
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.aiAutofillSuccess ??
                    "Form autofilled by AI! Please review.",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)?.aiError ?? 'AI Error: '}$e",
            ),
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.selectBloodGroupError ??
                "Please select Blood Group",
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('blood_requests').insert({
        'requester_id': user!.id,
        'blood_group': _selectedBloodGroup,
        'hospital_name': _locationController.text,
        'urgency': _urgency,
        'reason': _noteController.text,
        'status': 'OPEN',
        'accepted_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      Supabase.instance.client.functions
          .invoke(
            'notify-donors',
            body: {
              'blood_group': _selectedBloodGroup,
              'hospital': _locationController.text,
              'urgency': _urgency,
            },
          )
          .then((response) {
            debugPrint(" Notification Response: ${response.data}");
          })
          .catchError((error) {
            debugPrint(" Notification Failed: $error");
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.requestPostedSuccess ??
                  "Request Posted! Notifying nearby donors... ",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)?.errorPostingRequest ?? 'Error posting request: '}$e",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.requestBloodTitle ?? "Request Blood",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.deepPurple.shade900.withValues(alpha: 0.5),
                            AppColors.darkSurface,
                          ]
                        : [Colors.deepPurple.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.deepPurple.shade800
                        : Colors.deepPurple.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.deepPurple.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade300,
                                Colors.purple,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.quickAiFill ??
                                  "Quick AI Fill",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.deepPurple.shade100
                                    : Colors.deepPurple.shade800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)?.aiPrompt ??
                                  "Type or speak your need naturally",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.deepPurple.shade200
                                    : Colors.deepPurple.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _aiInputController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)?.aiHint ??
                            "Example: \"Urgent A+ blood needed at Dhaka Medical College for a road accident patient...\"",
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeWithAI,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.bolt_rounded, size: 20),
                        label: Text(
                          _isAnalyzing
                              ? "Processing..."
                              : "Auto-Fill Form with AI",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  AppLocalizations.of(context)?.manualEntry ?? "Manual Entry",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),

              _buildInputLabel(
                AppLocalizations.of(context)?.bloodGroup ?? "Blood Group",
                isDark,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: _inputDecoration(
                  hint:
                      AppLocalizations.of(context)?.selectGroup ??
                      "Select Group",
                  icon: Icons.bloodtype,
                  color: Colors.red,
                  isDark: isDark,
                ),
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map(
                      (group) => DropdownMenuItem(
                        value: group,
                        child: Text(
                          group,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedBloodGroup = val),
              ),
              const SizedBox(height: 20),

              _buildInputLabel(
                AppLocalizations.of(context)?.hospitalLocation ??
                    "Hospital / Location",
                isDark,
              ),
              TextFormField(
                controller: _locationController,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: _inputDecoration(
                  hint:
                      AppLocalizations.of(context)?.enterHospitalHelper ??
                      "Enter hospital name & area",
                  icon: Icons.location_on_outlined,
                  isDark: isDark,
                ),
                validator: (val) => val!.isEmpty
                    ? (AppLocalizations.of(context)?.required ?? "Required")
                    : null,
              ),
              const SizedBox(height: 20),

              _buildInputLabel(
                AppLocalizations.of(context)?.urgencyLevel ?? "Urgency Level",
                isDark,
              ),
              DropdownButtonFormField<String>(
                initialValue: _urgency,
                decoration: _inputDecoration(
                  hint:
                      AppLocalizations.of(context)?.selectUrgency ??
                      "Select Urgency",
                  icon: Icons.warning_amber_rounded,
                  color: _urgency == 'CRITICAL' ? Colors.red : Colors.orange,
                  isDark: isDark,
                ),
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                items: ['NORMAL', 'CRITICAL']
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Row(
                          children: [
                            Text(
                              u == 'CRITICAL'
                                  ? (AppLocalizations.of(context)?.critical ??
                                        'CRITICAL')
                                  : (AppLocalizations.of(context)?.normal ??
                                        'NORMAL'),
                              style: GoogleFonts.poppins(
                                color: u == 'CRITICAL'
                                    ? Colors.red
                                    : (isDark ? Colors.white : Colors.black),
                                fontWeight: u == 'CRITICAL'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (u == 'CRITICAL') ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.priority_high,
                                size: 16,
                                color: Colors.red,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _urgency = val!),
              ),
              const SizedBox(height: 20),

              _buildInputLabel(
                AppLocalizations.of(context)?.patientConditionNote ??
                    "Patient Condition / Note",
                isDark,
              ),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: _inputDecoration(
                  hint:
                      AppLocalizations.of(context)?.describeSituation ??
                      "Describe the situation...",
                  icon: Icons.note_alt_outlined,
                  isDark: isDark,
                ).copyWith(alignLabelWithHint: true),
                validator: (val) => val!.isEmpty
                    ? (AppLocalizations.of(context)?.required ?? "Required")
                    : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 6,
                    shadowColor: Colors.red.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)?.postBloodRequest ??
                              "POST BLOOD REQUEST",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Color? color,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: color ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        size: 22,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkPrimary.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade200, width: 1),
      ),
    );
  }
}
