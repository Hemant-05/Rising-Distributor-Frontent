import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/image_helper.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/category.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  File? _imageFile;
  bool _isUploading = false; // Local loading state for this screen
  String _targetType = 'sales';
  Category? _selectedCategory;
  Brand? _selectedBrand;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
      context.read<BrandService>().fetchBrands();
    });
  }

  Future<void> _pickImage() async {
    try {
      final File? pickedFile = await ImageHelper.pickAndCropImage(
        context: context,
        fromCamera: false,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      // Handle errors
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

    if (_targetType == 'category' && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for this banner'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_targetType == 'brand' && _selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a brand for this banner'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Get services
    final bannerService = context.read<BannerService>();
    final imageService = context.read<ImageService>(); // Needed for uploading

    final error = await bannerService.addBanner(
      _imageFile!,
      imageService,
      redirectRoute: _buildRedirectRoute(),
    );

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

  String? _buildRedirectRoute() {
    switch (_targetType) {
      case 'sales':
        return 'sales';
      case 'category':
        final name = _selectedCategory?.name?.trim();
        return name == null || name.isEmpty
            ? null
            : 'category:${Uri.encodeComponent(name)}';
      case 'brand':
        final id = _selectedBrand?.id;
        return id == null ? null : 'brand:$id';
      case 'none':
        return null;
      default:
        return null;
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
              const SizedBox(height: 20),
              _buildTargetSection(),
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

  Widget _buildTargetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banner Target',
              style: simple_text_style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColour.black,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _targetType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: 'sales', child: Text('Sale products')),
                DropdownMenuItem(value: 'category', child: Text('Category products')),
                DropdownMenuItem(value: 'brand', child: Text('Brand products')),
                DropdownMenuItem(value: 'none', child: Text('No link')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _targetType = value;
                  _selectedCategory = null;
                  _selectedBrand = null;
                });
              },
            ),
            if (_targetType == 'category') ...[
              const SizedBox(height: 12),
              Consumer<CategoryService>(
                builder: (context, categoryService, _) {
                  final categories = _getAllLeafCategories(categoryService.categories)
                      .where((category) => category.id != null)
                      .toList();
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategory?.id,
                    decoration: const InputDecoration(
                      labelText: 'Select category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id!,
                            child: Text(category.name ?? 'Unnamed category'),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      setState(() {
                        _selectedCategory = categories.firstWhere(
                          (category) => category.id == id,
                        );
                      });
                    },
                  );
                },
              ),
            ],
            if (_targetType == 'brand') ...[
              const SizedBox(height: 12),
              Consumer<BrandService>(
                builder: (context, brandService, _) {
                  final brands = brandService.brands
                      .where((brand) => brand.id != null)
                      .toList();
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedBrand?.id,
                    decoration: const InputDecoration(
                      labelText: 'Select brand',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: brands
                        .map(
                          (brand) => DropdownMenuItem<int>(
                            value: brand.id!,
                            child: Text(brand.name ?? 'Unnamed brand'),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      setState(() {
                        _selectedBrand = brands.firstWhere(
                          (brand) => brand.id == id,
                        );
                      });
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
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

  List<Category> _getAllLeafCategories(List<Category> categories) {
    final leafCategories = <Category>[];
    for (final category in categories) {
      final children = category.subCategories ?? [];
      if (children.isEmpty) {
        leafCategories.add(category);
      } else {
        leafCategories.addAll(_getAllLeafCategories(children));
      }
    }
    return leafCategories;
  }
}
