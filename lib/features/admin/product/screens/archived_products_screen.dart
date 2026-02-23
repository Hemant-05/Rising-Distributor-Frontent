import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/product_service.dart';

class ArchivedProductsScreen extends StatefulWidget {
  const ArchivedProductsScreen({super.key});

  @override
  State<ArchivedProductsScreen> createState() => _ArchivedProductsScreenState();
}

class _ArchivedProductsScreenState extends State<ArchivedProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchArchivedProducts();
    });
  }

  void _handleRestore(String pid) async {
    final error = await context.read<ProductService>().restoreProduct(pid);
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product restored!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
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
            Text('Trash / Archived', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, _) {
          if (productService.isLoading && productService.archivedProducts.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          if (productService.archivedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Trash is empty", style: simple_text_style(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productService.archivedProducts.length,
            itemBuilder: (context, index) {
              final product = productService.archivedProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (product.photosList != null && product.photosList!.isNotEmpty)
                        ? CachedNetworkImage(imageUrl: product.photosList!.first, width: 60, height: 60, fit: BoxFit.cover)
                        : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.inventory_2)),
                  ),
                  title: Text(product.name ?? "Unnamed", style: simple_text_style(fontWeight: FontWeight.bold)),
                  subtitle: Text("ID: ${product.pid}", style: simple_text_style(color: Colors.grey, fontSize: 12)),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade700,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text("Restore"),
                    onPressed: () => _handleRestore(product.pid!),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}