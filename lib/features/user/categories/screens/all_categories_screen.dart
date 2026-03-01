import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/features/user/categories/widgets/category_widget.dart';
import 'package:raising_india/features/user/categories/screens/category_product_screen.dart';
import 'package:raising_india/models/model/category.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final List<Category> _breadcrumb = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
    });
  }

  // Handle Android Hardware Back Button to go up the tree instead of exiting app
  Future<bool> _onWillPop() async {
    if (_breadcrumb.isNotEmpty) {
      setState(() {
        _breadcrumb.removeLast();
      });
      return false; // Stay on screen, just went up one level
    }
    return true; // Actually pop the screen
  }

  // Helper to get the current list of categories to display
  List<Category> _getCurrentCategories(List<Category> allCategories) {
    if (_breadcrumb.isEmpty) {
      // Show Root Categories (Items with no parent)
      return allCategories.where((c) => c.parentCategory == null).toList();
    } else {
      // Show Subcategories of the current active breadcrumb
      final currentCategory = _breadcrumb.last;

      // If the backend provides nested children natively
      if (currentCategory.subCategories != null && currentCategory.subCategories!.isNotEmpty) {
        return currentCategory.subCategories!;
      }

      // Fallback: If backend provides a flat list, filter by parent ID manually
      return allCategories.where((c) => c.parentCategory?.id == currentCategory.id).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: AppColour.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Row(
            children: [
              // Custom Back Button logic
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
                onPressed: () async {
                  if (await _onWillPop()) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 8),
              Text('Categories', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        body: Consumer<CategoryService>(
          builder: (context, categoryService, child) {
            if (categoryService.isLoading && categoryService.categories.isEmpty) {
              return Center(child: CircularProgressIndicator(color: AppColour.primary));
            }

            final displayList = _getCurrentCategories(categoryService.categories);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BREADCRUMB ROUTE UI ---
                Container(
                  width: double.infinity,
                  color: AppColour.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Root "All" Button
                        GestureDetector(
                          onTap: () => setState(() => _breadcrumb.clear()),
                          child: Text(
                              "All",
                              style: simple_text_style(
                                color: _breadcrumb.isEmpty ? AppColour.primary : Colors.grey.shade600,
                                fontWeight: _breadcrumb.isEmpty ? FontWeight.bold : FontWeight.w500,
                              )
                          ),
                        ),

                        // Dynamic Path Segments
                        ..._breadcrumb.asMap().entries.map((entry) {
                          int idx = entry.key;
                          Category cat = entry.value;
                          bool isLast = idx == _breadcrumb.length - 1;

                          return Row(
                            children: [
                              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                              GestureDetector(
                                onTap: () {
                                  // Jump back to this specific level in the tree
                                  setState(() {
                                    _breadcrumb.removeRange(idx + 1, _breadcrumb.length);
                                  });
                                },
                                child: Text(
                                  cat.name ?? "Unknown",
                                  style: simple_text_style(
                                    color: isLast ? AppColour.primary : Colors.grey.shade600,
                                    fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // --- CATEGORY GRID ---
                Expanded(
                  child: displayList.isEmpty
                      ? Center(
                    child: Text(
                      'No Categories Found',
                      style: simple_text_style(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8, // Adjusted to fit the new widget shape
                    ),
                    itemBuilder: (context, index) {
                      final category = displayList[index];

                      return category_widget(
                        context,
                        category,
                        onTap: () {
                          // Check if this category has children
                          final hasChildren = (category.subCategories != null && category.subCategories!.isNotEmpty) ||
                              categoryService.categories.any((c) => c.parentCategory?.id == category.id);

                          if (hasChildren) {
                            // DRILL DOWN: Add to breadcrumb and show children
                            setState(() {
                              _breadcrumb.add(category);
                            });
                          } else {
                            // LEAF NODE: Navigate to products screen!
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: CategoryProductScreen(category: category.name ?? ''),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}