import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/image_helper.dart';

class AdminImageService extends ChangeNotifier {
  // State: List of up to 5 images
  List<File> _selectedImages = [];
  List<File> get selectedImages => _selectedImages;

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final File image = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, image);
    notifyListeners();
  }

  void removeImageAtIndex(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  bool _isPicking = false;

  // Helper to pick image
  Future<void> pickImage(BuildContext context, bool fromCamera) async {
    if (_isPicking) return;
    
    int remainingSlots = 5 - _selectedImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 5 images.')),
      );
      return;
    }

    _isPicking = true;
    try {
      final List<File> images = await ImageHelper.pickAndCropMultipleImages(
        context: context,
        fromCamera: fromCamera,
        maxImages: remainingSlots,
      );

      if (images.isNotEmpty) {
        _selectedImages.addAll(images);
        notifyListeners();
      }
    } finally {
      _isPicking = false;
    }
  }
}