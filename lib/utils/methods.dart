import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future pickImage(BuildContext context) async {
  try {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, maxWidth: 400,
    );
    if (pickedImage == null) return;
    return File(pickedImage.path);
  } on PlatformException catch (e) {
    if (context.mounted) {
      showSnackBar(context, "Failed to pick image ${e.message.toString()}");
    }
  }
}
