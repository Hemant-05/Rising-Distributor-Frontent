import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/features/admin/category/screens/add_edit_category_screen.dart';
import 'package:raising_india/features/admin/category/screens/category_products_screen.dart';
import 'package:raising_india/models/model/category.dart';

class AdminCategoriesScreen extends StatefulWidget {
  final Category? parentCategory; // ✅ Pass this to view sub-categories

  const AdminCategoriesScreen({super.key, this.parentCategory});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Only fetch from network if we are at the root level
    if (widget.parentCategory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CategoryService>().loadCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If parent is null, we are at Root. Otherwise, we are inside a folder.
    final isRoot = widget.parentCategory == null;
    final title = isRoot ? 'Categories' : widget.parentCategory!.name ?? 'Sub-Categories';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToAddCategory(context),
            icon: Icon(Icons.add_circle, color: AppColour.primary, size: 28),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: Consumer<CategoryService>(
        builder: (context, categoryService, child) {
          if (categoryService.isLoading && isRoot) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary,));
          }

          // Decide which list to show
          List<Category> displayList = isRoot
              ? categoryService.categories // Top level
              : widget.parentCategory!.subCategories ?? []; // Nested level

          if (displayList.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildCategoryTile(context, displayList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    // Check if this category has children
    final hasChildren = category.subCategories != null && category.subCategories!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                ? Image.network(category.imageUrl!, fit: BoxFit.cover)
                : Icon(
              hasChildren ? Icons.folder : Icons.category, // ✅ Visual cue
              color: AppColour.primary,
            ),
          ),
        ),
        title: Text(
          category.name ?? "Unnamed",
          style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hasChildren ? '${category.subCategories!.length} Sub-categories' : 'No Sub-categories',
          style: simple_text_style(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _navigateToEditCategory(context, category),
            ),
            Icon(
              hasChildren ? Icons.chevron_right : Icons.arrow_forward,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        onTap: () {
          if (hasChildren) {
            // Drill down into sub-categories!
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminCategoriesScreen(parentCategory: category),
              ),
            );
          } else {
            // It's a leaf node, show products!
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(category: category),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            widget.parentCategory == null ? 'No Root Categories' : 'No Sub-Categories',
            style: simple_text_style(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add one.',
            style: simple_text_style(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(
          parentId: widget.parentCategory?.id, // ✅ Pass parent ID if we are inside a folder
        ),
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: category),
      ),
    );
  }
}