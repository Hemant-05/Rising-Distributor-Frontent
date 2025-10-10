import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/search/screens/product_search_screen.dart';

Widget search_bar_widget(BuildContext context) {
  return InkWell(
    onTap: () {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ProductSearchScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColour.lightGrey),
          const SizedBox(width: 16),
          Text(
            'Search for products or categories',
            style: simple_text_style(
              color: AppColour.lightGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}