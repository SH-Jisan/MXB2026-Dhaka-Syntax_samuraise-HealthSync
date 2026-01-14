import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../../core/constants/app_colors.dart';
import '../providers/doctor_provider.dart';

class DoctorListPage extends ConsumerStatefulWidget {
  final String specialty;
  final List<dynamic> internetDoctors; 

  const DoctorListPage({
    super.key,
    required this.specialty,
    this.internetDoctors = const [],
  });

  @override
  ConsumerState<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends ConsumerState<DoctorListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    
    final appDoctorsAsync = ref.watch(
      doctorsBySpecialtyProvider(widget.specialty),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.specialty}s"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          tabs: const [
            Tab(text: "App Doctors"),
            Tab(text: "From Google"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          
          appDoctorsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (doctors) {
              if (doctors.isEmpty) {
                return _buildEmptyState(
                  "No registered doctors found in our app.",
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary.withValues(alpha: 0.2)
                            : Colors.teal.shade100,
                        child: Icon(
                          Icons.person,
                          color: isDark ? AppColors.darkPrimary : Colors.teal,
                        ),
                      ),
                      title: Text(
                        doc['full_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(doc['specialty'] ?? widget.specialty),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                        ),
                        child: const Text("Book"),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          
          widget.internetDoctors.isEmpty
              ? _buildEmptyState("No results found on Google.")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.internetDoctors.length,
                  itemBuilder: (context, index) {
                    final doc = widget.internetDoctors[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue.shade900.withValues(alpha: 0.3)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.public,
                            color: isDark ? Colors.blue.shade200 : Colors.blue,
                          ),
                        ),
                        title: Text(
                          doc['title'] ?? 'Unknown Doctor',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              doc['address'] ?? 'No address available',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (doc['rating'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      " ${doc['rating']} (${doc['userRatingsTotal'] ?? 0})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.map, color: Colors.green),
                        onTap: () async {
                          
                          final query = Uri.encodeComponent(
                            "${doc['title']} ${doc['address'] ?? ""}",
                          );
                          final url = Uri.parse(
                            "https://www.google.com/maps/search/?api=1&query=$query",
                          );
                          if (await canLaunchUrl(url)) launchUrl(url);
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
