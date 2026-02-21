import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/models/model/category.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;
  final int? parentId; // ✅ NEW: Used when adding a sub-category

  const AddEditCategoryScreen({super.key, this.category, this.parentId});

  bool get isEdit => category != null;

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.category!.name ?? "";
    }
  }

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
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final categoryService = context.read<CategoryService>();
    final imageService = context.read<ImageService>();

    String? error;

    if (widget.isEdit) {
      final updatedCategory = Category(
          id: widget.category!.id,
          name: name,
          imageUrl: widget.category!.imageUrl,
          parentCategory: widget.category!.parentCategory,
          subCategories: widget.category!.subCategories
      );

      error = await categoryService.updateCategory(
        category: updatedCategory,
        newImageFile: _imageFile,
        imageService: imageService,
      );
    } else {
      // ✅ Pass the parentId to the service when adding!
      error = await categoryService.addCategory(
        name: name,
        parentId: widget.parentId,
        imageFile: _imageFile,
        imageService: imageService,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        // Force refresh the tree so the new subcategory appears
        await context.read<CategoryService>().loadCategories();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Category Saved!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(widget.isEdit ? 'Edit Category' : 'Add Category', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
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
              if (widget.parentId != null && !widget.isEdit)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("Adding as a sub-category", style: simple_text_style(color: Colors.blue.shade700)),
                    ],
                  ),
                ),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, color: AppColour.primary),
              const SizedBox(width: 8),
              Text('Category Image', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: _buildImageWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_imageFile!, fit: BoxFit.cover));
    } else if (widget.isEdit && widget.category?.imageUrl != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(widget.category!.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => _buildImagePlaceholder()));
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Tap to select', style: simple_text_style(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Category Name',
          labelStyle: simple_text_style(color: AppColour.primary),
          hintText: 'e.g., Smart Phones',
          prefixIcon: Icon(Icons.category_outlined, color: AppColour.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColour.primary, width: 2)),
        ),
        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
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
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
          widget.isEdit ? 'Save Changes' : 'Create Category',
          style: simple_text_style(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}