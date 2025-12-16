import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BloodRequestPage extends StatefulWidget {
  const BloodRequestPage({super.key});

  @override
  State<BloodRequestPage> createState() => _BloodRequestPageState();
}

class _BloodRequestPageState extends State<BloodRequestPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _aiInputController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  // Dropdown Values
  String? _selectedBloodGroup;
  String _urgency = 'NORMAL';

  bool _isAnalyzing = false;
  bool _isSubmitting = false;

  // 🧠 AI Analysis Function (Same as before)
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
            const validGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
            if (validGroups.contains(data['blood_group'])) {
              _selectedBloodGroup = data['blood_group'];
            }
          }
          _locationController.text = data['location'] ?? '';
          _noteController.text = data['patient_note'] ?? _aiInputController.text;

          if (data['urgency'] == 'CRITICAL') {
            _urgency = 'CRITICAL';
          } else {
            _urgency = 'NORMAL';
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Form autofilled by AI! Please review."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  // 💾 Submit to Database & Trigger Notification
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Blood Group")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      // ১. ডাটাবেসে রিকোয়েস্ট সেভ করা
      // আমরা রেসপন্সটি ভেরিয়েবলে রাখছি না কারণ আমাদের শুধু ইনসার্ট কনফার্মেশন দরকার
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

      // 🔥 ২. নোটিফিকেশন ট্রিগার (Fire & Forget)
      // আমরা এখানে 'await' ব্যবহার করছি না, যাতে ইউজারকে অপেক্ষা করতে না হয়।
      // নোটিফিকেশন ব্যাকগ্রাউন্ডে চলে যাবে।
      Supabase.instance.client.functions.invoke('notify-donors', body: {
        'blood_group': _selectedBloodGroup,
        'hospital': _locationController.text,
        'urgency': _urgency,
      }).then((response) {
        debugPrint("🔔 Notification Response: ${response.data}");
      }).catchError((error) {
        debugPrint("❌ Notification Failed: $error");
      });

      // ৩. সাকসেস মেসেজ এবং পেজ বন্ধ করা
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Request Posted! Notifying nearby donors... 📲"),
              backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error posting request: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Blood")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✨ AI SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.purple),
                        SizedBox(width: 8),
                        Text("AI Assistant (Voice/Text)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _aiInputController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "e.g., Need B+ blood at Dhaka Medical for accident...",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeWithAI,
                        icon: _isAnalyzing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.bolt),
                        label: Text(_isAnalyzing ? "Analyzing..." : "Auto-Fill Form"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text("Review Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 🩸 Blood Group Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedBloodGroup = val),
              ),
              const SizedBox(height: 16),

              // 🏥 Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Hospital / Location", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // 🚨 Urgency
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: const InputDecoration(labelText: "Urgency Level", border: OutlineInputBorder()),
                items: ['NORMAL', 'CRITICAL']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(color: u == 'CRITICAL' ? Colors.red : Colors.black))))
                    .toList(),
                onChanged: (val) => setState(() => _urgency = val!),
              ),
              const SizedBox(height: 16),

              // 📝 Reason / Note
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Patient Condition / Note", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 30),

              // ✅ Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("POST BLOOD REQUEST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}