import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../timeline/pages/medical_timeline_view.dart';
import '../../timeline/providers/timeline_provider.dart';

class DoctorPatientProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> patient;

  const DoctorPatientProfilePage({super.key, required this.patient});

  @override
  ConsumerState<DoctorPatientProfilePage> createState() =>
      _DoctorPatientProfilePageState();
}

class _DoctorPatientProfilePageState
    extends ConsumerState<DoctorPatientProfilePage> {
  final List<String> _selectedTests = [];
  List<String> _allAvailableTests = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableTests();
  }

  // ১. টেস্ট লিস্ট লোড (Fix: 'name' কলাম ব্যবহার করা হচ্ছে)
  Future<void> _fetchAvailableTests() async {
    try {
      final response = await Supabase.instance.client
          .from('available_tests')
          .select('name') // 🔥 FIX: test_name -> name
          .order('name');

      if (mounted) {
        setState(() {
          _allAvailableTests = (response as List)
              .map((e) => e['name'] as String)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading tests: $e");
    }
  }

  // ২. টেস্ট সিলেকশন ডায়ালগ
  void _showTestSelectionDialog(StateSetter updateModalState) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredTests = _allAvailableTests
                .where(
                  (test) =>
                      test.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return AlertDialog(
              title: const Text("Select Tests"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "Search (e.g. CBC)",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setStateDialog(() => searchQuery = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredTests.isEmpty
                          ? const Center(
                              child: Text("No tests found. Run SQL."),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredTests.length,
                              itemBuilder: (context, index) {
                                final testName = filteredTests[index];
                                final isSelected = _selectedTests.contains(
                                  testName,
                                );

                                return CheckboxListTile(
                                  title: Text(testName),
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setStateDialog(() {
                                      if (val == true) {
                                        if (!_selectedTests.contains(
                                          testName,
                                        )) {
                                          _selectedTests.add(testName);
                                        }
                                      } else {
                                        _selectedTests.remove(testName);
                                      }
                                    });
                                    updateModalState(() {});
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ৩. টেস্ট অ্যাসাইন ডায়ালগ
  void _showAssignTestDialog(bool isDark) {
    final notesCtrl = TextEditingController();
    setState(() => _selectedTests.clear());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assign Tests & Advice",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Selected Tests:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      ..._selectedTests.map(
                        (test) => Chip(
                          label: Text(test),
                          backgroundColor: isDark
                              ? AppColors.darkPrimary.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                          onDeleted: () {
                            setModalState(() {
                              _selectedTests.remove(test);
                            });
                          },
                        ),
                      ),
                      ActionChip(
                        avatar: Icon(
                          Icons.add,
                          size: 18,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                        label: Text(
                          "Add Test",
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        onPressed: () {
                          _showTestSelectionDialog(setModalState);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Clinical Notes / Additional Advice",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_selectedTests.isEmpty && notesCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select a test or add a note.",
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        try {
                          final doctorId =
                              Supabase.instance.client.auth.currentUser!.id;
                          final testsString = _selectedTests.join(", ");

                          await Supabase.instance.client.from('medical_events').insert({
                            'patient_id': widget.patient['id'],
                            'uploader_id': doctorId,
                            'title': _selectedTests.isNotEmpty
                                ? 'Test Assigned: ${_selectedTests.length}'
                                : 'Doctor Advice',
                            'event_type': 'PRESCRIPTION',
                            'event_date': DateTime.now().toIso8601String(),
                            'severity': 'MEDIUM',
                            'summary':
                                'Assigned Tests: $testsString. \nAdvice: ${notesCtrl.text}',
                            'key_findings': _selectedTests,
                            'extracted_text':
                                "Tests Assigned:\n$testsString\n\nNotes:\n${notesCtrl.text}",
                          });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Prescription Sent Successfully!",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // 🔥 টাইমলাইন রিফ্রেশ
                            ref.invalidate(
                              timelineProvider(widget.patient['id']),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("CONFIRM & ASSIGN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(widget.patient['full_name'] ?? 'Patient Profile'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignTestDialog(isDark),
        icon: const Icon(Icons.add_task),
        label: const Text("Assign Test"),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),

      body: Column(
        children: [
          // Patient Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary,
                  child: Text(
                    widget.patient['full_name'] != null
                        ? widget.patient['full_name'][0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      fontSize: 24,
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient['full_name'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.patient['email'] ?? '',
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    if (widget.patient['phone'] != null)
                      Text(
                        widget.patient['phone'],
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Timeline Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.history_edu,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Medical History & Reports",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // 🔥 Timeline View (এটি Red Screen ফিক্স করবে)
          Expanded(
            child: MedicalTimelineView(
              patientId: widget.patient['id'],
              isEmbedded: true,
            ),
          ),
        ],
      ),
    );
  }
}
