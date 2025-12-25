import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({super.key});

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _districtController = TextEditingController(); 
  final _phoneController = TextEditingController();    

  // State Variables
  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  bool _availability = true; // Default Active

  bool _isLoading = true; // ডাটা চেক করার জন্য লোডিং
  bool _isAlreadyDonor = false; // আগে থেকেই ডোনার কিনা
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyDonor();
  }

  // 🔍 ১. চেক করা ইউজার আগে থেকেই ডোনার কিনা
  Future<void> _checkIfAlreadyDonor() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    debugPrint("🔍 Checking donor status for User ID: ${user.id}");

    try {
      final data = await Supabase.instance.client
          .from('blood_donors')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      debugPrint("📄 Database Data: $data");

      if (data != null) {
        if (mounted) {
          setState(() {
            _isAlreadyDonor = true; 
            _selectedBloodGroup = data['blood_group'];
            _districtController.text = data['district'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _availability = data['availability'] ?? true;

            if (data['last_donation_date'] != null) {
              _lastDonationDate = DateTime.parse(data['last_donation_date']);
            }
          });
        }
      } else {
        debugPrint("⚠️ No donor record found for this user.");
      }
    } catch (e) {
      debugPrint("❌ Check Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 💾 ২. সেভ অথবা আপডেট করা
  Future<void> _submitOrUpdateDonor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Blood Group")));
      return;
    }

    setState(() => _isSubmitting = true);
    final user = Supabase.instance.client.auth.currentUser;

    final donorData = {
      'user_id': user!.id,
      'blood_group': _selectedBloodGroup,
      'district': _districtController.text.trim(),
      'phone': _phoneController.text.trim(),
      'availability': _availability,
      'last_donation_date': _lastDonationDate?.toIso8601String(),
    };

    try {
      if (_isAlreadyDonor) {
        // 🔄 আপডেট (Update)
        await Supabase.instance.client
            .from('blood_donors')
            .update(donorData)
            .eq('user_id', user.id);

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green));
      } else {
        // ➕ নতুন তৈরি (Insert)
        await Supabase.instance.client
            .from('blood_donors')
            .insert(donorData);

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome to the Donor Family! 🎉"), backgroundColor: Colors.green));
      }

      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ডেট পিকার
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isAlreadyDonor ? "Manage Profile" : "Become a Donor"),
        centerTitle: true,
        actions: [
          if(_isAlreadyDonor)
            IconButton(
              icon: Icon(_availability ? Icons.toggle_on : Icons.toggle_off,
                  color: _availability ? Colors.green : Colors.grey, size: 32),
              onPressed: () {
                setState(() => _availability = !_availability);
              },
              tooltip: "Availability Status",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚑 Header Status (যদি ইউজার আগে থেকেই ডোনার হয়)
              if (_isAlreadyDonor)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _availability ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _availability ? Colors.green.shade200 : Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _availability ? Colors.green.shade100 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_availability ? Icons.check_circle : Icons.do_not_disturb_on,
                            size: 32, color: _availability ? Colors.green.shade700 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _availability ? "You are AVAILABLE to donate" : "You are currently UNAVAILABLE",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _availability ? Colors.green.shade800 : Colors.grey.shade700
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Donors receive notifications only when available.", 
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.volunteer_activism, size: 64, color: Colors.teal.shade700),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Join our Hero Network!", 
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your donation can save up to 3 lives.", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

              Text(
                "Donor Details", 
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
              const SizedBox(height: 16),

              // 🩸 Blood Group (Disabled if editing)
              _buildInputLabel("Blood Group"),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: _inputDecoration(hint: "Select Group", icon: Icons.bloodtype, color: Colors.red),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group, style: GoogleFonts.poppins(fontWeight: FontWeight.w500))))
                    .toList(),
                onChanged: _isAlreadyDonor ? null : (val) => setState(() => _selectedBloodGroup = val),
                disabledHint: Text(_selectedBloodGroup ?? "", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              // 📍 District / City
              _buildInputLabel("District / City"),
              TextFormField(
                controller: _districtController,
                style: GoogleFonts.poppins(),
                decoration: _inputDecoration(hint: "Enter your city (e.g. Dhaka)", icon: Icons.location_city),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // 📞 Phone
              _buildInputLabel("Contact Number"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(),
                decoration: _inputDecoration(hint: "017xxxxxxxx", icon: Icons.phone),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // 📅 Last Donation Date
              _buildInputLabel("Last Donation Date (Optional)"),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _inputDecoration(hint: "", icon: Icons.calendar_today),
                  child: Text(
                      _lastDonationDate == null
                          ? "Tap to select date"
                          : "${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}",
                      style: GoogleFonts.poppins(color: _lastDonationDate == null ? Colors.grey.shade400 : AppColors.textPrimary)
                  ),
                ),
              ),

              // Availability Switch for existing donors
              if(_isAlreadyDonor) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: SwitchListTile(
                    title: Text("Available for Donation?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("Turn off if you recently donated or are sick.", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    value: _availability,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _availability = val),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // ✅ Submit / Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrUpdateDonor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isAlreadyDonor ? "UPDATE PROFILE" : "REGISTER AS DONOR", 
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Color? color}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: color ?? Colors.grey.shade600, size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade200, width: 1),
      ),
    );
  }
}