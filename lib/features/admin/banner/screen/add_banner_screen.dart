import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/image_service.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false; // Local loading state for this screen

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle permission errors
    }
  }

  Future<void> _handleAddBanner() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an image for Banner',
            style: simple_text_style(color: AppColour.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Get services
    final bannerService = context.read<BannerService>();
    final imageService = context.read<ImageService>(); // Needed for uploading

    final error = await bannerService.addBanner(_imageFile!, imageService);

    if (mounted) {
      setState(() => _isUploading = false);
      if (error == null) {
        Navigator.pop(context); // Go back on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Add New Banner', style: simple_text_style(fontSize: 18)),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploading ? null : _handleAddBanner,
                style: elevated_button_style(),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Add Banner',
                        style: simple_text_style(
                          color: AppColour.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),

          // Optional: Overlay while uploading
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: AppColour.primary),
            const SizedBox(width: 8),
            Text(
              'Banner Image',
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _buildImageWidget(),
            ),
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              _imageFile != null ? 'Change Image' : 'Select Image',
              style: simple_text_style(),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Select Image',
          style: simple_text_style(color: AppColour.lightGrey, fontSize: 14),
        ),
      ],
    );
  }
}
