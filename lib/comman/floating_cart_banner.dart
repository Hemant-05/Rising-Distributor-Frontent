// floating_cart_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/cart_service.dart';

class FloatingCartBanner extends StatelessWidget {
  final VoidCallback onCartTap; // ✅ Add this to handle navigation

  const FloatingCartBanner({super.key, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final cartItems = cartService.cartItems;

        if (cartItems.isEmpty) return const SizedBox.shrink();

        int totalItems = cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 1));
        double totalPrice = 0;
        double mrpTotal = 0;

        for (var item in cartItems) {
          final qty = item.quantity ?? 1;
          totalPrice += (item.product?.price ?? 0) * qty;
          mrpTotal += (item.product?.mrp ?? item.product?.price ?? 0) * qty;
        }

        double savings = mrpTotal - totalPrice;
        String? firstImage;
        if (cartItems.first.product?.photosList != null && cartItems.first.product!.photosList!.isNotEmpty) {
          firstImage = cartItems.first.product!.photosList!.first;
        }

        return Container(
          decoration: BoxDecoration(color: Colors.grey.shade50),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: firstImage != null
                        ? Image.network(firstImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, color: Colors.grey))
                        : const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$totalItems Item${totalItems > 1 ? 's' : ''}', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (savings > 0)
                        Text('You save ₹${savings.toStringAsFixed(0)}', style: simple_text_style(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColour.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: onCartTap, // ✅ Trigger the navigation passed from MainScreen
                  child: Text('View Cart', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}