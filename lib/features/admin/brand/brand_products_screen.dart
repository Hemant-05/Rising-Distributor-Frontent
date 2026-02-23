import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/brand_service.dart';
import 'package:raising_india/models/model/brand.dart';

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
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(widget.brand.name ?? "Brand Products", style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<BrandService>(
        builder: (context, brandService, child) {
          if (brandService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (brandService.error.isNotEmpty) {
            return Center(child: Text(brandService.error, style: simple_text_style(color: AppColour.red,)));
          }
          if (brandService.brandProducts.isEmpty) {
            return Center(child: Text("No products found for this brand"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brandService.brandProducts.length,
            itemBuilder: (context, index) {
              final product = brandService.brandProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (product.photosList != null && product.photosList!.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: product.photosList!.first,
                      width: 50, height: 50, fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image),
                  ),
                  title: Text(product.name ?? "", style: simple_text_style(fontWeight: FontWeight.bold)),
                  subtitle: Text("Stock: ${product.stockQuantity}"),
                  trailing: Text("₹${product.price}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}