import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/medical_event_model.dart';
import '../../../../core/constants/app_colors.dart';

class FileTab extends StatelessWidget {
  final MedicalEvent event;
  final bool isDark;

  const FileTab({super.key, required this.event, required this.isDark});

  Future<void> _downloadFile(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not launch download URL"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isImage(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp');
  }

  @override
  Widget build(BuildContext context) {
    if (event.attachmentUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.fileX, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "No attachment found",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Currently handling the first attachment.
    // In future, this could be a list or carousel if multiple files exist.
    final fileUrl = event.attachmentUrls.first;
    final isImage = _isImage(fileUrl);

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.black87,
      child: Stack(
        children: [
          // File Content
          Center(
            child: isImage
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      fileUrl,
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) => _buildErrorState(isDark),
                    ),
                  )
                : _buildDocumentPlaceholder(context, fileUrl, isDark),
          ),

          // Download Button Overlay
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _downloadFile(context, fileUrl),
              backgroundColor: AppColors.primary,
              icon: const Icon(
                PhosphorIconsBold.downloadSimple,
                color: Colors.white,
              ),
              label: Text(
                "Download",
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 48),
        const SizedBox(height: 16),
        Text(
          "Error loading content",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDocumentPlaceholder(
    BuildContext context,
    String url,
    bool isDark,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(PhosphorIconsDuotone.filePdf, size: 80, color: Colors.white70),
        const SizedBox(height: 16),
        Text(
          "Document Attachment",
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap download to view",
          style: GoogleFonts.manrope(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }
}
