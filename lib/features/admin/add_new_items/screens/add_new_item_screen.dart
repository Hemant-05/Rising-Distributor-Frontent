import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/image_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/admin/services/admin_image_service.dart';
import 'package:raising_india/models/dto/product_request.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/category.dart';

// Styles & Constants
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

// Widgets
import 'package:raising_india/features/admin/add_new_items/widgets/product_image_selector_widget.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen>
    with TickerProviderStateMixin {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();
  final TextEditingController _lowStockController = TextEditingController();

  bool isAvailable = true;
  bool isDiscountable = false;
  Category? selectedCategory; // Track selected category object
  Brand? selectedBrand;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Load Categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
      context.read<BrandService>().fetchBrands();
    });

    // Animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    _addFormListeners();
  }

  void _addFormListeners() {
    _itemNameController.addListener(_validateForm);
    _priceController.addListener(_validateForm);
    _quantityController.addListener(_validateForm);
    _measurementController.addListener(_validateForm);
  }

  void _validateForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      bool isValid =
          _itemNameController.text.isNotEmpty &&
          _priceController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _measurementController.text.isNotEmpty;

      if (isValid != _isFormValid) {
        setState(() => _isFormValid = isValid);
      }
    });
  }

  // ✅ Recursive function to extract all leaf nodes
  List<Category> _getAllLeafCategories(List<Category> categories) {
    List<Category> leafNodes = [];

    for (var cat in categories) {
      if (cat.subCategories == null || cat.subCategories!.isEmpty) {
        // It's a final leaf node (no children), add it!
        leafNodes.add(cat);
      } else {
        // It has children, recursively search inside them
        leafNodes.addAll(_getAllLeafCategories(cat.subCategories!));
      }
    }

    return leafNodes;
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _measurementController.dispose();
    _ratingController.dispose();
    _stockQuantityController.dispose();
    _lowStockController.dispose();
    selectedBrand = null;
    selectedCategory = null;
    _addFormListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: Stack(
        children: [
          _buildMainUI(),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          'Adding Product...',
                          style: simple_text_style(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColour.primary,
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_box_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Product',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _resetForm,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: Text(
                'RESET',
                style: simple_text_style(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainUI() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildPricingSection(),
                const SizedBox(height: 24),
                _buildStockSection(),
                const SizedBox(height: 24),
                _buildDetailsSection(),
                const SizedBox(height: 32),
                _buildAddButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sections ---

  Widget _buildImageSection() {
    return _buildSectionCard(
      title: 'Product Images',
      icon: Icons.image_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload high-quality images to showcase your product',
            style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const ProductImageSelector(), // Now uses AdminImageService internally
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Name, Category',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _itemNameController,
            hintText: 'Product Name',
            icon: Icons.shopping_bag_outlined,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          // Category Dropdown using Consumer
          Consumer<CategoryService>(
            builder: (context, catService, _) {
              if (catService.isLoading) return LinearProgressIndicator(color: AppColour.primary,);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.category_outlined,
                        color: AppColour.primary,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: Builder(
                            builder: (context) {
                              // ✅ 1. Filter the categories to ONLY include leaf nodes
                              final leafCategories = _getAllLeafCategories(catService.categories);

                              // ✅ 2. Safety check: Ensure selectedCategory exists in the new filtered list.
                              // If it doesn't (e.g., if it was a parent category), set it to null to prevent a Flutter crash.
                              if (selectedCategory != null && !leafCategories.contains(selectedCategory)) {
                                selectedCategory = null;
                              }

                              return DropdownButton<Category>(
                                isExpanded: true, // Good practice to prevent text overflow
                                hint: Text(
                                  "Select Category",
                                  style: simple_text_style(
                                    color: AppColour.lightGrey,
                                  ),
                                ),
                                value: selectedCategory,
                                // ✅ 3. Map the filtered leaf categories to the dropdown items
                                items: leafCategories.map((Category cat) {
                                  return DropdownMenuItem<Category>(
                                    value: cat,
                                    child: Text(
                                      cat.name ?? "Unnamed",
                                      style: simple_text_style(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    selectedCategory = newValue;
                                  });
                                },
                              );
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Consumer<BrandService>(
            builder: (context, brandService, _) {
              if (brandService.isLoading) return LinearProgressIndicator(color: AppColour.primary,);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.branding_watermark_rounded,
                        color: AppColour.primary,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Brand>(
                          hint: Text(
                            "Select Brand",
                            style: simple_text_style(
                              color: AppColour.lightGrey,
                            ),
                          ),
                          value: selectedBrand,
                          items: brandService.brands.map((Brand brand) {
                            return DropdownMenuItem<Brand>(
                              value: brand,
                              child: Text(
                                brand.name ?? "Unnamed",
                                style: simple_text_style(),
                              ),
                            );
                          }).toList(),
                          onChanged: (Brand? newValue) {
                            setState(() {
                              selectedBrand = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionCard(
      title: 'Qty, Price & Measurement',
      icon: Icons.scale_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _mrpController,
            hintText: 'MRP (₹)',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: _priceController,
            hintText: 'Selling Price (₹)',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: _quantityController,
            hintText: 'Quantity (e.g. 1)',
            icon: Icons.production_quantity_limits,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildMeasurementDropdown(),

          const SizedBox(height: 16),
          _buildDiscountableToggle(),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    return _buildSectionCard(
      title: 'Inventory Management',
      icon: Icons.inventory_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _stockQuantityController,
            hintText: 'Stock Quantity',
            icon: Icons.inventory_2_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: _lowStockController,
            hintText: 'Low Stock Alert',
            icon: Icons.warning_amber_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildAvailabilityToggle(),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return _buildSectionCard(
      title: 'Product Description',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _ratingController,
            hintText: 'Rating (e.g. 4.5)',
            icon: Icons.star_border_outlined,
            keyboardType: TextInputType.number,
            validator: (value) =>
            value?.isEmpty ?? true ? 'Rating is required' : null,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _itemDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your product...',
                hintStyle: simple_text_style(color: AppColour.lightGrey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.edit_note, color: AppColour.primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic ---

  void _resetForm() {
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details reset successfully!')),
    );
  }

  void _clearForm() {
    _priceController.clear();
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _quantityController.clear();
    _mrpController.clear();
    _measurementController.clear();
    _stockQuantityController.clear();
    _ratingController.clear();
    _lowStockController.clear();
    context.read<AdminImageService>().clearImages();
    setState(() {
      isAvailable = true;
      selectedCategory = null;
      selectedBrand = null;
      _isFormValid = false;
    });
  }

  void _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Get Images from Service
    final images = context
        .read<AdminImageService>()
        .selectedImages
        .whereType<File>()
        .toList();
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one image")),
      );
      return;
    }
    setState(() => _isLoading = true);


    try {
      // Construct Product Model
      final productRequest = ProductRequest(
        name: _itemNameController.text.trim(),
        rating: double.tryParse(_ratingController.text.trim()),
        description: _itemDescriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()),
        mrp: double.tryParse(_mrpController.text.trim()),
        categoryId: selectedCategory!.id,
        brandId : selectedBrand != null ? selectedBrand!.id : null,
        quantity: int.parse(_quantityController.text.trim()), // e.g. "1" or "500"
        measurement: _measurementController.text.trim(), // e.g. "kg"
        stockQuantity: int.tryParse(_stockQuantityController.text.trim()),
        available: isAvailable,
        discountable: isDiscountable,
        lowStockQuantity: int.tryParse(_lowStockController.text.trim()),
        photosList: []
      );
      // Call Service
      final error = await context.read<ProductService>().addProduct(
        productRequest,
        images,
        context.read<ImageService>(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (error == null) {
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Product added successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Helper Widgets (UI) ---

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
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColour.primary.withOpacity(0.1),
                  AppColour.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: simple_text_style(color: AppColour.lightGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: AppColour.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildMeasurementDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.straighten, color: AppColour.primary, size: 20),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(
                  "Measurement",
                  style: simple_text_style(color: AppColour.lightGrey),
                ),
                value: _measurementController.text.isEmpty
                    ? null
                    : _measurementController.text,
                onChanged: (val) =>
                    setState(() => _measurementController.text = val!),
                items: ['kg', 'gm', 'ltr', 'ml', 'pcs', 'dozen']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountableToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isDiscountable ? Icons.check_circle : Icons.cancel,
            color: isDiscountable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discountable Product',
              style: simple_text_style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDiscountable
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
          Switch(
            activeThumbColor: AppColour.primary,
            value: isDiscountable,
            onChanged: (val) => setState(() => isDiscountable = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'In Stock',
              style: simple_text_style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAvailable
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
          Switch(
            activeThumbColor: AppColour.primary,
            value: isAvailable,
            onChanged: (val) => setState(() => isAvailable = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: (_isFormValid && !_isLoading)
            ? LinearGradient(
                colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
              )
            : null,
        color: (_isFormValid && !_isLoading) ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _addProduct : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Add Product',
                style: simple_text_style(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
