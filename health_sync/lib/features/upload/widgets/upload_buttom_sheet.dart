import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Container(
      padding: const EdgeInsets.all(20),
      height: 600,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Upload Records", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),

          // File Selection Area
          Expanded(
            child: _selectedFiles.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, size: 60, color: Colors.teal.shade200),
                const SizedBox(height: 10),
                const Text("Select Reports (Images or PDF)"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text("Select Files"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            )
                : ListView.builder(
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                final isPdf = file.path.endsWith('.pdf');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image,
                      color: isPdf ? Colors.red : Colors.teal,
                    ),
                    title: Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
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
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.red.shade50,
              child: Text("Error: ${uploadState.error}", style: const TextStyle(color: Colors.red)),
            ),

          // Action Button
          ElevatedButton(
            onPressed: (_selectedFiles.isEmpty || isLoading) ? null : _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 10),
                Text("Analyzing Files..."),
              ],
            )
                : Text("UPLOAD & ANALYZE (${_selectedFiles.length})"),
          ),
        ],
      ),
    );
  }
}