import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminImageService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // State: List of 2 images (nullable) for the UI slots
  List<File?> _selectedImages = [null, null];
  List<File?> get selectedImages => _selectedImages;

  void setImageAtIndex(int index, File image) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages[index] = image;
      notifyListeners();
    }
  }

  void removeImageAtIndex(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages[index] = null;
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages = [null, null];
    notifyListeners();
  }

  // Helper to pick image
  Future<void> pickImage(int index, bool fromCamera) async {
    final File? image = fromCamera
        ? await pickFromCamera()
        : await pickFromGallery();

    if (image != null) {
      setImageAtIndex(index, image);
    }
  }

  Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    return picked != null ? File(picked.path) : null;
  }
}