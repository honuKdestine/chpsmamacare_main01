import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _client = Supabase.instance.client;

  Future<String> uploadTestFile(String filePath, String fileName) async {
    final file = File(filePath);

    await _client.storage.from('test_files').upload(fileName, file);

    final publicUrl = _client.storage.from('test_files').getPublicUrl(fileName);

    return publicUrl;
  }
}
