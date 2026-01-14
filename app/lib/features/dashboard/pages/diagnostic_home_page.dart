import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import '../providers/diagnostic_work_providers.dart';
import 'diagnostic_patient_view.dart';

class DiagnosticHomePage extends ConsumerStatefulWidget {
  const DiagnosticHomePage({super.key});

  @override
  ConsumerState<DiagnosticHomePage> createState() => _DiagnosticHomePageState();
}

class _DiagnosticHomePageState extends ConsumerState<DiagnosticHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _searchedPatient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _searchPatient() async {
    if (_searchController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchedPatient = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('email', _searchController.text.trim())
          .eq('role', 'CITIZEN')
          .maybeSingle();
      if (mounted) {
        if (data != null) {
          setState(() => _searchedPatient = data);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Patient not found!")));
          _showRegistrationDialog(
            preFilledEmail: _searchController.text.trim(),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _assignPatient() async {
    if (_searchedPatient == null) return;
    setState(() => _isLoading = true);
    final diagnosticId = Supabase.instance.client.auth.currentUser!.id;
    try {
      await Supabase.instance.client.from('diagnostic_patients').insert({
        'diagnostic_id': diagnosticId,
        'patient_id': _searchedPatient!['id'],
      });
      ref.invalidate(diagnosticPatientsProvider(diagnosticId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assigned Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _tabController.animateTo(0);
        setState(() {
          _searchedPatient = null;
          _searchController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error or Already Assigned: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerNewPatient() async {
    if (_emailController.text.isEmpty) return;
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.rpc(
        'create_dummy_user',
        params: {
          'u_email': _emailController.text.trim(),
          'u_password': '123456',
          'u_name': _nameController.text.trim(),
          'u_phone': _phoneController.text.trim(),
          'u_role': 'CITIZEN',
          'u_address': '',
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registered!"),
            backgroundColor: Colors.green,
          ),
        );
        _searchController.text = _emailController.text.trim();
        _searchPatient();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRegistrationDialog({String? preFilledEmail}) {
    _emailController.text = preFilledEmail ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Register Patient"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: _registerNewPatient,
            child: const Text("REGISTER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diagnosticId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Diagnostic Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          tabs: const [
            Tab(text: "Assigned"),
            Tab(text: "Pending"),
            Tab(text: "Search"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(diagnosticPatientsProvider(diagnosticId));
              ref.invalidate(pendingReportsProvider(diagnosticId));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignedPatientsTab(isDark, diagnosticId),
          _buildPendingReportsTab(isDark, diagnosticId),
          _buildSearchTab(isDark),
        ],
      ),
    );
  }

  Widget _buildAssignedPatientsTab(bool isDark, String diagnosticId) {
    final patientsAsync = ref.watch(diagnosticPatientsProvider(diagnosticId));

    return patientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text("No assigned patients. Go to Search tab."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final patient = list[index]['profiles'];
            if (patient == null) return const SizedBox.shrink();

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary.withValues(alpha: 0.2)
                      : null,
                  child: Text(
                    patient['full_name'][0],
                    style: TextStyle(
                      color: isDark ? AppColors.darkPrimary : null,
                    ),
                  ),
                ),
                title: Text(
                  patient['full_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(patient['phone'] ?? patient['email']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagnosticPatientView(patient: patient),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingReportsTab(bool isDark, String diagnosticId) {
    final pendingAsync = ref.watch(pendingReportsProvider(diagnosticId));

    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (pendingOrders) {
        if (pendingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 60, color: Colors.green.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Great! No pending reports.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingOrders.length,
          itemBuilder: (context, index) {
            final order = pendingOrders[index];
            final patient = order['profiles'];
            final tests = List.from(order['test_names'] ?? []).join(", ");
            final date = DateFormat(
              'dd MMM, hh:mm a',
            ).format(DateTime.parse(order['created_at']));

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? Colors.orange.shade700.withValues(alpha: 0.5)
                      : Colors.orange.shade200,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: isDark
                      ? Colors.orange.shade900.withValues(alpha: 0.3)
                      : Colors.orange.shade50,
                  child: Icon(
                    Icons.pending_actions,
                    color: isDark ? Colors.orange.shade300 : Colors.orange,
                  ),
                ),
                title: Text(
                  patient['full_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      tests,
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Ordered: $date",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiagnosticPatientView(patient: patient),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text("Process"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by Email",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _searchPatient,
              ),
            ),
            onSubmitted: (_) => _searchPatient(),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_searchedPatient != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                  const SizedBox(height: 16),
                  Text(
                    _searchedPatient!['full_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_searchedPatient!['email']),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _assignPatient,
                      icon: const Icon(Icons.person_add),
                      label: const Text("ASSIGN TO CENTER"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            TextButton.icon(
              onPressed: () => _showRegistrationDialog(),
              icon: const Icon(Icons.app_registration),
              label: Text(
                "Register New Patient",
                style: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
