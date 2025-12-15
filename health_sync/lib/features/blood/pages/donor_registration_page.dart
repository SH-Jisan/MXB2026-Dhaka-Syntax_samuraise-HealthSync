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
  String? _selectedBloodGroup;
  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _lastDonationDate;
  bool _isLoading = false;

  Future<void> _registerDonor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Blood Group")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      // 🔥 আলাদা টেবিলে ডাটা পাঠানো হচ্ছে
      await Supabase.instance.client.from('blood_donors').insert({
        'user_id': user!.id,
        'blood_group': _selectedBloodGroup,
        'district': _districtController.text.trim(), // ইউজার ইনপুট (District)
        'phone': _phoneController.text.trim(),       // ইউজার ইনপুট (Phone)
        'last_donation_date': _lastDonationDate?.toIso8601String(),
        'availability': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration Successful! You are now a donor. 🎉"), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Become a Donor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.volunteer_activism, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text("Join our hero network!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: "District / City", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_city)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number (For Urgent Calls)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // Last Donation Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_lastDonationDate == null ? "Select Last Donation Date (Optional)" : "Last Donation: ${_lastDonationDate.toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now()
                  );
                  if (date != null) setState(() => _lastDonationDate = date);
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerDonor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("REGISTER AS DONOR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}