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
    return Consumer<AdminImageService>(
      builder: (context, imageService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageService.selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageService.selectedImages.length,
                  onReorder: (oldIndex, newIndex) {
                    imageService.reorderImages(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    return _buildImageSlot(
                      context,
                      key: ValueKey(imageService.selectedImages[index].path),
                      imageFile: imageService.selectedImages[index],
                      index: index,
                      onRemove: () => imageService.removeImageAtIndex(index),
                    );
                  },
                ),
              ),
            if (imageService.selectedImages.length < 5) ...[
              if (imageService.selectedImages.isNotEmpty) const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColour.primary.withOpacity(0.5),
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 32, color: AppColour.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Add Image (${imageService.selectedImages.length}/5)',
                        style: simple_text_style(
                            color: AppColour.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        );
      },
    );
  }

  Widget _buildImageSlot(BuildContext context,
      {required Key key, required File imageFile, required int index, required VoidCallback onRemove}) {
    return Container(
      key: key,
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColour.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColour.primary.withOpacity(0.5)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColour.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
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
              context.read<AdminImageService>().pickImage(context, false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('Take a photo', style: simple_text_style()),
            onTap: () {
              Navigator.pop(ctx);
              context.read<AdminImageService>().pickImage(context, true);
            },
          ),
        ],
      ),
    );
  }
}