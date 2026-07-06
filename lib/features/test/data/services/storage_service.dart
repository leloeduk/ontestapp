import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadScreenshot({
    required String userName,
    required String testId,
    required String appName,
    required String filePath,
    required int captureNumber,
  }) async {
    final sanitizedUser = userName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final sanitizedApp = appName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final path =
        'users/$sanitizedUser/tests/$testId/${sanitizedApp}_capture$captureNumber.jpg';
    final ref = _storage.ref(path);
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
