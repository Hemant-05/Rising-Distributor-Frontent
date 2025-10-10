import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/categories/screens/category_product_screen.dart';
import 'package:raising_india/models/category_model.dart';

Widget category_widget(BuildContext context, CategoryModel category) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    height: 120,
    decoration: BoxDecoration(
      color: AppColour.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColour.grey.withOpacity(0.5),
          blurRadius: 2,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CategoryProductScreen(category: category.value),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8),bottom: Radius.circular(2)),
            child: CachedNetworkImage(
              imageUrl: category.image,
              width: double.infinity,
              height: 90,
              fit: BoxFit.cover,
              errorWidget: (context, error, stackTrace) {
                return SizedBox(
                  height: 90,
                    width: double.infinity,
                    child: Icon(Icons.image_not_supported_rounded));
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: simple_text_style(
              color: AppColour.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
