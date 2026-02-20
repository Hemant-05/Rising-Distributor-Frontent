import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raising_india/data/repositories/image_repo.dart';
import 'package:raising_india/error/exceptions.dart';

class ImageService extends ChangeNotifier {
  final ImageRepository _repo = ImageRepository();

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Future<String?> uploadImage(File file) async {
    _isUploading = true;
    notifyListeners();
    try {
      final url = await _repo.uploadImage(file);
      return url; // Return the URL on success
    } on AppError catch (e) {
      throw e; // Rethrow to let UI handle message
    } catch (e) {
      throw Exception("Image upload failed");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteImage(String imageUrl) async {
    try {
      await _repo.deleteImage(imageUrl);
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to delete image.";
    }
  }
}