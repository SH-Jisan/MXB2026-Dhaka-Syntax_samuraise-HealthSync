import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';
import '../../timeline/providers/timeline_provider.dart';

// 🔥 নতুন Enum স্ট্যাটাস বোঝার জন্য
enum UploadStatus { success, duplicate, failure }

final uploadProvider = StateNotifierProvider<UploadController, AsyncValue<void>>((ref) {
  return UploadController(ref);
});

class UploadController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  UploadController(this._ref) : super(const AsyncData(null));

  // Return type void থেকে UploadStatus এ চেঞ্জ করলাম
  Future<UploadStatus> uploadAndAnalyze(File file) async {
    state = const AsyncLoading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // ১. ফাইল প্রসেসিং
      final fileBytes = await file.readAsBytes();
      final fileBase64 = base64Encode(fileBytes);
      final fileHash = sha256.convert(fileBytes).toString();

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final fileExt = mimeType.split('/').last;
      final fileName = '${user.id}/${const Uuid().v4()}.$fileExt';

      // ২. আপলোড
      await Supabase.instance.client.storage.from('reports').upload(
        fileName,
        file,
        fileOptions: FileOptions(contentType: mimeType),
      );
      final fileUrl = Supabase.instance.client.storage.from('reports').getPublicUrl(fileName);

      // ৩. ফাংশন কল (Try-Catch দিয়ে হ্যান্ডেল করা)
      try {
        await Supabase.instance.client.functions.invoke(
          'process-medical-report',
          body: {
            'patient_id': user.id,
            'uploader_id': user.id,
            'imageBase64': fileBase64,
            'mimeType': mimeType,
            'file_url': fileUrl,
            'file_hash': fileHash,
            'file_path': fileName,
          },
        );

        // সব ঠিক থাকলে Success
        _ref.refresh(timelineProvider);
        state = const AsyncData(null);
        return UploadStatus.success;

      } on FunctionException catch (e) {
        // 🔥 এইখানের লজিকটিই আসল ফিক্স
        if (e.status == 409) {
          // যদি 409 হয়, তার মানে ডুপ্লিকেট। আমরা এটাকে এরর বলব না।
          state = const AsyncData(null); // স্টেট নরমাল করে দিলাম (লাল বক্স দেখাবে না)
          return UploadStatus.duplicate;
        }
        rethrow; // অন্য কোনো এরর হলে সেটা আসল এরর
      }

    } catch (e, stack) {
      state = AsyncError(e, stack);
      return UploadStatus.failure;
    }
  }
}