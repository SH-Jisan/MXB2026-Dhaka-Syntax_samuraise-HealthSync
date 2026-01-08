/// File: lib/features/blood/pages/blood_requests_feed_page.dart
/// Purpose: Displays a real-time feed of blood requests that users can accept.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/blood_feed_provider.dart';
import 'blood_request_page.dart';

/// Feed of active blood requests.
class BloodRequestsFeedPage extends ConsumerStatefulWidget {
  const BloodRequestsFeedPage({super.key});

  @override
  ConsumerState<BloodRequestsFeedPage> createState() =>
      _BloodRequestsFeedPageState();
}

class _BloodRequestsFeedPageState extends ConsumerState<BloodRequestsFeedPage> {
  Future<void> _acceptRequest(String requestId, String requesterPhone) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('request_acceptors').insert({
        'request_id': requestId,
        'donor_id': user.id,
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thank You, Hero! "),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "You have accepted to donate blood. Please contact the patient immediately.",
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                  title: Text(
                    requesterPhone,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)?.tapToCall ?? "Tap to call",
                  ),
                  onTap: () async {
                    final url = Uri.parse("tel:$requesterPhone");
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.invalidate(bloodFeedProvider);
                },
                child: Text(AppLocalizations.of(context)?.close ?? "CLOSE"),
              ),
            ],
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.alreadyAccepted ??
                    "You have accepted this request!",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${AppLocalizations.of(context)?.error ?? 'Error'}: ${e.message}",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)?.unexpectedError ?? 'Unexpected Error: '}$e",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(bloodFeedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.liveBloodRequests ??
              "Live Blood Requests",
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BloodRequestPage()),
          );
        },

        label: Text(
          AppLocalizations.of(context)?.postRequest ?? "Post Request",
        ),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            "${AppLocalizations.of(context)?.error ?? 'Error'}: $err",
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.green.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.noPendingRequests ??
                        "No pending requests right now!",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.caughtUp ??
                        "You are all caught up.",
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final requester = req['profiles'] ?? {};
              final isCritical = req['urgency'] == 'CRITICAL';
              final acceptedCount = req['accepted_count'] ?? 0;
              final neededCount = 3;
              final progress = (acceptedCount / neededCount).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isCritical
                      ? (isDark
                            ? Colors.red.shade900.withValues(alpha: 0.2)
                            : Colors.red.shade50.withValues(alpha: 0.5))
                      : (isDark ? theme.cardTheme.color : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isCritical
                      ? Border.all(
                          color: Colors.red.withValues(
                            alpha: isDark ? 0.5 : 0.3,
                          ),
                          width: 1.5,
                        )
                      : (isDark
                            ? Border.all(color: Colors.grey.shade800)
                            : null),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isCritical
                                    ? [Colors.red.shade600, Colors.red.shade800]
                                    : [
                                        Colors.red.shade400,
                                        Colors.red.shade600,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              req['blood_group'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isCritical)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red.shade800,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )?.criticalUrgency ??
                                              "CRITICAL URGENCY",
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a').format(
                                        DateTime.parse(req['created_at']),
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 20,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              req['hospital_name'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (req['reason'] != null &&
                          req['reason'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCritical
                                ? (isDark ? Colors.black26 : Colors.white)
                                : (isDark
                                      ? Colors.black26
                                      : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notes,
                                size: 16,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${req['reason']}",
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade800,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${AppLocalizations.of(context)?.requestedBy ?? "Requested by "}${requester['full_name'] ?? 'Unknown'}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)?.donorsFound ?? "Donors Found"} ($acceptedCount/$neededCount)",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : Colors.teal.shade700,
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark
                                  ? Colors.teal.shade900
                                  : Colors.teal.shade50,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : Colors.teal,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton.icon(
                            onPressed: () => _acceptRequest(
                              req['id'],
                              requester['phone'] ?? '',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCritical
                                  ? Colors.red.shade600
                                  : (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.primary),
                              foregroundColor: isDark && !isCritical
                                  ? Colors.black
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor:
                                  (isCritical ? Colors.red : AppColors.primary)
                                      .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.volunteer_activism_outlined,
                              size: 20,
                            ),
                            label: Text(
                              AppLocalizations.of(context)?.iCanDonate ??
                                  "I CAN DONATE",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
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
    );
  }
}
