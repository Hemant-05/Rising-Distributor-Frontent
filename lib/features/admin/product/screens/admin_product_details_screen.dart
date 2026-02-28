import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/data/services/admin_service.dart'; // ✅ Ensure AdminService is imported
import 'package:raising_india/features/admin/services/admin_image_service.dart';
import 'package:raising_india/models/model/product.dart';
import '../../../../models/model/brand.dart';
import '../../../../models/model/category.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final Product product;
  const AdminProductDetailScreen({super.key, required this.product});
  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController mrpController;
  late TextEditingController quantityController;
  late TextEditingController measurementController;
  late TextEditingController stockQuantityController;
  late TextEditingController lowStockController;
  late TextEditingController ratingController;
  late Category selectedCategory;
  late Brand? selectedBrand;
  List<String> photos_list = [];
  List<File> photos_files_list = [];
  List<String> deleted_photos_list = [];
  late ImageService imageService;
  late AdminImageService adminImageService;

  bool available = false;
  bool loading = false;
  String loadingText = ''; // ✅ Dynamic loading text
  bool _hasUnsavedChanges = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    imageService = context.read<ImageService>();
    adminImageService = context.read<AdminImageService>();

    nameController = TextEditingController(text: widget.product.name);
    photos_list.addAll(widget.product.photosList!);
    descriptionController = TextEditingController(
      text: widget.product.description,
    );
    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    mrpController = widget.product.mrp == null
        ? TextEditingController(text: (widget.product.price! + 5).toString())
        : TextEditingController(text: widget.product.mrp.toString());
    quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    measurementController = TextEditingController(
      text: widget.product.measurement ?? '',
    );
    stockQuantityController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '100',
    );
    lowStockController = TextEditingController(
      text: widget.product.lowStockQuantity?.toString() ?? '10',
    );
    ratingController = TextEditingController(
      text: widget.product.rating.toString(),
    );
    selectedCategory = widget.product.category!;
    selectedBrand = widget.product.brand;
    available = widget.product.available ?? false;

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();

    _addChangeListeners();
  }

  void _addChangeListeners() {
    nameController.addListener(_onFieldChanged);
    descriptionController.addListener(_onFieldChanged);
    priceController.addListener(_onFieldChanged);
    mrpController.addListener(_onFieldChanged);
    quantityController.addListener(_onFieldChanged);
    measurementController.addListener(_onFieldChanged);
    stockQuantityController.addListener(_onFieldChanged);
    lowStockController.addListener(_onFieldChanged);
    ratingController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    mrpController.dispose();
    quantityController.dispose();
    measurementController.dispose();
    stockQuantityController.dispose();
    lowStockController.dispose();
    ratingController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (loading) return;

    setState(() {
      loading = true;
      loadingText = 'Saving Changes...'; // ✅ Set specific text
    });

    try {
      List<String> newPhotosList = [];
      for (File file in photos_files_list) {
        String? url = await imageService.uploadImage(file);
        newPhotosList.add(url!);
      }
      photos_list.addAll(newPhotosList);
      if (deleted_photos_list.isNotEmpty) {
        for (String url in deleted_photos_list) {
          await imageService.deleteImage(url);
        }
      }

      Product product = Product(
        pid: widget.product.pid,
        uid: widget.product.uid,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price:
            double.tryParse(priceController.text.trim()) ??
            widget.product.price,
        mrp: mrpController.text.trim().isEmpty
            ? (widget.product.price! + 5)
            : double.parse(mrpController.text.trim()),
        quantity:
            int.tryParse(quantityController.text.trim()) ??
            widget.product.quantity,
        measurement: measurementController.text.trim().isNotEmpty
            ? measurementController.text.trim()
            : widget.product.measurement,
        stockQuantity:
            int.tryParse(stockQuantityController.text.trim()) ??
            widget.product.stockQuantity,
        lowStockQuantity:
            int.tryParse(lowStockController.text.trim()) ??
            widget.product.lowStockQuantity,
        rating:
            double.tryParse(ratingController.text.trim()) ??
            widget.product.rating,
        category: selectedCategory,
        available: available,
        photosList: photos_list,
        brand: selectedBrand,
        nameLower: nameController.text.trim().toLowerCase(),
        lastStockUpdate: DateTime.now(),
        discountable: widget.product.discountable ?? false,
      );

      final error = await context.read<ProductService>().updateProduct(product);

      if (error == null) {
        // ✅ CRITICAL FIX: Sync AdminService list so the previous screen updates instantly!
        await context.read<AdminService>().fetchAllProducts();

        setState(() {
          loading = false;
          _hasUnsavedChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '🎉 Product updated successfully!',
                    style: simple_text_style(color: AppColour.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(error);
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Save Failed: $e",
                    style: simple_text_style(color: AppColour.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Delete Product",
              style: simple_text_style(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete this product?",
              style: simple_text_style(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "This action cannot be undone.",
              style: simple_text_style(
                color: Colors.red.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: simple_text_style(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Delete",
              style: simple_text_style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // ✅ NEW: Handle the deletion with a loading state and auto-navigation
    if (confirmed == true) {
      setState(() {
        loading = true;
        loadingText = 'Deleting Product...'; // ✅ Dynamic text
      });

      final error = await context.read<ProductService>().deleteProduct(
        widget.product.pid!,
      );

      if (error == null) {
        // ✅ CRITICAL FIX: Sync AdminService so the list removes the product instantly
        await context.read<AdminService>().fetchAllProducts();

        if (mounted) {
          setState(() => loading = false);
          Navigator.pop(context); // Go back to the product list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Product deleted successfully',
                    style: simple_text_style(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
            onTap: () async {
              final image = await adminImageService.pickFromGallery();
              if (image != null) {
                setState(() {
                  _hasUnsavedChanges = true;
                  photos_files_list.add(image);
                });
              }
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('Take a photo', style: simple_text_style()),
            onTap: () async {
              final image = await adminImageService.pickFromCamera();
              if (image != null) {
                setState(() {
                  _hasUnsavedChanges = true;
                  photos_files_list.add(image);
                });
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: Stack(
        children: [
          _buildMainContent(),

          // ✅ Loading Overlay with Dynamic Text
          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColour.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loadingText, // ✅ Uses dynamic text (Saving or Deleting)
                          style: simple_text_style(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColour.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait...',
                          style: simple_text_style(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStunningAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _showUnsavedChangesDialog();
                if (shouldPop == true) {
                  if (mounted) Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Product',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update product information',
                  style: simple_text_style(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.orange.shade700, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Modified',
                    style: simple_text_style(
                      color: Colors.orange.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade100.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade300.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade100),
            onPressed: _confirmDelete,
            tooltip: 'Delete Product',
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProductImagesSection(),
              const SizedBox(height: 20),
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildPricingSection(),
              const SizedBox(height: 20),
              _buildStockManagementSection(),
              const SizedBox(height: 20),
              _buildStatusSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImagesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColour.primary.withOpacity(0.1),
                  AppColour.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColour.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.image,
                        color: AppColour.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Product Images',
                      style: simple_text_style(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColour.primary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showImageSourceDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColour.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: AppColour.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (photos_list.isNotEmpty && photos_files_list.isNotEmpty)
            Text(
              'Old Images',
              style: simple_text_style(color: AppColour.black),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: photos_list.isNotEmpty
                ? SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos_list.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColour.black,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: photos_list[index],
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    deleted_photos_list.add(photos_list[index]);
                                    _hasUnsavedChanges = true;
                                    photos_list.removeAt(index);
                                  });
                                },
                                child: Icon(Icons.cancel, color: AppColour.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No images available',
                          style: simple_text_style(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          if (photos_files_list.isNotEmpty) ...{
            Text(
              'New Images',
              style: simple_text_style(color: AppColour.black),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos_files_list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColour.black,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              photos_files_list[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _hasUnsavedChanges = true;
                                photos_files_list.removeAt(index);
                              });
                            },
                            child: Icon(Icons.cancel, color: AppColour.red),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Basic Information',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: nameController,
            label: 'Product Name',
            icon: Icons.shopping_bag_outlined,
            hintText: 'Enter product name',
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: descriptionController,
            label: 'Description',
            icon: Icons.description_outlined,
            hintText: 'Describe your product...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: ratingController,
            label: 'Product Rating (1-5)',
            icon: Icons.star_outline,
            hintText: '4.5',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledDropdown(
            label: 'Category',
            hintText: 'Select Category',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          _buildStyledBrandDropdown(
            label: 'Brand',
            hintText: 'Select Brand',
            icon: Icons.branding_watermark_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionCard(
      title: 'Pricing & Quantity',
      icon: Icons.attach_money_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: mrpController,
            label: 'MRP (₹)',
            icon: Icons.currency_rupee,
            hintText: '99.00',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: priceController,
            label: 'Selling Price (₹)',
            icon: Icons.currency_rupee,
            hintText: '99.00',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: quantityController,
            label: 'Selling Quantity',
            icon: Icons.production_quantity_limits,
            hintText: '500',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildMeasurementDropdown(),
        ],
      ),
    );
  }

  Widget _buildStockManagementSection() {
    return _buildSectionCard(
      title: 'Inventory Management',
      icon: Icons.inventory_outlined,
      child: Row(
        children: [
          Expanded(
            child: _buildStyledTextField(
              controller: stockQuantityController,
              label: 'Stock Quantity',
              icon: Icons.inventory_2_outlined,
              hintText: '100',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStyledTextField(
              controller: lowStockController,
              label: 'Low Stock Alert',
              icon: Icons.warning_amber_outlined,
              hintText: '10',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildSectionCard(
      title: 'Product Status',
      icon: Icons.toggle_on_outlined,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: available ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: available ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: available
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                available ? Icons.check_circle : Icons.cancel,
                color: available
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Availability',
                    style: simple_text_style(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    available
                        ? 'Available for sale'
                        : 'Currently unavailable',
                    style: simple_text_style(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              activeThumbColor: AppColour.primary,
              value: available,
              onChanged: (value) {
                setState(() {
                  available = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColour.primary.withOpacity(0.1),
                  AppColour.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColour.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: simple_text_style(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColour.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: simple_text_style(
            color: AppColour.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            style: simple_text_style(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: simple_text_style(color: AppColour.lightGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(icon, color: AppColour.primary, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDropdown({
    required String hintText,
    required IconData icon,
    required String label,
  }) {
    return Consumer<CategoryService>(
      builder: (context, categoryService, _) {
        if (categoryService.isLoading) {
          return Center(
              child: LinearProgressIndicator(color: AppColour.primary));
        }
        final leafNodeCategories = _getAllLeafCategories(categoryService.categories);
        Category c = widget.product.category!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: simple_text_style(
                color: AppColour.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(icon, color: AppColour.primary, size: 20),
                  ),
                  Expanded(
                    // 1. Specify the generic type <int> since your ID is an integer
                    child: DropdownMenu<int>(
                      onSelected: (selectedId) { // 2. This is the ID, not the index!
                        if (selectedId != null) {
                          // 3. Find the category by matching the ID
                          selectedCategory = leafNodeCategories.firstWhere(
                                (cat) => cat.id == selectedId,
                            orElse: () => leafNodeCategories.first,
                          );
                        }
                      },
                      width: double.infinity,
                      textStyle: simple_text_style(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      hintText: hintText,
                      inputDecorationTheme: InputDecorationTheme(
                        border: InputBorder.none,
                        hintStyle: simple_text_style(
                          color: AppColour.lightGrey,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(
                          AppColour.white,
                        ),
                        elevation: WidgetStateProperty.all(8),
                      ),
                      // 4. FIX: Pass the actual Category ID as the initial selection!
                      initialSelection: c.id,
                      dropdownMenuEntries: leafNodeCategories
                          .map(
                            (category) => DropdownMenuEntry<int>( // Specify type here too
                          value: category.id!, // This is what gets passed to onSelected
                          label: category.name!,
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyledBrandDropdown({
    required String hintText,
    required IconData icon,
    required String label,
  }) {
    return Consumer<BrandService>(
      builder: (context, brandService, _) {
        if (brandService.isLoading) {
          return Center(
              child: LinearProgressIndicator(color: AppColour.primary));
        }

        Brand? b = widget.product.brand ??
            (brandService.brands.isNotEmpty ? brandService.brands.first : null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: simple_text_style(
                color: AppColour.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(icon, color: AppColour.primary, size: 20),
                  ),
                  Expanded(
                    // 1. Specify the type <int> since your Brand ID is an integer
                    child: DropdownMenu<int>(
                      onSelected: (selectedId) { // 2. This is the Brand ID!
                        if (selectedId != null) {
                          // 3. Find the brand by matching the ID
                          selectedBrand = brandService.brands.firstWhere(
                                (brand) => brand.id == selectedId,
                            orElse: () => brandService.brands.first,
                          );
                        }
                      },
                      width: double.infinity,
                      textStyle: simple_text_style(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      hintText: hintText,
                      inputDecorationTheme: InputDecorationTheme(
                        border: InputBorder.none,
                        hintStyle: simple_text_style(
                          color: AppColour.lightGrey,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(
                          AppColour.white,
                        ),
                        elevation: WidgetStateProperty.all(8),
                      ),
                      // 4. FIX: Pass the actual Brand ID for initial selection
                      initialSelection: b?.id,
                      dropdownMenuEntries: brandService.brands
                          .map(
                            (brand) => DropdownMenuEntry<int>( // Specify type here too
                          value: brand.id!, // This is what gets passed to onSelected
                          label: brand.name!,
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeasurementDropdown() {
    final List<Map<String, String>> measurements = [
      {'value': 'KG', 'label': 'Kilogram (kg)'},
      {'value': 'GM', 'label': 'Gram (gm)'},
      {'value': 'LITER', 'label': 'Liter (l)'},
      {'value': 'ML', 'label': 'Milliliter (ml)'},
      {'value': 'PCS', 'label': 'Pieces (pcs)'},
      {'value': 'DAR', 'label': 'Dozen (12 pcs)'},
    ];

    String? normalizedCurrentValue;
    if (measurementController.text.isNotEmpty) {
      final currentValue = measurementController.text.trim().toUpperCase();
      switch (currentValue) {
        case 'KG':
        case 'KILOGRAM':
          normalizedCurrentValue = 'KG';
          break;
        case 'GM':
        case 'GRAM':
        case 'GMS':
          normalizedCurrentValue = 'GM';
          break;
        case 'LITER':
        case 'L':
        case 'LITRE':
          normalizedCurrentValue = 'LITER';
          break;
        case 'ML':
        case 'MILLILITER':
        case 'MILLILITRE':
          normalizedCurrentValue = 'ML';
          break;
        case 'PCS':
        case 'PIECES':
        case 'PIECE':
          normalizedCurrentValue = 'PCS';
          break;
        case 'DAR':
        case 'DARJAN':
        case 'DOZEN':
          normalizedCurrentValue = 'DAR';
          break;
        default:
          normalizedCurrentValue = null;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Measurement Unit',
          style: simple_text_style(
            color: AppColour.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: normalizedCurrentValue,
            dropdownColor: AppColour.white,
            borderRadius: BorderRadius.circular(12),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.straighten,
                color: AppColour.primary,
                size: 20,
              ),
            ),
            hint: Text(
              'Select measurement',
              style: simple_text_style(color: AppColour.lightGrey),
            ),
            items: measurements.map<DropdownMenuItem<String>>((measurement) {
              return DropdownMenuItem<String>(
                value: measurement['value']!,
                child: Text(
                  measurement['label']!,
                  style: simple_text_style(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                measurementController.text = value;
                _onFieldChanged();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please select a measurement unit';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: _hasUnsavedChanges
            ? LinearGradient(
                colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: _hasUnsavedChanges ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _hasUnsavedChanges
            ? [
                BoxShadow(
                  color: AppColour.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: _hasUnsavedChanges && !loading ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save,
              color: _hasUnsavedChanges ? Colors.white : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _hasUnsavedChanges ? 'Save Changes' : 'No Changes to Save',
              style: simple_text_style(
                color: _hasUnsavedChanges ? Colors.white : Colors.grey.shade500,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Unsaved Changes',
              style: simple_text_style(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: simple_text_style(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: simple_text_style(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: simple_text_style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _getAllLeafCategories(List<Category> categories) {
    List<Category> leafNodes = [];

    for (var cat in categories) {
      if (cat.subCategories == null || cat.subCategories!.isEmpty) {
        // It's a final leaf node, add it to the list!
        leafNodes.add(cat);
      } else {
        // It has children, so recursively search inside them and add the results
        leafNodes.addAll(_getAllLeafCategories(cat.subCategories!));
      }
    }

    return leafNodes;
  }
}
