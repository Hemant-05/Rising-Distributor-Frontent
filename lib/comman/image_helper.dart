import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:raising_india/constant/AppColour.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image and immediately opens the cropper.
  /// Returns the cropped [File] or null if the user cancels.
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required bool fromCamera,
  }) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColour.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// Crops an existing local image file.
  static Future<File?> cropImage({
    required BuildContext context,
    required String imagePath,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColour.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// Picks multiple images (or 1 from camera) and crops them sequentially.
  static Future<List<File>> pickAndCropMultipleImages({
    required BuildContext context,
    required bool fromCamera,
    int? maxImages,
  }) async {
    List<XFile> pickedFiles = [];
    
    if (fromCamera) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) pickedFiles.add(pickedFile);
    } else {
      final List<XFile> files = await _picker.pickMultiImage();
      if (maxImages != null && files.length > maxImages) {
        pickedFiles = files.take(maxImages).toList();
      } else {
        pickedFiles = files;
      }
    }

    List<File> croppedFiles = [];
    for (var pickedFile in pickedFiles) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image (${croppedFiles.length + 1}/${pickedFiles.length})',
            toolbarColor: AppColour.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Image (${croppedFiles.length + 1}/${pickedFiles.length})',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        croppedFiles.add(File(croppedFile.path));
      } else {
        // If the user cancels cropping for one image, we can either stop or continue.
        // Continuing allows them to skip an image.
      }
    }

    return croppedFiles;
  }

  /// Downloads a network image and opens the cropper.
  /// Returns the cropped [File] or null if the user cancels.
  static Future<File?> downloadAndCropImage({
    required BuildContext context,
    required String imageUrl,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      // Download the image
      final dir = Directory.systemTemp;
      final File file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await Dio().download(imageUrl, file.path);

      // Dismiss loading
      if (context.mounted) Navigator.pop(context);

      // Crop the downloaded file
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColour.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading if error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download/crop image: $e')),
        );
      }
    }
    return null;
  }
}
