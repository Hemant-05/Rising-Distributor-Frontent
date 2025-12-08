import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/Image_cubit/image_cubit.dart';
import 'package:raising_india/features/admin/add_new_items/bloc/product_bloc/product_bloc.dart';
import 'package:raising_india/features/admin/add_new_items/widgets/product_image_selector_widget.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();
  final TextEditingController _lowStockController = TextEditingController();
  final List<File?> photos_list = [];
  final List<String> photos_list_urls = [];
  bool isAvailable = true;

  // ✅ NEW: Animation controllers for stunning animations
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ NEW: Form validation and loading state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isLoading = false; // ✅ Track loading state locally

  @override
  void initState() {
    super.initState();

    // ✅ Initialize animations
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

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    // Add listeners for form validation
    _addFormListeners();
  }

  void _addFormListeners() {
    _itemNameController.addListener(_validateForm);
    _priceController.addListener(_validateForm);
    _categoryController.addListener(_validateForm);
    _quantityController.addListener(_validateForm);
    _measurementController.addListener(_validateForm);
  }

  // ✅ FIXED: Defer setState to avoid calling during build
  void _validateForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      bool isValid =
          _itemNameController.text.isNotEmpty &&
          _priceController.text.isNotEmpty &&
          _categoryController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _measurementController.text.isNotEmpty;

      if (isValid != _isFormValid) {
        setState(() {
          _isFormValid = isValid;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _measurementController.dispose();
    _ratingController.dispose();
    _stockQuantityController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAdded) {
            // ✅ Hide loading and clear form
            setState(() {
              _isLoading = false;
            });
            _clearForm();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('🎉 Product added successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is ProductAddError) {
            // ✅ Hide loading and show error
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error: ${state.message}')),
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
        },
        builder: (context, state) {
          return Stack(
            children: [
              // ✅ Main UI
              _buildMainUI(),

              // ✅ Loading Overlay
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
                              'Adding Product...',
                              style: simple_text_style(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColour.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please wait while we save your product',
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
          );
        },
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
            child: Icon(Icons.add_box_outlined, color: Colors.white, size: 24),
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
                Text(
                  'Create amazing product listings',
                  style: simple_text_style(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // ✅ Stylish Reset Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : _resetForm, // ✅ Disable during loading
              icon: Icon(Icons.refresh, color: Colors.white, size: 18),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image Selection Section
                _buildImageSection(),
                const SizedBox(height: 24),

                // ✅ Basic Information Section
                _buildBasicInfoSection(),
                const SizedBox(height: 24),

                // ✅ Pricing & Inventory Section
                _buildPricingSection(),
                const SizedBox(height: 24),

                // ✅ Stock Management Section
                _buildStockSection(),
                const SizedBox(height: 24),

                // ✅ Product Details Section
                _buildDetailsSection(),
                const SizedBox(height: 32),

                // ✅ Enhanced Add Button
                _buildAddButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return _buildSectionCard(
      title: 'Product Images',
      icon: Icons.image_outlined,
      isImage : false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload high-quality images to showcase your product',
            style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ProductImageSelector(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Name, Category',
      icon: Icons.info_outlined,
      isImage : false,
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
          _buildStyledDropdown(
            controller: _categoryController,
            hintText: 'Category',
            icon: Icons.category_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionCard(
      title: 'Qty, Price & Measurement',
      isImage: false,
      icon: Icons.scale_outlined,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _mrpController,
            hintText: 'MRP (₹)',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Price is required' : null,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: _priceController,
            hintText: 'Selling Price (₹)',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Price is required' : null,
          ),
          const SizedBox(height: 16),
          _buildStyledTextField(
            controller: _quantityController,
            hintText: 'Quantity',
            icon: Icons.production_quantity_limits,
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Quantity is required' : null,
          ),
          const SizedBox(height: 16),
          _buildMeasurementDropdown(),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    return _buildSectionCard(
      title: 'Inventory Management',
      icon: Icons.inventory_outlined,
      isImage: false,
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
          _buildStyledTextField(
            controller: _ratingController,
            hintText: 'Rating (1-5)',
            icon: Icons.star_outline,
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
      isImage: false,
      icon: Icons.description_outlined,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _itemDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe your product in detail...',
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isImage,
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
                if (isImage)
                  InkWell(
                    onTap: (){

                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColour.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add, color: AppColour.primary, size: 20),
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
        style: simple_text_style(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                child: Icon(icon, color: AppColour.primary, size: 20),
              ),
              Expanded(
                child: DropdownMenu(
                  onSelected: (value) {
                    controller.text = value.toString();
                  },
                  width: double.infinity,
                  textStyle: simple_text_style(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  hintText: hintText,
                  inputDecorationTheme: InputDecorationTheme(
                    border: InputBorder.none,
                    hintStyle: simple_text_style(color: AppColour.lightGrey),
                    contentPadding: EdgeInsets.zero,
                  ),
                  menuStyle: MenuStyle(
                    backgroundColor: MaterialStateProperty.all(AppColour.white),
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
        );
      },
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
            child: DropdownMenu(
              onSelected: (value) =>
                  _measurementController.text = value.toString(),
              width: double.infinity,
              textStyle: simple_text_style(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              hintText: 'Measurement',
              inputDecorationTheme: InputDecorationTheme(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: simple_text_style(color: AppColour.lightGrey),
              ),
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(8),
              ),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'KG', label: 'Kilogram (kg)'),
                DropdownMenuEntry(value: 'GM', label: 'Gram (gm)'),
                DropdownMenuEntry(value: 'LTR', label: 'Liter (l)'),
                DropdownMenuEntry(value: 'ML', label: 'Milliliter (ml)'),
                DropdownMenuEntry(value: 'PCS', label: 'Pieces (pcs)'),
                DropdownMenuEntry(value: 'Dar', label: 'Dozen (12 pcs)'),
              ],
            ),
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
            activeColor: AppColour.primary,
            value: isAvailable,
            onChanged: (value) {
              setState(() {
                isAvailable = value;
              });
              context.read<ProductBloc>().add(ToggleAvailabilityEvent(value));
            },
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: (_isFormValid && !_isLoading) ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: (_isFormValid && !_isLoading)
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
        onPressed: (_isFormValid && !_isLoading)
            ? _addProduct
            : null, // ✅ Disable during loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Adding Product...',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: (_isFormValid && !_isLoading)
                        ? Colors.white
                        : Colors.grey.shade500,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Product to Store',
                    style: simple_text_style(
                      color: (_isFormValid && !_isLoading)
                          ? Colors.white
                          : Colors.grey.shade500,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ✅ FIXED: Clear form with post-frame callback
  void _clearForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _priceController.clear();
      _itemNameController.clear();
      _itemDescriptionController.clear();
      _categoryController.clear();
      photos_list.clear();
      photos_list_urls.clear();
      _quantityController.clear();
      _measurementController.clear();
      _stockQuantityController.clear();
      _ratingController.clear();
      _lowStockController.clear();
      context.read<ImageSelectionCubit>().clearImages();

      setState(() {
        isAvailable = true;
        _isFormValid = false;
      });
    });
  }

  void _resetForm() {
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Details reset successfully!'),
          ],
        ),
        backgroundColor: AppColour.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return; // ✅ Prevent double submission

    try {
      String pid = Uuid().v4();
      setState(() {
        _isLoading = true;
      });
      String itemName = _itemNameController.text.trim();
      photos_list.addAll(context.read<ImageSelectionCubit>().state.images);
      photos_list_urls.addAll(
        await context.read<ImageSelectionCubit>().getImageUrl(
          itemName,
          photos_list,
        ),
      );
      String uid = "admin_dummy_uid";
      double price = double.parse(_priceController.text.trim());
      double mrp = double.parse(_mrpController.text.trim());
      String itemDescription = _itemDescriptionController.text.trim();
      String category = _categoryController.text.trim();
      double sellQuantity = double.parse(_quantityController.text.trim());
      String measurement = _measurementController.text.trim();
      double rating = _ratingController.text.isNotEmpty
          ? double.parse(_ratingController.text.trim())
          : 4.0;
      double stockQuantity = _stockQuantityController.text.isNotEmpty
          ? double.parse(_stockQuantityController.text.trim())
          : 100;
      double lowStockQuantity = _lowStockController.text.isNotEmpty
          ? double.parse(_lowStockController.text.trim())
          : 10;

      ProductModel newItem = ProductModel(
        price: price,
        mrp: mrp,
        name: itemName,
        name_lower: itemName.toLowerCase(),
        description: itemDescription,
        category: category,
        rating: rating,
        quantity: sellQuantity,
        measurement: measurement,
        photos_list: photos_list_urls,
        pid: pid,
        uid: uid,
        isAvailable: isAvailable,
        stockQuantity: stockQuantity,
        lowStockQuantity: lowStockQuantity,
      );

      BlocProvider.of<ProductBloc>(context).add(AddProductEvent(uid, newItem));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
