import 'package:flutter/material.dart';
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
  final _districtController = TextEditingController(); // Fixed: database column is 'district'
  final _phoneController = TextEditingController();    // Fixed: database column is 'phone'

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

    // ডিবাগিং এর জন্য প্রিন্ট
    debugPrint("🔍 Checking donor status for User ID: ${user.id}");

    try {
      final data = await Supabase.instance.client
          .from('blood_donors')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      // ডিবাগিং: ডাটা কি এসেছে নাকি নাল?
      debugPrint("📄 Database Data: $data");

      if (data != null) {
        if (mounted) {
          setState(() {
            _isAlreadyDonor = true; // ✅ সত্য হলো
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

    // 🔥 ডাটা অবজেক্ট তৈরি (আপনার ডাটাবেস কলাম অনুযায়ী)
    final donorData = {
      'user_id': user!.id,
      'blood_group': _selectedBloodGroup,
      'district': _districtController.text.trim(), // 🔥 Fixed
      'phone': _phoneController.text.trim(),       // 🔥 Fixed
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
      appBar: AppBar(
        title: Text(_isAlreadyDonor ? "Manage Donor Profile" : "Become a Donor"),
        actions: [
          if(_isAlreadyDonor)
            IconButton(
              icon: Icon(_availability ? Icons.toggle_on : Icons.toggle_off,
                  color: _availability ? Colors.green : Colors.grey, size: 40),
              onPressed: () {
                setState(() => _availability = !_availability);
              },
              tooltip: "Availability Status",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚑 Header Status (যদি ইউজার আগে থেকেই ডোনার হয়)
              if (_isAlreadyDonor)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _availability ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _availability ? Colors.green : Colors.grey),
                  ),
                  child: Column(
                    children: [
                      Icon(_availability ? Icons.check_circle : Icons.do_not_disturb_on,
                          size: 40, color: _availability ? Colors.green : Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        _availability ? "You are AVAILABLE to donate" : "You are currently UNAVAILABLE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _availability ? Colors.green.shade800 : Colors.grey.shade700
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text("Donors receive notifications only when available.", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              else
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.volunteer_activism, size: 80, color: Colors.teal),
                      SizedBox(height: 10),
                      Text("Join our hero network!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

              const Text("Donor Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 🩸 Blood Group (Disabled if editing)
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                // একবার সেট করলে ব্লাড গ্রুপ বদলানো সাধারণত উচিত নয়, তাই এডিট মোডে ডিজেবল রাখলাম
                onChanged: _isAlreadyDonor ? null : (val) => setState(() => _selectedBloodGroup = val),
                disabledHint: Text(_selectedBloodGroup ?? "", style: const TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 16),

              // 📍 District / City
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: "District / City", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_city)),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // 📞 Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Contact Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // 📅 Last Donation Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Last Donation Date (Optional)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(
                      _lastDonationDate == null
                          ? "Select Date"
                          : "${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}"
                  ),
                ),
              ),

              // Availability Switch for existing donors
              if(_isAlreadyDonor) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Available for Donation?"),
                  subtitle: const Text("Turn off if you recently donated or are sick."),
                  value: _availability,
                  activeColor: Colors.green,
                  onChanged: (val) => setState(() => _availability = val),
                ),
              ],

              const SizedBox(height: 30),

              // ✅ Submit / Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrUpdateDonor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isAlreadyDonor ? "UPDATE PROFILE" : "REGISTER AS DONOR", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}