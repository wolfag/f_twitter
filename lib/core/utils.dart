import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

String getNameFromEmail(String email) {
  return email.split('@')[0];
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  final ImagePicker picker = ImagePicker();
  final imageFiles = await picker.pickMultiImage();
  if (imageFiles.isNotEmpty) {
    for (final image in imageFiles) {
      images.add(File(image.path));
    }
  }
  return images;
}

Future<File?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final imageFile = await picker.pickImage(source: ImageSource.gallery);
  if (imageFile != null) {
    return File(imageFile.path);
  }
  return null;
}

String getLinkFromText(String text) {
  List<String> words = text.split(' ');
  for (String word in words) {
    if (word.startsWith('http://') ||
        word.startsWith('https://') ||
        word.startsWith('www.')) {
      return word;
    }
  }
  return '';
}

List<String> getHashtagsFromText(String text) {
  List<String> hashtags = [];
  List<String> words = text.split(' ');
  for (String word in words) {
    if (word.startsWith('#')) {
      hashtags.add(word);
    }
  }

  return hashtags;
}
