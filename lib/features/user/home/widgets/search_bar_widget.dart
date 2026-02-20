import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
// Ensure you have this screen created or use a placeholder
import 'package:raising_india/features/user/search/screens/product_search_screen.dart';

Widget search_bar_widget(BuildContext context) {
  return InkWell(
    onTap: () {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const ProductSearchScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.15), // Lighter background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300), // Subtle border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColour.primary),
          const SizedBox(width: 12),
          Text(
            'Search for products or categories...',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}