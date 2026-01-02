import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/medical_event_model.dart';
import '../../../l10n/app_localizations.dart';

class MedicalEventDetailsPage extends StatelessWidget {
  final MedicalEvent event;

  const MedicalEventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.reportDetails ?? "Report Details",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.shareComingSoon ??
                        "Share feature coming soon!",
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildAttachmentPreview(context, isDark),

            const SizedBox(height: 24),

            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isDark ? Border.all(color: Colors.grey.shade800) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSeverityBadge(context, event.severity, isDark),
                      Text(
                        DateFormat('dd MMM yyyy').format(event.eventDate),
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${AppLocalizations.of(context)?.typeLabel ?? 'Type:'} ${event.eventType.toUpperCase()}",
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            
            if (event.summary != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: isDark ? Colors.purple.shade300 : Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.aiAnalysisSummary ??
                          "AI Analysis Summary",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.purple.shade900.withValues(alpha: 0.4),
                            AppColors.darkSurface,
                          ]
                        : [Colors.purple.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.purple.shade700.withValues(alpha: 0.5)
                        : Colors.purple.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(
                        alpha: isDark ? 0.1 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        String summaryText = event.summary!;
                        final locale = Localizations.localeOf(
                          context,
                        ).languageCode;
                        if (locale == 'bn' &&
                            event.aiDetails != null &&
                            event.aiDetails!['summary_bn'] != null) {
                          summaryText = event.aiDetails!['summary_bn'];
                        }
                        return Text(
                          summaryText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.black87,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.generatedByAi ??
                              "Generated by HealthSync AI",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark
                                ? Colors.purple.shade200
                                : Colors.purple.shade300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(BuildContext context, bool isDark) {
    if (event.attachmentUrls.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.noAttachment ??
                  "No attachment available",
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, event.attachmentUrls.first);
      },
      child: Hero(
        tag: 'report_image_${event.id}',
        child: Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(event.attachmentUrls.first),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Hero(
                tag: 'report_image_${event.id}',
                child: Image.network(imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(
    BuildContext context,
    String severity,
    bool isDark,
  ) {
    Color color;
    Color bg;

    switch (severity) {
      case 'HIGH':
        color = isDark ? Colors.red.shade300 : Colors.red.shade700;
        bg = isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
        break;
      case 'MEDIUM':
        color = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        bg = isDark
            ? Colors.orange.shade900.withValues(alpha: 0.3)
            : Colors.orange.shade50;
        break;
      default:
        color = isDark ? Colors.green.shade300 : Colors.green.shade700;
        bg = isDark
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : Colors.green.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withValues(alpha: isDark ? 0.8 : 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            severity == 'HIGH'
                ? (AppLocalizations.of(context)?.severityHigh ?? severity)
                : severity == 'MEDIUM'
                ? (AppLocalizations.of(context)?.severityMedium ?? severity)
                : (AppLocalizations.of(context)?.severityNormal ?? severity),
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
