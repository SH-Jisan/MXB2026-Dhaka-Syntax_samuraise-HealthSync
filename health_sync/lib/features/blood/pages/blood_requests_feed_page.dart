import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/blood_feed_provider.dart';

class BloodRequestsFeedPage extends ConsumerStatefulWidget {
  const BloodRequestsFeedPage({super.key});

  @override
  ConsumerState<BloodRequestsFeedPage> createState() => _BloodRequestsFeedPageState();
}

class _BloodRequestsFeedPageState extends ConsumerState<BloodRequestsFeedPage> {

  // ✅ রক্ত দেওয়ার লজিক (আপডেট করা হয়েছে)
  Future<void> _acceptRequest(String requestId, String requesterPhone) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // ১. এক্সেপ্ট টেবিল এ এন্ট্রি
      await Supabase.instance.client.from('request_acceptors').insert({
        'request_id': requestId,
        'donor_id': user.id,
      });

      // ২. সাকসেস ডায়ালগ
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thank You, Hero! 🦸‍♂️"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("You have accepted to donate blood. Please contact the patient immediately."),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white)),
                  title: Text(requesterPhone, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Tap to call"),
                  onTap: () async {
                    final url = Uri.parse("tel:$requesterPhone");
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(ctx); // ডায়ালগ বন্ধ
                ref.refresh(bloodFeedProvider); // ফিড রিফ্রেশ
              }, child: const Text("CLOSE"))
            ],
          ),
        );
      }
    } on PostgrestException catch (e) {
      // 🔥 ERROR FIX: ডুপ্লিকেট এক্সেপ্ট হ্যান্ডেল করা
      if (e.code == '23505') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You have already accepted this request!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // অন্য কোনো এরর হলে
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unexpected Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(bloodFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Live Blood Requests")),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 10),
                  Text("No pending requests right now!", style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final requester = req['profiles'] ?? {};
              final isCritical = req['urgency'] == 'CRITICAL';
              final acceptedCount = req['accepted_count'] ?? 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isCritical ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              req['blood_group'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (isCritical)
                            const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red, size: 18),
                                SizedBox(width: 4),
                                Text("CRITICAL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(DateTime.parse(req['created_at'])),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Details
                      Text("Patient at: ${req['hospital_name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("Reason: ${req['reason']}", style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 8),

                      // Requester Info
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Requested by: ${requester['full_name'] ?? 'Unknown'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),

                      const Divider(height: 24),

                      // Actions - 🔥 OVERFLOW FIX: Row এর বদলে Wrap ব্যবহার করা হয়েছে
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10, // পাশাপাশি গ্যাপ
                        runSpacing: 10, // নিচে নামলে গ্যাপ
                        children: [
                          // Progress Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal.shade100),
                            ),
                            child: Text(
                              "$acceptedCount / 3 Donors Found",
                              style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // Donate Button
                          ElevatedButton.icon(
                            onPressed: () => _acceptRequest(req['id'], requester['phone'] ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCritical ? Colors.red : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.volunteer_activism),
                            label: const Text("I CAN DONATE"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}