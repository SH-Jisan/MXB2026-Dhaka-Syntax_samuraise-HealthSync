/// File: lib/features/blood/pages/hospital_blood_bank_page.dart
/// Purpose: Manages hospital's blood inventory stock.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Dashboard for hospitals to update and view their blood stock.
class HospitalBloodBankPage extends StatefulWidget {
  const HospitalBloodBankPage({super.key});

  @override
  State<HospitalBloodBankPage> createState() => _HospitalBloodBankPageState();
}

class _HospitalBloodBankPageState extends State<HospitalBloodBankPage> {
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  final int _maxStock = 999;

  Map<String, int> _inventory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('hospital_inventory')
          .select()
          .eq('hospital_id', user.id);

      final Map<String, int> loadedData = {};

      for (final item in data) {
        final String group = item['blood_group'] as String;
        final int qty = item['quantity'] as int? ?? 0;
        loadedData[group] = qty;
      }

      if (mounted) {
        setState(() {
          _inventory = loadedData;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint(" Error fetching inventory: $e");
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to load inventory. Please check your connection.",
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateStock(String bg, int change) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final previousQty = _inventory[bg] ?? 0;
    final newQty = previousQty + change;

    if (newQty < 0 || newQty > _maxStock) return;

    setState(() => _inventory[bg] = newQty);

    try {
      await Supabase.instance.client.from('hospital_inventory').upsert({
        'hospital_id': user.id,
        'blood_group': bg,
        'quantity': newQty,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'hospital_id,blood_group');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$bg stock updated to $newQty bags"),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      setState(() => _inventory[bg] = previousQty);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update $bg stock"),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hospital Blood Bank"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInventory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bloodGroups.length,
                itemBuilder: (context, index) {
                  final bg = _bloodGroups[index];
                  final qty = _inventory[bg] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              bg,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Available Stock",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "$qty Bags",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _updateStock(bg, -1),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _updateStock(bg, 1),
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
