import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../upload/widgets/upload_bottom_sheet.dart';
import '../providers/diagnostic_work_providers.dart';

class DiagnosticPatientView extends ConsumerStatefulWidget {
  final Map<String, dynamic> patient;

  const DiagnosticPatientView({super.key, required this.patient});

  @override
  ConsumerState<DiagnosticPatientView> createState() =>
      _DiagnosticPatientViewState();
}

class _DiagnosticPatientViewState extends ConsumerState<DiagnosticPatientView> {
  List<Map<String, dynamic>> _availableTests = [];
  bool _isTestsLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    setState(() => _isTestsLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('available_tests')
          .select('id, name, base_price')
          .order('name');

      if (mounted) {
        setState(() {
          _availableTests = List<Map<String, dynamic>>.from(data);
          _isTestsLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading tests: $e");
      setState(() => _isTestsLoading = false);
    }
  }

  Future<void> _createNewOrder({List<String>? initialTests}) async {
    final List<String> selectedTestNames = initialTests != null
        ? List.from(initialTests)
        : [];
    double currentTotal = 0;

    final amountController = TextEditingController();

    // Fetch tests to calculate price if initialTests is provided
    if (_availableTests.isEmpty) {
      await _fetchTests();
    }

    if (initialTests != null) {
      for (var testName in initialTests) {
        final match = _availableTests.firstWhere(
          (t) => t['name'].toString().toLowerCase() == testName.toLowerCase(),
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          currentTotal += (match['base_price'] as num).toDouble();
        }
      }
      amountController.text = currentTotal.toStringAsFixed(0);
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (sbContext, setStateDialog) {
          return AlertDialog(
            title: const Text("New Test Order"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isTestsLoading
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: const InputDecoration(
                            labelText: "Select Test",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medical_services_outlined),
                          ),
                          isExpanded: true,
                          hint: const Text("Choose a test..."),
                          items: _availableTests.map((test) {
                            return DropdownMenuItem(
                              value: test,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      test['name'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "৳${test['base_price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (selectedTest) {
                            if (selectedTest != null) {
                              setStateDialog(() {
                                if (!selectedTestNames.contains(
                                  selectedTest['name'],
                                )) {
                                  selectedTestNames.add(selectedTest['name']);

                                  currentTotal +=
                                      (selectedTest['base_price'] as num)
                                          .toDouble();
                                  amountController.text = currentTotal
                                      .toStringAsFixed(0);
                                }
                              });
                            }
                          },
                        ),

                  const SizedBox(height: 12),

                  if (selectedTestNames.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: selectedTestNames
                          .map(
                            (name) => Chip(
                              label: Text(
                                name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setStateDialog(() {
                                  selectedTestNames.remove(name);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Total Bill Amount",
                      prefixText: "৳ ",
                      border: OutlineInputBorder(),
                      helperText: "Price auto-fills, but you can edit.",
                    ),
                    onChanged: (val) {
                      currentTotal = double.tryParse(val) ?? 0;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedTestNames.isEmpty ||
                      amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a test and check amount"),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext);

                  try {
                    final providerId =
                        Supabase.instance.client.auth.currentUser!.id;

                    await Supabase.instance.client
                        .from('patient_payments')
                        .insert({
                          'patient_id': widget.patient['id'],
                          'provider_id': providerId,
                          'test_names': selectedTestNames,
                          'total_amount':
                              double.tryParse(amountController.text) ?? 0,
                          'paid_amount': 0,
                          'status': 'DUE',
                          'report_status': 'PENDING',
                        });

                    setState(() {});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order Created Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  } finally {}
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("CREATE ORDER"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updatePaymentStatus(String id, String currentStatus) async {
    final newStatus = currentStatus == 'PAID' ? 'DUE' : 'PAID';
    await Supabase.instance.client
        .from('patient_payments')
        .update({'status': newStatus})
        .eq('id', id);
    setState(() {});
  }

  void _openUploadSheet(String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadBottomSheet(
        patientId: widget.patient['id'],
        patientName: widget.patient['full_name'],
      ),
    ).then((_) => _confirmCompletion(orderId));
  }

  Future<void> _confirmCompletion(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mark as Complete?"),
        content: const Text("Did you successfully upload the reports?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Completed"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('patient_payments')
          .update({'report_status': 'COMPLETED'})
          .eq('id', orderId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerId = Supabase.instance.client.auth.currentUser!.id;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.patient['full_name'])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewOrder(),
        icon: const Icon(Icons.add_task),
        label: const Text("New Test"),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: Column(
        children: [
          _buildDoctorOrders(isDark),

          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primary,
                  child: Text(
                    widget.patient['full_name'][0],
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient['email'],
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      widget.patient['phone'] ?? "No Phone",
                      style: TextStyle(
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
          Divider(height: 1, color: isDark ? Colors.grey.shade800 : null),

          Expanded(
            child: FutureBuilder(
              future: Supabase.instance.client
                  .from('patient_payments')
                  .select()
                  .eq('patient_id', widget.patient['id'])
                  .eq('provider_id', providerId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data as List;

                if (orders.isEmpty) {
                  return const Center(child: Text("No tests found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isPending = order['report_status'] == 'PENDING';
                    final isPaid = order['status'] == 'PAID';
                    final tests = List.from(
                      order['test_names'] ?? [],
                    ).join(", ");
                    final date = DateFormat(
                      'dd MMM, hh:mm a',
                    ).format(DateTime.parse(order['created_at']));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isPending
                              ? (isDark
                                    ? Colors.orange.shade700.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.orange.shade200)
                              : (isDark
                                    ? Colors.green.shade700.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.green.shade200),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(order['report_status']),
                                  backgroundColor: isPending
                                      ? (isDark
                                            ? Colors.orange.shade900.withValues(
                                                alpha: 0.3,
                                              )
                                            : Colors.orange.shade100)
                                      : (isDark
                                            ? Colors.green.shade900.withValues(
                                                alpha: 0.3,
                                              )
                                            : Colors.green.shade100),
                                  labelStyle: TextStyle(
                                    color: isPending
                                        ? (isDark
                                              ? Colors.orange.shade300
                                              : Colors.orange.shade900)
                                        : (isDark
                                              ? Colors.green.shade300
                                              : Colors.green.shade900),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tests,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => _updatePaymentStatus(
                                    order['id'],
                                    order['status'],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isPaid
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "৳${order['total_amount']}  ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          isPaid ? "PAID" : "DUE",
                                          style: TextStyle(
                                            color: isPaid
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.edit,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isPending)
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _openUploadSheet(order['id']),
                                    icon: const Icon(
                                      Icons.upload_file,
                                      size: 16,
                                    ),
                                    label: const Text("Upload"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                else
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Done",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorOrders(bool isDark) {
    final doctorOrdersAsync = ref.watch(
      doctorOrdersProvider(widget.patient['id']),
    );

    return doctorOrdersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (orders) {
        if (orders.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_liquid,
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Doctor's Pending Orders",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.blue.shade300
                          : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final tests = List<String>.from(order['key_findings'] ?? []);

                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.blue.shade900
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dr. ${order['uploader']?['full_name'] ?? 'Unknown'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd MMM',
                              ).format(DateTime.parse(order['created_at'])),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            tests.join(", "),
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                _createNewOrder(initialTests: tests),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text(
                              "Create Bill",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
