import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/features/user/categories/screens/all_categories_screen.dart';
import 'category_showing_widget.dart';

Widget categories_section(BuildContext context) {
  return Consumer<CategoryService>(
    builder: (context, categoryService, _) {
      if(categoryService.isLoading && categoryService.categories.isEmpty){
        return SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: AppColour.primary)),
        );
      }

      // ✅ IMPLEMENTATION UPGRADE: Only show top-level "Root" categories on the Home Screen!
      final rootCategories = categoryService.categories
          .where((c) => c.parentCategory == null)
          .toList();

      if (rootCategories.isEmpty) return const SizedBox.shrink();

      // Show up to 8 items horizontally (users expect to scroll this list)
      final displayList = rootCategories.take(8).toList();

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: simple_text_style(
                    color: AppColour.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const AllCategoriesScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Text(
                  'See All',
                  style: simple_text_style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColour.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110, // Adjusted height for the new circular widgets
            width: double.infinity,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                return category_showing_widget(context, displayList[index]);
              },
            ),
          ),
        ],
      );
    },
  );
}