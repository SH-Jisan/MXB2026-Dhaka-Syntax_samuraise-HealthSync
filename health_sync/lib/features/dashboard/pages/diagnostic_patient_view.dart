import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../upload/widgets/upload_buttom_sheet.dart';

class DiagnosticPatientView extends StatefulWidget {
  final Map<String, dynamic> patient;

  const DiagnosticPatientView({super.key, required this.patient});

  @override
  State<DiagnosticPatientView> createState() => _DiagnosticPatientViewState();
}

class _DiagnosticPatientViewState extends State<DiagnosticPatientView> {
  // টেস্ট লিস্ট রাখার জন্য
  List<Map<String, dynamic>> _availableTests = [];
  bool _isTestsLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTests(); // পেজ লোড হলেই টেস্ট লিস্ট আনবে
  }

  // 📥 ১. ডাটাবেস থেকে টেস্ট এবং দাম নিয়ে আসা
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

  // 🆕 ২. নতুন অর্ডার তৈরি (Dropdown + Auto Price সহ)
  Future<void> _createNewOrder() async {
    // সিলেক্ট করা টেস্টগুলো এখানে জমা হবে
    final List<String> selectedTestNames = [];
    double currentTotal = 0;

    final amountController = TextEditingController();

    // টেস্ট লোড না হয়ে থাকলে আবার ট্রাই করবে
    if (_availableTests.isEmpty) {
      await _fetchTests();
    }
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        // ডায়ালগের ভেতর স্টেট চেঞ্জ করার জন্য
        builder: (sbContext, setStateDialog) {
          return AlertDialog(
            title: const Text("New Test Order"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔽 Dropdown Menu
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
                                // লিস্টে নাম যোগ করা
                                if (!selectedTestNames.contains(
                                  selectedTest['name'],
                                )) {
                                  selectedTestNames.add(selectedTest['name']);

                                  // 💰 অটোমেটিক প্রাইস যোগ করা
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

                  // 📋 Selected Tests List (Chips)
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
                                  // ডিলেট করলে প্রাইস কমানোর লজিকটা একটু জটিল হতে পারে যদি মাল্টিপল সেম দামের টেস্ট থাকে।
                                  // সিম্পলিসিটির জন্য ইউজারকে ম্যানুয়ালি এডিট করতে দিচ্ছি অথবা পুরো ক্লিয়ার করতে পারে।
                                  // এখানে আমরা দাম কমাচ্ছি না, ইউজার ম্যানুয়ালি ঠিক করতে পারবে।
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 12),

                  // 💵 Total Amount (Editable)
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

                  // মেইন উইজেটের লোডিং অন করা

                  try {
                    final providerId =
                        Supabase.instance.client.auth.currentUser!.id;

                    await Supabase.instance.client
                        .from('patient_payments')
                        .insert({
                          'patient_id': widget.patient['id'],
                          'provider_id': providerId,
                          'test_names': selectedTestNames, // Array
                          'total_amount':
                              double.tryParse(amountController.text) ?? 0,
                          'paid_amount': 0,
                          'status': 'DUE',
                          'report_status': 'PENDING',
                        });

                    setState(() {}); // UI রিফ্রেশ
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

  // ... (বাকি ফাংশনগুলো যেমন _updatePaymentStatus, _openUploadSheet আগের মতোই থাকবে)
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.patient['full_name'])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewOrder, // 🔥 আপডেটেড ফাংশন কল হচ্ছে
        icon: const Icon(Icons.add_task),
        label: const Text("New Test"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    widget.patient['full_name'][0],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient['email'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      widget.patient['phone'] ?? "No Phone",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Orders List
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
                              ? Colors.orange.shade200
                              : Colors.green.shade200,
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
                                      ? Colors.orange.shade100
                                      : Colors.green.shade100,
                                  labelStyle: TextStyle(
                                    color: isPending
                                        ? Colors.orange.shade900
                                        : Colors.green.shade900,
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

                            // Bill & Actions
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
}
