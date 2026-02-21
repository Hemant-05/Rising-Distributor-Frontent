import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/admin/category/screens/add_edit_category_screen.dart';
import 'package:raising_india/models/model/category.dart';
import 'package:raising_india/models/model/product.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  // ✅ Store the category in local state so we can update it after editing
  late Category _currentCategory;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;

    // Fetch the products for this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchProductsByCategory(_currentCategory.name!);
    });
  }

  // ✅ Recursive helper to find the updated category from the tree after editing
  Category? _findCategoryInTree(List<Category> categories, int targetId) {
    for (var cat in categories) {
      if (cat.id == targetId) return cat;
      if (cat.subCategories != null && cat.subCategories!.isNotEmpty) {
        final found = _findCategoryInTree(cat.subCategories!, targetId);
        if (found != null) return found;
      }
    }
    return null;
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
            Expanded(
              child: Text(
                _currentCategory.name ?? "Category",
                style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Consumer<ProductService>(
            builder: (context, productService, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildCategoryHeader(productService.categoryProducts),
                  ),
                  if (productService.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (productService.categoryProducts.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildProductCard(productService.categoryProducts[index]),
                          childCount: productService.categoryProducts.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // ✅ Beautiful Loading Overlay during Deletion
          if (_isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Deleting Category...',
                          style: simple_text_style(fontWeight: FontWeight.bold),
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

  // ✅ Redesigned Category Header
  Widget _buildCategoryHeader(List<Product> list) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Image & Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (_currentCategory.imageUrl != null && _currentCategory.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: _currentCategory.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(Icons.category, color: AppColour.primary, size: 30),
                    )
                        : Icon(Icons.category, color: AppColour.primary, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCategory.name ?? "Unnamed",
                        style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${list.length} Products',
                          style: simple_text_style(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // ✅ Interactive Action Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _navigateToEditCategory(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit Category', style: simple_text_style(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: InkWell(
                  onTap: () => _showDeleteCategoryDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('Delete', style: simple_text_style(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Modern Product List Cards
  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (product.photosList != null && product.photosList!.isNotEmpty)
                ? CachedNetworkImage(
              imageUrl: product.photosList!.first,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const Icon(Icons.inventory_2, color: Colors.grey),
            )
                : const Icon(Icons.inventory_2, color: Colors.grey),
          ),
        ),
        title: Text(
          product.name ?? "Product",
          style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                '₹${product.price?.toStringAsFixed(0)}',
                style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '• Stock: ${product.stockQuantity ?? 0}',
                style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Optional: Navigate to product details
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "Add products to this category to see them here.",
            style: simple_text_style(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ✅ Properly sync state after editing
  void _navigateToEditCategory(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: _currentCategory),
      ),
    );

    if (result == true && mounted) {
      // 1. Refresh the main categories tree
      await context.read<CategoryService>().loadCategories();

      // 2. Find the newly updated version of this category from the refreshed tree
      if (mounted) {
        final categories = context.read<CategoryService>().categories;
        final updatedCategory = _findCategoryInTree(categories, _currentCategory.id!);

        if (updatedCategory != null) {
          setState(() {
            _currentCategory = updatedCategory; // UI INSTANTLY UPDATES!
          });
          // Re-fetch products just in case category name changed
          context.read<ProductService>().fetchProductsByCategory(_currentCategory.name!);
        }
      }
    }
  }

  void _showDeleteCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Category'),
          ],
        ),
        content: Text('Are you sure you want to delete "${_currentCategory.name}"?\nAll nested sub-categories will also be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Close Dialog

              setState(() => _isDeleting = true); // Show loading overlay

              if (_currentCategory.id != null) {
                final error = await context.read<CategoryService>().deleteCategory(_currentCategory.id!);

                if (error == null) {
                  // ✅ CRITICAL: Sync parent screen state before popping!
                  await context.read<CategoryService>().loadCategories();

                  if (mounted) {
                    setState(() => _isDeleting = false);
                    Navigator.pop(context); // Go back to Category List Screen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Category Deleted"), backgroundColor: Colors.green));
                  }
                } else {
                  if (mounted) {
                    setState(() => _isDeleting = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}