import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class StorageService {
  final _client = SupabaseConfig.client;
  final String _bucket = 'avatars';

  // ---------- PICK IMAGE FROM GALLERY ----------
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- PICK IMAGE FROM CAMERA ----------
  Future<File?> takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPLOAD AVATAR ----------
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExtension';

      // Upload (upsert = replace if exists)
      await _client.storage.from(_bucket).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl =
          _client.storage.from(_bucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- DELETE AVATAR ----------
  Future<void> deleteAvatar(String userId) async {
    try {
      final files = await _client.storage.from(_bucket).list(path: userId);
      if (files.isNotEmpty) {
        final filePaths =
            files.map((file) => '$userId/${file.name}').toList();
        await _client.storage.from(_bucket).remove(filePaths);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPLOAD AND UPDATE PROFILE AVATAR ----------
  Future<String> uploadAndUpdateAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Upload image
      final avatarUrl = await uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );

      // Update profile with new URL
      await _client.from('profiles').update({
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return avatarUrl;
    } catch (e) {
      rethrow;
    }
  }
}
