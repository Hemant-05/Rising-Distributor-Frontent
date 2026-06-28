import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/features/admin/product/screens/admin_product_details_screen.dart';
import 'package:raising_india/features/admin/widgets/admin_responsive.dart';
import 'package:raising_india/models/model/brand.dart';
import 'package:raising_india/models/model/product.dart';

class BrandProductsScreen extends StatefulWidget {
  final Brand brand;
  const BrandProductsScreen({super.key, required this.brand});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.brand.id != null) {
        context.read<BrandService>().fetchProductsByBrand(widget.brand.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.brand.name ?? 'Brand Products',
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<BrandService>(
        builder: (context, brandService, child) {
          if (brandService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (brandService.error.isNotEmpty) {
            return AdminPageShell(
              child: Center(
                child: Text(
                  brandService.error,
                  textAlign: TextAlign.center,
                  style: simple_text_style(color: AppColour.red),
                ),
              ),
            );
          }
          if (brandService.brandProducts.isEmpty) {
            return _buildEmptyState();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >= AdminResponsive.desktopBreakpoint;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AdminResponsive.maxContentWidth,
                  ),
                  child: isDesktop
                      ? _buildDesktopGrid(brandService.brandProducts)
                      : _buildMobileList(brandService.brandProducts),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 150,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) =>
          _buildProductTile(products[index], compact: false),
    );
  }

  Widget _buildMobileList(List<Product> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildProductTile(products[index], compact: true),
    );
  }

  Widget _buildProductTile(Product product, {required bool compact}) {
    final imageUrl =
        product.photosList != null && product.photosList!.isNotEmpty
        ? product.photosList!.first
        : null;
    final stock = product.stockQuantity ?? 0;
    final isLowStock = stock <= (product.lowStockQuantity ?? 10);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminProductDetailScreen(product: product),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: compact ? 64 : 78,
                  height: compact ? 64 : 78,
                  color: Colors.grey.shade100,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_outlined, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name ?? 'Product',
                      style: simple_text_style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _pill(
                          'Rs. ${product.price?.toStringAsFixed(0) ?? '-'}',
                          AppColour.primary,
                        ),
                        _pill(
                          'Stock $stock',
                          isLowStock ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: simple_text_style(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AdminPageShell(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found for this brand',
              style: simple_text_style(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
