import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/upload_provider.dart';

class UploadBottomSheet extends ConsumerStatefulWidget {
  
  final String? patientId;
  final String? patientName; 

  const UploadBottomSheet({super.key, this.patientId, this.patientName});

  @override
  ConsumerState<UploadBottomSheet> createState() => _UploadBottomSheetState();
}

class _UploadBottomSheetState extends ConsumerState<UploadBottomSheet> {
  List<File> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;

    final uploader = ref.read(uploadProvider.notifier);
    int successCount = 0;
    int duplicateCount = 0;

    for (var file in _selectedFiles) {
      
      final status = await uploader.uploadAndAnalyze(file, patientId: widget.patientId);
      if(status == UploadStatus.success) successCount++;
      if(status == UploadStatus.duplicate) duplicateCount++;
    }

    if (mounted) {
      Navigator.pop(context);
      String message = "";
      if (successCount > 0) {
        message = widget.patientId != null
            ? "Uploaded $successCount files for ${widget.patientName}!"
            : "Successfully uploaded $successCount file(s)!";
      } else if (duplicateCount > 0) {
        message = "Skipped duplicate file(s).";
      } else {
        message = "Upload failed.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
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

    
    final title = widget.patientName != null
        ? "Upload for ${widget.patientName}"
        : "Upload Records";

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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.displayMedium?.color ?? (isDark ? Colors.white : AppColors.textPrimary)
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
                    Icon(Icons.cloud_upload_outlined, size: 48, color: isDark ? AppColors.darkPrimary : AppColors.primary),
                    const SizedBox(height: 16),
                    Text("Tap to Select Reports", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    if(widget.patientName != null)
                      Text("(Saving to Patient's Profile)", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
            )
                : ListView.builder(
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(file.path.split('/').last),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _selectedFiles.removeAt(index)),
                  ),
                );
              },
            ),
          ),

          if (uploadState is AsyncError)
            Text("Error: ${uploadState.error}", style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: (_selectedFiles.isEmpty || isLoading) ? null : _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: isLoading
                ? const Text("Processing...")
                : Text("UPLOAD & ANALYZE (${_selectedFiles.length})"),
          ),
        ],
      ),
    );
  }
}