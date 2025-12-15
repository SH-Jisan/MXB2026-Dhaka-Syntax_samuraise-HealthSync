import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/my_requests_provider.dart';

class MyBloodRequestsPage extends ConsumerWidget {
  const MyBloodRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRequestsAsync = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Requests & Donors")),
      body: myRequestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text("You haven't posted any requests yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final acceptors = List<dynamic>.from(req['request_acceptors'] ?? []);
              final isCritical = req['urgency'] == 'CRITICAL';
              final isOpen = req['status'] == 'OPEN';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCritical ? Colors.red.shade100 : Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          req['blood_group'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCritical ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['hospital_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(req['created_at'])),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      acceptors.isEmpty
                          ? "Waiting for donors..."
                          : "${acceptors.length} Donor(s) Accepted ✅",
                      style: TextStyle(
                          color: acceptors.isEmpty ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  children: [
                    if (acceptors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No one has accepted yet. Don't worry, notifications are sent!"),
                      )
                    else
                      ...acceptors.map((acceptor) {
                        final profile = acceptor['profiles'];
                        final name = profile['full_name'] ?? 'Unknown Hero';
                        final phone = profile['phone'] ?? '';

                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.teal),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Click to call"),
                          trailing: IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 18,
                              child: Icon(Icons.call, color: Colors.white, size: 18),
                            ),
                            onPressed: () async {
                              final url = Uri.parse("tel:$phone");
                              if (await canLaunchUrl(url)) await launchUrl(url);
                            },
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}