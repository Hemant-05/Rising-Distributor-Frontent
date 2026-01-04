import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/features/admin/category/screens/add_edit_category_screen.dart';
import 'package:raising_india/models/category_model.dart';
import 'package:raising_india/models/product_model.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: widget.category.value)
          .get();

      setState(() {
        products = snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e',style: simple_text_style(color: AppColour.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(widget.category.name,style: simple_text_style(fontSize: 20),),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppColour.white,
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteCategoryDialog(context);
              } else if (value == 'edit') {
                _navigateToEditCategory(context, widget.category);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Category', style: simple_text_style(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Edit Category', style: simple_text_style(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Header
          _buildCategoryHeader(),

          // Products List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColour.primary,))
                : products.isEmpty
                ? _buildEmptyState()
                : _buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.category.image.isNotEmpty
                  ? Image.network(
                widget.category.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category_outlined),
                ),
              )
                  : Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: simple_text_style(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Value: ${widget.category.value}',
                    style: simple_text_style(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${products.length} products available',
                    style: simple_text_style(
                      color: Colors.orange.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          color: AppColour.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.photosList.isNotEmpty
                        ? product.photosList.first
                        : '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fastfood),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: simple_text_style(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.quantity} ${product.measurement}',
                        style: simple_text_style(
                          color: AppColour.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: simple_text_style(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColour.green,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColour.green.withOpacity(0.2)
                                  : AppColour.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.isAvailable ? 'Available' : 'Out of Stock',
                              style: simple_text_style(
                                color: product.isAvailable
                                    ? AppColour.green
                                    : AppColour.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: simple_text_style(
              fontSize: 18,
              color: AppColour.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products in this category yet',
            style: simple_text_style(
              color: AppColour.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context, CategoryModel category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<CategoryBloc>(context),
          child: AddEditCategoryScreen(category: category),
        ),
      ),
    );

    // ✅ Reload categories if operation was successful
    if (result == true) {
      if (mounted) {
        context.read<CategoryBloc>().add(LoadCategories());
        Navigator.pop(context);
      }
    }
  }

  void _showDeleteCategoryDialog(BuildContext screenContext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColour.white,
        title: Text('Delete Category',style: simple_text_style(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${widget.category.name}"?',style: TextStyle(fontFamily: 'Sen'),),
            const SizedBox(height: 8),
            Text(
              'This category has ${products.length} products. The products will not be deleted, but they will need to be recategorized.',
              style: TextStyle(
                fontFamily: 'Sen',
                color: AppColour.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',style: simple_text_style(),),
          ),
          InkWell(
            onTap: () {
              context.read<CategoryBloc>().add(DeleteCategory(widget.category.id, widget.category.image));
              Navigator.pop(context);
              Navigator.pop(screenContext);
            },
            child: Text('Delete',style: simple_text_style(color: AppColour.red,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }
}
