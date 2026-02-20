import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/categories/screens/category_product_screen.dart';
import 'package:raising_india/models/model/category.dart';

Widget category_showing_widget(BuildContext context, Category category) {

  return Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    // ... decoration ...
    child: InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CategoryProductScreen(category: category.name ?? ''),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // If you have icons/images in your Category model:
          category.imageUrl != null
              ? ClipRRect(child: Image.network(category.imageUrl!))
              : const Icon(Icons.category, size: 40, color: Colors.grey),

          const SizedBox(height: 4),
          Text(
            category.name ?? '',
            style: simple_text_style(
              color: AppColour.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
