import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // কল করার জন্য
import '../../../core/constants/app_colors.dart';
import '../providers/donor_provider.dart';

class DonorSearchPage extends ConsumerStatefulWidget {
  const DonorSearchPage({super.key});

  @override
  ConsumerState<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends ConsumerState<DonorSearchPage> {
  String? _selectedBloodGroup;
  final _districtController = TextEditingController();

  // 📞 কল করার ফাংশন
  void _callDonor(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch dialer")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ফিল্টার অবজেক্ট তৈরি
    final filter = DonorFilter(
      bloodGroup: _selectedBloodGroup,
      district: _districtController.text.trim(),
    );

    // প্রোভাইডার ওয়াচ করা (ফিল্টার পাল্টালে অটোমেটিক সার্চ হবে)
    final donorsAsync = ref.watch(donorSearchProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text("Find Blood Donors")),
      body: Column(
        children: [
          // 🔍 SEARCH FILTERS SECTION
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              children: [
                // Blood Group Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: "Select Blood Group",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                ),
                const SizedBox(height: 10),

                // District Search
                TextField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: "Search by District (e.g. Dhaka)",
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _districtController.clear();
                        setState(() {}); // ক্লিয়ার করলে রিবিল্ড হবে
                      },
                    ),
                  ),
                  onSubmitted: (_) => setState(() {}), // এন্টার চাপলে সার্চ
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() {}), // সার্চ বাটন
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text("SEARCH DONORS"),
                  ),
                )
              ],
            ),
          ),

          // 📋 RESULTS LIST
          Expanded(
            child: donorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (donors) {
                if (donors.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bloodtype_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No donors found matching criteria."),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    final profile = donor['profiles'] ?? {}; // প্রোফাইল ডাটা
                    final name = profile['full_name'] ?? 'Unknown Donor';
                    final lastDate = donor['last_donation_date'];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Blood Group Badge
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                donor['blood_group'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      Text(donor['district'], style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  if (lastDate != null)
                                    Text("Last donated: $lastDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),

                            // Call Button
                            IconButton(
                              onPressed: () => _callDonor(donor['phone']),
                              icon: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.call, color: Colors.white, size: 20),
                              ),
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