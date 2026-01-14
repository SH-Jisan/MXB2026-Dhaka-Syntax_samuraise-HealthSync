/// File: lib/features/blood/pages/donor_search_page.dart
/// Purpose: Interface for searching blood donors by group and location.
/// Author: HealthSync Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/donor_provider.dart';

/// Screen to find donors based on blood group and district.
class DonorSearchPage extends ConsumerStatefulWidget {
  const DonorSearchPage({super.key});

  @override
  ConsumerState<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends ConsumerState<DonorSearchPage> {
  String? _selectedBloodGroup;
  final _districtController = TextEditingController();

  void _callDonor(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotLaunchDialer ??
                  "Could not launch dialer",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = DonorFilter(
      bloodGroup: _selectedBloodGroup,
      district: _districtController.text.trim(),
    );

    final donorsAsync = ref.watch(donorSearchProvider(filter));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.findBloodDonors ?? "Find Blood Donors",
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardTheme.color : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBloodGroup,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? AppColors.darkSurface
                            : Colors.white,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.group ?? "Group",
                          prefixIcon: const Icon(
                            Icons.bloodtype,
                            color: Colors.red,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 14,
                          ),
                        ),
                        items:
                            ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      g,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedBloodGroup = v),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: TextField(
                        controller: _districtController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.districtHint ??
                              "District (e.g. Dhaka)",
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: _districtController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _districtController.clear();
                                    setState(() {});
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              : null,
                        ),
                        onSubmitted: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context)?.searchDonors ??
                            "SEARCH DONORS",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: donorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "${AppLocalizations.of(context)?.error ?? 'Error'}: $err",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (donors) {
                if (donors.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 80,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)?.noDonorsFound ??
                                "No donors found",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.tryChangingLocation ??
                                "Try changing the location or blood group.",
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    final profile = donor['profiles'] ?? {};
                    final name =
                        profile['full_name'] ??
                        AppLocalizations.of(context)?.unknownDonor ??
                        'Unknown Donor';
                    final lastDate = donor['last_donation_date'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardTheme.color : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.red.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                profile['blood_group'] ?? '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          profile['district'] ??
                                              AppLocalizations.of(
                                                context,
                                              )?.unknown ??
                                              'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (lastDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      "${AppLocalizations.of(context)?.lastDonated ?? "Last donated: "}$lastDate",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _callDonor(profile['phone'] ?? ''),
                                borderRadius: BorderRadius.circular(50),
                                child: Ink(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.green.shade900.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.green.shade50,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.green.shade700
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    color: isDark
                                        ? Colors.green.shade300
                                        : Colors.green.shade700,
                                    size: 22,
                                  ),
                                ),
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
