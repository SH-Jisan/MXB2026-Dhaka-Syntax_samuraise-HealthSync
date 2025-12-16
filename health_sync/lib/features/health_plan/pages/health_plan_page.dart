import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class HealthPlanPage extends StatefulWidget {
  const HealthPlanPage({super.key});

  @override
  State<HealthPlanPage> createState() => _HealthPlanPageState();
}

class _HealthPlanPageState extends State<HealthPlanPage> {
  bool _isLoading = false;
  bool _isBangla = false; // ভাষা পরিবর্তনের জন্য
  Map<String, dynamic>? _healthPlan; // AI এর রেসপন্স এখানে থাকবে

  // AI Function Call
  Future<void> _generateHealthPlan() async {
    setState(() => _isLoading = true);
    _healthPlan = null; // আগের প্ল্যান ক্লিয়ার করা

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // ১. ডাটাবেস থেকে ডাটা আনা (সঠিক কলাম নাম ব্যবহার করবেন, যেমন 'patient_id' বা 'user_id')
      final List<dynamic> historyResponse = await Supabase.instance.client
          .from('medical_events')
          .select('title, event_type, severity, summary')
          .eq('patient_id', user.id) // ⚠️ আপনার টেবিলের সঠিক কলাম নাম দিন
          .order('event_date', ascending: false)
          .limit(10);

      // 🔥 FIX: যদি কোনো হিস্ট্রি না থাকে, তাহলে AI কল করার দরকার নেই
      if (historyResponse.isEmpty) {
        setState(() {
          _healthPlan = {
            'summary': _isBangla
                ? "আপনার কোনো মেডিকেল রেকর্ড পাওয়া যায়নি। রিপোর্ট আপলোড করার পর আবার চেষ্টা করুন।"
                : "No medical records found. Please upload a report first.",
            'diet': _isBangla ? "সাধারণ সুষম খাবার গ্রহণ করুন।" : "Maintain a balanced diet.",
            'exercise': _isBangla ? "প্রতিদিন ৩০ মিনিট হাঁটুন।" : "Walk for 30 minutes daily.",
            'precautions': _isBangla ? "কোনো সমস্যা হলে ডাক্তারের পরামর্শ নিন।" : "Consult a doctor if you feel unwell."
          };
        });
        return;
      }

      // ২. Edge Function কল করা (ডাটা থাকলে)
      final response = await Supabase.instance.client.functions.invoke(
        'generate-health-plan',
        body: {
          'history': historyResponse,
          'language': _isBangla ? 'bangla' : 'english',
        },
      );

      if (response.status == 200) {
        setState(() {
          _healthPlan = response.data;
        });
      } else {
        throw "Server Error: ${response.status}";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(_isBangla ? "স্বাস্থ্য রুটিন" : "Health Plan"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Language Toggle Switch
          Row(
            children: [
              Text(_isBangla ? "বাংলা" : "English", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              Switch(
                value: _isBangla,
                activeColor: Colors.teal,
                onChanged: (val) {
                  setState(() => _isBangla = val);
                },
              ),
            ],
          ),
        ],
      ),
      body: _healthPlan == null && !_isLoading
          ? _buildWelcomeState()
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPlanContent(),
    );
  }

  // ১. যখন কোনো প্ল্যান জেনারেট করা হয়নি
  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              _isBangla
                  ? "আপনার ব্যক্তিগত স্বাস্থ্য রুটিন তৈরি করুন"
                  : "Generate Your Personalized Health Plan",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _isBangla
                  ? "AI আপনার মেডিকেল ইতিহাস বিশ্লেষণ করে ডায়েট এবং ব্যায়ামের পরামর্শ দিবে।"
                  : "AI will analyze your medical history to suggest diet and exercises.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _generateHealthPlan,
              icon: const Icon(Icons.auto_awesome),
              label: Text(_isBangla ? "রুটিন তৈরি করুন" : "Generate Plan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ২. প্ল্যান দেখানোর ডিজাইন
  Widget _buildPlanContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _isBangla ? "স্বাস্থ্য সারাংশ" : "Health Summary",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _healthPlan?['summary'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle(Icons.restaurant, _isBangla ? "খাদ্যাভ্যাস (Diet)" : "Diet Plan"),
          _buildCard(_healthPlan?['diet'] ?? ''),

          _buildSectionTitle(Icons.directions_run, _isBangla ? "ব্যায়াম (Exercise)" : "Exercise Routine"),
          _buildCard(_healthPlan?['exercise'] ?? ''),

          _buildSectionTitle(Icons.warning_amber, _isBangla ? "সতর্কতা (Precautions)" : "Precautions"),
          _buildCard(_healthPlan?['precautions'] ?? '', isWarning: true),

          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: _generateHealthPlan,
              icon: const Icon(Icons.refresh),
              label: Text(_isBangla ? "নতুন করে তৈরি করুন" : "Regenerate Plan"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(String content, {bool isWarning = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? Colors.orange.shade200 : Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 15, height: 1.5, color: isWarning ? Colors.orange.shade900 : Colors.black87),
      ),
    );
  }
}