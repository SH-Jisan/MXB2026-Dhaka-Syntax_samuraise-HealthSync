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

  // Medicine Prescription State
  final List<Map<String, String>> _medicines = [
    {'name': '', 'dosage': '', 'duration': '', 'instruction': ''},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAvailableTests();
  }

  Future<void> _fetchAvailableTests() async {
    try {
      final response = await Supabase.instance.client
          .from('available_tests')
          .select('name')
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

  void _showTestOrderDialog(bool isDark) {
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
          builder: (context, setModalState) {
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
                  Row(
                    children: [
                      const Icon(Icons.biotech, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Order Diagnostic Tests",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      ..._selectedTests.map(
                        (test) => Chip(
                          label: Text(test),
                          onDeleted: () =>
                              setModalState(() => _selectedTests.remove(test)),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text("Add Test"),
                        onPressed: () =>
                            _showTestSelectionDialog(setModalState),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedTests.isEmpty
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              await _saveMedicalEvent(
                                title: 'Diagnostic Test Order',
                                type: 'TEST_ORDER',
                                findings: _selectedTests,
                                summary:
                                    'Doctor advised diagnostic tests: ${_selectedTests.join(", ")}',
                              );
                            },
                      child: const Text("SEND TEST ORDER"),
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

  void _showPrescriptionDialog(bool isDark) {
    setState(() {
      _medicines.clear();
      _medicines.add({
        'name': '',
        'dosage': '',
        'duration': '',
        'instruction': '',
      });
    });
    final adviceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          "Write Prescription",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._medicines.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var med = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Medicine Name",
                                    ),
                                    onChanged: (v) => med['name'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Dosage (1+0+1)",
                                    ),
                                    onChanged: (v) => med['dosage'] = v,
                                  ),
                                ),
                                if (_medicines.length > 1)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => setModalState(
                                      () => _medicines.removeAt(idx),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Duration (7 days)",
                                    ),
                                    onChanged: (v) => med['duration'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Instruction (After meal)",
                                    ),
                                    onChanged: (v) => med['instruction'] = v,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setModalState(
                        () => _medicines.add({
                          'name': '',
                          'dosage': '',
                          'duration': '',
                          'instruction': '',
                        }),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Another Medicine"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: adviceCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Medical Advice / Notes",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_medicines.any((m) => m['name']!.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter medicine names"),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          await _saveMedicalEvent(
                            title: 'Prescription',
                            type: 'PRESCRIPTION',
                            summary: adviceCtrl.text,
                            params: {'medicines': _medicines},
                          );
                        },
                        child: const Text("SEND PRESCRIPTION"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveMedicalEvent({
    required String title,
    required String type,
    String? summary,
    List<String>? findings,
    Map<String, dynamic>? params,
  }) async {
    try {
      final doctorId = Supabase.instance.client.auth.currentUser!.id;
      final event = {
        'patient_id': widget.patient['id'],
        'uploader_id': doctorId,
        'title': title,
        'event_type': type,
        'event_date': DateTime.now().toIso8601String(),
        'severity': type == 'TEST_ORDER' ? 'MEDIUM' : 'LOW',
        'summary': summary ?? '',
        'key_findings': findings ?? [],
        ...?params,
      };

      await Supabase.instance.client.from('medical_events').insert(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sent Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(timelineProvider(widget.patient['id']));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
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

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'test_order',
            onPressed: () => _showTestOrderDialog(isDark),
            icon: const Icon(Icons.biotech),
            label: const Text("Order Test"),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'prescription',
            onPressed: () => _showPrescriptionDialog(isDark),
            icon: const Icon(Icons.medication),
            label: const Text("Prescription"),
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            foregroundColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
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
