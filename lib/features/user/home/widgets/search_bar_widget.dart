import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/search/screens/product_search_screen.dart';

Widget search_bar_widget(BuildContext context) {
  return InkWell(
    onTap: () {
      PersistentNavBarNavigator.pushNewScreen(
        context, screen: const ProductSearchScreen(),
        withNavBar: false, pageTransitionAnimation: PageTransitionAnimation.fade,
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Search "Milk, Bread, Eggs..."', style: simple_text_style(color: Colors.grey.shade500, fontSize: 15)),
          ),
          Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Icon(Icons.mic_none_rounded, color: AppColour.primary, size: 22), // Voice search visual cue
        ],
      ),
    ),
  );
}