import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/image_helper.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/models/model/brand.dart';

class AddBrandScreen extends StatefulWidget {
  final Brand? brand;
  const AddBrandScreen({super.key, this.brand});

  bool get isEdit => brand != null;

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.brand!.name ?? "";
    }
  }

  Future<void> _pickImage() async {
    try {
      final File? pickedFile = await ImageHelper.pickAndCropImage(
        context: context,
        fromCamera: false,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && !widget.isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a brand logo"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageService = context.read<ImageService>();
      final brandService = context.read<BrandService>();

      String? imageUrl;

      // 1. Upload Image
      if (_imageFile != null) {
        imageUrl = await imageService.uploadImage(_imageFile!);
        if (imageUrl == null) {
          throw Exception("Image upload failed. Aborting brand update.");
        }
      } else {
        imageUrl = widget.brand?.imageUrl;
      }

      String? error;

      if (widget.isEdit) {
        Brand updatedBrand = Brand(
          id: widget.brand!.id,
          name: _nameController.text.trim(),
          imageUrl: imageUrl,
        );
        error = await brandService.updateBrand(widget.brand!.id!, updatedBrand);
      } else {
        Brand newBrand = Brand(
          name: _nameController.text.trim(),
          imageUrl: imageUrl,
        );
        error = await brandService.addBrand(newBrand);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.isEdit ? "Brand Updated Successfully!" : "Brand Added Successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(widget.isEdit ? 'Edit Brand' : 'Add Brand', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildImageWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, fit: BoxFit.cover));
    } else if (widget.isEdit && widget.brand?.imageUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(widget.brand!.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => _buildImagePlaceholder())),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () async {
                final croppedImage = await ImageHelper.downloadAndCropImage(
                  context: context,
                  imageUrl: widget.brand!.imageUrl!,
                );
                if (croppedImage != null) {
                  setState(() => _imageFile = croppedImage);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.crop, color: Colors.blue, size: 20),
              ),
            ),
          ),
        ],
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 30, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(widget.isEdit ? "Change Logo" : "Upload Logo", style: simple_text_style(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Brand Name',
          hintText: 'e.g., Apple, Nike',
          prefixIcon: Icon(Icons.branding_watermark, color: AppColour.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter brand name' : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColour.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(widget.isEdit ? 'Save Changes' : 'Create Brand', style: simple_text_style(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}