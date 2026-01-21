import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/product/bloc/products_cubit.dart';
import 'package:raising_india/features/admin/product/screens/admin_product_details_screen.dart';
import 'package:raising_india/models/product_model.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen>
    with TickerProviderStateMixin {

  // ✅ Animation Controllers for stunning animations
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // ✅ Search and filter functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'available', 'unavailable'

  @override
  void initState() {
    super.initState();

    // ✅ Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeAnimationController.forward();

    // Add search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.loading) {
            return _buildLoadingState();
          } else if (state.error != null) {
            return _buildErrorState(state.error!);
          } else {
            final filteredProducts = _getFilteredProducts(state.products);
            return _buildProductList(filteredProducts);
          }
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
            colors: [
              AppColour.primary,
              AppColour.primary.withOpacity(0.8),
            ],
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
            child: Icon(
              Icons.inventory_2_outlined,
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
                  'Product Inventory',
                  style: simple_text_style(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your product catalog',
                  style: simple_text_style(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // ✅ Filter Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(Icons.filter_list, color: Colors.white, size: 20),
            tooltip: 'Filter Products',
          ),
        ),
        // ✅ Search Button
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: _showSearchDialog,
            icon: Icon(Icons.search, color: Colors.white, size: 20),
            tooltip: 'Search Products',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColour.primary.withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColour.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColour.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Products...',
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColour.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch your inventory',
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Products',
              style: simple_text_style(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: simple_text_style(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductsCubit>().fetchProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Retry',
                style: simple_text_style(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List products) {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // ✅ Stats Header
          _buildStatsHeader(products),

          // ✅ Products Grid/List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                ProductModel product = products[index];
                return _buildProductCard(product, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List products) {
    final availableProducts = products.where((p) => p.isAvailable).length;
    final unavailableProducts = products.length - availableProducts;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColour.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Products',
                products.length.toString(),
                Icons.inventory_2,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                'Available',
                availableProducts.toString(),
                Icons.check_circle,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                'Unavailable',
                unavailableProducts.toString(),
                Icons.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: simple_text_style(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: simple_text_style(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminProductDetailScreen(product: product),
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ✅ Product Image
                    _buildProductImage(product),
                    const SizedBox(width: 16),

                    // ✅ Product Info
                    Expanded(
                      child: _buildProductInfo(product),
                    ),

                    // ✅ Status Badge & Arrow
                    _buildProductStatus(product),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(dynamic product) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: product.photosList.isNotEmpty
            ? CachedNetworkImage(
          imageUrl : product.photosList.first,
          fit: BoxFit.cover,
          errorWidget: (context, error, stackTrace) => Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.broken_image,
              color: Colors.grey.shade400,
              size: 32,
            ),
          ),
        )
            : Container(
          color: Colors.grey.shade100,
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product.name,
          style: simple_text_style(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Price and Quantity
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColour.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '₹${product.mrp?.toStringAsFixed(0) ?? (product.price + 5).toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Sen',
                  decoration: TextDecoration.lineThrough,
                  color: AppColour.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColour.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '₹${product.price.toStringAsFixed(0)}',
                style: simple_text_style(
                  color: AppColour.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${product.quantity.toStringAsFixed(0)} ${product.measurement ?? 'pcs'}',
                style: simple_text_style(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Category
        if (product.category.isNotEmpty)
          Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                product.category,
                style: simple_text_style(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProductStatus(dynamic product) {
    return Column(
      children: [
        // ✅ Status Badge (removed toggle functionality)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: product.isAvailable
                ? Colors.green.shade100
                : Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: product.isAvailable
                  ? Colors.green.shade300
                  : Colors.red.shade300,
            ),
          ),
          child: Icon(
            product.isAvailable ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: product.isAvailable
                ? Colors.green.shade600
                : Colors.red.shade600,
          ),
        ),
        const SizedBox(height: 12),

        // ✅ Navigate Arrow
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products Found',
            style: simple_text_style(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your product inventory is empty.\nAdd some products to get started!',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ Filter products based on search and filter criteria
  List _getFilteredProducts(List products) {
    return products.where((product) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          (product.category ?? '').toLowerCase().contains(_searchQuery);

      // Availability filter
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'available' && product.isAvailable) ||
          (_selectedFilter == 'unavailable' && !product.isAvailable);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ✅ Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Search Products',
          style: simple_text_style(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Product name or category',
            prefixIcon: Icon(Icons.search, color: AppColour.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColour.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColour.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: Text('Clear', style: simple_text_style(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Search', style: simple_text_style(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Filter Products',
          style: simple_text_style(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'All Products', Icons.inventory_2),
            _buildFilterOption('available', 'Available Only', Icons.check_circle),
            _buildFilterOption('unavailable', 'Unavailable Only', Icons.cancel),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Apply', style: simple_text_style(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilter = newValue ?? 'all';
        });
      },
      title: Row(
        children: [
          Icon(icon, size: 20, color: AppColour.primary),
          const SizedBox(width: 4),
          Text(label, style: simple_text_style(fontSize: 12)),
        ],
      ),
      activeColor: AppColour.primary,
    );
  }
}
