import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/helper_functions.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/product_details/widgets/build_detail_chip.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../bloc/product_funtction_bloc/product_fun_bloc.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key, required this.product});
  final ProductModel product;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFunBloc, ProductFunState>(
      builder: (context, state) {
        var totalPrice = product.price * state.quantity;
        var mrpTotal = (product.mrp ?? product.price + 5) * state.quantity;
        return state.isLoadingProductDetails
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                ),
              )
            : Scaffold(
                backgroundColor: AppColour.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      back_button(),
                      const SizedBox(width: 10),
                      Text(
                        "Product Details",
                        style: simple_text_style(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColour.black,
                        ),
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Enhanced Image Slider with Overlay
                                  Container(
                                    height: 280,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColour.black.withOpacity(
                                            0.08,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          itemCount: product.photos_list.length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    product.photos_list[index],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                progressIndicatorBuilder:
                                                    (context, child, progress) {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              value: progress
                                                                  .progress,
                                                              color: AppColour
                                                                  .primary,
                                                              strokeWidth: 2,
                                                            ),
                                                      );
                                                    },
                                                errorWidget:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: AppColour.lightGrey
                                                          .withOpacity(0.1),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          size: 60,
                                                          color: AppColour
                                                              .lightGrey,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Image Count Overlay
                                        Positioned(
                                          bottom: 16,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: SmoothPageIndicator(
                                              controller: _pageController,
                                              count: product.photos_list.length,
                                              effect: ExpandingDotsEffect(
                                                activeDotColor:
                                                    AppColour.primary,
                                                dotColor: Colors.white
                                                    .withOpacity(0.5),
                                                dotHeight: 8,
                                                dotWidth: 8,
                                                expansionFactor: 3,
                                                spacing: 4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Product Name
                                  Text(
                                    state.product!.name,
                                    style: simple_text_style(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColour.black,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Rating Row with Stars
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index <
                                                    state.product!.rating
                                                        .round()
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: AppColour.primary,
                                            size: 20,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${state.product!.rating.toStringAsFixed(1)})',
                                        style: TextStyle(
                                          fontFamily: 'Sen',
                                          fontSize: 14,
                                          color: AppColour.lightGrey,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColour.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${10} Reviews',
                                          style: TextStyle(
                                            fontFamily: 'Sen',
                                            fontSize: 12,
                                            color: AppColour.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Interactive Details Chips
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      buildDetailChip(
                                        icon: clock_svg,
                                        label: '20 mins',
                                        isIcon: true,
                                        color: AppColour.green.withOpacity(0.1),
                                      ),
                                      buildDetailChip(
                                        icon: delivery_svg,
                                        label: 'Free Delivery',
                                        isIcon: true,
                                        color: AppColour.primary.withOpacity(
                                          0.1,
                                        ),
                                      ),
                                      buildDetailChip(
                                        label:
                                            '${state.product!.quantity} ${state.product!.measurement}',
                                        isIcon: false,
                                        color: AppColour.lightGrey.withOpacity(
                                          0.1,
                                        ),
                                        icon: '',
                                      ),
                                      buildDetailChip(
                                        icon: '',
                                        label: 'Organic',
                                        isIcon: false,
                                        color: Colors.green.withOpacity(0.1),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Description Section
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Description',
                                        style: simple_text_style(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColour.black,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            state.product!.isAvailable &&
                                            !state.product!.isOutOfStock,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColour.primary
                                                .withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            border: Border.all(
                                              color: AppColour.primary
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: state.isInCart
                                              ? Text(
                                                  state.quantity.toString(),
                                                  style: simple_text_style(
                                                    fontSize: 18,
                                                    color: AppColour.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        context
                                                            .read<
                                                              ProductFunBloc
                                                            >()
                                                            .add(
                                                              DecreaseQuantity(),
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColour
                                                                  .black
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Icon(
                                                          Icons.remove,
                                                          color:
                                                              AppColour.primary,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      state.quantity.toString(),
                                                      style: simple_text_style(
                                                        fontSize: 18,
                                                        color: AppColour.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    GestureDetector(
                                                      onTap: () {
                                                        context
                                                            .read<
                                                              ProductFunBloc
                                                            >()
                                                            .add(
                                                              IncreaseQuantity(),
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColour
                                                                  .black
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          color:
                                                              AppColour.primary,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.product!.description,
                                    style: TextStyle(
                                      fontFamily: 'Sen',
                                      fontSize: 16,
                                      color: AppColour.lightGrey,
                                      height: 1.5,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Modern Bottom Action Bar
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColour.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColour.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: state.isCheckingIsInCart
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColour.primary,
                                ),
                              ),
                            )
                          : (!state.product!.isOutOfStock &&
                                state.product!.isAvailable)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Enhanced Price Display
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Price', style: simple_text_style()),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${totalPrice.toStringAsFixed(0)}',
                                          style: simple_text_style(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColour.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '₹${mrpTotal.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontFamily: 'Sen',
                                            fontSize: 18,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationThickness: 2,
                                            color: AppColour.lightGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColour.green.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${calculatePercentage(mrpTotal, totalPrice).toStringAsFixed(0)}% OFF',
                                            style: TextStyle(
                                              fontFamily: 'Sen',
                                              fontSize: 12,
                                              color: AppColour.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Enhanced Add to Cart Button & Inc or Dec
                                state.isAddingToCart
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 120,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColour.primary,
                                            foregroundColor: AppColour.white,
                                            elevation: 8,
                                            shadowColor: AppColour.primary
                                                .withOpacity(0.3),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: state.isInCart
                                              ? () {
                                                  PersistentNavBarNavigator.pushNewScreen(
                                                    context,
                                                    screen: CartScreen(),
                                                    withNavBar: false,
                                                    pageTransitionAnimation:
                                                        PageTransitionAnimation
                                                            .cupertino,
                                                  );
                                                }
                                              : () {
                                                  context
                                                      .read<ProductFunBloc>()
                                                      .add(
                                                        AddToCartPressed(
                                                          productId:
                                                              product.pid,
                                                        ),
                                                      );
                                                  context
                                                      .read<ProductFunBloc>()
                                                      .add(
                                                        CheckIsInCart(
                                                          productId:
                                                              product.pid,
                                                        ),
                                                      );
                                                },
                                          child: Text(
                                            state.isInCart
                                                ? "View Cart"
                                                : "Add to Cart",
                                            style: simple_text_style(
                                              color: AppColour.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            )
                          : Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 48,
                                    color: AppColour.lightGrey,
                                  ),

                                  Text(
                                    'Out of Stock',
                                    style: simple_text_style(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColour.lightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
