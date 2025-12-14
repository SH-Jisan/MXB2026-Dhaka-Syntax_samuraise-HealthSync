import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

class AiUploadService {
  final _supabase = Supabase.instance.client;

  Future<void> processAndUploadReport(File file, String patientId) async {
    try {
      print("🚀 1. Upload Started...");

      // A. ফাইল প্রিপারেশন
      final bytes = await file.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String? mimeType = lookupMimeType(file.path);

      // এক্সটেনশন ঠিক করা
      String extension = 'jpg'; // Default
      if (mimeType == 'application/pdf') extension = 'pdf';
      else if (mimeType == 'image/png') extension = 'png';

      // B. স্টোরেজে আপলোড (ব্যাকআপ হিসেবে)
      print("📦 2. Uploading Image to Storage...");
      final String fileName = 'reports/${const Uuid().v4()}.$extension';
      await _supabase.storage.from('reports').upload(
        fileName,
        file,
        fileOptions: FileOptions(contentType: mimeType),
      );
      final String publicUrl = _supabase.storage.from('reports').getPublicUrl(fileName);

      // C. Backend Function কল করা (The Magic Moment ✨)
      print("⚡ 3. Calling Supabase Edge Function...");

      final FunctionResponse response = await _supabase.functions.invoke(
        'analyze-report', // আপনার ডেপ্লয় করা ফাংশনের নাম
        body: {
          'imageBase64': base64Image,
          'mimeType': mimeType ?? 'image/jpeg',
        },
      );

      // D. রেসপন্স চেক করা
      if (response.status != 200) {
        // যদি সার্ভারে কোনো এরর হয়, সেটা এখানে প্রিন্ট হবে
        print("❌ Server Error: ${response.data}");
        throw Exception("Backend failed: ${response.data}");
      }

      print("✅ 4. AI Analysis Complete!");
      final aiData = response.data; // সরাসরি JSON অবজেক্ট

      // E. ডাটাবেসে সেভ করা
      print("💾 5. Saving to Database...");
      await _supabase.from('medical_events').insert({
        'patient_id': patientId,
        'title': aiData['title'] ?? 'Unknown Report',
        'event_type': aiData['event_type'] ?? 'REPORT',
        'event_date': aiData['event_date'] ?? DateTime.now().toIso8601String(),
        'severity': aiData['severity'] ?? 'LOW',
        'summary': aiData['summary'] ?? 'Analyzed by Edge Function',
        'attachment_urls': [publicUrl],
        'details': aiData,
      });

    } catch (e) {
      print("💥 CRITICAL ERROR: $e");
      throw Exception("Process Failed: $e");
    }
  }
}