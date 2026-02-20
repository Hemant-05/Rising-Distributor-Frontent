import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/admin/category/screens/add_edit_category_screen.dart';
import 'package:raising_india/models/model/category.dart'; // New Model
import 'package:raising_india/models/model/product.dart'; // New Model

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

  @override
  void initState() {
    super.initState();
    context.read<ProductService>().fetchProductsByCategory(widget.category.name!);
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
            Expanded(child: Text(widget.category.name ?? "Category", style: simple_text_style(fontSize: 20), overflow: TextOverflow.ellipsis,)),
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
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Category', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Edit Category', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, _) {
          return Column(
            children: [
              _buildCategoryHeader(productService.categoryProducts),
              Expanded(
                child: productService.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColour.primary))
                    : productService.categoryProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(productService.categoryProducts),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildCategoryHeader(List list) {
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
              child: (widget.category.imageUrl != null && widget.category.imageUrl!.isNotEmpty)
                  ? Image.network(
                widget.category.imageUrl!,
                width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.category)),
              )
                  : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.category)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.category.name ?? "Unnamed", style: simple_text_style(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('${list.length} products', style: simple_text_style(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                (product.photosList != null && product.photosList!.isNotEmpty) ? product.photosList!.first : '',
                width: 50, height: 50, fit: BoxFit.cover,
                errorBuilder: (_,__,___) => const Icon(Icons.fastfood),
              ),
            ),
            title: Text(product.name ?? "Product", style: simple_text_style(fontWeight: FontWeight.bold)),
            subtitle: Text('₹${product.price}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No products in this category"));
  }

  void _navigateToEditCategory(BuildContext context, Category category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: category),
      ),
    );
    // Reload list if needed
    if (result == true && mounted) {
      context.read<ProductService>().fetchProductsByCategory(widget.category.name!);
      Navigator.pop(context); // Optional: close detail screen after edit
    }
  }

  void _showDeleteCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${widget.category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              if (widget.category.id != null) {
                final error = await context.read<CategoryService>().deleteCategory(widget.category.id!);

                if (error == null) {
                  Navigator.pop(context); // Close Screen
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Category Deleted"), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}