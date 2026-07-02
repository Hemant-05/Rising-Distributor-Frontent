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

  const ProductCollectionScreen.category({
    super.key,
    required this.categoryName,
  }) : title = categoryName ?? 'Category Products',
       type = ProductCollectionType.category,
       brand = null,
       brandId = null;

  ProductCollectionScreen.brand({super.key, this.brand, this.brandId})
    : title = brand?.name ?? 'Brand Products',
      type = ProductCollectionType.brand,
      categoryName = null;

  @override
  State<ProductCollectionScreen> createState() =>
      _ProductCollectionScreenState();
}

class _ProductCollectionScreenState extends State<ProductCollectionScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadProducts(showLoader: true),
    );
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
          await context.read<ProductService>().fetchProductsByCategory(
            category,
            showLoader: showLoader,
          );
        }
        break;
      case ProductCollectionType.brand:
        final brandId = widget.brand?.id ?? widget.brandId;
        if (brandId != null) {
          await context.read<BrandService>().fetchProductsByBrand(
            brandId,
            showLoader: showLoader,
          );
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

  String? _errorMessage(BuildContext context) {
    switch (widget.type) {
      case ProductCollectionType.brand:
        final error = context.watch<BrandService>().error;
        return error.isEmpty ? null : error;
      case ProductCollectionType.sale:
      case ProductCollectionType.category:
        return context.watch<ProductService>().error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts(context);
    final isLoading = _isLoading(context);
    final error = _errorMessage(context);

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
                    error == null
                        ? Icons.inventory_2_outlined
                        : Icons.error_outline,
                    color: error == null
                        ? Colors.grey.shade300
                        : Colors.red.shade300,
                    size: 84,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error == null
                        ? 'No products found'
                        : 'Failed to load products',
                    textAlign: TextAlign.center,
                    style: simple_text_style(
                      color: error == null
                          ? Colors.grey.shade600
                          : Colors.red.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: simple_text_style(
                          color: Colors.redAccent,
                          isEllipsisAble: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadProducts(showLoader: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColour.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          'Retry',
                          style: simple_text_style(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
