import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:shimmer/shimmer.dart'; // ✅ Added Shimmer package
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/admin/product/screens/admin_product_details_screen.dart';
import 'package:raising_india/models/model/product.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'available', 'unavailable', 'low_stock'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().fetchAllProducts();
      context.read<CategoryService>().loadCategories();
      context.read<BrandService>().fetchBrands();
    });

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    _fadeAnimationController.forward();

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

  Future<void> _onRefresh() async {
    await context.read<AdminService>().fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: Consumer<AdminService>(
        builder: (context, adminService, _) {
          // ✅ Show Shimmer instead of CircularProgressIndicator
          if (adminService.isLoading && adminService.products.isEmpty) {
            return _buildShimmerLoadingState();
          } else if (adminService.error != null) {
            return _buildErrorState(adminService.error!);
          } else {
            final filteredProducts = _getFilteredProducts(adminService.products);
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColour.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInlineSearchBar(),
                        _buildFilterChips(),
                        _buildStatsHeader(filteredProducts),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: filteredProducts.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildProductCard(filteredProducts[index], index),
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
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
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Inventory',
                  style: simple_text_style(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Manage your product catalog',
                  style: simple_text_style(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products or categories...',
          prefixIcon: Icon(Icons.search, color: AppColour.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip('all', 'All Products'),
          _buildChip('available', 'Available'),
          _buildChip('unavailable', 'Unavailable'),
          _buildChip('low_stock', 'Low Stock', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, {bool isWarning = false}) {
    final isSelected = _selectedFilter == value;
    final activeColor = isWarning ? Colors.orange : AppColour.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        checkmarkColor: AppColour.white,
        label: Text(
          label,
          style: simple_text_style(
            color: isSelected ? Colors.white : (isWarning ? Colors.orange.shade700 : Colors.grey.shade700),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        selectedColor: activeColor,
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? activeColor : Colors.grey.shade300),
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name!.toLowerCase().contains(_searchQuery) ||
          (product.category!.name ?? '').toLowerCase().contains(_searchQuery);

      bool matchesFilter = true;
      if (_selectedFilter == 'available') {
        matchesFilter = product.isAvailable ?? false;
      } else if (_selectedFilter == 'unavailable') {
        matchesFilter = !(product.isAvailable ?? false);
      } else if (_selectedFilter == 'low_stock') {
        matchesFilter = (product.stockQuantity ?? 0) <= (product.lowStockQuantity ?? 10);
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildStatsHeader(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${products.length} products',
            style: simple_text_style(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    final isLowStock = (product.stockQuantity ?? 0) <= (product.lowStockQuantity ?? 10);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock ? Colors.orange.shade300 : Colors.transparent,
          width: isLowStock ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminProductDetailScreen(product: product)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 16),
              Expanded(child: _buildProductInfo(product, isLowStock)),
              _buildProductStatus(product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: product.photosList != null && product.photosList!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: product.photosList!.first,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
        )
            : const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  Widget _buildProductInfo(Product product, bool isLowStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name ?? 'Unknown',
          style: simple_text_style(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '₹${product.price?.toStringAsFixed(0) ?? '0'}',
              style: simple_text_style(color: AppColour.primary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '${product.quantity?.toStringAsFixed(0) ?? '0'} ${product.measurement ?? 'pcs'}',
              style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.inventory_2, size: 12, color: isLowStock ? Colors.orange : Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              'Stock: ${product.stockQuantity ?? 0}',
              style: simple_text_style(
                color: isLowStock ? Colors.orange.shade700 : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductStatus(Product product) {
    final isAvail = product.isAvailable ?? false;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isAvail ? Colors.green.shade50 : Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isAvail ? Icons.check_circle : Icons.cancel,
        size: 20,
        color: isAvail ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('No products found matching your criteria.'),
      ),
    );
  }

  // ✅ NEW: Shimmer Loading State
  Widget _buildShimmerLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer for Search Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Shimmer for Filter Chips
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (context, index) => Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Shimmer for Stats Header Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shimmer for Product List Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShimmerProductCard(),
                childCount: 6, // Show 6 dummy skeleton cards
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Helper for individual Shimmer Cards
  Widget _buildShimmerProductCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          // Image skeleton
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Text block skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 120, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 80, height: 12, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Status icon skeleton
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}