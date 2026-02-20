import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/services/admin_image_service.dart';

class ProductImageSelector extends StatelessWidget {
  const ProductImageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the new Service
    return Consumer<AdminImageService>(
      builder: (context, imageService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImagePicker(
              context,
              imageFile: imageService.selectedImages[0],
              onTap: () => _showImageSourceDialog(context, 0),
            ),
            _buildImagePicker(
              context,
              imageFile: imageService.selectedImages[1],
              onTap: () => _showImageSourceDialog(context, 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePicker(BuildContext context, {File? imageFile, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColour.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColour.primary.withOpacity(0.5)),
        ),
        child: imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(imageFile, fit: BoxFit.cover),
        )
            : Icon(Icons.add_a_photo, size: 40, color: AppColour.primary),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, int imageSlot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColour.white,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: Text('Pick from gallery', style: simple_text_style()),
            onTap: () {
              Navigator.pop(ctx);
              context.read<AdminImageService>().pickImage(imageSlot, false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('Take a photo', style: simple_text_style()),
            onTap: () {
              Navigator.pop(ctx);
              context.read<AdminImageService>().pickImage(imageSlot, true);
            },
          ),
        ],
      ),
    );
  }
}