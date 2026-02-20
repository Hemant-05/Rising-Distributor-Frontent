import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';

class CategoryProductScreen extends StatefulWidget {
  const CategoryProductScreen({super.key, required this.category});

  final String category;

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products for this specific category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('============================= ${widget.category}');
      context.read<ProductService>().fetchProductsByCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text(
              widget.category,
              style: simple_text_style(fontSize: 20),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, child) {
          if (productService.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          if (productService.categoryProducts.isEmpty) {
            return const Center(child: Text('No Product in this Category !!!'));
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ProductGrid(products: productService.categoryProducts),
          );
        },
      ),
    );
  }
}