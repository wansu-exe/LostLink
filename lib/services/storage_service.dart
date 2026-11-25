import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Open the device camera or gallery and return the picked file, or null.
  Future<File?> pickImage({bool fromCamera = false}) async {
    final xFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,   // compress to ~70% — reduces Storage bandwidth
      maxWidth: 1024,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Upload [file] to Storage under item_photos/{itemId}.jpg
  /// and return the public download URL saved in the Firestore item document.
  Future<String> uploadItemPhoto({
    required File file,
    required String itemId,
  }) async {
    final ref = _storage.ref().child('item_photos/$itemId.jpg');

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return task.ref.getDownloadURL();
  }

  /// Delete a photo when the report is removed.
  Future<void> deleteItemPhoto(String itemId) async {
    try {
      await _storage.ref().child('item_photos/$itemId.jpg').delete();
    } catch (_) {
      // File may not exist — safe to swallow
    }
  }
}
