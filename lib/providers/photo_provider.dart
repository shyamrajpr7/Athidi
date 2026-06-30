import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athidhi/models/photo_model.dart';

enum PhotoLoadStatus { initial, loading, loaded, error }

class PhotoProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  PhotoLoadStatus _status = PhotoLoadStatus.initial;
  List<MemoryPhoto> _photos = [];
  bool _isUploading = false;
  String? _errorMessage;

  PhotoLoadStatus get status => _status;
  List<MemoryPhoto> get photos => _photos;
  List<MemoryPhoto> get approvedPhotos =>
      _photos.where((p) => p.isApproved).toList();
  List<MemoryPhoto> get pendingPhotos =>
      _photos.where((p) => p.isPending).toList();
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPhotos(String eventId) async {
    _status = PhotoLoadStatus.loading;
    notifyListeners();

    try {
      final response = await _client
          .from('memory_photos')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false);

      _photos = (response as List)
          .map((p) => MemoryPhoto.fromMap(p as Map<String, dynamic>))
          .toList();
      _status = PhotoLoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PhotoLoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> uploadPhoto({
    required String eventId,
    required String guestName,
    required File imageFile,
    String? caption,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ext = imageFile.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${eventId}.$ext';
      final storagePath = 'memory-wall/$eventId/$fileName';

      await _client.storage.from('memory-wall').upload(
            storagePath,
            imageFile,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      final imageUrl = _client.storage.from('memory-wall').getPublicUrl(storagePath);

      final photo = MemoryPhoto(
        id: fileName,
        eventId: eventId,
        guestName: guestName,
        imageUrl: imageUrl,
        caption: caption,
        status: 'pending',
      );

      await _client.from('memory_photos').insert(photo.toMap());
      _photos.insert(0, photo);
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> approvePhoto(String photoId) async {
    await _updatePhotoStatus(photoId, 'approved');
  }

  Future<void> rejectPhoto(String photoId) async {
    await _updatePhotoStatus(photoId, 'rejected');
  }

  Future<void> _updatePhotoStatus(String photoId, String status) async {
    try {
      await _client
          .from('memory_photos')
          .update({'status': status})
          .eq('id', photoId);

      final index = _photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        _photos[index] = _photos[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> deletePhoto(String photoId, String imageUrl) async {
    try {
      await _client.from('memory_photos').delete().eq('id', photoId);

      final storagePath = imageUrl.replaceAll(
          _client.storage.from('memory-wall').getPublicUrl(''), '');
      await _client.storage.from('memory-wall').remove([storagePath]);

      _photos.removeWhere((p) => p.id == photoId);
      notifyListeners();
    } catch (_) {}
  }

  Future<String> uploadAndGetUrl(File imageFile, String eventId) async {
    final ext = imageFile.path.split('.').last;
    final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'memory-wall/$eventId/$fileName';

    await _client.storage.from('memory-wall').upload(
          storagePath,
          imageFile,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );

    return _client.storage.from('memory-wall').getPublicUrl(storagePath);
  }
}
