import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/wishlist_service.dart';
import 'package:raising_india/models/model/product.dart';

class FavoriteButton extends StatelessWidget {
  final Product product;
  final double size;

  const FavoriteButton({super.key, required this.product, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, WishlistService>(
      builder: (context, authService, wishlistService, _) {
        final userId = authService.customer?.uid;
        final isWished = wishlistService.isInWishlist(product.pid!);

        return GestureDetector(
          onTap: () {
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please log in to add to wishlist')),
              );
              return;
            }
            // Trigger optimistic toggle
            wishlistService.toggleWishlist(userId, product);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isWished ? Colors.red.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (!isWished)
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: Icon(
              isWished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isWished ? Colors.red : Colors.grey.shade400,
              size: size,
            ),
          ),
        );
      },
    );
  }
}