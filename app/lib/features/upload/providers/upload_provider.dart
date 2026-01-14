import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';
import '../../timeline/providers/timeline_provider.dart';

enum UploadStatus { success, duplicate, failure }

final uploadProvider =
    StateNotifierProvider<UploadController, AsyncValue<void>>((ref) {
      return UploadController(ref);
    });

class UploadController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  UploadController(this._ref) : super(const AsyncData(null));

  Future<UploadStatus> uploadAndAnalyze(File file, {String? patientId}) async {
    state = const AsyncLoading();
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      
      
      final targetUserId = patientId ?? currentUser.id;

      
      final fileBytes = await file.readAsBytes();
      final fileBase64 = base64Encode(fileBytes);
      final fileHash = sha256.convert(fileBytes).toString();

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final fileExt = mimeType.split('/').last;

      final fileName = '$targetUserId/${const Uuid().v4()}.$fileExt';

      
      await Supabase.instance.client.storage
          .from('reports')
          .upload(
            fileName,
            file,
            fileOptions: FileOptions(contentType: mimeType),
          );
      final fileUrl = Supabase.instance.client.storage
          .from('reports')
          .getPublicUrl(fileName);

      
      try {
        await Supabase.instance.client.functions.invoke(
          'process-medical-report',
          body: {
            'patient_id': targetUserId, 
            'uploader_id': currentUser.id, 
            'imageBase64': fileBase64,
            'mimeType': mimeType,
            'file_url': fileUrl,
            'file_hash': fileHash,
            'file_path': fileName,
          },
        );

        

        
        _ref.invalidate(timelineProvider(targetUserId));

        
        
        if (targetUserId == currentUser.id) {
          _ref.invalidate(timelineProvider(null));
        }

        state = const AsyncData(null);
        return UploadStatus.success;
      } on FunctionException catch (e) {
        if (e.status == 409) {
          state = const AsyncData(null);
          return UploadStatus.duplicate;
        }
        rethrow;
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return UploadStatus.failure;
    }
  }
}
