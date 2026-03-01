import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/data/services/wishlist_service.dart';
import 'package:raising_india/models/model/product.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthService>().customer?.uid;
      if (userId != null) {
        context.read<WishlistService>().fetchWishlist(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().customer?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('My Wishlist', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<WishlistService>(
        builder: (context, wishlistService, _) {
          if (wishlistService.isLoading && wishlistService.items.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          if (wishlistService.items.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistService.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = wishlistService.items[index].product;
              if (product == null) return const SizedBox.shrink();

              return _buildWishlistItem(context, product, userId!);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, Product product, String userId) {
    final imageUrl = (product.photosList != null && product.photosList!.isNotEmpty)
        ? product.photosList!.first
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 80, height: 80, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported)),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Unknown',
                  style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price?.toStringAsFixed(0) ?? '0'}',
                  style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Actions (Remove & Add to Cart)
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => context.read<WishlistService>().toggleWishlist(userId, product),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColour.primary,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // Add to Cart and optionally remove from wishlist
                  context.read<CartService>().addToCart(product.pid!, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to Cart!'), backgroundColor: Colors.green),
                  );
                },
                child: Text('Add', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Your Wishlist is Empty', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Save your favorite items to view them later.', style: simple_text_style(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}