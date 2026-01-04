import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/features/admin/product/bloc/products_cubit.dart';
import 'package:raising_india/features/admin/services/image_services.dart';
import 'package:raising_india/features/services/stock_management_repository.dart';
import 'package:raising_india/models/product_model.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const AdminProductDetailScreen({super.key, required this.product});
  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen>
    with TickerProviderStateMixin {
  // ✅ Enhanced Controllers for all editable fields
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController mrpController;
  late TextEditingController quantityController;
  late TextEditingController measurementController;
  late TextEditingController stockQuantityController;
  late TextEditingController lowStockController;
  late TextEditingController ratingController;
  late TextEditingController categoryController;
  List<String> photos_list = [];
  List<File> photos_files_list = [];
  List<String> deleted_photos_list = [];
  final ImageServices _imageServices = ImageServices();

  bool isAvailable = false;
  bool loading = false;
  bool _hasUnsavedChanges = false;

  // ✅ Animation Controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize all controllers with product data
    nameController = TextEditingController(text: widget.product.name);
    photos_list.addAll(widget.product.photosList);
    descriptionController = TextEditingController(
      text: widget.product.description,
    );
    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    mrpController = widget.product.mrp == null
        ? TextEditingController(text: (widget.product.price + 5).toString())
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
    categoryController = TextEditingController(text: widget.product.category);
    isAvailable = widget.product.isAvailable;

    // ✅ Initialize animations
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

    // Start animations
    _fadeAnimationController.forward();
    _scaleAnimationController.forward();

    // ✅ Add listeners for unsaved changes detection
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
    categoryController.addListener(_onFieldChanged);
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
    categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      List<String> new_photos_list = await _imageServices.uploadImages(photos_files_list, widget.product.name);
      photos_list.addAll(new_photos_list);
      if(deleted_photos_list.isNotEmpty){
        for(String url in deleted_photos_list){
          await _imageServices.deleteImage(url);
        }
      }
      // ✅ Prepare updated data with validation
      final updatedData = {
        'photos_list': photos_list,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price':
            double.tryParse(priceController.text.trim()) ??
            widget.product.price,
        'mrp': mrpController.text.trim().isEmpty
            ? (widget.product.price + 5)
            : double.parse(mrpController.text.trim()),
        'quantity':
            double.tryParse(quantityController.text.trim()) ??
            widget.product.quantity,
        'measurement': measurementController.text.trim().isNotEmpty
            ? measurementController.text.trim()
            : widget.product.measurement,
        'lowStockQuantity':
            double.tryParse(lowStockController.text.trim()) ?? 10.0,
        'rating':
            double.tryParse(ratingController.text.trim()) ??
            widget.product.rating,
        'category': categoryController.text.trim(),
        'isAvailable': isAvailable,
        'name_lower': nameController.text.trim().toLowerCase(),
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.pid)
          .update(updatedData);

      StockManagementRepository().refillStock(
        widget.product.pid,
        double.tryParse(stockQuantityController.text.trim()) ?? 100.0,
        double.tryParse(lowStockController.text.trim()) ?? 10.0,
      );

      setState(() {
        loading = false;
        _hasUnsavedChanges = false;
      });

      // ✅ Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
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

    if (confirmed == true) {
      context.read<ProductsCubit>().deleteProduct(
        context,
        widget.product.pid,
        widget.product.photosList,
      );
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColour.white,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Pick from gallery', style: simple_text_style()),
            onTap: () async {
              final image = await _imageServices.pickFromGallery();
              if (image != null) {
                setState(() {
                  _hasUnsavedChanges = true;
                  photos_files_list.add(image);
                });
              }
              /*if (image != null) {
                context.read<ImageSelectionCubit>().setImageAtIndex(imageSlot, image);
              }*/
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a photo', style: simple_text_style()),
            onTap: () async {
              final image = await _imageServices.pickFromCamera();
              if (image != null) {
                setState(() {
                  _hasUnsavedChanges = true;
                  photos_files_list.add(image);
                });
              }
              /*if (image != null) {
                context.read<ImageSelectionCubit>().setImageAtIndex(imageSlot, image);
              }*/
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
          // ✅ Main Content
          _buildMainContent(),

          // ✅ Loading Overlay
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
                          'Updating Product...',
                          style: simple_text_style(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColour.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait while we save changes',
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
                if (shouldPop == true) Navigator.pop(context);
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
              child: Icon(
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
          // ✅ Unsaved Changes Indicator
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
        // ✅ Delete Button
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
              // ✅ Product Images Section
              _buildProductImagesSection(),
              const SizedBox(height: 20),

              // ✅ Basic Information Section
              _buildBasicInfoSection(),
              const SizedBox(height: 20),

              // ✅ Pricing & Inventory Section
              _buildPricingSection(),
              const SizedBox(height: 20),

              // ✅ Stock Management Section
              _buildStockManagementSection(),
              const SizedBox(height: 20),

              // ✅ Product Status Section
              _buildStatusSection(),
              const SizedBox(height: 32),

              // ✅ Save Button
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
          // Header
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
                  onTap: () {
                    _showImageSourceDialog(context);
                  },
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
          // Images Content
          const SizedBox(height: 10),
          if(photos_list.isNotEmpty && photos_files_list.isNotEmpty)
          Text('Old Images', style: simple_text_style(color: AppColour.black)),
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
                                border: Border.all(color: AppColour.black,width: 1),
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
          if (photos_files_list.isNotEmpty)...{
            Text('New Images', style: simple_text_style(color: AppColour.black)),
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
                                color: AppColour.black, width: 1),
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
          }
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
            controller: categoryController,
            hintText: 'Select Category',
            icon: Icons.category_outlined,
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
          color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable
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
                    isAvailable
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
              activeColor: AppColour.primary,
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
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
          // Section Header
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

          // Section Content
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
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String label,
  }) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                    child: DropdownMenu(
                      controller: categoryController,
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
                        backgroundColor: MaterialStateProperty.all(
                          AppColour.white,
                        ),
                        elevation: MaterialStateProperty.all(8),
                      ),
                      dropdownMenuEntries: state is CategoryLoaded
                          ? state.categories
                                .map(
                                  (category) => DropdownMenuEntry(
                                    value: category.value,
                                    label: category.name,
                                  ),
                                )
                                .toList()
                          : [],
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
    // ✅ FIXED: Ensure unique values and handle case sensitivity
    final List<Map<String, String>> measurements = [
      {'value': 'KG', 'label': 'Kilogram (kg)'},
      {'value': 'GM', 'label': 'Gram (gm)'},
      {'value': 'LITER', 'label': 'Liter (l)'},
      {'value': 'ML', 'label': 'Milliliter (ml)'},
      {'value': 'PCS', 'label': 'Pieces (pcs)'},
      {
        'value': 'DAR',
        'label': 'Dozen (12 pcs)',
      }, // ✅ Changed from 'Dar' to 'DAR'
    ];

    // ✅ CRITICAL: Normalize the current value to match dropdown values
    String? normalizedCurrentValue;
    if (measurementController.text.isNotEmpty) {
      final currentValue = measurementController.text.trim().toUpperCase();

      // Handle different variations and normalize them
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
          // ✅ If value doesn't match any known measurement, set to null
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
            // ✅ Use normalized value that matches dropdown items
            value: normalizedCurrentValue,
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
            // ✅ Generate unique dropdown items
            items: measurements.map<DropdownMenuItem<String>>((measurement) {
              return DropdownMenuItem<String>(
                value: measurement['value']!, // Each value is unique
                child: Text(
                  measurement['label']!,
                  style: simple_text_style(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                // ✅ Update controller with the selected value
                measurementController.text = value;
                _onFieldChanged();
              }
            },
            // ✅ Add validation
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a measurement unit';
              }
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
}
