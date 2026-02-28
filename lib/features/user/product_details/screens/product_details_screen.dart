import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/data/services/cart_service.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/models/model/product.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// UI Components
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/helper_functions.dart'; // Ensure calculatePercentage is here
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart'; // For SVGs like clock_svg
import 'package:raising_india/features/user/product_details/widgets/build_detail_chip.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();

  // Local state for quantity selector (before adding to cart)
  int _currentQuantity = 1;

  @override
  Widget build(BuildContext context) {
    // Determine MRP & Price safely
    final double price = widget.product.price ?? 0;
    final double mrp = widget.product.mrp ?? (price + 5);
    final bool isOutOfStock = (widget.product.stockQuantity ?? 0) <= 0;
    final bool isAvailable = widget.product.available ?? true; // Assuming this flag exists or default true

    return Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- IMAGE SLIDER ---
                        _buildImageSlider(),
                        const SizedBox(height: 20),

                        // --- PRODUCT NAME ---
                        Text(
                          widget.product.name ?? "Unknown Product",
                          style: simple_text_style(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColour.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- RATING ROW ---
                        _buildRatingRow(),
                        const SizedBox(height: 20),

                        // --- DETAILS CHIPS ---
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            buildDetailChip(
                              icon: clock_svg, // Ensure this path exists
                              label: '20 mins',
                              isIcon: true,
                              color: AppColour.green.withOpacity(0.1),
                            ),
                            buildDetailChip(
                              icon: delivery_svg, // Ensure this path exists
                              label: 'Free Delivery',
                              isIcon: true,
                              color: AppColour.primary.withOpacity(0.1),
                            ),
                            if (widget.product.quantity != null) // e.g. "500g" or "1kg"
                              buildDetailChip(
                                label: '${widget.product.quantity} ${widget.product.measurement ?? ""}',
                                isIcon: false,
                                color: AppColour.lightGrey.withOpacity(0.1),
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

                        // --- DESCRIPTION HEADER & QUANTITY SELECTOR ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Description',
                              style: simple_text_style(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColour.black,
                              ),
                            ),
                            // Only show quantity controls if NOT out of stock
                            if (!isOutOfStock && isAvailable)
                              _buildQuantityControl(),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // --- DESCRIPTION TEXT ---
                        Text(
                          widget.product.description ?? "No description available.",
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

          // --- BOTTOM ACTION BAR ---
          _buildBottomBar(price, mrp, isOutOfStock, isAvailable),
        ],
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildImageSlider() {
    final images = widget.product.photosList ?? [];

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColour.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return _buildPlaceholderImage();
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  progressIndicatorBuilder: (context, child, progress) {
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                        color: AppColour.primary,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorWidget: (context, error, stackTrace) => _buildPlaceholderImage(),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: images.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColour.primary,
                    dotColor: Colors.white.withOpacity(0.5),
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColour.lightGrey.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 60,
          color: AppColour.lightGrey,
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    // Assuming product.rating is available, defaulting to 4.5 if null
    final double rating = widget.product.rating ?? 0.0;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              color: AppColour.primary,
              size: 20,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '(${rating.toStringAsFixed(1)})',
          style: TextStyle(
            fontFamily: 'Sen',
            fontSize: 14,
            color: AppColour.lightGrey,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '10 Reviews', // You can fetch real reviews count if available
            style: TextStyle(
              fontFamily: 'Sen',
              fontSize: 12,
              color: AppColour.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl() {
    // We check if item is in cart to show correct quantity
    return Consumer<CartService>(
      builder: (context, cartService, _) {
        // Find if this product is already in the cart
        final cartItemIndex = cartService.cartItems.indexWhere((item) => item.product?.pid == widget.product.pid);
        final bool isInCart = cartItemIndex != -1;

        // Use cart quantity if present, otherwise local _currentQuantity
        final int displayQty = isInCart
            ? (cartService.cartItems[cartItemIndex].quantity ?? 1)
            : _currentQuantity;

        // If NOT in cart, we manipulate local state. If IN cart, we call API.
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColour.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease Button
              GestureDetector(
                onTap: () {
                  if (isInCart) {
                    if (displayQty > 1) {
                      cartService.updateQuantity(widget.product.pid!, displayQty - 1);
                    } else {
                      cartService.removeFromCart(widget.product.pid!);
                    }
                  } else {
                    if (_currentQuantity > 1) {
                      setState(() => _currentQuantity--);
                    }
                  }
                },
                child: _qtyIcon(Icons.remove),
              ),
              const SizedBox(width: 12),
              Text(
                displayQty.toString(),
                style: simple_text_style(
                  fontSize: 18,
                  color: AppColour.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              // Increase Button
              GestureDetector(
                onTap: () {
                  if (isInCart) {
                    cartService.updateQuantity(widget.product.pid!, displayQty + 1);
                  } else {
                    setState(() => _currentQuantity++);
                  }
                },
                child: _qtyIcon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColour.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: AppColour.primary, size: 18),
    );
  }

  Widget _buildBottomBar(double price, double mrp, bool isOutOfStock, bool isAvailable) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: (isOutOfStock || !isAvailable)
          ? Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: AppColour.lightGrey),
            const SizedBox(width: 10),
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
      )
          : Consumer<CartService>(
        builder: (context, cartService, _) {
          final isInCart = cartService.cartItems.any((item) => item.product?.pid == widget.product.pid);

          // Calculate Total Price based on quantity
          final int qty = isInCart
              ? (cartService.cartItems.firstWhere((item) => item.product?.pid == widget.product.pid).quantity ?? 1)
              : _currentQuantity;

          final double finalTotal = price * qty;
          final double finalMrpTotal = mrp * qty;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price', style: simple_text_style()),
                  Row(
                    children: [
                      Text(
                        '₹${finalTotal.toStringAsFixed(0)}',
                        style: simple_text_style(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColour.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${finalMrpTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          color: AppColour.lightGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColour.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${calculatePercentage(mrp, price).toStringAsFixed(0)}% OFF',
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

              // Add Button / View Cart
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColour.primary,
                    foregroundColor: AppColour.white,
                    elevation: 8,
                    shadowColor: AppColour.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (isInCart) {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const CartScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    } else {
                      // Add to cart with locally selected quantity
                      cartService.addToCart(widget.product.pid!, _currentQuantity);
                    }
                  },
                  child: cartService.isLoading
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                      : Text(
                    isInCart ? "View Cart" : "Add to Cart",
                    style: simple_text_style(
                      color: AppColour.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}