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
  bool _isBangla = false;
  Map<String, dynamic>? _healthPlan;

  
  Future<void> _generateHealthPlan() async {
    setState(() => _isLoading = true);
    _healthPlan = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final List<dynamic> historyResponse = await Supabase.instance.client
          .from('medical_events')
          .select('title, event_type, severity, summary')
          .eq('patient_id', user.id)
          .order('event_date', ascending: false)
          .limit(10);

      if (historyResponse.isEmpty) {
        setState(() {
          _healthPlan = {
            'summary': _isBangla
                ? "আপনার কোনো মেডিকেল রেকর্ড পাওয়া যায়নি। রিপোর্ট আপলোড করার পর আবার চেষ্টা করুন।"
                : "No medical records found. Please upload a report first.",
            'diet': _isBangla
                ? "সাধারণ সুষম খাবার গ্রহণ করুন।"
                : "Maintain a balanced diet.",
            'exercise': _isBangla
                ? "প্রতিদিন ৩০ মিনিট হাঁটুন।"
                : "Walk for 30 minutes daily.",
            'precautions': _isBangla
                ? "কোনো সমস্যা হলে ডাক্তারের পরামর্শ নিন।"
                : "Consult a doctor if you feel unwell.",
          };
        });
        return;
      }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isBangla ? "স্বাস্থ্য রুটিন" : "Health Plan"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _isBangla ? "বাংলা" : "English",
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isBangla,
                  activeTrackColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() => _isBangla = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _healthPlan == null && !_isLoading
          ? _buildWelcomeState(isDark)
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPlanContent(isDark),
    );
  }

  Widget _buildWelcomeState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.teal.shade900.withValues(alpha: 0.3)
                    : Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 80,
                color: isDark ? AppColors.darkPrimary : Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isBangla
                  ? "আপনার ব্যক্তিগত স্বাস্থ্য রুটিন তৈরি করুন"
                  : "Generate Your Personalized Health Plan",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isBangla
                  ? "AI আপনার মেডিকেল ইতিহাস বিশ্লেষণ করে ডায়েট এবং ব্যায়ামের পরামর্শ দিবে।"
                  : "AI will analyze your medical history to suggest a custom diet and exercise routine.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateHealthPlan,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  _isBangla ? "রুটিন তৈরি করুন" : "Generate Plan",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : Colors.teal,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.teal.shade900, Colors.teal.shade800]
                    : [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.primary).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.health_and_safety_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBangla ? "স্বাস্থ্য সারাংশ" : "Health Summary",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _healthPlan?['summary'] ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(
            Icons.restaurant_menu,
            _isBangla ? "খাদ্যাভ্যাস (Diet)" : "Diet Plan",
            Colors.green,
            isDark,
          ),
          _buildCard(_healthPlan?['diet'] ?? '', Colors.green, isDark),

          _buildSectionTitle(
            Icons.fitness_center,
            _isBangla ? "ব্যায়াম (Exercise)" : "Exercise Routine",
            Colors.blue,
            isDark,
          ),
          _buildCard(_healthPlan?['exercise'] ?? '', Colors.blue, isDark),

          _buildSectionTitle(
            Icons.warning_amber_rounded,
            _isBangla ? "সতর্কতা (Precautions)" : "Precautions",
            Colors.orange,
            isDark,
          ),
          _buildCard(
            _healthPlan?['precautions'] ?? '',
            Colors.orange,
            isDark,
            isWarning: true,
          ),

          const SizedBox(height: 32),
          Center(
            child: OutlinedButton.icon(
              onPressed: _generateHealthPlan,
              icon: const Icon(Icons.refresh),
              label: Text(_isBangla ? "নতুন করে তৈরি করুন" : "Regenerate Plan"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                foregroundColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    IconData icon,
    String title,
    Color color,
    bool isDark,
  ) {
    final displayColor = isDark ? color.withValues(alpha: 0.8) : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: displayColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: displayColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String content,
    Color accentColor,
    bool isDark, {
    bool isWarning = false,
  }) {
    final borderColor = isWarning
        ? (isDark
              ? accentColor.withValues(alpha: 0.5)
              : accentColor.withValues(alpha: 0.3))
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);

    
    final textColor = isWarning
        ? (isDark ? accentColor.withValues(alpha: 0.9) : Colors.orange.shade900)
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(fontSize: 15, height: 1.6, color: textColor),
      ),
    );
  }
}
