import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Import File Picker
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../services/ai_upload_service.dart';

class UploadBottomSheet extends StatefulWidget {
  const UploadBottomSheet({super.key});

  @override
  State<UploadBottomSheet> createState() => _UploadBottomSheetState();
}

class _UploadBottomSheetState extends State<UploadBottomSheet> {
  final AiUploadService _aiService = AiUploadService();
  bool _isAnalyzing = false;
  String _statusMessage = "Select an option";

  // --- Option A: Image Picker (Camera/Gallery) ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      _startProcessing(File(image.path));
    }
  }

  // --- Option B: File Picker (PDF) ---
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // শুধু PDF এলাও করব
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      _startProcessing(file);
    }
  }

  // --- Common Processing Function ---
  Future<void> _startProcessing(File file) async {
    setState(() {
      _isAnalyzing = true;
      _statusMessage = "Uploading & Analyzing...";
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // AI Service Call
      await _aiService.processAndUploadReport(file, userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success! Report added."),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _statusMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 320, // হাইট একটু বাড়ালাম
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, color: Colors.grey[300]),
          const SizedBox(height: 20),

          Text("Upload Record", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 30),

          if (_isAnalyzing) ...[
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(_statusMessage, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(Icons.camera_alt, "Camera", () => _pickImage(ImageSource.camera)),
                _buildOption(Icons.photo_library, "Gallery", () => _pickImage(ImageSource.gallery)),
                _buildOption(Icons.picture_as_pdf, "PDF", () => _pickDocument()), // New PDF Button
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}