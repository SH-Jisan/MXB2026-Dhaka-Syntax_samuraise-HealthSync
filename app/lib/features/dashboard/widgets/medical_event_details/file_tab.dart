import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../shared/models/medical_event_model.dart';

class FileTab extends StatelessWidget {
  final MedicalEvent event;
  final bool isDark;

  const FileTab({super.key, required this.event, required this.isDark});

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

    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            event.attachmentUrls.first,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Error loading image",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
