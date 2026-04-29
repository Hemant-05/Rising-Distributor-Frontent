import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/categories/screens/all_categories_screen.dart';
import 'package:raising_india/models/model/category.dart';

Widget category_showing_widget(BuildContext context, Category category) {
  final String imageUrl = category.imageUrl ?? '';
  final bool hasImage = imageUrl.isNotEmpty;

  return GestureDetector(
    onTap: () {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: AllCategoriesScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    },
    child: Container(
      width: 76, // Fixed width prevents long category names from breaking the layout
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // --- MODERN CIRCULAR BUBBLE ---
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColour.primary.withOpacity(0.05),
              border: Border.all(color: AppColour.primary.withOpacity(0.15), width: 1.5),
            ),
            padding: const EdgeInsets.all(2), // Gives a slight gap between the border and the image
            child: ClipOval(
              child: hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColour.primary.withOpacity(0.5)),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.category, color: Colors.grey),
              )
                  : Icon(Icons.category_outlined, size: 30, color: AppColour.primary.withOpacity(0.5)),
            ),
          ),

          const SizedBox(height: 8),

          // --- CATEGORY TEXT ---
          Text(
            category.name ?? '',
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: simple_text_style(
              color: AppColour.black,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              // height: 1.1, // Tighter line height for stacked text
            ),
          ),
        ],
      ),
    ),
  );
}