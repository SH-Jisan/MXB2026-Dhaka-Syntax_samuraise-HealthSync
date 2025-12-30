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

  // State
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

  // 🔄 Fetch profile + donor info
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

  // 💾 Save / Update
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
      // 1️⃣ Update profile (common data)
      await Supabase.instance.client
          .from('profiles')
          .update({
            'blood_group': _selectedBloodGroup,
            'district': _districtController.text.trim(),
            'phone': _phoneController.text.trim(),
          })
          .eq('id', user.id);

      // 2️⃣ Donor data
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
                : "Welcome to the donor family! 🎉",
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

    return Scaffold(
      backgroundColor: AppColors.background,
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
              _buildHeader(),

              _buildLabel("Blood Group"),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedBloodGroup,
                items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                decoration: _inputDecoration("Select group", Icons.bloodtype),
              ),
              const SizedBox(height: 16),

              _buildLabel("District / City"),
              TextFormField(
                controller: _districtController,
                decoration: _inputDecoration(
                  "Dhaka, Chattogram...",
                  Icons.location_city,
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Phone"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("017xxxxxxxx", Icons.phone),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Last Donation Date (Optional)"),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _inputDecoration("", Icons.calendar_today),
                  child: Text(
                    _lastDonationDate == null
                        ? "Tap to select"
                        : "${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}",
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  "Available for donation",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  "Turn off if you recently donated or are sick",
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
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

  Widget _buildHeader() {
    if (!_isAlreadyDonor) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _availability ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            _availability ? Icons.check_circle : Icons.do_not_disturb_on,
            size: 40,
            color: _availability ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            _availability
                ? "You are available to donate"
                : "You are currently unavailable",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
