import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/pages/doctor_list_page.dart'; // 🔥 Fixed Import

class AiDoctorPage extends ConsumerStatefulWidget {
  const AiDoctorPage({super.key});

  @override
  ConsumerState<AiDoctorPage> createState() => _AiDoctorPageState();
}

class _AiDoctorPageState extends ConsumerState<AiDoctorPage> {
  final _stt = stt.SpeechToText();
  bool _isListening = false;
  final _textController = TextEditingController();

  // রেজাল্ট রাখার ভেরিয়েবল
  Map<String, dynamic>? _aiResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _stt.initialize();
    if (mounted) setState(() {});
  }

  // 🎤 ভয়েস লিসেনিং শুরু/বন্ধ
  void _listen() async {
    if (!_isListening) {
      bool available = await _stt.initialize();
      if (available) {
        setState(() => _isListening = true);
        _stt.listen(
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _stt.stop();
    }
  }

  // 🧠 সার্ভারে পাঠানো
  Future<void> _consultAI() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResult = null;
    });

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'triage-symptoms',
        body: {'symptoms': _textController.text, 'location': 'Dhaka'},
      );

      if (response.status == 200) {
        setState(() {
          _aiResult = response.data; // JSON ডাটা
        });
      } else {
        throw Exception("Failed to analyze");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Health Assistant")),
      // 🔥 ফিক্স: SingleChildScrollView যোগ করা হয়েছে overflow এড়াতে
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. ইনপুট সেকশন
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    "Describe your symptoms (e.g., 'Severe chest pain on left side')...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  onPressed: _listen,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _consultAI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CONSULT AI DOCTOR"),
              ),
            ),

            const SizedBox(height: 24),

            // 2. রেজাল্ট সেকশন (কার্ড)
            if (_aiResult != null) ...[_buildResultCard()],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final data = _aiResult!;
    final specialty = data['specialty'] ?? 'GENERAL_PHYSICIAN';
    final urgency = data['urgency'] ?? 'LOW';
    final condition = data['condition'] ?? 'Unknown';

    // 🔥 নতুন: কারণগুলো লিস্ট আকারে নেওয়া
    final causes = List<String>.from(data['potential_causes'] ?? []);

    Color color = urgency == 'HIGH'
        ? Colors.red.shade100
        : Colors.green.shade100;
    Color textColor = urgency == 'HIGH' ? Colors.red : Colors.green;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  "AI Diagnosis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    urgency,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // 1. Condition
            const SizedBox(height: 8),
            const Text(
              "Possible Condition:",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              condition,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // 🔥 2. Potential Causes (NEW SECTION)
            if (causes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Potential Causes (Why?):",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              // লিস্ট আইটেমগুলো লুপ করে দেখানো
              ...causes.map(
                (cause) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          cause,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // 3. Specialist
            const SizedBox(height: 12),
            const Text(
              "Recommended Specialist:",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              specialty,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 4. Advice
            const SizedBox(height: 12),
            const Text(
              "Immediate Advice:",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              data['advice'] ?? '',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),

            // 5. Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final internetDocs = data['internet_doctors'] ?? [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorListPage(
                        specialty: specialty,
                        internetDoctors: internetDocs,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: Text("FIND $specialty NOW"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
