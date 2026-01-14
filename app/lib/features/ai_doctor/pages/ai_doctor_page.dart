import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/pages/doctor_list_page.dart';
import '../../../l10n/app_localizations.dart';

class AiDoctorPage extends ConsumerStatefulWidget {
  const AiDoctorPage({super.key});

  @override
  ConsumerState<AiDoctorPage> createState() => _AiDoctorPageState();
}

class _AiDoctorPageState extends ConsumerState<AiDoctorPage> {
  final _stt = stt.SpeechToText();
  bool _isListening = false;
  final _textController = TextEditingController();

  
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
          _aiResult = response.data; 
        });
      } else {
        throw Exception("Failed to analyze");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)?.error ?? 'Error'}: $e",
            ),
          ),
        );
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.aiHealthAssistant ??
              "AI Health Assistant",
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)?.describeSymptomsHint ??
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
                    : Text(
                        AppLocalizations.of(context)?.consultAiDoctor ??
                            "CONSULT AI DOCTOR",
                      ),
              ),
            ),

            const SizedBox(height: 24),

            
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
            
            Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.aiDiagnosis ?? "AI Diagnosis",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

            
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.possibleCondition ??
                  "Possible Condition:",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              condition,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            
            if (causes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)?.potentialCauses ??
                    "Potential Causes (Why?):",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              
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

            
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.recommendedSpecialist ??
                  "Recommended Specialist:",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              specialty,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)?.immediateAdvice ??
                  "Immediate Advice:",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              data['advice'] ?? '',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),

            
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
                label: Text(
                  AppLocalizations.of(context)?.findSpecialistNow(specialty) ??
                      "FIND $specialty NOW",
                ),
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
