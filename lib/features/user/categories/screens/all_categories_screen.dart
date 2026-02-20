import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/category_service.dart';
import 'package:raising_india/features/user/categories/widgets/category_widget.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when screen opens (if not already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('All Categories', style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Consumer<CategoryService>(
        builder: (context, categoryService, child) {
          if (categoryService.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          if (categoryService.categories.isEmpty) {
            return const Center(child: Text('No Categories Found'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: categoryService.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              // Ensure category_widget accepts the new Category model
              itemBuilder: (context, index) => category_widget(
                  context,
                  categoryService.categories[index]
              ),
            ),
          );
        },
      ),
    );
  }
}