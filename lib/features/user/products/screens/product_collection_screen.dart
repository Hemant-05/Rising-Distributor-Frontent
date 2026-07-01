import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/product.dart';

enum ProductCollectionType { sale, category, brand }

class ProductCollectionScreen extends StatefulWidget {
  final String title;
  final ProductCollectionType type;
  final String? categoryName;
  final Brand? brand;
  final int? brandId;

  const ProductCollectionScreen.sale({super.key})
      : title = 'Sale Products',
        type = ProductCollectionType.sale,
        categoryName = null,
        brand = null,
        brandId = null;

  ProductCollectionScreen.category({
    super.key,
    required this.categoryName,
  })  : title = categoryName ?? 'Category Products',
        type = ProductCollectionType.category,
        brand = null,
        brandId = null;

  ProductCollectionScreen.brand({
    super.key,
    this.brand,
    this.brandId,
  })  : title = brand?.name ?? 'Brand Products',
        type = ProductCollectionType.brand,
        categoryName = null;

  @override
  State<ProductCollectionScreen> createState() => _ProductCollectionScreenState();
}

class _ProductCollectionScreenState extends State<ProductCollectionScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts(showLoader: true));
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _loadProducts(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts({required bool showLoader}) async {
    if (!mounted) return;

    switch (widget.type) {
      case ProductCollectionType.sale:
        await context.read<ProductService>().fetchAvailableProducts(
              forceRefresh: true,
              showLoader: showLoader,
            );
        break;
      case ProductCollectionType.category:
        final category = widget.categoryName?.trim();
        if (category != null && category.isNotEmpty) {
          await context.read<ProductService>().fetchProductsByCategory(category);
        }
        break;
      case ProductCollectionType.brand:
        final brandId = widget.brand?.id ?? widget.brandId;
        if (brandId != null) {
          await context.read<BrandService>().fetchProductsByBrand(brandId);
        }
        break;
    }
  }

  List<Product> _visibleProducts(BuildContext context) {
    switch (widget.type) {
      case ProductCollectionType.sale:
        return context.watch<ProductService>().saleProducts;
      case ProductCollectionType.category:
        return context.watch<ProductService>().categoryProducts;
      case ProductCollectionType.brand:
        return context.watch<BrandService>().brandProducts;
    }
  }

  bool _isLoading(BuildContext context) {
    switch (widget.type) {
      case ProductCollectionType.brand:
        return context.watch<BrandService>().isLoading;
      case ProductCollectionType.sale:
      case ProductCollectionType.category:
        return context.watch<ProductService>().isLoading;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts(context);
    final isLoading = _isLoading(context);

    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColour.primary,
        onRefresh: () => _loadProducts(showLoader: false),
        child: isLoading && products.isEmpty
            ? Center(child: CircularProgressIndicator(color: AppColour.primary))
            : products.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey.shade300,
                        size: 84,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        textAlign: TextAlign.center,
                        style: simple_text_style(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: ProductGrid(products: products),
                  ),
      ),
    );
  }
}
