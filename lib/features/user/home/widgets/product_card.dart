import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/models/model/product.dart';

class product_card extends StatelessWidget {
  final Product product;
  final bool isBig;
  const product_card({super.key, required this.product, required this.isBig});

  @override
  Widget build(BuildContext context) {
    final bool unavailable = (product.stockQuantity ?? 0) <= 0;
    final String imageUrl =
        (product.photosList != null && product.photosList!.isNotEmpty)
        ? product.photosList![0]
        : '';

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductDetailsScreen(product: product),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColour.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Section ---
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFF8F9FA,
                      ), // Soft background for images
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Optional: Discount Badge Top Left
                  if (product.mrp != null &&
                      product.mrp! > (product.price ?? 0))
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '${(((product.mrp! - product.price!) / product.mrp!) * 100).toStringAsFixed(0)}% OFF',
                          style: simple_text_style(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Details Section ---
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Product",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: simple_text_style(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.measurement ?? "1 item",
                    style: simple_text_style(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Price & Add Button Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.mrp != null &&
                              product.mrp! > (product.price ?? 0))
                            Text(
                              '₹${product.mrp}',
                              style: simple_text_style(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                isLineThrough: true,
                              ),
                            ),
                          Text(
                            '₹${product.price ?? 0}',
                            style: simple_text_style(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Zepto Style Add Button
                      unavailable
                          ? Text(
                              'Out of stock',
                              style: simple_text_style(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                context.read<CartService>().addToCart(product.pid!,1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColour.primary),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ADD',
                                  style: simple_text_style(
                                    color: AppColour.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
