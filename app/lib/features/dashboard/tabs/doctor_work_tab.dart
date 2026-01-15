import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../pages/doctor_patient_profile_page.dart';
import '../pages/doctor_appointments_page.dart';
import '../providers/doctor_work_providers.dart';
import '../../../l10n/app_localizations.dart';

class DoctorWorkTab extends ConsumerWidget {
  const DoctorWorkTab({super.key});

  void _addHospital(BuildContext context, WidgetRef ref, String doctorId) {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.addHospital ?? "Add Hospital",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.hospitalName ??
                    "Hospital Name",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeCtrl,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.visitingHours ??
                    "Visiting Hours",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.cancel ?? "Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final supabase = Supabase.instance.client;
                final navigator = Navigator.of(ctx);

                await supabase.from('doctor_hospitals').insert({
                  'doctor_id': doctorId,
                  'hospital_name': nameCtrl.text,
                  'visiting_hours': timeCtrl.text,
                });

                ref.invalidate(doctorChambersProvider(doctorId));
                navigator.pop();
              }
            },
            child: Text(AppLocalizations.of(context)?.add ?? "Add"),
          ),
        ],
      ),
    );
  }

  void _searchAndAddPatient(
    BuildContext context,
    WidgetRef ref,
    String doctorId,
  ) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.addNewPatient ?? "Add New Patient",
        ),
        content: TextField(
          controller: emailCtrl,
          decoration: InputDecoration(
            labelText:
                AppLocalizations.of(context)?.patientEmail ?? "Patient Email",
            hintText:
                AppLocalizations.of(context)?.enterEmailSearch ?? "Enter email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.cancel ?? "Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = Supabase.instance.client;
              final l10n = AppLocalizations.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final data = await supabase
                    .from('profiles')
                    .select('id')
                    .eq('email', emailCtrl.text.trim())
                    .maybeSingle();

                if (data != null) {
                  await supabase.from('doctor_patients').insert({
                    'doctor_id': doctorId,
                    'patient_id': data['id'],
                  });
                  ref.invalidate(doctorPatientsProvider(doctorId));
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n?.patientAddedSuccess ?? "Success"),
                      ),
                    );
                  }
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n?.userNotFound ?? "Not found")),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n?.alreadyAssignedOrError ?? "Error"),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)?.addNewPatient ?? "Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctorId = Supabase.instance.client.auth.currentUser!.id;

    final chambersAsync = ref.watch(doctorChambersProvider(doctorId));
    final patientsAsync = ref.watch(doctorPatientsProvider(doctorId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(doctorChambersProvider(doctorId));
        ref.invalidate(doctorPatientsProvider(doctorId));
        await Future.wait([
          ref.read(doctorChambersProvider(doctorId).future),
          ref.read(doctorPatientsProvider(doctorId).future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorAppointmentsPage(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.darkPrimary.withValues(alpha: 0.8),
                              AppColors.darkPrimary.withValues(alpha: 0.6),
                            ]
                          : [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Manage Appointments",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "View and respond to patient requests",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.currentChambers ??
                        "Current Chambers",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _addHospital(context, ref, doctorId),
                    icon: Icon(
                      Icons.add_circle,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: chambersAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => const SizedBox.shrink(),
              data: (hospitals) {
                if (hospitals.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)?.noHospitalsAdded ??
                          "No hospitals",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.grey,
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final h = hospitals[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_hospital,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              h['hospital_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              h['visiting_hours'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.underTreatment ??
                        "Under Treatment",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _searchAndAddPatient(context, ref, doctorId),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: Text(
                      AppLocalizations.of(context)?.newPatient ?? "New Patient",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.secondary,
                      foregroundColor: isDark
                          ? AppColors.textPrimary
                          : Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
          patientsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (list) {
              if (list.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 48,
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.noPatientsAssigned ??
                                "No patients",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final patient = list[index]['profiles'];
                    return Card(
                      elevation: isDark ? 0 : 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary.withValues(alpha: 0.5)
                              : AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primary,
                          child: Text(patient['full_name'][0]),
                        ),
                        title: Text(
                          patient['full_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "Phone: ${patient['phone'] ?? 'N/A'}",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DoctorPatientProfilePage(patient: patient),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: list.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
