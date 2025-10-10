import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/categories/screens/all_categories_screen.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';
import 'package:raising_india/models/category_model.dart';
import '../../../../constant/AppData.dart';
import 'category_showing_widget.dart';

Widget categories_section(BuildContext context) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Categories',
            style: simple_text_style(color: AppColour.black, fontSize: 20,fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryProductBloc>().add(FetchCategories());
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AllCategoriesScreen(),
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
      const SizedBox(height: 10),
      SizedBox(
        height: 120,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            category_showing_widget(context, CategoryModel.fromMap(categories[0], '')),
            category_showing_widget(context, CategoryModel.fromMap(categories[1], '')),
            category_showing_widget(context, CategoryModel.fromMap(categories[2], '')),
          ],
        ),
      ),
    ],
  );
}
