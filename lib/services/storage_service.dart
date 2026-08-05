import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Handles file uploads to Supabase Storage.
///
/// Bucket: `listing-images` (must be created in Supabase Dashboard
/// under Storage → New Bucket, set to Public).
class StorageService {
  static final _storage = Supabase.instance.client.storage;
  static const _bucket = 'listing-images';
  static const _uuid = Uuid();

  /// Uploads a listing image and returns its public CDN URL.
  ///
  /// Files are stored as `{userId}/{uuid}.jpg` for ownership isolation.
  /// Throws [StorageException] on upload failure.
  static Future<String> uploadListingImage({
    required File imageFile,
    required String userId,
  }) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final allowedExts = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowedExts.contains(ext)) {
      throw ArgumentError('Only JPG, PNG, and WebP images are allowed.');
    }

    // Limit file size to 5MB
    final sizeInBytes = await imageFile.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      throw ArgumentError('Image must be smaller than 5MB.');
    }

    final filename = '${_uuid.v4()}.$ext';
    final storagePath = '$userId/$filename';

    await _storage.from(_bucket).upload(
      storagePath,
      imageFile,
      fileOptions: FileOptions(
        contentType: 'image/$ext',
        upsert: false,
      ),
    );

    final publicUrl = _storage.from(_bucket).getPublicUrl(storagePath);
    debugPrint('[StorageService] Uploaded: $publicUrl');
    return publicUrl;
  }

  /// Deletes a listing image from storage by its full URL.
  /// Silently ignores errors (image may have already been deleted).
  static Future<void> deleteListingImage(String publicUrl) async {
    try {
      final uri = Uri.tryParse(publicUrl);
      if (uri == null) return;

      // Extract the storage path after /object/public/{bucket}/
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_bucket);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) return;

      final storagePath =
          pathSegments.sublist(bucketIndex + 1).join('/');
      await _storage.from(_bucket).remove([storagePath]);
    } catch (e) {
      debugPrint('[StorageService] deleteListingImage notice: $e');
    }
  }
}
