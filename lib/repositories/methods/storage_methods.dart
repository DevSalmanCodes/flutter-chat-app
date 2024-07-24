import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../utils/methods.dart';

class StorageMethods {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static Future<String?> uploadFileToFirebase(
      File? file, String path, File? voicePath, BuildContext context) async {
    try {
      if (file != null) {
        final filename = file.path.split('/').last;

        TaskSnapshot res = await _storage
            .ref()
            .child('images/$path/$filename')
            .putFile(File(file.path));
        final url = await res.ref.getDownloadURL();
        return url;
      } else {
        final uid = const Uuid().v4();
        TaskSnapshot res = await _storage
            .ref()
            .child('voices/$uid.acc')
            .putFile(File(voicePath!.path));
        final url = await res.ref.getDownloadURL();
        return url;
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message.toString());
    }
    return null;
  }
}
