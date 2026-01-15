import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';
import '../widgets/medical_event_details/analysis_tab.dart';
import '../widgets/medical_event_details/file_tab.dart';
import '../widgets/medical_event_details/medicines_tab.dart';
import '../widgets/medical_event_details/overview_tab.dart';
import '../widgets/medical_event_details/prescription_tab.dart';

class MedicalEventDetailsPage extends StatefulWidget {
  final MedicalEvent event;

  const MedicalEventDetailsPage({super.key, required this.event});

  @override
  State<MedicalEventDetailsPage> createState() =>
      _MedicalEventDetailsPageState();
}

class _MedicalEventDetailsPageState extends State<MedicalEventDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    int tabCount = 4; // Overview, Medicines, Analysis, File
    if (event.eventType == 'PRESCRIPTION' || event.eventType == 'TEST_ORDER')
      tabCount++; // + Prescription

    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final event = widget.event;
    final locale = Localizations.localeOf(context).languageCode;
    final isBangla = locale == 'bn';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          event.title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            if (event.eventType == 'PRESCRIPTION' ||
                event.eventType == 'TEST_ORDER')
              const Tab(text: 'Prescription'),
            Tab(text: isBangla ? 'ওভারভিউ' : 'Overview'),
            Tab(text: isBangla ? 'ঔষধ' : 'Medicines'),
            Tab(text: isBangla ? 'বিশ্লেষণ (AI)' : 'AI Analysis'),
            Tab(text: isBangla ? 'ফাইল' : 'File'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (event.eventType == 'PRESCRIPTION' ||
              event.eventType == 'TEST_ORDER')
            PrescriptionTab(event: event, isDark: isDark),
          OverviewTab(event: event, isDark: isDark, isBangla: isBangla),
          MedicinesTab(event: event, isDark: isDark),
          AnalysisTab(event: event, isDark: isDark, isBangla: isBangla),
          FileTab(event: event, isDark: isDark),
        ],
      ),
    );
  }
}
