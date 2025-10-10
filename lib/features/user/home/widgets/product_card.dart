import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/helper_functions.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/models/product_model.dart';

class product_card extends StatelessWidget {
  final ProductModel product;
  final bool isBig;
  const product_card({super.key, required this.product, required this.isBig});

  @override
  Widget build(BuildContext context) {
    final unavailable = product.isOutOfStock || !product.isAvailable;
    return Card.outlined(
      // Material 3 outlined card
      color: AppColour.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<ProductFunBloc>().add(
            CheckIsInCart(productId: product.pid),
          );
          context.read<ProductFunBloc>().add(
            GetProductByID(productId: product.pid),
          );
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
            // Image with aspect ratio and top badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15, // consistent card top
                  child: CachedNetworkImage(
                    imageUrl: product.photos_list[0],
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_rounded, size: 30),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      '⭐ ${product.rating}',
                      style: simple_text_style(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: simple_text_style(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: simple_text_style(
                      fontSize: 13,
                      color: AppColour.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  unavailable
                      ? Row(
                          children: [
                            Icon(
                              unavailable
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_outline,
                              size: 16,
                              color: unavailable ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Unavailable',
                              style: simple_text_style(
                                fontSize: 10,
                                color: unavailable ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            if (isBig)
                              Text(
                                '₹${product.mrp ?? (product.price + 5).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough
                                ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: simple_text_style(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${calculatePercentage((product.mrp?? product.price + 5) , product.price).toStringAsFixed(0)}% off',
                              style: simple_text_style(
                                fontSize: 10,
                                color: AppColour.green,
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
