import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/features/user/categories/widgets/category_widget.dart';
import 'package:raising_india/features/user/categories/screens/category_product_screen.dart';
import 'package:raising_india/models/model/category.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  Category? _selectedRootCategory;

  // This stack keeps track of how deep the user has clicked inside the right pane
  final List<Category> _rightPanePath = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
    });
  }

  // Helper to safely get child categories
  List<Category> _getChildren(Category parent, List<Category> allCategories) {
    if (parent.subCategories != null && parent.subCategories!.isNotEmpty) {
      return parent.subCategories!;
    }
    return allCategories
        .where((c) => c.parentCategory?.id == parent.id)
        .toList();
  }

  // Handle hardware back button
  Future<bool> _onWillPop() async {
    if (_rightPanePath.isNotEmpty) {
      setState(() => _rightPanePath.removeLast());
      return false; // Stay on screen, just went up one level in the right pane
    }
    return true; // Actually pop the screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColour.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'All Categories',
            style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 28),
              onPressed: () {
                // TODO: Navigate to search screen
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<CategoryService>(
          builder: (context, categoryService, child) {
            if (categoryService.isLoading &&
                categoryService.categories.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColour.primary),
              );
            }

            final allCategories = categoryService.categories;
            final rootCategories = allCategories
                .where((c) => c.parentCategory == null)
                .toList();

            if (rootCategories.isEmpty) {
              return Center(
                child: Text(
                  'No Categories Found',
                  style: simple_text_style(color: Colors.grey.shade600),
                ),
              );
            }

            // Auto-select the first category if none is selected
            _selectedRootCategory ??= rootCategories.first;

            // Determine what to show in the right pane
            Category currentParent = _rightPanePath.isEmpty
                ? _selectedRootCategory!
                : _rightPanePath.last;
            List<Category> displayList = _getChildren(
              currentParent,
              allCategories,
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // LEFT SIDEBAR
                // ==========================================
                Container(
                  width: 90,
                  color: Colors.grey.shade50, // Slight off-white for sidebar
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: rootCategories.length,
                    itemBuilder: (context, index) {
                      final category = rootCategories[index];
                      final isSelected =
                          category.id == _selectedRootCategory?.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRootCategory = category;
                            _rightPanePath
                                .clear(); // Reset right pane when changing root
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? AppColour.primary
                                    : Colors.transparent,
                                width: 4, // The blue active indicator line
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColour.primary.withOpacity(0.1)
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    category.imageUrl != null &&
                                        category.imageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: category.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.category,
                                        color: isSelected
                                            ? AppColour.primary
                                            : Colors.grey.shade500,
                                        size: 20,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name ?? 'Unknown',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: simple_text_style(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColour.primary
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Vertical Divider
                Container(width: 1, color: Colors.grey.shade200),

                // ==========================================
                // RIGHT CONTENT AREA
                // ==========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header / Back Button for deep linking
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            if (_rightPanePath.isNotEmpty)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rightPanePath.removeLast()),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: AppColour.primary,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                currentParent.name ?? 'Categories',
                                style: simple_text_style(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grid of Subcategories
                      Expanded(
                        child: displayList.isEmpty
                            ? Center(
                                child: Text(
                                  "No items here",
                                  style: simple_text_style(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: displayList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // 3 items per row in the remaining space
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 16,
                                      childAspectRatio:
                                          0.70, // Taller boxes for image + text
                                    ),
                                itemBuilder: (context, index) {
                                  final childCategory = displayList[index];

                                  return category_widget(
                                    context,
                                    childCategory,
                                    onTap: () {
                                      final children = _getChildren(
                                        childCategory,
                                        allCategories,
                                      );

                                      if (children.isNotEmpty) {
                                        // It has children, drill down!
                                        setState(
                                          () =>
                                              _rightPanePath.add(childCategory),
                                        );
                                      } else {
                                        // It's a leaf node, go to products!
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: CategoryProductScreen(
                                            category: childCategory.name ?? '',
                                          ),
                                          withNavBar: false,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
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
