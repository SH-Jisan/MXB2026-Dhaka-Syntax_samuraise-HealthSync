import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাটের জন্য
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/side_drawer.dart';
import 'diagnostic_patient_view.dart';

class DiagnosticHomePage extends StatefulWidget {
  const DiagnosticHomePage({super.key});

  @override
  State<DiagnosticHomePage> createState() => _DiagnosticHomePageState();
}

class _DiagnosticHomePageState extends State<DiagnosticHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // সার্চ ও রেজিস্ট্রেশন কন্ট্রোলার
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _searchedPatient;

  @override
  void initState() {
    super.initState();
    // 🔥 UPDATE: ট্যাব সংখ্যা ৩ করা হলো (Assigned, Pending, Search)
    _tabController = TabController(length: 3, vsync: this);
  }

  // ... (Search, Assign, Register লজিকগুলো আগের মতোই থাকবে) ...

  Future<void> _searchPatient() async {
    if (_searchController.text.isEmpty) return;
    setState(() { _isLoading = true; _searchedPatient = null; });
    try {
      final data = await Supabase.instance.client.from('profiles').select().eq('email', _searchController.text.trim()).eq('role', 'CITIZEN').maybeSingle();
      if (mounted) {
        if (data != null) {
          setState(() => _searchedPatient = data);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Patient not found!")));
          _showRegistrationDialog(preFilledEmail: _searchController.text.trim());
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assigned Successfully!"), backgroundColor: Colors.green));
        _tabController.animateTo(0); // লিস্টে ফিরে যাওয়া
        setState(() { _searchedPatient = null; _searchController.clear(); });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error or Already Assigned: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerNewPatient() async {
    // রেজিস্ট্রেশন লজিক (সংক্ষেপে)
    if (_emailController.text.isEmpty) return;
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.rpc('create_dummy_user', params: {
        'u_email': _emailController.text.trim(),
        'u_password': '123456',
        'u_name': _nameController.text.trim(),
        'u_phone': _phoneController.text.trim(),
        'u_role': 'CITIZEN',
        'u_address': ''
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registered!"), backgroundColor: Colors.green));
        _searchController.text = _emailController.text.trim();
        _searchPatient();
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(onPressed: _registerNewPatient, child: const Text("REGISTER")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text("Diagnostic Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Assigned"),
            Tab(text: "Pending"), // 🔥 NEW TAB
            Tab(text: "Search"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState((){}))
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignedPatientsTab(), // 1. সব রোগী
          _buildPendingReportsTab(),   // 2. শুধু পেন্ডিং কাজ (🔥 NEW)
          _buildSearchTab(),           // 3. নতুন অ্যাসাইন
        ],
      ),
    );
  }

  // --- TAB 1: ALL ASSIGNED PATIENTS ---
  Widget _buildAssignedPatientsTab() {
    final diagnosticId = Supabase.instance.client.auth.currentUser!.id;
    return FutureBuilder(
      future: Supabase.instance.client
          .from('diagnostic_patients')
          .select('*, profiles:patient_id(*)')
          .eq('diagnostic_id', diagnosticId)
          .order('assigned_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));

        final list = snapshot.data as List;
        if (list.isEmpty) return const Center(child: Text("No assigned patients. Go to Search tab."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final patient = list[index]['profiles'];
            if (patient == null) return const SizedBox.shrink();

            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(patient['full_name'][0])),
                title: Text(patient['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(patient['phone'] ?? patient['email']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiagnosticPatientView(patient: patient))),
              ),
            );
          },
        );
      },
    );
  }

  // --- 🔥 TAB 2: PENDING REPORTS TAB (NEW) ---
  Widget _buildPendingReportsTab() {
    final diagnosticId = Supabase.instance.client.auth.currentUser!.id;

    // আমরা 'patient_payments' টেবিল থেকে পেন্ডিং টেস্ট খুঁজব
    return FutureBuilder(
      future: Supabase.instance.client
          .from('patient_payments')
          .select('*, profiles:patient_id(*)') // পেশেন্ট ডিটেইলস সহ
          .eq('provider_id', diagnosticId)
          .eq('report_status', 'PENDING') // 🔍 ফিল্টার: শুধু পেন্ডিং
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final pendingOrders = snapshot.data as List;

        if (pendingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 60, color: Colors.green.shade300),
                const SizedBox(height: 16),
                const Text("Great! No pending reports.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
            final date = DateFormat('dd MMM, hh:mm a').format(DateTime.parse(order['created_at']));

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.shade200)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: const Icon(Icons.pending_actions, color: Colors.orange),
                ),
                title: Text(patient['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(tests, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    Text("Ordered: $date", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // সরাসরি ওই রোগীর প্রোফাইলে নিয়ে যাব
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DiagnosticPatientView(patient: patient)));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact
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

  // --- TAB 3: SEARCH & ASSIGN ---
  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by Email",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _searchPatient),
            ),
            onSubmitted: (_) => _searchPatient(),
          ),
          const SizedBox(height: 32),
          if (_isLoading) const CircularProgressIndicator()
          else if (_searchedPatient != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                  const SizedBox(height: 16),
                  Text(_searchedPatient!['full_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_searchedPatient!['email']),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _assignPatient,
                      icon: const Icon(Icons.person_add),
                      label: const Text("ASSIGN TO CENTER"),
                    ),
                  )
                ],
              ),
            )
          else
            TextButton.icon(
              onPressed: () => _showRegistrationDialog(),
              icon: const Icon(Icons.app_registration),
              label: const Text("Register New Patient"),
            )
        ],
      ),
    );
  }
}