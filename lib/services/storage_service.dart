import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadTestFile(String filePath, String fileName) async {
    final ref = _storage.ref().child('test_files/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
