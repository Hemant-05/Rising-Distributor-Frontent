import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/models/model/product.dart';

class product_card extends StatelessWidget {
  final Product product;
  final bool isBig;
  const product_card({super.key, required this.product, required this.isBig});

  @override
  Widget build(BuildContext context) {
    final bool unavailable = (product.stockQuantity ?? 0) <= 0;
    final String imageUrl = (product.photosList != null && product.photosList!.isNotEmpty)
        ? product.photosList![0]
        : '';

    return Card.outlined(
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ProductDetailsScreen(product: product),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_rounded, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Product",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: simple_text_style(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category!.name ?? "Category",
                    style: simple_text_style(fontSize: 13, color: AppColour.grey),
                  ),
                  const SizedBox(height: 6),

                  if (unavailable)
                    Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'Unavailable',
                          style: simple_text_style(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        if (isBig && product.mrp != null) ...[
                          Text(
                            '₹${product.mrp}',
                            style: const TextStyle(
                                fontFamily: 'Sen',
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '₹${product.price ?? 0}',
                          style: simple_text_style(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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