import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/upload_provider.dart';

class UploadBottomSheet extends ConsumerStatefulWidget {
  const UploadBottomSheet({super.key});

  @override
  ConsumerState<UploadBottomSheet> createState() => _UploadBottomSheetState();
}

class _UploadBottomSheetState extends ConsumerState<UploadBottomSheet> {
  // একাধিক ফাইল রাখার লিস্ট
  List<File> _selectedFiles = [];

  // ফাইল পিক করার ফাংশন (PDF + Image + Multiple)
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // 🔥 একাধিক ফাইল সিলেক্ট করার অপশন
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // 🔥 PDF সাপোর্ট
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  // আপলোড লজিক (লুপ চালিয়ে একে একে আপলোড)
  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;

    final uploader = ref.read(uploadProvider.notifier);

    int successCount = 0;
    int duplicateCount = 0;

    // সব ফাইল একে একে প্রসেস হবে
    for (var file in _selectedFiles) {
      final status = await uploader.uploadAndAnalyze(file);

      if(status == UploadStatus.success) successCount++;
      if(status == UploadStatus.duplicate) duplicateCount++;
    }

    // সব শেষ হলে বন্ধ হবে
    if (mounted) {
      Navigator.pop(context);
      String message = "";
      if (successCount > 0 && duplicateCount > 0) {
        message = "Saved $successCount files. Skipped $duplicateCount duplicate(s).";
      } else if (successCount > 0) {
        message = "Successfully uploaded $successCount file(s)!";
      } else if (duplicateCount > 0) {
        message = "Skipped $duplicateCount duplicate file(s).";
      } else {
        message = "Upload failed.";
      }
      final color = (successCount == 0 && duplicateCount > 0) ? Colors.orange : Colors.green;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final isLoading = uploadState is AsyncLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      height: 600,
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.modalBackgroundColor ?? (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 "Upload Records", 
                 style: GoogleFonts.poppins(
                   fontSize: 22, 
                   fontWeight: FontWeight.bold,
                   color: theme.textTheme.displayMedium?.color ?? (isDark ? Colors.white : AppColors.textPrimary)
                 )
               ),
              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: const Icon(Icons.close),
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // File Selection Area
          Expanded(
            child: _selectedFiles.isEmpty
                ? GestureDetector(
                    onTap: _pickFiles,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, 
                          style: BorderStyle.solid, 
                          width: 2
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle
                            ),
                            child: Icon(
                              Icons.cloud_upload_outlined, 
                              size: 48, 
                              color: isDark ? AppColors.darkPrimary : AppColors.primary
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Tap to Select Reports",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, 
                              fontSize: 16, 
                              color: theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Supports JPG, PNG & PDF",
                            style: GoogleFonts.poppins(
                              fontSize: 12, 
                              color: theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      final isPdf = file.path.endsWith('.pdf');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black12 : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPdf ? Icons.picture_as_pdf : Icons.image,
                              color: isPdf ? Colors.red : (isDark ? AppColors.darkPrimary : AppColors.primary),
                            ),
                          ),
                          title: Text(
                            file.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              setState(() => _selectedFiles.removeAt(index));
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Error Show
          if (uploadState is AsyncError)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${uploadState.error}", 
                      style: const TextStyle(color: AppColors.error)
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Action Button
          ElevatedButton(
            onPressed: (_selectedFiles.isEmpty || isLoading) ? null : _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.black : Colors.white, 
                          strokeWidth: 2
                        )
                      ),
                      const SizedBox(width: 12),
                      const Text("Analyzing Files..."),
                    ],
                  )
                : Text("UPLOAD & ANALYZE (${_selectedFiles.length})"),
          ),
        ],
      ),
    );
  }
}