import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = basename(imageFile.path);
      Reference reference = _storage.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print("Error uploading image: $e");
      throw Exception("Error uploading image");
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference reference = _storage.refFromURL(imageUrl);
      await reference.delete();
    } catch (e) {
      // ignore: avoid_print
      print("Error deleting image: $e");
      throw Exception("Error deleting image");
    }
  }
}
