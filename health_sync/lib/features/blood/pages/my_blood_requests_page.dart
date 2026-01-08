/// File: lib/features/blood/pages/my_blood_requests_page.dart
/// Purpose: Shows the user's history of blood requests and accepted donors.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/my_requests_provider.dart';

/// Screen displaying list of blood requests made by the current user.
class MyBloodRequestsPage extends ConsumerWidget {
  const MyBloodRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRequestsAsync = ref.watch(myRequestsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.myRequestsDonors ??
              "My Requests & Donors",
        ),
      ),
      body: myRequestsAsync.when(
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
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_edu,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)?.noRequestsYet ??
                        "No Requests Yet",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.noRequestsPosted ??
                        "You haven't posted any blood requests.",
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
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final acceptors = List<dynamic>.from(
                req['request_acceptors'] ?? [],
              );
              final isCritical = req['urgency'] == 'CRITICAL';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardTheme.color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: isCritical
                      ? Border.all(
                          color: Colors.red.shade100.withValues(
                            alpha: isDark ? 0.2 : 1.0,
                          ),
                          width: 1.5,
                        )
                      : (isDark
                            ? Border.all(color: Colors.grey.shade800)
                            : null),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    childrenPadding: const EdgeInsets.only(bottom: 16),
                    iconColor: isDark ? Colors.white70 : Colors.black54,
                    collapsedIconColor: isDark
                        ? Colors.grey.shade500
                        : Colors.grey,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCritical
                                  ? [Colors.red.shade400, Colors.red.shade700]
                                  : [
                                      isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary,
                                      isDark
                                          ? Colors.teal.shade700
                                          : AppColors.secondary,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isCritical
                                            ? Colors.red
                                            : AppColors.primary)
                                        .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            req['blood_group'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req['hospital_name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'dd MMM, hh:mm a',
                                    ).format(DateTime.parse(req['created_at'])),
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
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            acceptors.isEmpty
                                ? Icons.hourglass_empty
                                : Icons.check_circle,
                            size: 16,
                            color: acceptors.isEmpty
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            acceptors.isEmpty
                                ? (AppLocalizations.of(
                                        context,
                                      )?.waitingForDonors ??
                                      "Waiting for donors...")
                                : "${acceptors.length} ${AppLocalizations.of(context)?.donorsAccepted ?? "Donor(s) Accepted"}",
                            style: GoogleFonts.poppins(
                              color: acceptors.isEmpty
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      if (acceptors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 40,
                                color: Colors.orange.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)?.notifiedDonors ??
                                    "We have notified nearby donors.",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)?.willSeeDetails ??
                                    "You will see their details here once they accept.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...acceptors.map((acceptor) {
                          final profile = acceptor['profiles'];
                          final name = profile['full_name'] ?? 'Unknown Hero';
                          final phone = profile['phone'] ?? '';

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.shade900.withValues(alpha: 0.3)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.green.shade800
                                    : Colors.green.shade100,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: isDark
                                    ? Colors.green.shade800
                                    : Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: isDark
                                      ? Colors.green.shade100
                                      : Colors.green.shade700,
                                ),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                AppLocalizations.of(context)?.heroDonor ??
                                    "Hero Donor",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.green.shade200
                                      : Colors.green.shade700,
                                ),
                              ),
                              trailing: IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.green.shade600,
                                  radius: 20,
                                  child: const Icon(
                                    Icons.call,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () async {
                                  final url = Uri.parse("tel:$phone");
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                            ),
                          );
                        }),
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
